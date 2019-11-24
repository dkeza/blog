---
title: "Raspberry Pi SD card image backup issue"
date: 2019-11-24T19:31:19+02:00
draft: false
staticpage: false
---
For my Raspberry Pi I have many times done backup from SD card to image file.  
But first time when I wanted to actually restore my saved image backup from file on disk to SC card for Raspberry Pi, I expirienced unpleasent suprise:  
I couldn't restore my backup.

<!--more-->

I created backup from 16GB SD card with [Win32 Disk Imager](https://sourceforge.net/projects/win32diskimager/). Later I used [Etcher](https://www.balena.io/etcher/) to restore image to another 16GB SD card. But then Etcher complained that SD card is smaller for 47 MB that image file?!  

After some googling I realized that every SD card has slightly different size because of errors in production.

Solution was to resize Linux partition on SD card with Live CD Linux distribution [Redo Backup and Recovery](https://sourceforge.net/projects/redobackup/). When you boot from USB, exit from started rescue window, and from menu start [GParted](https://gparted.org/) application. You can also use [GParted Live CD](https://gparted.org/livecd.php) to boot from USB and use this program.

Before booting from live USB, put also Raspberry Pi SD card into PC.

I decreased size for 100 MB. Be careful, not to resize partition to part of disk where data is actually written.

Then I used [USB Image Tool](https://www.alexpage.de/usb-image-tool/) to write image file to SD card.  
Here is important in Options tab to turn on check box *Truncate oversize images in device mode*.  
Now I clicked on *Restore* button, and my image file was successfully written to SD card.  
This worked because USB Image Tool doesn't check for SD card size before starting to write image file.

Now I am always using USB Image tool, for creating and restoring images. Before I create image file, I always first reduce size of image for 100 MB (or more).

With this method is also possible to write image file to larger and smaller SD cards, or to reduce image size to 4GB, or less, that is, to also reduce backup file size.

Nowadays is hard to find 4GB and 8GB SD cards, and for smaller Raspberry Pi projects 16GB, 32GB and 64GB SD cards are overkill, but this way we can make smaller backups.