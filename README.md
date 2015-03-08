# Docker-friendly Vagrant base boxes

<img src="http://blog.phusion.nl/wp-content/uploads/2013/11/vagrant.png" height="150">
<img src="http://blog.phusion.nl/wp-content/uploads/2013/11/docker.png" height="150">

This repository contains definitions for various Docker-friendly [Vagrant](http://www.vagrantup.com/) base boxes. There are boxes that are based on Ubuntu 12.04 64-bit, and boxes that are based on Ubuntu 14.04 64-bit. They reuse a lot of the hard work that the good people from [Phusion have created with their open-vagrant-boxes](https://github.com/phusion/open-vagrant-boxes) and differs only in that we install salt and a few extra packages (such as python dev tools, and the JDK).

 * We provide 2 virtual CPUs by default, so that the boxes can make better use of multicore hosts.
 * We provide more RAM by default: 1 GB.
 * We provide a bigger virtual hard disk: around 40 GB.
 * We use LVM so that partitioning is easier.
 * On the Ubuntu 12.04 version, our default kernel version is 3.13 (instead of 3.2), so that you can use [Docker](http://www.docker.io/) out-of-the-box.
 * [The memory cgroup and swap accounting](http://docs.docker.io/en/latest/installation/ubuntulinux/#memory-and-swap-accounting) are turned on, for some Docker features.
 * Chef is installed via the Ubuntu packages that they provide, instead of via RubyGems. This way the box doesn't have to come with Ruby by default, making the environment cleaner.
 * Our VMWare Fusion boxes recompile VMWare Tools on every kernel upgrade, so that Shared Folders keep working even if you change the kernel.

These base boxes are automatically built from [Veewee](https://github.com/jedi4ever/veewee) definitions. These definitions make building boxes quick and unambigious. The entire building process is described in the definitions; no manual intervention is required.


## Using these boxes in Vagrant

If you have Vagrant 1.5, you can use our boxes through [Vagrant Cloud](https://vagrantcloud.com/mojdigital):

    vagrant init mojdigital/ubuntu-14.04-amd64
    # -OR-
    vagrant init mojdigital/ubuntu-12.04-amd64

You can login with username `vagrant` and password `vagrant`. This user has sudo privileges. The root user also has password `vagrant`.

## Building the boxes yourself

### Setup your environment

 1. Install [Vagrant](http://www.vagrantup.com/).
 2. Install [VirtualBox](https://www.virtualbox.org/) or VMWare Fusion.
 3. Install 7-zip (OS X: `brew install p7zip`).
 4. `bundle install --path vendor`

    The `--path` is important! Not installing with `--path` will break Vagrant.

### Building a box and importing it into Vagrant

VirtualBox:

    bundle exec rake virtualbox:ubuntu-14.04-amd64:all
    bundle exec rake virtualbox:ubuntu-12.04-amd64:all

VMWare Fusion:

    bundle exec rake vmware_fusion:ubuntu-14.04-amd64:all
    bundle exec rake vmware_fusion:ubuntu-12.04-amd64:all
