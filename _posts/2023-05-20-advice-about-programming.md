---
layout: post
title: "On Learning To Program"
date: 2023-5-20 02:22:22 -0400
categories: advice
tags: advice
usemathjax: true
---

*[Epistemic Status: Not that confident. I'll footnote stuff I'm even less confident[^1] on or more confident[^2] on. I'm only writing this ~3.5 years after starting to program seriously. The advice is generally aimed at someone in middle or high school. Also, everyone learns at a different rate. Please keep in mind the [law of equal and opposite advice](https://slatestarcodex.com/2014/03/24/should-you-reverse-any-advice-you-hear/).]*


A few people have approached me to ask how to get better at programming computers, so I thought I would write something that could help the most people -- a blog post.

I'll start with the journey that I took, and then give some distilled advice.
## My Journey

By the time I started coding seriously in eighth grade, I had always been familiar with code. I had done some coding camps where I copied boilerplate Java and Swift code and then changed it a bit. I knew what an if statement was, what a loop was, etc... But I never coded much at home. I hadn't grasped the essence of what it means to program a computer. When I tried, I would get stuck on something and then give up on coding. I'll assume you're starting close to here. If you are more advanced than I was when I started -- awesome!


In eighth grade, we had tech class where the project was to create a game in Scratch. Scratch is a really good program, and if you are using it, that's great! However, I tried to code my game in Scratch, but got really frustrated with how limiting the blocks were. I thought that if I used something else to code it, it would be easier. Starting a pattern where I say "how hard could it be," (and then it turns out to be hard) I started using my Mom's old Thinkpad x220 to code in [pygame](https://www.pygame.org/news). This undoubtedly took much more time than just doing the equivalent in scratch, but I learned python, so that's a plus. (If you want to see the (really bad) code, [here](https://github.com/g-w1/JacobsGameForTech/blob/master/jacobs_game_source.py) it is.)

I also was simultaneously learning calculus just for fun[^3]. I have some really cringey memories of doing Khan Academy during art class free draw. Thankfully, my art teacher was chill and didn't mind. This allowed me to kind of understand how neural networks worked (not that well, but the important thing was that I **felt** that I understood how neural networks worked and I **believed** that it wasn't hard to learn.) I had lots of fun watching 3Blue1Brown's series on [neural networks](https://www.3blue1brown.com/topics/neural-networks) and reading an [excellent book on the topic](http://neuralnetworksanddeeplearning.com/). So I said "how hard could it be" again and tried to implement my own neural network (by liberally copying from the book) that could kind of guess if you drew a smiley or frowney face. I then implemented the neural network in JavaScript, [put it on the web](https://g-w1.github.io/first-ML/), called it a science fair project.

In February 2020, I applied to the [Recurse Center](https://recurse.com), "The retreat where curious programmers recharge and grow," and got in! I spent a week there and met some amazing people who helped me learn to program. I learned about functional programming and big O notation.

A month later, the pandemic (Covid-19) hit. School went from taking up most of my time to basically non-existent. I had so much more time to spend programming. I installed Linux on an old laptop laying around. I programmed a simple video editor, made [another platformer game](https://github.com/g-w1/rust_game) in the Rust Programming Language, [some web scrapers](https://github.com/g-w1/toys), failed on a bunch of projects (self-driving car simulator, text editor, ..., autoencoder for smiley faces), started watching Luke Smith on YouTube (I don't particularly recommend this). I learned $$ \LaTeX $$ (a scientific typesetting program) and way over-engineered my *To Kill A Mockingbird* final essay -- that never got graded -- with $$ \LaTeX $$. I just had a glut of time and soaked up knowledge. I probably didn't learn nearly as efficiently as I could have, but I still learned.

I've also made some web-apps that utterly failed. One was an outright copy of another web-app. Another one was a to-do app with a novel feature -- it scheduled your time for you. Both got no users (I didn't even use them) and I gave up on them. But both of these gave me really valuable web development knowledge, so I don't regret making them at all.

At the end of the summer of 2020, I was on vacation in Maine with my family. I brought my kindle with me and used its web browser to read programming blogs. Then, I suddenly had an urge to learn about compilers (the program that turns human code into something that a machine can understand). I downloaded compiler books onto my kindle from my Mom's computer, and started to read as much as I could. I got really excited and called up my High School's computer science teacher to ask him if I could do an independent study with him about writing a compiler when I entered high school in a month, and he said yes. I made my own programming language called [ez](https://github.com/g-w1/ezc). Ez was my biggest project so far and I learned so much writing a compiler! (I later independent-studied AP Computer Science A with the same teacher in freshman year. If you want to do it, and already know how to code, it's pretty easy. I recommend just buying a Barron's review book, reading it, and doing all the practice tests.)

To learn how to write ez, I read the source code of the [Zig compiler](https://github.com/ziglang/zig) and then got involved in the development of Zig's compiler. I learned so much contributing to a real-world, big, open-source project. Contributing to Zig took up a substantial amount of my time in the 2020-2021 school year. Getting involved in the open-source community was one of the best things I could have done. I chatted with real adults on IRC who didn't know my age and took me seriously as another adult. I matured both in personality and in technical knowledge. I understand the fear that there are dangerous strangers on the internet, but in my opinion, as long as you know what to look out for, talking with people on the internet is a really good way to learn programming. People will take you more seriously if you show them that you have something to contribute to their project, so try to fix some bugs.

I then got really interested in the Plan9 operating system and installed it on an old Thinkpad that I had lying around my house. I had the amazing idea to try combine my interests and get Zig running on Plan9. I had to reverse engineer Plan9's binary format and write an extension to the Zig compiler that allowed it to output Plan9 binaries. I did this (it's still not fully complete -- I plan to finish it this summer) and then gave a [talk about it](https://www.youtube.com/watch?v=Z6c1JUBciIA).

Since then, I have been doing [physics-informed neural networks research](https://lu.seas.upenn.edu/people/), learning about [spaced repetition memory systems](http://augmentingcognition.com/ltm.html), and learning about [rationality](https://lesswrong.com).

## Advice

**PROGRAM A LOT -- This is the only way to get better.[^2]**

This advice has worked for me, and I'm not sure how well it will work for others. Feel free to pick and choose what you take.
* If you don't know what to program, you can find bugs in your workflow or things that take you time. Some things I've done. If you spend a lot of time making video montages that could be automated by just fading some images together with music -- use moviepy and implement a program to do it for you. You want to be able to read code on your kindle -- write a [program that takes a codebase and turns it into a pdf file](https://github.com/g-w1/pdfcr). You spend time on the computer past your bedtime -- make a [program that shuts your computer off after a certain time](https://github.com/g-w1/ulysses). What you make isn't important, but the process of making it is.
* Use stackoverflow. If you have any errors, just look them up on google.[^2] Learning how to look things up is a really good skill to have as a developing programmer. Once you get really deep into a project and understand it fully, you eventually won't have to look things up.
* Use ChatGPT. Even today, I use it to help me write code and use APIs. I think that just blindly copy and pasting code from it is not that good of an idea though. Make sure you understand what you are doing. There is a fine balance to be struck, and it might not be that good to use it when you are initially learning to code.[^1]
* Learn vim.[^1]
* Learn to use the command line. If you have a spare old laptop lying around, install Linux on it and play around with it. Try to use it as your main machine. This will help you understand how computers actually work. If you have a Mac, use the command line. If you have Windows -- well, I don't know what to tell you.
* If you are stuck, print out your code on physical paper, read it, and try to spot the bug.
* Read [Hacker News](https://news.ycombinator.com)[^1] (don't worry; its not about hacking. It uses the traditional definition of hacking as in being curious and playing around with things). This one is probably controversial because it can be a source of addiction, but I think that in moderation, it can help you understand what "real" programmers think about on a day to day basis.
* If you are interested in Game Programming, which many early programmers are, I suggest that you should keep an open mind and don't only stick to Game Programming. It's very hard and unforgiving to create real, good games. You can get more satisfaction with other types of programming like low-level or web programming.
* Use IRC (or Discord) to talk with other developers and contribute to open-source projects. Try to contribute to beginning projects that need help rather than mature ones. Try to find ones with experienced developers that can help you develop your skills.
* Lean into the deep end! **Make "how hard can it be" your mantra** and don't let anyone else tell you something is too hard. Always be pushing your comfort zone.[^2]


### If you have any questions about programming or want to talk to me, feel free to contact me at jacoblevgw at gmail dot com.

[^1]: Even less confident.
[^2]: More confident.
[^3]: If you want to learn calculus, which I *highly recommend* (high school calculus becomes really easy, you can learn neural networks, and its really fun), first use 3Blue1Brown's *excellent* [calculus playlist](https://www.youtube.com/watch?v=WUvTyaaNkzM&list=PL0-GT3co4r2wlh6UHTUeQsrf3mlS2lk6x) and then do Khan Academy for practice. As long as you are motivated, I'd say only algebra is the prerequisite. [There is no speed limit](https://sive.rs/kimo).
