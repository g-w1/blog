---
layout: post
title: "Noticing confusion in physics"
date: 2023-10-12 9:49:00 -0400
categories: observation
tags: physics
usemathjax: true
---

I recently had a Physics test, and the only thing I got wrong was the answer to this question: "What happens to the speed of sound in a gas when the gas is heated up?"

My answer was "The speed of sound decreases because heating up a gas decreases its density. Lower density means lower speed of sound because the particles have to travel further to bump into other particles." I got 1/2 points on this question because although I got the incorrect answer, my justification was "correct". 

When I got the test back and saw what I got wrong and how I had gotten it wrong, I realized that my mental process went wrong. I was *equally able to explain the truth as the opposite of the truth*, and this is bad. I want to find the truth.

The reason that my teacher gave was that if a gas was hotter, the molecules moved faster, and thus bumped into each other faster and the speed of sound was faster.

This explanation is not that convincing to me, so I'm going to do an analysis of what went wrong in my thought process and how I can prevent it in the future.

1. My mind immediatly jumped to the density explanation without considering how the opposite could be correct.
2. My first thought now is to see how much molecular speed vs density would change with an increase of speed. Since $$ T = \frac{\sum \frac{1}{2} m v^2}{N} $$, it would follow that if you double $$ T $$ you increase $$ v $$ by $$ \sqrt{2} $$. But if you double $$ T $$, density should halve. This still leaves me confused.
3. At this point, I'm thinking that a decrease in density does not decrease the speed of sound in gases, only in liquids and solids. I searched the answer up and found [this explanation](https://physics.stackexchange.com/questions/177997/how-can-the-speed-of-sound-increase-with-an-increase-in-temperature). This says that $$ v \propto \sqrt{T} $$ *only*. I kept searching and found [this question](https://physics.stackexchange.com/questions/555687/why-does-the-speed-of-sound-decrease-with-increase-in-density), which cleared it up even more for me.
4. Here is my synthesis of what happened: in solids and liquids, density *does* affect the speed of sound, but in gases, a third factor is pressure. If you increase the temperature, density can decrease, but pressure also increases by a portional amount since the molecules are hitting harder. These two changes cancel out. Thus, in a gas $$ v \propto \sqrt{T} $$ only.

So it seems the main thing that I missed was the extra factor of pressure, in addition to density. In the future, I should try to include *all* of the factors in a problem and give equal weight to the true or false answers. I'll admit thought that this might be hard to prevent in the general case since it didn't seem to be a meta-level confusion – just an object level one.

--- 

If you have a better explanation for this, please feel free to email me at jacoblevgw at gmail dot com and I'll put it here.