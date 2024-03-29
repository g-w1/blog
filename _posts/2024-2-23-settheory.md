---
layout: post
title: "In set theory, everything is a set"
date: 2024-02-23 07:19:00 -0500
categories: math
tags: math
usemathjax: true
---

In Unix, everything is a file; in set theory, everything is a set.

---

This abstraction is very cool and allows us to prove facts that would not be provable if we thought that sets could include stuff that were not sets and therefore could not be broken down further.

Here's a nice example:

I was asked to prove both of the following statements in *Naive Set Theory*

$$
X=\bigcup \mathcal{P}(X) ;
\\
X \subset \mathcal{P}\left (\bigcup X \right ).
$$

When I try to prove something, especially in set theory, I try to visualize it in my head to make an intuitive proof and then write the mathematical proof after. I was able to easily visualize the first statement. Since the power set is just all of the subsets of a set, surely unioning all of the subsets of a set would give the set itself. 

The second one was much more confusing and I couldn't visualize it. It’s basically saying, take a set, union all its elements together, then take the power set of *that*, and the original set will be a subset of that power set. I got lost at union all of its elements together. How does this work? For example, how do we do  $$\bigcup \{ 1, 5, 113, 55 \}$$ ? The elements are just numbers, not sets! … Oh wait, the beginning of the book said that in set theory **all we have are sets**. So they are actually sets!

For each item in $$X$$, there are two possibilities of what it could be.

1) It could either be the empty set ($$\varnothing$$), or a set with items in it (literally everything else including numbers, ordered pairs, functions, etc). If it is the empty set, no elements will be added to the union, but the empty set is always an element of any power set, because it is a subset of all sets. So that element of $$X$$ is taken care of. 

2) For the rest of the elements of $$X$$ that were *not* the empty set, their underlying elements will get merged together in $$\bigcup X$$. For example, let’s say $$X = \{ \varnothing, \{a,b \}, \{ c\} \}$$. Then $$\bigcup X = \{a,b,c\}$$. The key thing is that taking the power set of this will create **all the sets that were originally in $$X$$, and more. $$\mathcal{P} \left ( \bigcup X \right ) = \{\varnothing, \{a\}, \{b\}, \{c\}, \{a,b\}, \{a,c\},\{b,c\},  \{a,b,c\}\}$$.** This contains all of the sets that were originally in $$X$$ plus a few more. Once we have the everything is a set mindset, then it becomes visually intuitive why $$X \subset \mathcal{P} \left ( \bigcup X\right )$$: we are re-building all of the sets that made up $$X$$, and more. A simple change of perspective turned an unintuitive problem into an intuitive one! I love this.

---

**Why am I writing about this?**

When I find a cool idea that challenges my previous thinking, I like to blog about it so that I can think even more clearly about it. I also like to do it because I think more people should know that everything is a set!