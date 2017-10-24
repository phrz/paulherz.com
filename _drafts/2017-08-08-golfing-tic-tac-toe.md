---
layout: post
title:  "Golfing Tic Tac Toe"
date:   2017-08-08 15:00:00 -0500
author: "Paul Herz"
categories: test
---

This week, just for fun, I took my first shot at code golf. The name comes from golf, where lower scores are better: it's a programming game where you try to make your code as short as possible. Golfers gather to work on puzzles in several places, like [Reddit](https://www.reddit.com/r/codegolf/) and [StackExchange](https://codegolf.stackexchange.com/).

For no reason other than boredom, I challenged myself to write the shortest Tic Tac Toe game I could. I started by writing out a full-length version with Python 3. I gradually stripped away unnecessary abstractions, external libraries, and verbosity until I got this:

```python
L,Y,W,E,G='-',lambda i:B[A[i][0]][A[i][1]],[0,0],[2,2],0
B=[L]*3,[L]*3,[L]*3
while 1:
	G=1-G;t='XO'[G]
	for[a,b,c]in B:print(a+b+c)
	while 1:
		q=ord(input(t)[0])-49
		if q in range(9):x,c=B[q//3],q%3
		if x[c]==L:x[c]=t;break
	A=[(x+V*i,y+v*i)for a,b in[W,(0,1),(0,2)]for x,y,V,v in[(a,b,1,0),(b,a,0,1)]for i in[0,1,2]]+[W,E,(1,1),(2,0),E,(0,2)]
	exec("if(Y(0)==Y(1)==Y(2)!=L):print('W'+Y(0));exit()\nA=A[3:]\n"*8)
```

That's **415 bytes total** for a command line interface that prints out a 3x3 grid to represent the game state, prompts the user for a number, and can detect a winning state. Of course, I had to make some compromises to save bytes -- I'll explain those as I go line by line.

**Line 1:**
```python
L,Y,W,E,G='-',lambda i:B[A[i][0]][A[i][1]],[0,0],[2,2],0
```

In this line, I create several single-letter variables. If a variable is only replacing something used once or twice, it may not be economical: counting the one letter variable name, assignment carries an overhead of three letters. The list format I use above has the same character overhead as regular assignment -- it's only for the appearance of compactness. Every time I considered breaking out a value into a variable, I checked the byte count before and after to verify that I was saving space: more often than not, I was actually adding bytes.

`L='-'` is the character I use to denote a blank spot in the board. Every time I use this constant, I save two characters over using the literal.

`Y=lambda i:B[A[i][0]][A[i][1]]`: let's break this down. `B` is the global storing the board in a two-dimensional, row-ordered list. `A` is a variable that will be in scope when this function is called, and it contains a list of vectors as tuples. I frequently needed to say "go to the spot on the board corresponding to the vector at the i-th position in A," which looked like `B[ A[i][0] ][ A[i][1] ]`. I call this three times in the loop where I check for winning game states, so it was unacceptably verbose.

`W=[0,0]` and `E=[2,2]` allowed me to save a few bytes by replacing coordinates I referred to more than once with single letters.

`G=0` is the only stateful variable here: it flip-flops between zero and one in the game loop to determine whose turn it.

**Line 2:**
```python
B=[L]*3,[L]*3,[L]*3
```

Here, I create the game board. This format may seem like a very space inefficient way to build the board, creating a size-3 array three separate times. However, simply "multiplying" the list to create the 2D list causes an interesting problem. When I build the board with `[[L]*3]*3`, assigning a value to the first item in the first row (index `[0][0]`) fills every cell in that column with the value. 

The explanation? In Python, <mark>strings are value types and lists are reference types</mark>. The first layer of duplication, `[L]*3`, copies the string `L` into three places, but when we "multiply" the lists, we just create three references to a single list. As such, this longer version is necessary to work within the parameters of Python.