---
layout: post
title:  "How to make a sound"
date:   2019-01-09 21:00:00 -0600
author: "Paul Herz"
categories: snippets
---

This article will introduce you to programming sound: writing a program that can generate a particular sound. I will demonstrate how to create sound, while also exploring the technical side of digital sound.
You will need the following on your computer:

- Python 3 (I used 3.7.0)
- Audacity (available <a href="https://www.audacityteam.org/download/">here</a>)

Our first program will generate a <em>square wave</em>. Unlike sound waves that move smoothly, a square wave is only ever at its maximum or its minimum. It's also one of the simplest waves to generate digitally, as you only need to output two possible values.

In the resulting audio file, we'll represent each moment of sound (sample) as an 8-bit unsigned integer, so "all the way up/down" will be represented by 255 and 0. That means the most positive and negative voltages on the speaker, and the maximum and minimum pressures the speakers can produce in the air.

## What's a sample? (needs an accompanying "what's frequency/wavelength/amplitude/displacement")

In analog systems like record players and microphones hooked up to speakers, the sound signal is also analog. Another word for this is <em>continuous</em>. Between the lowest and highest possible displacement values for sound waves in these systems, there are infinitely many possible values — a <em>continuous</em> range. Also, between one second and the next, the sound wave has infinitely many values — you could zoom in on such a sound wave and there would be no blank spots.

In this digital representation, we can't really have infinitely many values with which to represent the possible values of the sound wave. Some formats use floating point numbers, but I'm going to use 8-bit unsigned integers, meaning I can use the numbers 0 to 255. 

Also, to represent infinitely many points across time would require infinite storage, assuming we don't represent the wave as a formula. So I'm going to reduce the resolution of the wave over time as well. I will settle for a fixed number of values per second, meaning I'll only really know the value of the wave at certain discrete points in time. These discrete points in time where the value of the wave is known are called samples, and the number of values per second is called the <em>sample rate</em>.

Both of these steps are considered <em>discretization</em> — taking continuous data and sacrificing resolution to fit it into a discrete, finite format.

## The generator

Python generators are very helpful for sound wave generation. They are iterable like lists, but you only generate values as needed. Generator functions can use the `yield` keyword, which behaves like a `return`, but allows the function to pick back up in the same location when the generator needs to produce the next value.

We need to import `itertools.islice`, which allows us to take the first n values yielded by a generator:

```python
from itertools import islice
```

Next, this is what the generator looks like:

```python
def square_wave(wavelength, sample_rate):
	# given the sample rate, the number of samples in one wavelength.
	wave_samples = int(round(wavelength * sample_rate))

	# generate a square wave indefinitely, alternating between
	# high and low.
	while True:
		for x in [0, 255]:
			# in a square wave, you keep the same output for
			# half of a wavelength before switching to the other.
			for _ in range(wave_samples // 2):
				yield x
```

## Constants (revise)
### Samples and sample rate

```python
sample_rate = 44100
seconds = 4
```

### Frequency and wavelength

```python
f = 440.0
wavelength = 1.0/f
```

Whereas `sample_rate` and `seconds` above defined the format of the file and its length, these constants will define characteristics of the sound wave itself. We define frequency (`f`) as 440 Hertz (Hz).

## Reconstruction (revise)

To play the sampled audio out loud, the original sound must be "reconstructed" from this incomplete data — that happens behind the scenes on your device's Digital-to-Analog Converter (DAC).

> First we define `sample_rate`, which is how many samples there are per second. You can pick any value, but a very high sample rate wastes file size without sounding much better, and a very low sample rate sounds "blurry" and low definition, like a poor quality phone call. 44,100 samples per second is a common, high-quality rate that was originally used as the sample rate for audio on CDs.

We define `seconds`, which is the total length of the audio file. To achieve this length, we'll just repeat the sound wave many times over until the number of samples equals `seconds * sample_rate`, that many seconds measured in samples.

(WORK IN PROGRESS)