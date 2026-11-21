# The base of the controller node images: meta-artie's common image, plus what a controller
# node needs on top.

inherit artie-image

SUMMARY = "The base image all the artie-controller-node images are based on."

IMAGE_INSTALL += " led-daemon \
                 "
