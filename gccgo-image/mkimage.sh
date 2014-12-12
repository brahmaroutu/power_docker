#!/bin/bash

# Install debootstrap
#   Ubuntu/Debian: apt-get install debootstrap
#   Fedora: yum install debootstrap

set -xe

case `uname -m` in
  x86_64|ppc64le) 
    repo=ubuntu
    tag=trusty
    opt=("--components=main,universe")
    arg=()
    ;;
  s390x)
    repo=debian
    tag=wheezy
    opt=()
    arg=()
    ;;
  ppc64)
    repo=debian
    tag=sid
    opt=("--no-check-gpg")
    arg=("http://ftp.de.debian.org/debian-ports")
esac

baseimg=$(docker images "$repo" | awk "\$2 == \"$tag\" { print \$3 }")

if [ -z "$baseimg" ]; then
  sudo ./debootstrap.sh "$repo" ${opt[@]} "$tag" ${arg[@]}
  if [ `uname -m` = "ppc64" ]; then
    sudo chroot "$repo" apt-get install -y --force-yes debian-ports-archive-keyring
    sudo chroot "$repo" apt-get update -y
  fi 
  sudo tar -C "$repo" -c . | docker import - "$repo:$tag"
  sudo rm -fr "$repo"
fi

sudo docker tag -f "$repo:$tag" gccgo-base-image
sudo docker build -t gccgo-image . 
sudo docker rmi gccgo-base-image
