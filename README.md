Instant Drupal
=============

Vagrant and puppet team up to spin up a brand new instance of a Drupal web server.

Use Virtual machines to isolate your development environment.  Abstract project
dependencies to the VMs and leave your host stable and productive.  

Host Requirements
-----------

### Virtual Box


VirtualBox is a virtualization software to provide the work
horse of the virtual machine operations and isolation of environments
and resources.

### Vagrant


Vagrant is a virtualization utility to provide an easier to use
command line interface that uses a configuration file to assist
with how a virtual machine is built and set up.

### Lucid Box


The vagrant configuration file in this repo uses "lucid64" as it's box.
This box is provided at the vagrant site.  Follow the instructions there
to download the box and to add it to your vagrant registry.

Installation
------------

Clone the repo into your home directory.  The repo is actually going to be your
"vagrant directory". Commands issued in this directory will be executed
against the configuration and the VM that spawns from it.

```bash
git clone git@github.com:MFoster/instantdrupal.git 
```

Now change into the newly created directory and issue the 
vagrant up commands

```bash
cd instandrupal
vagrant up
```

The vagrant configuration file is set up to use a bridged network, meaning the VM
will attach directly to your host's network.  This is useful because now
everyone on the network can send this machine HTTP requests.  

But we don't know what that IP has been set to, we have to SSH
into the machine and find out.

```bash
vagrant ssh
ifconfig
```

You'll see 3 network devices, one will be 10.0.0.X and another will be the loopback, 127.0.0.1 but
the second device is typically the public interface.  It will have an
address like 192.168 or 172.10.

Once you've obtained the IP, you can set up a local domain for it or just 
plug the IP into your browser.


Run through the Drupal Installation wizard and configure your new Drupal Web Server.

The default configurations for the database are...

```yml
database: drupal
username: drupal_user
password: time2shine
```

