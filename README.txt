This is a simple but powerful way of deploying a local development environment with Docker which supports multiple virtual hosts, and works the same on Windows, Linux, and Mac (thanks to Vagrant).

It consists of a near-default VagrantFile, a few bash scripts for setting up the Docker environment within a VM (prep.sh), and adding new projects (add.sh) as well as a few docker-compose.yml files for some base project options (LEMP stack, LAMP stack, WordPress base).

Benefits:

1. It works the same on Windows, Linux and Mac. Since Vagrant and VirtualBox work on all of them, and the script set runs within the VM, the experience should be identical no matter the base OS. This also avoids the need of using OS-specific stacks like XAMPP, which may have some OS-specific issues.

2. Multiple virtual hosts out of the box. Thanks to nginx-proxy this single VM can host multiple projects each with their own local domain name. 

3. Infinite options of stacks - since each project is a Docker stack they can run whatever you want within them. Just need to modify docker-compose files. Out of the box, all the basics are supported.

REQUIREMENTS:

* Vagrant + VirtualBox
* The VM should run Ubuntu 16.04 or later.


NOTES:

The scripts were first created as a way of deploying a Docker based web hosting environment.

This is why I was working on support for SSH-ing into each app, with each app being assigned a unique available port. 

And that's also why the add.sh script has a "redirector" option, for cases where you just want your server (like a VPS) to redirect a subdomain elsewhere.

I left these in for now because they still might be marginally useful even in the context of local development.

