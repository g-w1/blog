---
layout: post
title: "An alternative intuition for attribution patching"
date: 2023-12-20 3:00:00 -400
categories: observation
tags: observation programming
usemathjax: true
---

When I saw the following equation in the [attribution patching paper](https://arxiv.org/pdf/2310.10348.pdf), I got really confused and spent a bunch of time thinking about it: 

$$ 
L(x_\text{clean} | \operatorname{do}{(E = e_\text{corr})}) \approx L(x_\text{clean}) + (e_\text{corr} - e_\text{clean})^\top \frac{\partial}{\partial e_\text{clean}} L(x_\text{clean}| \operatorname{do}{(E = e_\text{clean})})
$$

Eventually, I realized that my confusion boiled down to the fact that I didn't really have any experience with the multivariate Taylor series, but it is actually not necessary.

I present another simple way to derive the above formula without really doing the Taylor series (it is exactly equivalent though):

$$ \frac{\partial L}{\partial e_\text{clean}} \approx \frac{\Delta L}{\Delta e} = \frac{L_\text{corr} - L_\text{clean}}{e_\text{corr} - e_\text{clean}}.$$

Solving for $$ \Delta L $$, we get

$$ \Delta L = \frac{\partial L}{\partial e_\text{clean}} * (e_\text{corr} - e_\text{clean}) $$

by multiplying the $$ e_\text{corr} - e_\text{clean} $$ over.

This gives $$ \Delta L $$ with shape of the activations, with the biggest components  having the biggest sway in the circuit. To turn it back into a scalar for the metric, we can just reduce sum over it, or equivalently compute it using the dot product instead of elementwise product, which is what the paper did.

I hope that this post illuminated the method better, especially if you don't have a math background.
