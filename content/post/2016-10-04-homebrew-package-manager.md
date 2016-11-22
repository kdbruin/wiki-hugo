+++
date = "2016-10-04T12:11:53+02:00"
description = ""
tags = []
title = "Homebrew Package Manager"
topics = []

+++

Although macOS comes with a large array of applications and utility programs, several essential developer tools are missing or out of date. Several solutions exist to remedy this and I prefer to use [Homebrew](http://brew.sh) to add those programs to the system.

<!--more-->

## Installation

Installation of Homebrew is very simple. Just execute the following command in a Terminal window:

```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Follow the directions on the screen and the Homebrew package manager will be installed.

## What packages to install?

At least the following packages need to be installed:

* ```homebrew/dupes/rsync```
* ```wget```
* ```python```

To keep this website up to date it is also necessary to install the ```hugo``` package.
