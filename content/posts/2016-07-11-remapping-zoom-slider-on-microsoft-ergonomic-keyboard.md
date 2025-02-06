---
title: Remapping zoom slider on Microsoft Ergonomic Keyboard
author: nicr9
type: post
date: 2016-07-11T14:39:07+00:00
url: /2016/07/11/remapping-zoom-slider-on-microsoft-ergonomic-keyboard/
tags:
  - lifehacks
  - linux
---

I'm a big fan of Microsoft's "Natural Ergonomic Keyboard 4000". I'm just not a fan of it's name, it's a mouthful! (How about for future reference we just call it the Ergo?)

![](/wp-content/uploads/2016/07/b112ddfc-0541-4948-a804-a7268b0cc2a7.jpg)

The Ergo's great for typing on and also has a selection of feature keys that you can key-map to. Depending on your distro/desktop environment, you can map keys for all sorts of reasons: to replace caps lock with ctrl, control your music player, to run scripts, etc. There's plenty of guides about remapping keys around so I won't talk too much about that here. Google around and if you have questions [askubuntu.com][1] is [a great][2] place [to find answers][3]. What I'm interested in is getting the zoom slider working!

The zoom slider sits above the space bar and between the two primary sets of keys. It's a spring-loaded rocker switch and button that's supposed to be used to zoom in/out (I've never used it in Windows so I've never actually seen it in action). I thought it'd be cool to remap but it doesn't seem to work like the other keys. Turns out it needs a little fiddling.

## Enabling the zoom slider

When I try to use it, the zoom slider just seems to be totally ignored. I believe this is because they're custom keys created specifically for (and supported only by) Windows. They have no analogue in Linux. To get them working we'll have tell Linux that they're equivalent to some other keys.

This is where `udev` steps in. We need to write rules to interpret these as keys and put em into the hardware database. Easy! Create a new set of keyboard rules like so:

```bash
$ sudo mkdir /etc/udev/hwdb.d
$ sudo vim /etc/udev/hwdb.d/61-keyboard-local.hwdb
```

And add this:

```
keyboard:usb:v045Ep00DB*
keyboard:usb:v045Ep071D*
 KEYBOARD_KEY_0c022d=pageup
 KEYBOARD_KEY_0c022e=pagedown
```

`hwdb` rules are grouped together by device. The first two lines here identify two different models of Ergo (the 4000 and the 7000) that our block of rules will apply to. It's pretty obvious that these are for targeting USB keyboards but what is the set of seemingly random characters near the end? They are for matching specific devices by vendor/product code, they follow the pattern `v<vendor_code>p<product_code>`.

How could you be certain that your device will match this code? You can check your keyboard's code by running:

```bash
$ lsusb | grep Ergo | awk '{print $6}'
```

It should appear in the form `<vender>:<product>`. For my keyboard I get `045e:00db` which matches the first line of the example as expected.

The next two lines (each indented with a single space) are the rules to tell `udev` which scan codes map to which buttons. In this case we're telling `udev` that the slider keys (scan code `0c022d` and `0c022e`) are supposed to map to `pageup` and `pagedown` respectively.

For these rules to take effect, you'll need to recompile the `hwdb` and reload `udev`:

```bash
$ sudo udevadm hwdb --update
$ sudo udevadm control --reload
```

At this point you might need to plug the keyboard out/in to get it to work.

## Identifying other keys and scan codes

Okay that's great if all you wanna do is page up or down. Where do you go to find the names of other keys to map to? They're all listed (in upper case with `KEY_` as a prefix) in `/usr/include/linux/input-event-codes.h`.

If you want to write `udev` rules for other keys you'll need a way to identify key scan codes. For that we'll use `evtest`.

```bash
$ evtest /dev/input/event0
```

When this is running you can move the slider up and down and it should post event logs like this:

```
Event: time 1468247448.373417, type 4 (EV_MSC), code 4 (MSC_SCAN), value c022e
Event: time 1468247448.373417, type 1 (EV_KEY), code 109 (KEY_PAGEDOWN), value 0
```

If it doesn't, kill it with `CTRL+C` and try the next event file (`/dev/input/event1`) and keep going until you get these kind of logs (for me it was event10).

**UPDATE: **A friend of mine pointed out (in the comments below) that you don't need to step through each of the devices manually. You can run `sudo evtest` without any arguments and it will display all devices as a list with short descriptions for you to choose from by simply entering the device number.

The first line in each event will be the scan code (`MSC_SCAN`) and the value listed (`c022e`) is the scan code.

## Suggested Fixes

Depending on what distro of Linux you're using, you might need to tweak the rules a bit. The ones I've shown above worked fine for me with Ubuntu 12.04. I've also had success getting them working with CentOS 7. Here's two suggested changes if you run into trouble.

In newer versions of Ubuntu (15.01+) you might need to change the device matching rule to include a bus number (a four digit code, 0003 for USB devices). Here's an example:

```
keyboard:usb:b0003v045Ep00DB*
```

In the example the scan codes started with a zero. Sometimes this doesn't work (but I've no idea why). Try it out without the leading zero, like so:

```
KEYBOARD_KEY_c022d=pageup
```

## Footnotes

  1. Originally got this working by reading [this askubuntu question][4].
  2. Learned about `hwdb` was by reading [the man page][5].
  3. Got some of the nitty gritty details of how to write hwdb rules by reading [this Arch wiki page][6].
  4. To figure out how to use evtest I used [this guide][7].

 [1]: https://askubuntu.com/
 [2]: https://askubuntu.com/questions/24916/how-do-i-remap-certain-keys-or-devices
 [3]: https://askubuntu.com/questions/296155/how-can-i-remap-keyboard-keys
 [4]: https://askubuntu.com/questions/471802/make-the-zoom-slider-of-microsoft-natural-ergonomic-keyboard-4000-and-7000-scrol
 [5]: https://www.freedesktop.org/software/systemd/man/hwdb.html
 [6]: https://wiki.archlinux.org/index.php/Map_scancodes_to_keycodes
 [7]: https://shkspr.mobi/blog/2011/12/changing-the-microsoft-4000s-zoom-keys-in-ubuntu/
