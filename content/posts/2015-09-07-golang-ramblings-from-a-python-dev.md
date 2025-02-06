---
title: Golang Ramblings from a Python Dev
author: nicr9
type: post
date: 2015-09-07T07:28:17+00:00
url: /2015/09/07/golang-ramblings-from-a-python-dev/
tags:
  - golang
  - Python
---

I've been spending time lately learning Go and I thought I'd throw some of my thoughts down here. As the title implies my experience is mostly in Python so expect lots of apples to oranges comparisons!

![5 year anniversary pic, taken from the golang blog](https://blog.golang.org/5years/gophers5th.jpg)

## Tooling

I guess the first thing that jumps out is the quality of the tooling, I've only had a chance to play around with a few of the CLI's features but already I'm impressed with how simple it makes some day to day things.

When you're looking at new code for the first time the first thing on your mind is usually vendoring dependencies (I didn't realise 'vendor' is a verb, ya learn something new every day). [`go get ...`][2] will download and install individual dependencies but it can also recursively scan through a project to save you the effort:

```bash
go get -d ./...
```

This can pull in code automagically from git repositories (mercurial, bazaar and subversion too) which is nice and it doesn't involve installing an extra package like pip/setuptools.

When you're adding changes to code don't forget about [`gofmt`][3]. It takes advantage of the relative ease of parsing Go's syntax to automate/enforce certain elements of coding style like use of whitespace. It's also really easy to include in your workflow; I use [fatih/vim-go][4], a vim plugin that (among other cool things) runs `gofmt` every time you save changes. If vim's not your style (pun not intended) then it's easy to find [docs for setting up a git hook][5] that runs `gofmt` before you commit.

There are some other tools that use Go's simplicity to automate away the boring stuff. These are tools I haven't had a lot of time to try out but for the adventurous: [`godoc`][6] "extracts and generates documentation for Go programs" and [`gofix`][7] which "finds Go programs that use old APIs and rewrites them to use newer ones." The later one sounds particularly ambitious! Reminds me of [2to3][8], which never offered any guarantees other than a helping hand; you were still expected to go most of the porting work yourself.

Next step is usually building/installing code; the [`go build ...`][9] and [`go install ...`][10] commands serve all your needs here. No need to choose between packaging libs like setuptools and distribute! The problem here is that what these packaging libs provide for is a standard way of declaring package metadata so that they can be found on an index like [PYPI][11], which leads me to...

## Argh! Packaging!

So far this is the first big thing missing for Go and I'm not entirely sure how I feel about it!

On the one hand there is no need to set up and actively maintain your project listings on a centralised site; all you need to do is to choose (and choice is important to developers) which site you host your code on.

On the other hand PYPI can really leverage that metadata and offer a powerful way to search for the package you need. If you haven't tried browsing by package category before, [give it a quick try][12] so you can see what I mean. I can wait...

I tried looking into a similar resource for golang and most of the internet pointed me to [godashboard.appspot.com/...](https://godashboard.appspot.com/project), which seems to be down at the time of writing. After a little bit of research it seems that the listings it hosted were moved around some wikis till they found their new home at [golang/go](https://github.com/golang/go/wiki/Projects). Having this page in the language's git wiki seems to makes sense in terms of go's philosophy but it just leaves me wanting something better.

But I Digress...

## Lets Talk About Testing

So the compiler hasn't found any problems in your code; it all builds without issue. Hurray!

The next thing to check is tests and the command for running them is (big surprise here, drum-roll please) [`go test`][13]. This quite frankly makes `python -m unittest discover` look like an afterthought.

Here's something that shocked me when I was writing tests: there's no assertions in Go! [The aim here][14] was to remove a crutch that developers too often use to avoid thinking about proper error handling. That should be a top consideration when you're writing server-side code; if you're not careful with errors requests will die and cause lots of trouble for the client.

So what do tests look like in a world without assertions? Not that different really, assertions are just if statements with some syntactic sugar to make things look a bit more formal. All you need is to write your own if statements and make calls to `t.Fatal(...)` if things look broken.

I did some soul searching regarding this; is there anything that we really lose from leaving assertions out of the language? At first I was a bit miffed because I'm used to the array of assertions available as member functions of `unittest.TestCase` in Python but I got over it quickly! Keystrokes saved while writing tests aren't worth it if it means people get lazy with error handling.

## Convention Over Configuration

The common theme that I keep coming back to in my head here is "what can we automate by relying on a convention and what should we let developers control by way of configuration?".

Go's tooling stuff all depends on a strict directory structure and syntax (which probably required a lot of thinking on Google's part). Python's package distribution relies on the maintainer filling out setup.py. Both languages also have conventions regarding writing test cases to facilitate test discovery.

It makes me think a lot about the upfront investment in terms of reading docs. When you're starting out learning programming, documentation can be daunting; there's a hell of a lot of it! I'm not ready to say which language has the greater learning curve for developers starting out but it's a very important consideration

## More Rambling?

I realise that this post has been far from a comprehensive comparison and that there are many important things I left out, e.g., goroutines vs asyncio, support for paradigms like OO and functional programming, third party libraries, etc.

There's way too much to cover in a single blog post. I hope to write more as I get familiar with the language and maybe I'll ramble about other technologies too!

If you have any comments, suggestions, or questions feel free to get in contact with me! I'd love to hear from you.

 [1]: https://blog.golang.org/5years/gophers5th.jpg
 [2]: https://golang.org/cmd/go/#hdr-Download_and_install_packages_and_dependencies
 [3]: https://golang.org/cmd/gofmt/
 [4]: https://github.com/fatih/vim-go
 [5]: https://golang.org/misc/git/pre-commit
 [6]: https://godoc.org/golang.org/x/tools/cmd/godoc
 [7]: https://golang.org/cmd/fix/
 [8]: https://docs.python.org/2/library/2to3.html
 [9]: https://golang.org/cmd/go/#hdr-Compile_packages_and_dependencies
 [10]: https://golang.org/cmd/go/#hdr-Compile_and_install_packages_and_dependencies
 [11]: https://pypi.python.org
 [12]: https://pypi.python.org/pypi?%3Aaction=browse
 [13]: https://golang.org/cmd/go/#hdr-Test_packages
 [14]: https://golang.org/doc/faq#assertions
