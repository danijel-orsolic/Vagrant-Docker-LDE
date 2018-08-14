This is a simple but powerful way of deploying a local development environment with Docker which supports multiple virtual hosts, and works the same on Windows, Linux, and Mac (thanks to Vagrant).

It consists of a near-default VagrantFile, a few bash scripts for setting up the Docker environment within a VM (prep.sh), and adding new projects (add.sh) as well as a few docker-compose.yml files for some base project options (LEMP stack, LAMP stack, WordPress base).

Benefits:

1. It works the same on Windows, Linux and Mac. Since Vagrant and VirtualBox work on all of them, and the script set runs within the VM, the experience should be identical no matter the base OS. This also avoids the need of using OS-specific stacks like XAMPP, which may have some OS-specific issues.

2. Multiple virtual hosts out of the box. Thanks to nginx-proxy this single VM can host multiple projects each with their own local domain name. 

3. Infinite options of stacks - since each project is a Docker stack they can run whatever you want within them. Just need to modify docker-compose files. Out of the box, all the basics are supported.



