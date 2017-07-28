+++
date = "2017-07-28T11:53:26+02:00"
title = "Open with Visual Studio Code"
tags = []
topics = []
description = ""
+++

On Windows it is possible to select a file or folder and from the context menu open this in Visual Studio Code. For macOS we need to add this functionality ourselves.

<!--more-->

However, it is very simple using the following steps:

1. Start Automator
1. Create a new Service
1. Change "Service Receives" to "files or folders" in "Finder"
1. Add a "Run Shell Script" action
1. Change "Pass input" to "as arguments" 
1. Paste the following in the shell script box: ```open -n -b "com.microsoft.VSCode" --args "$*"```
1. Save it as something like "Open in Visual Studio Code"

And that's it.

Found this snippet [here](https://gist.github.com/tonysneed/f9f09bfa28bcf98e8d8306f9b21f99e2).