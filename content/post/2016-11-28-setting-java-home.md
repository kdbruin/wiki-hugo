+++
draft = false
tags = [
]
topics = [
]
description = ""
date = "2016-11-28T20:03:26+01:00"
title = "Setting JAVA_HOME Environment Variable"

+++

When using Java GUI applications it is necessary to set the ```JAVA_HOME``` environment variable. However, when added to either ```~/.profile``` or ```~/.bash_profile```, this setting will not be used for GUI applications unless started from a Terminal window.

<!--more-->

To set the ```JAVA_HOME``` environment variable we need to add a LaunchAgent file to start a simple shell script when a user logs in. Place the following lines in ```~/Library/LaunchAgents/com.user.loginscript.plist```:

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
   <key>Label</key>
   <string>com.user.loginscript</string>
   <key>Program</key>
   <string>/path/to/executable/script</string>
   <key>RunAtLoad</key>
   <true/>
</dict>
</plist>
```

In the file change ```/path/to/executable/script``` to the actual startup script. In this script place the following lines:

```
# Set JAVA_HOME is Java is installed
if [ -x /usr/libexec/java_home ]; then
  launchctl setenv JAVA_HOME "$(/usr/libexec/java_home)"
fi
```

Make sure the file is executable.

After the user logs out and in again, open a Terminal window and use

```
echo $JAVA_HOME
```

to check that the environment variable is set.

