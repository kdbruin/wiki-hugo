+++
date = "2016-09-25T18:12:40+02:00"
description = ""
tags = []
title = "macOS Sierra Installation USB Stick"
topics = []
series = ["macOS Sierra"]

+++

Having a bootable USB stick with the latest operating system installer ready makes system maintenance a lot easier. Installation on multiple computers requires only a single download of the installer and also a clean install is much easier to perform. In this article I describe how you can create such a bootable USB stick.

<!--more-->

## Download the macOS installer

First download the macOS Sierra Installer from the Mac App Store. When the download is finished the installer will start automatically. Just quit the installation before continuing.

## Prepare the USB stick

The minimal required size of the USB stick is 8GB. Plug the USB stick into the computer and use Disk Utility to format and name the stick. In this example we will be using "os-install".

## Create the macOS Sierra bootable USB stick

Open a Terminal window and use the following command (on a single line) to place the installation program on the USB stick:

```
sudo /Applications/Install\ macOS\ Sierra.app/Contents/Resources/createinstallmedia
        --volume /Volumes/os-install
        --applicationpath /Applications/Install\ macOS\ Sierra.app
        --nointeraction
```

When the process is finished the bootable USB stick with the macOS Sierra installer is ready to use. In Finder the USB stick will be identified as "Install macOS Sierra".

## Start the installation

To perform a clean install execute the following steps:

 * Place the USB stick in the computer to update
 * Start the computer keep the <span class="key">option</span> key pressed
 * Choose the bootable USB stick to start the system
 * Choose a clean install

Source (in Dutch): [macOS Sierra: Een installatie USB stick maken](https://www.appletips.nl/bootable-usb-stick-macos-sierra/)
