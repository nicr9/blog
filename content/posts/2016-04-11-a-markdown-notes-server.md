---
title: A Markdown notes server
author: nicr9
type: post
date: 2016-04-11T08:35:01+00:00
url: /?p=992
categories:
  - Uncategorised
tags:
  - lifehacks
  - linux

---
I keep a lot of notes&#8230;

## Writing notes

Any time I&#8217;m researching anything computing related, whether it&#8217;s for work or in my spare time, I keep a log of my &#8220;stream of conciousness&#8221;. This includes thoughts like &#8220;I think this is because&#8230;&#8221;, &#8220;I wonder if this is related to&#8230;&#8221;, &#8220;What the fuck is&#8230;?&#8221;.

This is great when I&#8217;ve spent a lot of time learning something new and I can look back over them once a week to reinforce the stuff I&#8217;ve covered. I get to see how wrong I was about some things and I can gain a new appreciation for other things that might not have dawned on me the first time around. I encourage anyone to keep stream of conciousness notes while they&#8217;re in learning mode.

A few specifics: I write these notes in vim using [Markdown][1]. I typically write the date as a header and use sub-headers for breaking up a days thoughts into topics. Then I write down what ever thoughts occur to me as I go in a bullet-point list. If I&#8217;m googling and find helpful resources I&#8217;ll throw the links into the notes as well so I can come back to them later, rather than break the flow of my exploration.

These aren&#8217;t strict rules you have to follow; just my own personal style. There&#8217;s nothing wrong with experimenting and finding what works for you!

## Reading notes

When it comes to reviewing what I&#8217;ve written, I&#8217;ve found that reading markdown in vim sucks.

What I really wanted was to format the notes in HTML and make them look visually appealing (this makes a big difference when you&#8217;ve got an attention span as short as mine).

Hosting them from a webpage (over LAN) would be ideal because then I could check &#8217;em from a phone or tablet when I&#8217;m away from my desk (great for recounting details during stand ups).

It should be noted that I didn&#8217;t want to use any of the note taking web apps like Evernote or Google Keep or even though they&#8217;d making note syncing really easy. Why you ask? Because 1) vim, 2) grep, and 3) I wanna host my own notes and not expose them over the internet because sometimes they&#8217;re sensitive work related stuff.

## What did I come up with?

Simple: flask app in a docker container. It uses [pandoc][2] to convert to HTML and it spruces things up with [dashed/github-pandoc.css][3].

You can pull it from the Docker Hub and mount the folder with all your notes when you run it. No fuss, relatively little muss. Here&#8217;s the commands to serve files from ~/notes at [localhost:4000][4] if you wanna try it yourself:

<script src="https://gist.github.com/nicr9/4bbc01b7c3dceb14c323a6d1ba89705a.js"></script>

Want to take a closer look? The code is up on my [github][5] and the latest image is on the [docker hub][6]! It&#8217;s just something I threw together quickly. If you have ideas for improvements I&#8217;ll be happy to look at any pull requests.

This is actually the first image I put on the hub so that was fun.

I also posted some screenshots below:

<div id='gallery-1' class='gallery galleryid-992 gallery-columns-3 gallery-size-thumbnail'>
  <figure class='gallery-item'> 
  
  <div class='gallery-icon landscape'>
    <a href='/wp-content/uploads/2016/04/screenshot-from-2016-04-10-19-40-24.png'><img width="150" height="150" src="/wp-content/uploads/2016/04/screenshot-from-2016-04-10-19-40-24-150x150.png" class="attachment-thumbnail size-thumbnail" alt="" srcset="/wp-content/uploads/2016/04/screenshot-from-2016-04-10-19-40-24-150x150.png 150w, /wp-content/uploads/2016/04/screenshot-from-2016-04-10-19-40-24-100x100.png 100w" sizes="100vw" /></a>
  </div></figure><figure class='gallery-item'> 
  
  <div class='gallery-icon landscape'>
    <a href='/wp-content/uploads/2016/04/screenshot-from-2016-04-10-19-06-45.png'><img width="150" height="150" src="/wp-content/uploads/2016/04/screenshot-from-2016-04-10-19-06-45-150x150.png" class="attachment-thumbnail size-thumbnail" alt="" srcset="/wp-content/uploads/2016/04/screenshot-from-2016-04-10-19-06-45-150x150.png 150w, /wp-content/uploads/2016/04/screenshot-from-2016-04-10-19-06-45-100x100.png 100w" sizes="100vw" /></a>
  </div></figure><figure class='gallery-item'> 
  
  <div class='gallery-icon landscape'>
    <a href='/wp-content/uploads/2016/04/screenshot-from-2016-04-10-19-40-58.png'><img width="150" height="150" src="/wp-content/uploads/2016/04/screenshot-from-2016-04-10-19-40-58-150x150.png" class="attachment-thumbnail size-thumbnail" alt="" srcset="/wp-content/uploads/2016/04/screenshot-from-2016-04-10-19-40-58-150x150.png 150w, /wp-content/uploads/2016/04/screenshot-from-2016-04-10-19-40-58-100x100.png 100w" sizes="100vw" /></a>
  </div></figure>
</div>

Give it a go and let me know what you think! I&#8217;d love to hear from you about your own note taking strategies.

Enjoy!

 [1]: https://daringfireball.net/projects/markdown/basics
 [2]: http://pandoc.org/
 [3]: https://gist.github.com/dashed/6714393
 [4]: http://localhost:4000/
 [5]: https://github.com/nicr9/mdserver
 [6]: https://hub.docker.com/r/nicr9/mdserver/
