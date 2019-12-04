FROM ubuntu:18.04
MAINTAINER Swind <swind@code-life.info>

# No interactive frontend during docker build
ENV DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true

RUN apt-get update -y && \
    apt-get install -y \
            binutils \
            debootstrap \
            squashfs-tools \
            xorriso \
            grub-pc-bin \
            grub-efi-amd64-bin \
            mtools \
            unzip \
            dosfstools
