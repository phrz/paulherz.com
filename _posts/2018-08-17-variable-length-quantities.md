---
layout: post
title:  "Deep dive: variable length quantities"
date:   2018-08-17 23:55:00 -0500
author: "Paul Herz"
categories: deep-dive
excerpt_separator: <!-- more -->
---

{% assign post_assets = 'assets/posts/variable-length-quantities' %}

<figure>
	<div class="no-upscale-image-container" style="background:rgba(255, 37,0,.1);padding:2rem 0">
		<img 
		src="{{ post_assets 
			| append: '/piano-roll-alpha.png' 
			| relative_url 
		}}" 
		class="pixelated-image"
		width="200">
	</div><!-- .no-upscale-image-container -->
	<figcaption>
		<strong>Image:</strong>
		MIDI files encode music like the cylinder of a music box. This cylinder contains the beginning of Für Elise.<a href="#c1" name="c1s"><sup>1</sup></a>
	</figcaption>
</figure>

While I was working on a program that could read in MIDI files and (roughly) replay them, I ran into something I had never seen before: Variable Length Quantities (VLQs). It's an integer format unlike any fixed-length type: smaller numbers are represented in less space than large numbers.

<!-- more -->

MIDI files represent music as a series of events, like pressing a piano key down, or lifting it up. Event sections begin with the number of ticks since the previous event. The MIDI format is a compact binary format chock-full of numbers, so representing them compactly is a priority. Towards this goal, MIDI represents ticks relative to the previous event rather than absolutely: this means smaller numbers. But that only matters if your number format rewards you for smaller numbers (while still allowing for huge ones). Thus, MIDI uses VLQs for the best of both worlds: small numbers are small, but not to the exclusion of very large numbers when they're necessary.

This is a foreign concept to many people — in Computer Science classes, you learn about a variety of integer format choices; 32-bit, 64-bit, unsigned, sign-magnitude, one's-complement, two's-complement, and so on. None of these formats become more compact with smaller numbers — they are fixed length. It makes sense that the most common integer formats be fixed size, for several reasons:

1. At the low-level, if a type has a guarantee of a fixed size, you can calculate the size of a variable of that type or an array of that type at compile-time, you can allocate memory for it more easily.

2. With that same guarantee, you can randomly access the <em>n</em><sup>th</sup> element in the array through basic pointer arithmetic: that element will be located at `A + sizeof(type) * n` where `A` is the array's base address.

However, these benefits matter when executing a program, and MIDI does not use VLQs in any runtime — it's just a static file format. MIDI exists as a stream of bytes inside of a file, or running along a wire between devices, so as long as there exist *delimiters* that clarify when a value starts and ends, fixed-length values are unimportant.


## The VLQ format in MIDI

Technically, you can only represent unsigned integers in VLQ, but practically, you can represent plenty of things this way. VLQ is always represented in network order (big endian), such that the first VLQ byte contains the most significant bits of the number.

Generating VLQ in code is more tedious than *demonstrating* the algorithm, so I'll stick to demonstration. VLQ happens one byte at a time, and each byte is laid out as follows:

```
CNNN NNNN
```

Where `C` is the *continuation bit* and `N` is a bit from the original number. Each byte contains seven bits of data from the original number, which is odd: this means you have to split your original number into seven-bit chunks — you'll probably have to add some extra zeros to the left side of the most significant 7-bit chunk.

Back to the continuation bit: `C` will be set to `1` for every byte except the last, where it will be set to `1`. This is the entire reason we sacrifice one bit from each byte: we can denote whether to continue or not for a variable-length number buffer.

Below, we convert `256` from an unsigned, 64-bit integer in big-endian format to a VLQ, to demonstrate the greater storage and transmission efficiency.

```
// original u64 representation
d256 -> 0x0000000000000100

// 7 bit chunks
[000 0010, 000 0000]

// continuation bits (1 for "continue")
[1000 0010, 0000 0000]

// variable-length quantity representation
// (a saving of 6 bytes)
0xF200
```

However, *saving space* is not the only benefit of VLQs, although it is a meaningful one. VLQs also allow you to represent **arbitrarily large** numbers, whereas fixed-size integer formats have a hard limit on the largest numbers they can represent. All you need to do is make the VLQ byte sequence longer — a VLQ interpreter will keep parsing a stream for VLQ numbers until the continuation bit on the current byte is zero. 

Then, the only issue is finding a way to store the number if it is beyond the capacity of hardware types, which is easy to do if your language has built-in support for arbitrary-length integers. For example, the `Integer` type in Haskell can be arbitrarily large, whereas `Int` is guaranteed to be a hardware type. In Python 3, all integers are of arbitrary length.

<footer class="footnotes">
	<a href="#c1s" name="c1"><sup>1</sup></a> Mesh: <a href="https://www.thingiverse.com/thing:552498">shootquin</a>. Rendering/animation: me. License: <a href="https://creativecommons.org/licenses/by-sa/3.0/">CC BY-SA 3.0</a>
</footer>