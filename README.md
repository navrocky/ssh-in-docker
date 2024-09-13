# Setup reverse SSH connection from Docker container to localhost

This script solves the problem when you have a docker container and want to ssh into it.

1. Run `./setup.sh`
2. Enter password for `root` user inside docker container
3. Enter your user and host name to create ssh tunnel from docker container to your host
4. Execute connection command to establish ssh session from your host inside container
