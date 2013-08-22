Instant Drupal
=============

Vagrant and puppet team up to spin up a brand new instance of a Drupal web server.

Use Virtual machines to isolate your development environment.  Abstract project
dependencies to the VMs and leave your host stable and productive.  

Host Requirements
-----------

### [Virtual Box][2]


VirtualBox is a virtualization software to provide the work
horse of the virtual machine operations and isolation of environments
and resources.

### [Vagrant][2]


Vagrant is a virtualization utility to provide an easier to use
command line interface that uses a configuration file to assist
with how a virtual machine is built and set up.

Installation
------------

Clone the repo into your home directory. Commands issued in this directory 
will be executed against the configuration and the VM that spawns from it.

```bash
git clone git@github.com:MFoster/instantdrupal.git 
```

Now change into the newly created directory and issue the 
vagrant up commands

```bash
cd instantdrupal
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

You'll see 3 network devices, but the second device is typically the public interface. 
It will have an address like 192.168 or 172.10.

Once you've obtained the IP, you can set up a local domain for it or just 
plug the IP into your browser.


Run through the Drupal Installation wizard and configure your new Drupal Web Server.

The default configurations for the database are...

```yml
database: drupal
username: drupal_user
password: time2shine
```

Shared Folder on Host
---------------------

After the installation is up and running you will see a new folder in your instantdrupal directory.
The directory "www" is a shared folder pointing at the guest's /home/vagrant/www directory.  This is where
the drupal source code gets downloaded and stashed.

To begin editing your Drupal installation, point your IDE to instantdrupal/www/${drupalversion} and you
should be looking at your freshly downloaded copy of whatever drupal version you have configured, defaults to 
drupal-7.23.

[1]: http://www.vagrantup.com/                      "Vagrant"
[2]: https://www.virtualbox.org/wiki/Downloads      "VirtualBox"
[3]: http://files.vagrantup.com/lucid64.box         "Download Lucid 64"
[4]: http://docs.vagrantup.com/v2/boxes.html        "Vagrant Install Box"
