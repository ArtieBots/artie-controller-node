# Only parsed when meta-raspberrypi is in the build (see BBFILES_DYNAMIC in conf/layer.conf).
# The LED daemon drives the LED through RPi.GPIO, which comes from meta-raspberrypi.
RDEPENDS:${PN} += " rpi-gpio"
