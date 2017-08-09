---
layout: post
title:  "Golfing Tic Tac Toe"
date:   2017-08-08 15:00:00 -0500
author: "Paul Herz"
categories: test
---

In the real world, we focus on making our code simple, human-readable, and (allegedly) self-documenting. On the other hand, code golfing is a fun exercise in *impractical* coding. A "golfer" exploits syntax tricks and side-effects to solve a problem with fewer bytes of code. The name comes from golf, where a lower score is better. Golfers gather to present their solutions to challenges  in several places, namely on [Reddit](https://www.reddit.com/r/codegolf/) and [StackExchange](https://codegolf.stackexchange.com/).

Personally, I am not experienced in code golf; I only mess around with it when I'm bored. One day, I got particularly bored, and put more effort into it than ever before. I started by writing out a full-length implementation of Tic Tac Toe in Python 3, to be played in the command line. I gradually stripped away unnecessary abstractions, external libraries, and verbosity until I got this:

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