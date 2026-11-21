#! /bin/bash
#
# Args:
# --machine <MACHINE>  the board to build for; one with a file in
#                      meta-controller-node/conf/artie-boards/ (default: raspberrypi4-64)
# --insecure-registries <comma-separated list of insecure registries>
# --hosts <comma-separated list of 'address<space>host' entries to add to /etc/hosts>

POSITIONAL_ARGS=()
MACHINE="raspberrypi4-64"

while [[ $# -gt 0 ]]; do
  case $1 in
    -m|--machine)
      MACHINE="$2"
      shift # past argument
      shift # past value
      ;;
    -i|--insecure-registries)
      INSECURE_REGISTRIES="$2"
      shift # past argument
      shift # past value
      ;;
    -h|--hosts)
      HOSTS="$2"
      shift # past argument
      shift # past value
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      shift # past argument
      ;;
  esac
done

echo "Machine: $MACHINE"
echo "Insecure Registries: $INSECURE_REGISTRIES"
echo "Hosts: $HOSTS"

# Only boards with a controller-node configuration are supported.
BOARD_CONF="meta-controller-node/conf/artie-boards/${MACHINE}.conf"
if [[ ! -f "$BOARD_CONF" ]]; then
    echo "Unsupported machine '$MACHINE'. Supported machines:"
    ls meta-controller-node/conf/artie-boards/ | sed 's/\.conf$//; s/^/  /'
    exit 1
fi

# Clone Yocto
if [[ ! -d poky ]]; then
    git clone git://git.yoctoproject.org/poky
    cd poky
    git checkout -t origin/scarthgap -b scarthgap-local
    cd ..
fi

# Set up the build directory
source poky/oe-init-build-env "$PWD"/build
cp "$PWD"/conf/bblayers.ours.conf "$PWD"/conf/bblayers.conf
cp "$PWD"/conf/local.ours.conf "$PWD"/conf/local.conf

# The board, its controller-node configuration, and the build-time inputs meta-artie reads.
cat >> "$PWD"/conf/local.conf <<EOF

#
# Written by setup.sh
#
MACHINE = "${MACHINE}"
require conf/artie-boards/\${MACHINE}.conf
ARTIE_INSECURE_REGISTRIES = "${INSECURE_REGISTRIES}"
ARTIE_EXTRA_HOSTS = "${HOSTS}"
EOF
cd ..

# Download layers
if [[ ! -d meta-raspberrypi ]]; then
    git clone https://github.com/agherzan/meta-raspberrypi
    cd meta-raspberrypi
    git checkout -t origin/scarthgap -b scarthgap-local
    cd ..
fi

if [[ ! -d meta-splash ]]; then
    git clone https://github.com/hamzamac/meta-splash.git
fi

if [[ ! -d meta-openembedded ]]; then
    git clone git://git.openembedded.org/meta-openembedded
    cd meta-openembedded
    git checkout -t origin/scarthgap -b scarthgap-local
    cd ..
fi

if [[ ! -d meta-virtualization ]]; then
    git clone https://git.yoctoproject.org/git/meta-virtualization
    cd meta-virtualization
    git checkout -t origin/scarthgap -b scarthgap-local
    cd ..
fi

# The common Artie layer
if [[ ! -d meta-artie ]]; then
    git clone https://github.com/ArtieBots/meta-artie.git
fi

# Add splash file
cp assets/splash.png meta-splash/recipes-core/psplash/files/logo.png
