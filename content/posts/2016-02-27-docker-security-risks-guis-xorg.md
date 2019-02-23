---
title: 'Docker Security Risks: GUIs + Xorg'
author: nicr9
type: post
date: 2016-02-27T11:39:47+00:00
url: /?p=496
featured_image: /wp-content/uploads/2016/02/docker_and_xorg2.png
categories:
  - Uncategorised
tags:
  - docker
  - security

---
Recently I [wrote a post][1] where I was running a GUI application in a docker container. I did so because I couldn&#8217;t be confident of the software&#8217;s origins and thought it&#8217;d be best not to take any chances. What other potential exploits does this leave one vulnerable to and how can one best protect themselves?

<img class="alignnone size-full wp-image-833" src="/wp-content/uploads/2016/02/docker_and_xorg2.png" alt="docker_and_xorg" width="2000" height="901" srcset="/wp-content/uploads/2016/02/docker_and_xorg2.png 2000w, /wp-content/uploads/2016/02/docker_and_xorg2-300x135.png 300w, /wp-content/uploads/2016/02/docker_and_xorg2-768x346.png 768w, /wp-content/uploads/2016/02/docker_and_xorg2-1024x461.png 1024w" sizes="(max-width: 767px) 89vw, (max-width: 1000px) 54vw, (max-width: 1071px) 543px, 580px" />

## But isn&#8217;t everything running in Docker secure?

First things first, let&#8217;s talk about what kind of security assurances docker tries to provide and under what circumstances those assurances would be considered null and void.

One of the major selling points of containers is the various forms of isolation that they provide (here&#8217;s Solomon&#8217;s [list from DockerConEu][2]). Docker&#8217;s strategy is to lock down as many avenues between containers and the host as it can. From here it lets you decide whether or not your application needs them and lets you open some of these avenues at your discretion.

This means that you&#8217;re free to provide containers with access to things like _/var/run/docker.sock_ which means they can control the docker engine running on the host. People do this all the time, e.g., if they&#8217;re running Continuous Integration software inside a container that wants to execute build plans in other containers. That doesn&#8217;t mean that it&#8217;s particularly safe if you don&#8217;t trust code running in those build plans. Processes in these containers could use this to become root on the host (here&#8217;s a [pretty succinct explanation][3] of how this works), although it&#8217;s my understanding that the new [support for user namespaces][4] in Docker 1.10 nips this in the bud.

This brings me back to running  GUI applications in Docker. To display the GUI they need to be able to talk to the X server (Xorg) running on your host through a socket file; _/tmp/.X11-unix._ This also provides it with access to a smorgasbord of things that it can use against you.

The problem is that Xorg is in charge of more than just what gets displayed on the screen, it also handles input from keyboard/mouse. It does have a security layer but it&#8217;s kinda tacked on and doesn&#8217;t support fine grain control over which resources are accessible.

## What can I do about it?

So how do we know when access to certain resources is a bad idea? I don&#8217;t believe it&#8217;s an exaggeration to say that every piece of software that serves a practical purpose also comes with potential security implications. Security omniscience (knowing every facet of the software we run, understanding how it relates to security and how these facets interrelate) is impractical, for this reason security omnipotence (the power to be 100% secure) is impossible.

The best we can do is to constantly seek clarity on what it is that our software does and (if at all possible) how it does it. I&#8217;ve found that as a result of adopting this policy, an intuition regarding security will naturally begin to develop. It all boils down to this: never stop asking questions.

So the next question to ask is&#8230;

## How can I fuck over the end-user?

After poking around for a bit I realised that containers with access to Xorg could indeed do some scary things (at least while the container was still running.)

So I decided I&#8217;d throw together a few demos of containers that spy on/manipulate their host. These are really basic! They&#8217;re purely to remind you that just because you&#8217;re running something in a container doesn&#8217;t mean you&#8217;re not exposed to potential attacks.

### Screenshots

Imagemagik is used a lot on Linux to take screenshots and it does this by interacting with X. Ergo; if your container has access to X on the host, than it can screenshot the host (and without any particular form of warning).

Here&#8217;s a demo dockerfile that screenshots with imagemagik and displays the resulting image with feh:

<script src="https://gist.github.com/nicr9/b239a57f9cc93151cc73.js"></script>

Here&#8217;s the commands needed to get this working:

<script src="https://gist.github.com/nicr9/5950d050744c24a1d7ff.js"></script>

You&#8217;ll notice that the only additional things this container needs is to tell xhost to allow any access from localhost, to mount the X socket and the provide the display number. These are all things you would need to do to allow any GUI to run from the confines of a container.

### Toggling capslock every 20 minutes

This example installs xdotool which can be used for (among other things) simulating keypresses. Then it creates a cron that uses xdotool to toggle caps lock every 20 minutes.

Clearly I&#8217;m some kind of deranged lunatic for coming up with something this nefarious. Use responsibly.

<script src="https://gist.github.com/nicr9/55a6f2ac73cdf3bf33f9.js"></script>

Pretty much the same docker commands for running this container so I won&#8217;t bother including those from now on.

### Peeking at the clipboard

This one is ridiculously easy! Xclip is a tool for read and write access to the various clipboards provided by X. That includes the regular clipboard (Ctrl+c/Ctrl+v), used in the example here, as well as the selection clipboard (highlight/middle mouse button) if you&#8217;re on Linux.

<script src="https://gist.github.com/nicr9/989836942f582ce17610.js"></script>

### Scripting mouse movements

Our old friend xdotool can also be used to script mouse movements! Here&#8217;s an example of it moving to certain co-ordinates (15, 15) and clicking, it&#8217;s just a minor modification of the capslock example:

<script src="https://gist.github.com/nicr9/d0d703185da4bc21e471.js"></script>

On it&#8217;s own this could be fairly random and useless but if we were to combine this with the screenshots we took above, we could get a reasonable idea of where we&#8217;d like to click to cause the most damage.

### What else?

We could go further and grant access to other stuff like /dev/input/* (log data from keyboard + mouse), /dev/snd (speakers + microphones) or /dev/video0 (web cams). The possibilities are endless.

With all of this we could put together a [RAT][5]!&#8230; But at the risk of being put on some kinda watch-list, I think I&#8217;ll just leave that as an exercise for the reader&#8230;

## Conclusions

The purpose of this article is to inform you of what you&#8217;re opening yourself up to when running GUIs in containers. Don&#8217;t do it when you&#8217;re working on anything sensitive on the host!

If you don&#8217;t actually need to interact with the GUI itself (maybe you&#8217;re considering your testing options) then you might get some of the benefits of containerisation by running these applications headless (a lot of people [containerise Selenium tests][6] this way).

**Silver lining**: Programs running in containers need a some kind of exploit to escape the confines of that container (like the /var/run/docker.sock thing I talked about at the beginning). This means that most of the time we can be assured that as soon as we stop the container running our hypothetical RAT, it will be unable to continue spying on us (it&#8217;s the equivalent of pulling the plug.)

 [1]: http://blog.nicro.land/p87/
 [2]: http://www.slideshare.net/Docker/dockercon-eu-day-1-general-session/84
 [3]: http://www.slideshare.net/gvarisco/road-to-opscon-pisa-15-devooops/54
 [4]: https://blog.docker.com/2016/02/docker-engine-1-10-security/
 [5]: https://www.google.ie/search?q=remote+access+trojan
 [6]: http://agiletesting.blogspot.ie/2016/01/running-headless-selenium-webdriver.html
