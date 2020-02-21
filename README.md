# shareef12-meta

This project is a debian metapackage intended to configure my personal
development environment.

Pre-built versions are available at my ppa. You can also build and install it
from source.


## Installing from the PPA

Add the ppa and install the `shareef12-desktop` package. Run the installed shell
script to configure user-specific settings.

```
sudo add-apt-repository ppa:shareef12/devenv
sudo apt-get update
sudo apt-get install shareef12-desktop
setup-shareef12-desktop-user
```


## To build and install from source

Build the package with devscripts.

```
sudo apt install devscripts
debuild
```

Install the package with dpkg and use the installed shell script to configure
user-specific settings.

```
sudo dpkg -i ../shareef12-desktop_0.1.0~ubuntu18.04_all.deb
setup-shareef12-desktop-user
```
