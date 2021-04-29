usvn
================

#Introduction
It is a container that provides subversion and usvn (web management) with docker.
The files in the container are quarantined from the host side. If you need to save persistent files, use the -v option to mount the host-side directory to:
+ / var / lib / svn

How to use
------
#Installation
Pull the docker image as follows.

    docker pull sharaku / usvn


You can also build your own Docker image.

    git clone https://github.com/sharaku/docker-usvn.git
    cd docker-usvn
    docker build --tag = "$ USER / usvn".

# Quick Start
Run the ldap image.

    docker run -d \
      --name usvn \
      -v / path / to / svn /: / var / lib / svn: rw \
      -p 80:80 \
      sharaku / usvn

# usvn install
After starting, access the following and install.
http: // server IP / install.php
Make the settings as follows. Otherwise, the setting will fail.

1. System Check
    next

2. Language Selection
    Any
    next

3. License Agreement
    Accept the license and go to the next

4. USVN Configuration
    * All default values
    next

5. Database Installation
    Database type: PDO SqLite
    Database: /usr/local/src/usvn-1.0.10/files/usvn.db
    next

6. Administrator User Creation
    Arbitrary setting
    next

7. Check for a Newer Version
    Arbitrary setting
    next

8. Installation is complete
    Connect to USVN

## Argument

+ `USVN_SUBDIR`:
    Specify a subdirectory of the URL. By default there are no subdirectories.
    The specification should start with / and not end with /, such as `USVN_SUBDIR = / usvn`.
    If you set `USVN_SUBDIR = / usvn`,` http: // server IP / usvn / `will be the current directory.
    Please use it when operating as a subdirectory using a reverse proxy.

## When operating as a subdirectory

This is an example of operating under the following conditions.

+ Server IP 192.168.1.100
+ Operation directory http://192.168.1.100/usvn
+ Persistent directory / var / lib / usvn

    docker run -d \
      --name usvn \
      -v / var / lib / usvn: / var / lib / svn: rw \
      -e USVN_SUBDIR = / usvn \
      -p 80:80 \
      sharaku / usvn

# Limitations
+ Persistent data used once executed cannot be moved to another subdirectory
In the directory to be made persistent, the setting of which subdirectory to operate is described.
Currently, it does not have a conversion function, so it cannot be operated in another subdirectory as it is.
To make it a different subdirectory, you need to change the setting information in the config directory in the persistent directory.

# TODO
+ LDAP connection is not successful, so investigation is required