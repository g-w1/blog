---
layout: post
title: "Writing A Compiler"
date: TODO
date:   2020-10-04 08:38:21 -0400
categories: code
---

At the start of the 2020 I wanted to learn more about compilers so I started writing a compiler. I did this as an independent study for school. I wanted to grow *dramatically* as a thinker and learn a lot about computer science and compilers in specific.

# Why I Chose Rust

I chose Rust for this because I wanted to learn it and it is just a very cool language. Some language features that make it very easy to write a compiler in are:

**Enums (algebraic data types)**

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
