---
layout: post
title: "Writing A Compiler"
date: TODO
date:   2020-10-04 08:38:21 -0400
categories: code
---

At the start of the 2020 I wanted to learn more about compilers so I started writing a compiler. I did this as an independent study for school. I wanted to grow _dramatically_ as a thinker and learn a lot about computer science and compilers in specific.

# Why I Chose Rust

I chose Rust for this because I wanted to learn it and it is just a very cool language. Some language features that make it very easy to write a compiler in are:

**Enums (algebraic data types)**

Algebraic data types are most present in functional languages (haskell, ocaml, etc).

These allow for efficient representation of tokens and nodes of an abstract syntax tree in memory. I think in a c world one could think of them as tagged unions. For example my Expression type is defined as this

```rust
pub enum Expr {
    /// a number
    Number(String),
    /// an iden
    Iden(String),
    /// a binop
    BinOp {
        lhs: Box<Expr>,
        op: BinOp,
        rhs: Box<Expr>,
    },
}
```

This means an expression is either a number, an identifier (variable name), or a combination of 2 expressions with a Binary operator in between. It is defined as Box<Expr> because recursive data types are not allowed, so it has to be a pointer (a box is basically a pointer to the heap)

**Pattern Matching**

Along with algebraic data types, pattern matching comes. It is used to destructure an enum into the parts that it is made up of. It is best explained with an example

```rust
match e { // e is the expression we are matching against
  Expr::Number(n) => println!("It is a number: {}", n),
  Expr::Iden(i) => println!("It is an identifier: {}",i),
  // This will capture everything and put it in a fallback. We know is has to be a BinOp Expr because that is all that is left
  recurse => println!("Uh-oh we do not know how to do revursive expressions yet: {:?}", recurse),
}
```

As you can imagine, Rust enums are **soooooooooooooo** cool. Most of the major types in my compiler are enums compared to structs although I have more structs than enums. I can't imagine doing this in a language like c where I would have to use many layers of tagged unions and structs to achieve the same.

Enums and Pattern Matching were the main reasons I chose Rust over something like Python. Another reason is probably the strong typing. It makes it soo much easier to debug your program when you know exactly what each function will return. The last reason I chose Rust over a language like c++ is because of the safety guarantees. It makes your life easier when you can debug why the assembly code your compiler is generating is segfaulting rather than why the compiler is segfaulting :).
