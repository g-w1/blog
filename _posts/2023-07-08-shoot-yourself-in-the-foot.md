---
layout: post
title: "Why it's necessary to shoot yourself in the foot"
date: 2023-07-08 17:47:21 -0400
categories: observation
tags: observation personal
---

Without shooting yourself in the foot, learning lacks motivation. Complexity without reason is really confusing.

<hr>

At the Recurse Center Feb 2020: I watch a talk during presentations about someone optimizing a database engine. It was really complicated, and I remeber nothing about the talk itself. What I do remember is thinking to myself "this seems really complicated for no good reason." Keep in mind, I had never made a web application at that time and when I needed to store data, I just used a csv file or a python pickle file on the disk. I thought that a filesystem was sufficient for storing data.


Fast forward a few months and I'm building my first web application. I don't remember what it was for, but I remember using a csv file as the database. I had to load the file into memory every time I wanted to look something up and it was just a big pain. I now understood why using a database is (sometimes) a good idea.

<hr>

Learning Rust, July 2020: I start learning about the borrow checker. It prevents you from keeping a pointer to an item of a vector (`&vec[i]`) if you pass the `Vec<T>` as a `&mut`. I don't really get why this is necessary. I have never done low-level programming before, never used pointers, and now I am being told that following the borrow checker is 'safe'. It is still very confusing to me.

Fast forward to when I am writing Zig code. I take `&array_list.items[i]`, append to the `array_list` and then try to write to the stored pointer. I get a segfault. Ahh, now I get the problem Rust solves.

<hr>

Learning Vue, July 2020: Why are there all of these complicated ways to represent state? Shouldn't developing a web app be simpler than this?

After writing a bunch of vanilla JS, I can see why these frameworks could be useful. I have never made a very big web app, but I could see that keeping track of state and what is or isn't rendered is hard and gets much harder with a bigger web app.

<hr>

To fully understand a "best practice" or why something is necessary, it's important to experience how things go wrong without it. When teaching programming, we should let people make these mistakes, and *then* show them the tools to correct them. Just giving someone a complicated tool without a salient reason to explain its complexity will just make them really confused.

Some opinions:
* You should store stuff in csv files before using a database
* You should learn Zig (or C) before you learn Rust
* You should write a web app in vanilla JS before you learn a framework
* You should write a game from scratch before using Unity
* You should use `javac` from the command line before using an IDE

Have you had an experience like this?
Email me at jacoblevgw at gmail and I'll put it below.

Examples from readers:

> Arian Araf: You should learn Assembly before you learn optimization

> Almoctar Hassoumi: Use HTML before using a CMS like WordPress

See more on [HN](https://news.ycombinator.com/item?id=36688738)
