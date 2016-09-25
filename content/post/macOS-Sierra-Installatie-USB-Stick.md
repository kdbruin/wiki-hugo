+++
date = "2016-09-25T18:12:40+02:00"
description = ""
tags = []
title = "macOS Sierra Installatie USB Stick"
topics = []

+++

## Download de macOS installer

Via de Mac App Store moet je eerst het installatie programma van macOS Sierra downloaden. Wanneer de download klaar is, zal het installatie programma automatisch opstarten. Stop nu het installatie programma voordat je verder gaat.

## Voorbereiden USB stick

De USB stick moet minimaal 8GB groot zijn. Plaats de USB stick in de computer en gebruik Disk Utility om deze te formatteren en een naam te geven, bijvoorbeeld "Install macOS Sierra".

## macOS Sierra bootable USB stick maken

Gebruik het volgende commando (op 1 regel) om het installatie programma op de USB stick te plaatsen:

```
sudo /Applications/Install\ macOS\ Sierra.app/Contents/Resources/createinstallmedia
        --volume /Volumes/Install\ macOS\ Sierra
        --applicationpath /Applications/Install\ macOS\ Sierra.app
        --nointeraction
```

