---
layout: post
title:  "Self-documenting makefile"
date:   2017-11-11 21:03:00 -0600
author: "Paul Herz"
categories: snippets
---

The following snippet of Makefile adds a `make help` target that lists out all available targets. What it currently *doesn't* do is print out descriptions, which I hope to add soon, probably by attempting to parse specially-formatted comments à la Doxygen.

```make
help:
	perl -wnE 'say for /^[^\s:]+/g' < Makefile
```

I love `make` because it's easy and commonplace. Newer build tools may be great for very advanced or specific use-cases, but my projects usually come with a Makefile. Even when I have a project with a preexisting build system, I usually wrap it in `make` for the utmost simplicity. This site, for example, is built with Jekyll, but I use a Makefile. My reasoning is I don't want to memorize build commands for a dozen projects with a dozen different build systems. 

I belong to a few particular schools of thought regarding Makefile design: first, there's nothing wrong with dummy targets. `make` is ideally meant to have targets named after files, so certain files can depend on others, and files that are already there don't get remade. `make` will tolerate targets not named after real files, but it will always rebuild those targets assuming there's not a file with a matching name. This can be a problem in projects with expensive-to-build targets, but not really an issue here. Second, targets that don't actually generate output (e.g. compiled files, bundles) are not evil. Many of the targets I put in my Makefiles wrap complex Docker commands or local development server runners. This makes life easier for me as well as those I collaborate with.

I generally believe that by just looking at a `README`, you should immediately know how to setup a project you've downloaded, and furthermore, it shouldn't take too many steps. This is not a widely-held belief in the development community, which is littered with build tools *du jour* and very picky dependencies. As an extension to this idea, I want someone to be able to list out all the targets a Makefile offers.

I decided to write the above command for the Makefile to parse itself using perl-flavored regex. I tried `grep` and `egrep` but they couldn't seem to parse tabs as whitespace. The common wisdom was to add the `-P` flag to `grep` to enable perl regex mode, but that only works on GNU `grep`, aka not what's on macOS.

The syntax isn't that clear, but it looks for lines that begin with a chain of characters not including whitespace or colons. In one step, this excludes lines that aren't target declarations, and strips the trailing colon. The one thing I don't quite understand is why it implicitly runs the pattern against STDIN, but I don't know perl that well.

Thanks to [this](https://stackoverflow.com/a/6259821/3592716) answer on StackOverflow for helping me get the Perl syntax right.