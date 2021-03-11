---
layout: post
title: "Learning About ELF With Zig"
date: 2021-3-08 08:47:21 -0400
categories: zig low-level
---

ELF is an object format that is used widely in Linux and other modern operating systems. I wanted to learn about it to become more fluent in low-level code as well as start contributing to the zig self-hosted elf linker backend.

This post will go through how I learned about the ELF format and applied it to create a minimal linker. I could then use this linker to link some x86_64 brainfuck code. This post will also go over how linked and created the brainfuck code since it mixes with the linker a little.

# Setting Things Up

The ELF file format is a binary file format, meaning that humans can not read it without special tools. Here are some of the tools I used that helped me a lot:

* hexl-mode - an emacs mode to read binary files by converting them to human-readable hex
* xxd - I used xxd to write a [script](https://github.com/g-w1/bz/tree/TODO) that can give a human readable diff of binary files.
* readelf - this was very helpful for making sure my elf was conforming to the elf spec/seeing what the operating system thought of my ELF file.
* objdump - this was useful for making sure my sections/section header table matched the spec (NOTE: llvm-objdump was much more helpful here as it was better at detecting errors/showing them TODO pic/text)

# Starting to generate code

```nasm
; nasm -f bin -o minimal this.asm
BITS 64
  org 0x400000

ehdr:           ; Elf64_Ehdr
  db 0x7f, "ELF", 2, 1, 1, 0 ; e_ident
  times 8 db 0
  dw  2         ; e_type
  dw  0x3e      ; e_machine
  dd  1         ; e_version
  dq  _start    ; e_entry
  dq  phdr - $$ ; e_phoff
  dq  0         ; e_shoff
  dd  0         ; e_flags
  dw  ehdrsize  ; e_ehsize
  dw  phdrsize  ; e_phentsize
  dw  1         ; e_phnum
  dw  0         ; e_shentsize
  dw  0         ; e_shnum
  dw  0         ; e_shstrndx
  ehdrsize  equ  $ - ehdr

phdr:           ; Elf64_Phdr
  dd  1         ; p_type
  dd  5         ; p_flags
  dq  0         ; p_offset
  dq  $$        ; p_vaddr
  dq  $$        ; p_paddr
  dq  filesize  ; p_filesz
  dq  filesize  ; p_memsz
  dq  0x1000    ; p_align
  phdrsize  equ  $ - phdr

_start:
  mov rax, 231 ; sys_exit_group
  mov rdi, [ecode]  ; int status
  syscall
ecode:
  db 42

filesize equ  $ - $$
```
This is one of the simplest elf files online - it really helped me have a good mental model of the elf file format. Above, `ehdr` stands for the ELF header and `phdr` stands for the program header, basically what tells the OS how to load the segment in to memory.

We can represent these as structs in zig: 

```zig
const ElfHeader = struct {
    /// e_ident
    magic: [4]u8 = "\x7fELF".*,
    /// 32 bit (1) or 64 (2)
    class: u8 = 2,
    /// endianness little (1) or big (2)
    endianness: u8 = 1,
    /// elf version
    version: u8 = 1,
    /// osabi: we want systemv which is 0
    abi: u8 = 0,
    /// abiversion: 0
    abi_version: u8 = 0,
    /// paddding
    padding: [7]u8 = [_]u8{0} ** 7,

    /// object type
    e_type: [2]u8 = cast(@as(u16, 2)),

    /// arch
    e_machine: [2]u8 = cast(@as(u16, 0x3e)),

    /// version
    e_version: [4]u8 = cast(@as(u32, 1)),

    /// entry point
    e_entry: [8]u8,

    /// start of program header
    /// It usually follows the file header immediately,
    /// making the offset 0x34 or 0x40
    /// for 32- and 64-bit ELF executables, respectively.
    e_phoff: [8]u8 = cast(@as(u64, 0x40)),

    /// e_shoff
    /// start of section header table
    e_shoff: [8]u8,

    /// ???
    e_flags: [4]u8 = .{0} ** 4,

    /// Contains the size of this header,
    /// normally 64 Bytes for 64-bit and 52 Bytes for 32-bit format.
    e_ehsize: [2]u8 = cast(@as(u16, 0x40)),

    /// size of program header
    e_phentsize: [2]u8 = cast(@as(u16, 56)),

    /// number of entries in program header table
    e_phnum: [2]u8 = cast(@as(u16, 1)),

    /// size of section header table entry
    e_shentsize: [2]u8 = cast(@as(u16, 0x40)),

    /// number of section header entries
    e_shnum: [2]u8,

    /// index of section header table entry that contains section names (.shstrtab)
    e_shstrndx: [2]u8,
};

const PF_X = 0x1;
const PF_W = 0x2;
const PF_R = 0x4;

const ProgHeader = struct {
    /// type of segment
    /// 1 for loadable
    p_type: [4]u8 = cast(@as(u32, 1)),

    /// segment dependent
    /// NO PROTECTION
    p_flags: [4]u8 = cast(@as(u32, PF_R | PF_W | PF_X)),

    /// offset of the segment in the file image
    p_offset: [8]u8,

    /// virtual addr of segment in memory. start of this segment
    p_vaddr: [8]u8 = cast(@as(u64, base_point)),

    /// same as vaddr except on physical systems
    p_paddr: [8]u8 = cast(@as(u64, base_point)),

    p_filesz: [8]u8,

    p_memsz: [8]u8,

    /// 0 and 1 specify no alignment.
    /// Otherwise should be a positive, integral power of 2,
    /// with p_vaddr equating p_offset modulus p_align.
    p_align: [8]u8 = cast(@as(u64, 0x100)),
};

```

Note that we can provide default values for struct values in Zig. This is helpful for constants in the ELF header. Don't mind the cast function yet, I will get to that soon. I made the default permissions for the program header read write execute for simplicity. In practice, you would use multiple program headers, some for executable code, some for mutable memory, and some for immutable memory.

## Writing To Files

Before we write to a file, we must write the headers to a buffer so that we can add the machine code after them.

In Zig, we can represent a code buffer as a `std.ArrayList(u8)`. Notice how Zig handles generics: a generic structure is just a function that takes a type and returns one:

```zig
pub fn Container(comptime inner: type) type {
    return struct {
       inside: type, 
    };
}
const instance = Container(u32) { .inside = 1234 };
const instance = Container([]const u8) { .inside = "Zig Generics Are Cool" };
```

Since types are first class values at compile-time in Zig, lets make a function that writes our header structs to out code (`std.ArrayList(u8)`).


```zig
fn writeTypeToCode(c: *std.ArrayList(u8), comptime T: type, s: T) !void {
    inline for (std.meta.fields(T)) |f| {
        switch (f.field_type) {
            u8 => try c.append(@field(s, f.name)),
            else => try c.appendSlice(&@field(s, f.name)),
        }
    }
}
```

A lot to unpack in this function, lets do it! It takes 3 things, the code buffer to write to, the type  of the thing to write, and something of that type. Lets see how we use it first.

```zig
// PROGRAM HEADERS
try writeTypeToCode(&dat, ProgHeader, .{
    .p_filesz = cast(filesize),
    .p_memsz = cast(filesize),
    .p_offset = .{0} ** 8,
});
```

This is how we use it, provide our code, the type of the struct and an instance of it. The function iterates over all the fields of the struct at comptime, switches on the type of that field, if it is just a primitive u8, it just writes that to the code buffer by using the `@field` builtin. That builtin allows you to set a field of a struct with a comptime known string (`[]const u8`). Now heres where it gets interesting, lets say we have a field like this: 
```zig
/// object type
e_type: [2]u8 = cast(@as(u16, 2)),
```
This is an array of 2 `u8`s. So this would use the else case in the switch as the type is `[2]u8`, not `u8`:
`else => try c.appendSlice(&@field(s, f.name)),` We can coerce any array in Zig (`[N]T`) to a slice (`[]T`) (slices are just a `struct { ptr: [*]T, len: usize }` behind the scenes) with the address-of operator `&`. We do this and then append that slice to the code buffer.

In my opinion, this is a pretty cool example of compile time meta-programming in Zig.

### Cast Function


We have seen the `cast` function in use, but I have not gone over what it does. This is another example of comptime meta-programming in zig. Here is the source:

```zig
pub fn cast(i: anytype) [@sizeOf(@TypeOf(i))]u8 {
    return @bitCast([@sizeOf(@TypeOf(i))]u8, i);
}
```

If I have a number that is a `u24` (yes, Zig has arbitrary integer types (up to a limit)), and run cast on it, I will get the bits of that number but as type `[3]u8`. What cast does is turn a numeric type into an array of `u8`'s. This makes it easier to deal with at the lower level since they are all the same.

`anytype` means that the function accepts, well any type for i. This is like a parameter in a dynamic language like python with no types by default. In the return type, we have a call to a builtin function, this *is* allowed in Zig, since, again, types are first class at compile time. We then bitcast the int into an array of its size in bytes of `u8`s.

This function helped me reduce a lot of repetitive code ex:
```zig
e_ehsize: [2]u8 = cast(@as(u16, 0x40)),
```
vs
```zig
e_ehsize: [2]u8 = @bitCast([2]u8, (@as(u16, 0x40))),
```
This could be determined by the size of the number as we already cast it to a u16, so no reason to specify the size again in a different format.

Okay, enough talking about Zig, back to ELF!
