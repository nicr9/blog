---
title: Running QtCreator in Docker
author: nicr9
type: post
date: 2015-12-06T19:53:55+00:00
url: /?p=87
featured_image: /wp-content/uploads/2015/11/docker_qt.png
categories:
  - Uncategorised
tags:
  - docker
  - qt

---
**Update:** I wrote a follow up post detailing potential security risks of running GUIs in containers, [check it out here][1].

The first thing I ever tried installing from source was Qt. For those who don&#8217;t know, Qt is a cross platform framework for writing GUI applications.

<img class=" size-full wp-image-134 aligncenter" src="/wp-content/uploads/2015/11/5954820.png" alt="5954820" width="280" height="280" srcset="/wp-content/uploads/2015/11/5954820.png 280w, /wp-content/uploads/2015/11/5954820-150x150.png 150w, /wp-content/uploads/2015/11/5954820-100x100.png 100w" sizes="(max-width: 280px) 100vw, 280px" />

## That was then&#8230;

I was in college, I had a macbook at the time and I was toying around with writing GUIs with Python/Tkinter. I kept fighting against Tkinter&#8217;s limitations and I finally decided it was time to find something with more power.

All I remember was putting together the endless list of dependencies and sitting through lectures while they were compiling. Clearly I hadn&#8217;t discovered [homebrew][2] at this point. From what I can tell Qt and it&#8217;s python bindings (pyqt) were added to homebrew around the same time I needed them in 2009, go figure!

## &#8230; This is now!

This week I decided to take the latest Qt for a spin and see what I&#8217;d been missing all these years!

I found their [wiki][3] which points to the official download page where you can get an installer for QtCreator with instructions on how to chmod/run it. This made me feel a bit uncomfortable for a number of reasons (no signed deb/rpm, no https and twas binary so no source and no insight into what the installer actually does).

I thought that it&#8217;d be a nice idea to run the installer inside a container. This isn&#8217;t a perfect buffer from potential threats of executing untrusted code (see security notes below) but at least it&#8217;s a first step.

<img class=" size-full wp-image-163 aligncenter" src="/wp-content/uploads/2015/11/docker_qt.png" alt="docker_qt" width="1973" height="1080" srcset="/wp-content/uploads/2015/11/docker_qt.png 1973w, /wp-content/uploads/2015/11/docker_qt-300x164.png 300w, /wp-content/uploads/2015/11/docker_qt-768x420.png 768w, /wp-content/uploads/2015/11/docker_qt-1024x561.png 1024w" sizes="(max-width: 767px) 89vw, (max-width: 1000px) 54vw, (max-width: 1071px) 543px, 580px" />

Here&#8217;s my plan:

  * Build a base image (qt:base) with all dependencies installed and a copy of the installer.
  * Run installer in container, go through installation wizard, the container should exit when everything is finished.
  * Commit that container to another image (qt:installed).

I hate installation wizards. Maybe I&#8217;ve been spoiled by wealth of scriptable packaging and configuration tools available on Linux. Hopefully as I learn more about how QtCreator works, I&#8217;ll find a way to automate away the configuration steps (hell, I might even find the time to write a Dockerfile that builds it from source so that I can save other people the trouble!)

In the meantime, I&#8217;ll have what I need: an image that I can run QtCreator from whenever I have any GUI development on hand. Lets get to it!

## Building QtCreator inside a container

Here&#8217;s the dockerfile I wrote:

<script src="https://gist.github.com/nicr9/c945194f7f0227eb8c22.js"></script>

Here&#8217;s the commands to get things working:

<script src="https://gist.github.com/nicr9/0b49f576efcf606ee325.js"></script>

## Problems encountered

When I was trying to get this working, there were a few things that broke straight away.

This error in particular appeared straight away and meant that both the installer and QtCreator wouldn&#8217;t accept keyboard input at all:

<pre>xkbcommon: ERROR: failed to add default include path /usr/share/X11/xkb
Qt: Failed to create XKB context!
Use QT_XKB_CONFIG_ROOT environmental variable to provide an additional search path, add ':' as separator to provide several search paths and/or make sure that XKB configuration data directory contains recent enough contents, to update please see http://cgit.freedesktop.org/xkeyboard-config/ .</pre>

When launching QtCreator it also warned me with pop ups about a few libs it couldn&#8217;t find like libxslt and libgstapp.

I was able to solve these problems by adding a few more packages to the list that are installed in the Dockerfile: libxkbcommon-dev, libxcb-xkb-dev, libxslt1-dev and libgstreamer-plugins-base0.10-dev.

## Security Concerns

As for security implications of running untrusted code in a container; Docker is such a fast evolving field right now, it makes it difficult to stay on top of the potential security implications.

My first thought was that it might be a bad idea to execute code using the root inside the container given that it had access to stuff I didn&#8217;t fully understand: /tmp/.X11-unix, /dev/shm and /dev/dri.

To understand the risks a bit better I had to find some reading material.

The docker docs have [a page][4] which gives a broad outline of security concerns. This was a good read but it didn&#8217;t give any hints regarding my own concerns other than I should run as non-root user. I&#8217;ve tried this but I need to find a way to allow installation as non-root user without adding complexity of multiple docker build steps (things are bad enough as they are). I&#8217;d say it just requires some permissions changes inside the container, I&#8217;ll poke around and update here when I&#8217;ve got it working.

Took me a while to find a decent article with details I was looking for, written by someone who knows what they&#8217;re talking about. Stéphane Graber discusses [some of the problems with access to X11 and things in /dev][5] on his blog. Essentially, GUIs running in containers could still eavesdrop on the host while the container is running but when the container is off, nothing you installed in there will continue running. FYI: Examples of eavesdropping permitted by giving untrusted code access to X might include key logging or ability to take screenshots.

If anyone has suggestions regarding container security, please [reach out to me][6]! Container security is a pretty cool topic and I&#8217;m really interested to hear your thoughts!

## More about GUIs in containers

For anyone who hasn&#8217;t seen &#8217;em yet, Jessie Frazelle (a core contributor to Docker) has some great [blog posts][7] and [conference][8] [talks][9] about running GUI applications inside containers! I looked to these to get some inspiration, you should check &#8217;em out too!

Aquameerkat also had a [great article][10] that gives a crash course on the X server, what displays are, and how to run headless GUIs in docker containers for testing purposes (not what I was doing here but interesting all the same!).

 [1]: https://nicroland.wordpress.com/2016/02/27/docker-security-risks-guis-xorg/
 [2]: https://github.com/Homebrew/homebrew
 [3]: https://wiki.qt.io/Install_Qt_5_on_Ubuntu
 [4]: http://docs.docker.com/engine/articles/security/
 [5]: https://www.stgraber.org/2014/02/09/lxc-1-0-gui-in-containers/
 [6]: https://twitter.com/nicr9_
 [7]: https://blog.jessfraz.com/post/docker-containers-on-the-desktop/
 [8]: https://youtu.be/1qlLUf7KtAw
 [9]: https://youtu.be/GsLZz8cZCzc
 [10]: https://linuxmeerkat.wordpress.com/2014/10/17/running-a-gui-application-in-a-docker-container/
