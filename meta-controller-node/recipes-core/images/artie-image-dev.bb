SUMMARY = "A console-only image suitable for dev/debug work on Artie. NOT suitable for release."
LICENSE = "MIT"

inherit artie-controller-node-image

IMAGE_INSTALL += " vim \
                   docker-check \
                   docker-compose-file \
                   openssh \
                   systemd-analyze \
                 "
