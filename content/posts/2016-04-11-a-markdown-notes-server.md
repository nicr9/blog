---
title: A Markdown notes server
author: nicr9
type: post
date: 2016-04-11T08:35:01+00:00
url: /2016/04/11/a-markdown-notes-server/
tags:
  - lifehacks
  - docker

---
I keep a lot of notes...

## Writing notes

Any time I'm researching anything computing related, whether it's for work or in my spare time, I keep a log of my "stream of conciousness". This includes thoughts like "I think this is because...", "I wonder if this is related to...", "What the fuck is...?".

This is great when I've spent a lot of time learning something new and I can look back over them once a week to reinforce the stuff I've covered. I get to see how wrong I was about some things and I can gain a new appreciation for other things that might not have dawned on me the first time around. I encourage anyone to keep stream of conciousness notes while they're in learning mode.

A few specifics: I write these notes in `vim` using [Markdown][1]. I typically write the date as a header and use sub-headers for breaking up a days thoughts into topics. Then I write down what ever thoughts occur to me as I go in a bullet-point list. If I'm googling and find helpful resources I'll throw the links into the notes as well so I can come back to them later, rather than break the flow of my exploration.

These aren't strict rules you have to follow; just my own personal style. There's nothing wrong with experimenting and finding what works for you!

## Reading notes

When it comes to reviewing what I've written, I've found that reading markdown in vim sucks.

What I really wanted was to format the notes in HTML and make them look visually appealing (this makes a big difference when you've got an attention span as short as mine).

Hosting them from a webpage (over LAN) would be ideal because then I could check 'em from a phone or tablet when I'm away from my desk (great for recounting details during stand ups).

It should be noted that I didn't want to use any of the note taking web apps like Evernote or Google Keep or even though they'd making note syncing really easy. Why you ask? Because:

1. `vim`
2. `grep`
3. I wanna host my own notes and not expose them over the internet because sometimes they're sensitive work related stuff.

## What did I come up with?

Simple: a flask app in a docker container. It uses [pandoc][2] to convert to HTML and it spruces things up with [dashed/github-pandoc.css][3].

You can pull it from the Docker Hub and mount the folder with all your notes when you run it. No fuss, relatively little muss. Here's the commands to serve files from `~/notes` at [localhost:4000][4] if you wanna try it yourself:

```bash
docker pull nicr9/mdserver
docker run -dp 4000:4000 -v /home/$USER/notes:/opt/notes nicr9/mdserver
```

Want to take a closer look? The code is up on github at [nicr9/mdserver][5] and the latest image is on the [docker hub][6]! It's just something I threw together quickly. If you have ideas for improvements I'll be happy to look at any pull requests.

This is actually the first image I put on the hub so that was fun.

I also posted some screenshots below:

![](/wp-content/uploads/2016/04/screenshot-from-2016-04-10-19-40-24.png)

![](/wp-content/uploads/2016/04/screenshot-from-2016-04-10-19-06-45.png)

![](/wp-content/uploads/2016/04/screenshot-from-2016-04-10-19-40-58.png)

Give it a go and let me know what you think! I'd love to hear from you about your own note taking strategies.

Enjoy!

 [1]: https://daringfireball.net/projects/markdown/basics
 [2]: https://pandoc.org/
 [3]: https://gist.github.com/dashed/6714393
 [4]: http://localhost:4000/
 [5]: https://github.com/nicr9/mdserver
 [6]: https://hub.docker.com/r/nicr9/mdserver/
