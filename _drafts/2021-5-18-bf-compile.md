---
layout: post
title: "Writing A Brain**** Compiler (part 2)"
date: 2021-5-20 08:47:21 -0400
categories: zig low-level compiler
---

# My Question Was Answered
In the [previous post](https://g-w1.github.io/blog/zig/low-level/2021/03/15/elf-linux.html) I asked a question, and got an answer! My question was: "From what i've seen, linux executables are loaded into memory at 0x400000 (if someone knows why this is, please tell me!)" 


Rafael Ávila de Espíndola kindly replied with this answer:

> The value is arbitrary, and not directly imposed by linux. In fact, it is the executable that sets it. In your asm file you have
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
[https://github.com/llvm/llvm-project/commit/c9de3b4d267bf6c7bd2734a1382a65a8812b07d9](https://github.com/llvm/llvm-project/commit/c9de3b4d267bf6c7bd2734a1382a65a8812b07d9)
So the reason for the 0x400000 (4MiB) is that that is the size of
superpages in some x86 modes.
It looks like the gnu linker used that for x86-64 too, but that is
probably an oversight. LLD uses 2MiB since that is the large page size in
that architecture. It was set in
[https://github.com/llvm/llvm-project/commit/8fd0196c6fd1bb3fed20418ba319677b66645d9c](https://github.com/llvm/llvm-project/commit/8fd0196c6fd1bb3fed20418ba319677b66645d9c)
Welcome to the world of linkers :-)
Cheers,
Rafael

I am grateful that someone went out of their way to help me.


The Zig self-hosted linker has this code:
```zig
const default_entry_addr = 0x8000000;
```
andrewrk (zig author) said the reason for putting it at 8mb:

> note that is virtual address space; it does not actually take up 8 MiB of space
1. (not important) there is a tradition of making that the entry point (citation needed)
2. it works for both 32 and 64 bit address space
3. it leaves plenty room for stuff to go before it, such as unmapped pages, to cause segfaults for null pointer and e.g. field access of null pointers
   - also stuff like the Global Offset Table

Lesson learned: one small mistake (or even change that is not ideal) can propogate through a whole industry. I was pretty interested by this :)
It is also pretty interesting that 3 different backends use 3 different values.

# Brainfuck Compiler

In the previous post, I said that the next post would be about me writing a brainfuck compiler. In case you do not know, brainfuck is an esoteric programming language created in the 90's. It has 8 instructions:

``` 
>	increment the data pointer (to point to the next cell to the right).
<	decrement the data pointer (to point to the next cell to the left).
+	increment (increase by one) the byte at the data pointer.
-	decrement (decrease by one) the byte at the data pointer.
.	output the byte at the data pointer.
,	accept one byte of input, storing its value in the byte at the data pointer.
[	if the byte at the data pointer is zero, then instead of moving the instruction pointer forward to the next command, jump it forward to the command after the matching ] command.
]	if the byte at the data pointer is nonzero, then instead of moving the instruction pointer forward to the next command, jump it back to the command after the matching [ command.
```


You can think of it as a mini turing machine. Since it is such a simple language, it seemed like an ideal first language to implement. I implemented it from the input source code to outputting a full ELF file. I have written a compiler before, but it just emitted textual assembly and I used nasm/ld to turn it into ELF. This post will go over how I wrote it. I recommend you also read the previous post as it shows the setup for ELF part so that in this part, we can just get to emitting code.
The first thing I did was setup a `Code.zig`. In Zig, files with capital letters mean that they are structs (all files are) with fields. In this case, the only field is a 
```zig
output: []const u8,
```

field, but I left it like this so in the future I could add more fields, for storing different info about the generated code. I used the `r10` as the sort of "array pointer" for the code, the thing that > and < increment and decrement. I could have used an address in data, but decided just using a register was easier. The main loop for generating the code is small enough that I can paste it here:
> 🤦 moment: so I was reading the wikipedia page to write this article and realized that I read the brainfuck spec wrong. :^( I was jumping backwards instead of forwards (or maybe in even weirder ways), so most programs worked, but some didn't. This is how I am bad at reading stuff.


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
`read(` looks like this:
```zig
fn read(c: *std.ArrayList(u8)) !void {
    // mov rax, 0
    try c.appendSlice(&.{
        0xb8,
        0x00,
        0x00,
        0x00,
        0x00,
    });
    // mov rdi, 1
    try c.appendSlice(&.{
        0xbf,
        0x01,
        0x00,
        0x00,
        0x00,
    });
    // mov rdx, 1
    try c.appendSlice(&.{
        0xba,
        0x01,
        0x00,
        0x00,
        0x00,
    });
    // mov rsi, r10
    try c.appendSlice(&.{
        0x4c,
        0x89,
        0xd6,
    });
    try syscall(c);
}
```
and `syscall(` looks like this
```zig
fn syscall(c: *std.ArrayList(u8)) !void {
    try c.appendSlice(&.{
        0x0f, 0x05,
    });
}
```
Hopefully this gives you a sense of how it all fits together. Its just machine code all the way down!
The way I got the x64 opcodes was just writing then in nasm, then assembling the assembly file, then using objdump to see the opcodes. I still don't fully understand the instruction encoding (I see myself learning this in the future if I want to do more compiler stuff), so this seemed like the easiest way.
I used the `r10` x64 register as the pointer to the current cell. 
Some pain points I ran into:

* Offset math is hard! I spent a lot of time trying to do the offset math for the conditional loops. At first, my understanding of brainfuck was wrong, so that went wrong. Then I had to learn about different sizes of backwards jumps in x86 and how to represent negative numbers in binary. `objdump` helped me a lot in seeing what was wrong, I couldn't have done this without it!

* Relocation stuff. From my understanding, a relocation is a place in a binary that you need to change based on information that you get in the future.
Here is the code for making and "doing" the relocations:
```zig
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
```
I would probably use more complicated data structures if I needed to do more complicated relocation stuff, but for now a stack (`std.ArrayList(u64)`) works fine. Basically, I just append 4 bytes of zero to the place in the elf binary where it shows where to jump to. With `std.mem.copy(u8, code.items[popped + 6 ..], &cast(@intCast(u32, code.items.len - popped - 10 - 1)));` I "do" the relocation. For the "cast" function, see the [previous post](https://g-w1.github.io/blog/zig/low-level/2021/03/15/elf-linux.html). This was probably the hardest part, getting the offset math right, but I did it! I used `NOP`s (aka 0x90) for the locations to jump to, just for simplicity.

* I thought I could just use `inc r10` to move the pointer to the next cell, but this is not the case. Let's take a look at why:
Using [this program](https://esolangs.org/wiki/Brainfuck#Cell_Size) for calculating the size of a brainfuck cell, we get:
`32 bit cells`. It basically checks when it overflows I think. Due to the way pointers on x64 work, `inc` only increments it by one, so `r10` is pointing to the space in between a few cells. You actually need to do `add r10, 8` in order to make it work.
See this diagram (the carets are where r10 points):
```
[        ][        ][        ][        ]
 ^^^^^^^^
> inc r10
[        ][        ][        ][        ]
    ^^^^^^^^
```
This is what happens when we just do `inc r10`, but if we `add r10, 8` then the diagram will look like this:
```
[        ][        ][        ][        ]
 ^^^^^^^^
> add r10, 8
[        ][        ][        ][        ]
             ^^^^^^^^
```

We get the nice offset instead of a really weird one. (This also took me a while to debug)

# Running some code!

Before we talk about the "bugs" in `bz` (the name I chose for it. I know, soooo creative :P.) lets talk about the features:
Here is a sample `bz` session.
```
% rm hello
removed 'hello'
% zig build
% cat hello.bf
++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.
% ./zig-out/bin/bz hello.bf -o hello
% file hello
hello: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, stripped
% ./hello
Hello World!
%
```
I took the hello world brainfuck program from the wikipedia article, and it works!
Lets try something a little more complicated, fibonacci:
```
% cat fib.bf
>++++++++++>+>+[
    [+++++[>++++++++<-]>.<++++++[>--------<-]+<<<]>.>>[
        [-]<[>+<-]>>[<<+>+>-]<[>+<-[>+<-[>+<-[>+<-[>+<-[>+<-
            [>+<-[>+<-[>+<-[>[-]>+>+<<<-[>+<-]]]]]]]]]]]+>>>
    ]<<<
]
This program doesn't terminate; you will have to kill it.
Daniel B Cristofani (cristofdathevanetdotcom)
http://www.hevanet.com/cristofd/brainfuck/
% ./zig-out/bin/bz fib.bf -o fib
% ./fib
0
1
1
2
3
5
8
13
21
34
55
89
1E01)844
2W02#633
4b045u77
7072YK10
1F]212�87
2=s0�01<97
4J3Y3370�4
7N�
   542"B81
12_+8*88�5
20t343��46
^C
%
```
as you can see, for the first few fibonacci numbers it works! Then it slowly goes haywire. I think the program actually calculates the right numbers as 1E01)844 looks like 144 and 2W02#633 looks like 233. I think I just have some weird miscompilation that I can't identify for printing the numbers. I am sad. But, this is good enough for now. I officially declare this project "done" for now. You can see the code for this commit [here](https://github.com/g-w1/zelf/commit/62c3bac27ad1b2e195626847f3b50181cf61357a).

Sources:
https://en.wikipedia.org/wiki/Brainfuck#Commands 
https://esolangs.org/wiki/Brainfuck
