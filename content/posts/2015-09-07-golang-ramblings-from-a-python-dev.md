---
title: Golang Ramblings from a Python Dev
author: nicr9
type: post
date: 2015-09-07T07:28:17+00:00
url: /?p=61
categories:
  - Uncategorized
tags:
  - golang
  - Python

---
I&#8217;ve been spending time lately learning Go and I thought I&#8217;d throw some of my thoughts down here. As the title implies my experience is mostly in Python so expect lots of apples to oranges comparisons!

[<img class="alignnone" src="https://blog.golang.org/5years/gophers5th.jpg" alt="￼Taken from the golang blog" width="1262" height="733" />][1]

## Tooling

I guess the first thing that jumps out is the quality of the tooling, I&#8217;ve only had a chance to play around with a few of the CLI&#8217;s features but already I&#8217;m impressed with how simple it makes some day to day things.

When you&#8217;re looking at new code for the first time the first thing on your mind is usually vendoring dependencies (I didn&#8217;t realise &#8216;vendor&#8217; is a verb, ya learn something new every day). &#8220;[go get][2] &#8230;&#8221; will download and install individual dependencies but it can also recursively scan through a project to save you the effort:

[code]
  
go get -d ./&#8230;
  
[/code]

This can pull in code automagically from git repositories (mercurial, bazaar and subversion too) which is nice and it doesn&#8217;t involve installing an extra package like pip/setuptools.

When you&#8217;re adding changes to code don&#8217;t forget about [gofmt][3]. It takes advantage of the relative ease of parsing Go&#8217;s syntax to automate/enforce certain elements of coding style like use of whitespace. It&#8217;s also really easy to include in your workflow; I use [fatih/vim-go][4], a vim plugin that (among other cool things) runs gofmt every time you save changes. If vim&#8217;s not your style (pun not intended) then it&#8217;s easy to find [docs for setting up a git hook][5] that runs gofmt before you commit.

There are some other tools that use Go&#8217;s simplicity to automate away the boring stuff. These are tools I haven&#8217;t had a lot of time to try out but for the adventurous: [godoc][6] &#8220;extracts and generates documentation for Go programs&#8221; and [gofix][7] which &#8220;finds Go programs that use old APIs and rewrites them to use newer ones.&#8221; The later one sounds particularly ambitious! Reminds me of [2to3][8], which never offered any guarantees other than a helping hand; you were still expected to go most of the porting work yourself.

Next step is usually building/installing code; the &#8220;[go build][9]&#8221; and &#8220;[go install][10]&#8221; commands serve all your needs here. No need to choose between packaging libs like setuptools and distribute! The problem here is that what these packaging libs provide for is a standard way of declaring package metadata so that they can be found on an index like [PYPI][11], which leads me to&#8230;

## Argh! Packaging!

So far this is the first big thing missing for Go and I&#8217;m not entirely sure how I feel about it!

On the one hand there is no need to set up and actively maintain your project listings on a centralised site; all you need to do is to choose (and choice is important to developers) which site you host your code on.

On the other hand PYPI can really leverage that metadata and offer a powerful way to search for the package you need. If you haven&#8217;t tried browsing by package category before, [give it a quick try][12] so you can see what I mean. I can wait&#8230;

I tried looking into a similar resource for golang and most of the internet pointed me to godashboard.appspot.com/project, which seems to be down at the time of writing. After a little bit of research it seems that the listings it hosted were moved around some wikis till they found their new home at <https://github.com/golang/go/wiki/Projects>. Having this page in the language&#8217;s git wiki seems to makes sense in terms of go&#8217;s philosophy but it just leaves me wanting something better.

## But I Digress&#8230; Lets Talk About Testing

So the compiler hasn&#8217;t found any problems in the code; it all builds without issue. Hurray!

The next thing to check is tests and the command for running them is (big surprise here, drum-roll please) &#8220;[go test][13]&#8220;. This quite frankly makes &#8220;python -m unittest discover&#8221; look like an afterthought.

Here&#8217;s something that shocked me when I was writing tests: there&#8217;s no assertions in Go! [The aim here][14] was to remove a crutch that developers too often use to avoid thinking about proper error handling. That should be a top consideration when you&#8217;re writing server-side code; if you&#8217;re not careful with errors requests will die and cause lots of trouble for the client.

So what do tests look like in a world without assertions? Not that different really, assertions are just if statements with some syntactic sugar to make things look a bit more formal. All you need is to write your own if statements and make calls to &#8220;t.Fatal(&#8230;)&#8221; if things look broken.

I did some soul searching regarding this; is there anything that we really lose from leaving assertions out of the language? At first I was a bit miffed because I&#8217;m used to the array of assertions available as member functions of unittest.TestCase in Python but I got over it quickly! Keystrokes saved while writing tests aren&#8217;t worth it if it means people get lazy with error handling.

## Convention Over Configuration

The common theme that I keep coming back to in my head here is &#8220;what can we automate by relying on a convention and what should we let developers control by way of configuration?&#8221;.

Go&#8217;s tooling stuff all depends on a strict directory structure and syntax (which probably required a lot of thinking on Google&#8217;s part). Python&#8217;s package distribution relies on the maintainer filling out setup.py. Both languages also have conventions regarding writing test cases to facilitate test discovery.

It makes me think a lot about the upfront investment in terms of reading docs. When you&#8217;re starting out learning programming, documentation can be daunting; there&#8217;s a hell of a lot of it! I&#8217;m not ready to say which language has the greater learning curve for developers starting out but it&#8217;s a very important consideration

## More Rambling?

I realise that this post has been far from a comprehensive comparison and that there are many important things I left out, e.g., goroutines vs asyncio, support for paradigms like OO and functional programming, third party libraries, etc.

There&#8217;s way too much to cover in a single blog post. I hope to write more as I get familiar with the language and maybe I&#8217;ll ramble about other technologies too!

If you have any comments, suggestions, or questions feel free to get in contact with me! I&#8217;d love to hear from you.

 [1]: https://blog.golang.org/5years/gophers5th.jpg
 [2]: https://golang.org/cmd/go/#hdr-Download_and_install_packages_and_dependencies
 [3]: https://golang.org/cmd/gofmt/
 [4]: https://github.com/fatih/vim-go
 [5]: https://golang.org/misc/git/pre-commit
 [6]: http://godoc.org/golang.org/x/tools/cmd/godoc
 [7]: http://golang.org/cmd/fix/
 [8]: https://docs.python.org/2/library/2to3.html
 [9]: https://golang.org/cmd/go/#hdr-Compile_packages_and_dependencies
 [10]: https://golang.org/cmd/go/#hdr-Compile_and_install_packages_and_dependencies
 [11]: http://pypi.python.org
 [12]: https://pypi.python.org/pypi?%3Aaction=browse
 [13]: https://golang.org/cmd/go/#hdr-Test_packages
 [14]: https://golang.org/doc/faq#assertions