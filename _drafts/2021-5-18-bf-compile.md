---
layout: post
title: "Learning About ELF With Zig"
date: 2021-3-15 08:47:21 -0400
categories: zig low-level compiler
---

Writing a Brainfuck Compiler

I got a response to a question in the previous post: why do the addresses have to start at 0x400000?

Rafael Ávila de Espíndola kindly replied with this answer:
“The value is arbitrary, and not directly imposed by linux. In fact, it
is the executable that sets it. In your asm file you have

```
org 0x400000
...
phdr:           ; Elf64_Phdr
  dd  1         ; p_type
  dd  5         ; p_flags
  dq  0         ; p_offset
  dq  $$        ; p_vaddr
```

So you are creating a `PT_LOAD (type 1)` with a `p_vaddr` a bit above
0x400000. This is what the kernel uses to decide where to put your
binary.

BTW, it is better if the value is page aligned. It looks like the linux
kernel aligns it for you, but it is a bit more clear if the value in the
file is already aligned.

As for why 0x400000 is common, that is quite a bit of archaeology. A good
place to look is the lld history, as we had to do a bit of archaeology
when creating it. LLD started by using the smallest value that would
work: the second page. The current value was changed in

https://github.com/llvm/llvm-project/commit/c9de3b4d267bf6c7bd2734a1382a65a8812b07d9 

So the reason for the 0x400000 (4MiB) is that that is the size of
superpages in some x86 modes.

It looks like the gnu linker used that for x86-64 too, but that is
probably an oversight. LLD uses 2MiB since that is the large page size in
that architecture. It was set in

https://github.com/llvm/llvm-project/commit/8fd0196c6fd1bb3fed20418ba319677b66645d9c 

Welcome to the world of linkers :-)

Cheers,
Rafael

So, I guess the Zig codebase that I used copied gnu and was slightly wrong. 2MB seems slightly more correct.

I am grateful that someone went out of their way to help me.

In the previous post, I said that the next post would be about me writing a brainfuck compiler. In case you do not know, brainfuck is an esoteric programming language created in the 90’s. It has 8 instructions: 
>	increment the data pointer (to point to the next cell to the right).
<	decrement the data pointer (to point to the next cell to the left).
+	increment (increase by one) the byte at the data pointer.
-	decrement (decrease by one) the byte at the data pointer.
.	output the byte at the data pointer.
,	accept one byte of input, storing its value in the byte at the data pointer.
[	if the byte at the data pointer is zero, then instead of moving the instruction pointer forward to the next command, jump it forward to the command after the matching ] command.
]	if the byte at the data pointer is nonzero, then instead of moving the instruction pointer forward to the next command, jump it back to the command after the matching [ command.

You can think of it as a mini Von Neuman machine. It is turing complete, and you can do basic input and output with it. Since it is such a simple language, it seemed like an ideal first language to implement. I implemented it from the input source code to outputting a full ELF file. I have written a compiler before, but it just emitted textual assembly and I used nasm/ld to turn it into ELF. This post will go over how I wrote it. I recommend you also read the previous post as it shows the setup for ELF part so that in this part, we can just get to emitting code.
The first thing I did was setup a `Code.zig`. In Zig, files with capital letters mean that they are structs (all files are) with fields. In this case, the only field is a 
```zig
output: []const u8,
```
field, but I left it like this so in the future I could add more fields, for storing different info about the generated code. I used the `r10` as the sort of “array pointer” for the code, the thing that > and < increment and decrement. I could have used an address in data, but decided just using a register was easier. The main loop for generating the code is small enough that I can paste it here:
> 🤦 moment: so I was reading the wikipedia page to write this article and realized that I read the brainfuck spec wrong. :^( I was jumping backwards instead of forwards (or maybe in even weirder ways), so most programs worked, but some didn’t. This is how I am bad at reading stuff.
```zig
/// generate the assembly from the brainfuck input
/// ASSUMTIONS:
/// at the start of the code running,
/// dat_idx is r10,
pub fn gen(gpa: *std.mem.Allocator, bfsrc: []const u8) !Code {
    var code = std.ArrayList(u8).init(gpa);
    errdefer code.deinit();

    var loop_stack = std.ArrayList(u64).init(gpa);
    defer loop_stack.deinit();

    for (bfsrc) |c, i| {
        switch (c) {
            // inc dword [dat_idx]
            '+' => try code.appendSlice(&.{ 0x41, 0xff, 0x02 }),
            // dec dword qword [dat_idx]
            '-' => try code.appendSlice(&.{ 0x41, 0xff, 0x0a }),
            // add r10, 8
            '>' => try code.appendSlice(&.{ 0x49, 0x83, 0xc2, 0x08 }),
            // sub r10, 8
            '<' => try code.appendSlice(&.{ 0x49, 0x83, 0xea, 0x08 }),
            // write(1, dat_idx, 1)
            '.' => try write(&code),
            // read(0, dat_idx, 1)
            ',' => try read(&code),
            // NOP
            '[' => {
                // jumped to by the closing bracket
                try code.append(0x90);
                try loop_stack.append(code.items.len);
                // cmp QWORD PTR [r10],0x0
                try code.appendSlice(&.{
                    0x41, 0x83, 0x3a, 0x00,
                });
                // je <location of [
                try code.appendSlice(&.{
                    0x0f,
                    0x84,
                });
                // filled in by the closing bracket
                try code.appendSlice(&cast(@as(u32, 0)));
            },
            ']' => {
                const popped = loop_stack.popOrNull() orelse {
                    std.log.emerg("found a ] without a matching [: at index {d}", .{i});
                    std.process.exit(1);
                };
                // jmp <location of [
                try code.appendSlice(&.{
                    0xe9,
                });
                // heavy-lifting all the jump calculations
                const diff = code.items.len - popped;
                try code.appendSlice(cast(-1 * @intCast(i64, diff + 5))[0..4]);

                try code.append(0x90);
                std.mem.copy(u8, code.items[popped + 6 ..], &cast(@intCast(u32, code.items.len - popped - 10 - 1)));
            },
            else => {},
        }
    }
    if (loop_stack.items.len != 0) {
        std.log.emerg("found a [ without a matching ]", .{});
    }
    try exit0(&code);

    return Code{ .output = code.toOwnedSlice() };
}
```
The way I got the x64 opcodes was just writing then in nasm, then assembling the assembly file, then using objdump to see the opcodes. I still don’t fully understand the instruction encoding, so this seemed like the easiest way. 
Some pain points I ran into:
* Offset math is hard! I spent a lot of time trying to do the offset math for the conditional loops. At first, my understanding of brainfuck was wrong, so that went wrong. Then I had to learn about different sizes of backwards jumps in x86 and how to represent negative numbers in binary. `objdump` helped me a lot in seeing what was wrong, I couldn’t have done this without it!
* Relocation stuff. From my understanding, a relocation is a place in a binary that you need to change based on information that you get in the future.
Sources:
https://en.wikipedia.org/wiki/Brainfuck#Commands 
https://webcache.googleusercontent.com/search?q=cache:B4H_lOMY1OcJ:https://esolangs.org/wiki/Brainfuck+&cd=1&hl=en&ct=clnk&gl=us 
