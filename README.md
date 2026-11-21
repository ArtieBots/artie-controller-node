# Artie Controller Node

The Yocto build for an Artie controller node: the SBC in the robot that runs its low-level
services and joins the k3s cluster.

The Artie Project is an open source developmental robotics platform, research effort, and reference robot.
The documentation, the getting started guide, and the architecture overview live in the main
repository: https://github.com/ArtieBots/Artie

## How it is put together

An Artie Yocto image is built from three kinds of layer:

- [meta-artie](https://github.com/ArtieBots/meta-artie) - what every Artie SBC needs: the `artie`
  distro, the common image class, Artie CLI, Docker, k3s, SSH, networking.
- the board's BSP layer, chosen with `MACHINE` - for example `meta-raspberrypi`.
- `meta-controller-node` (in this repository) - what a controller node needs on top: its images,
  the LED daemon, and, for each supported board, which of its peripherals to turn on.

### Supported boards

A board is supported when it has a file in `meta-controller-node/conf/artie-boards/`, named
after its `MACHINE`:

| MACHINE | Board |
|---|---|
| `raspberrypi4-64` | Raspberry Pi 4B |

Adding a board means:

1. a `meta-controller-node/conf/artie-boards/<MACHINE>.conf` with the peripheral settings
   (UART, I2C, SPI/CAN) in that board's terms,
2. its BSP layer in `build/conf/bblayers.ours.conf` and cloned by `setup.sh`, if it is not
   already there,
3. anything board-specific in a recipe goes under `dynamic-layers/<bsp collection>/`, in
   meta-artie if every Artie image on that board needs it, or here if only a controller node does,
4. a case in `create-img.sh` for how to lay out its SD card image.

## Development

To initialize this repository (which should only be done for developing it - not building Artie),
run the setup script. It pulls all the layers that we need and writes the build configuration
for the chosen board:

```bash
./setup.sh --machine raspberrypi4-64
```

It also takes `--insecure-registries` (comma-separated registries Docker may pull from without
TLS) and `--hosts` (comma-separated `"<address> <host name>"` entries for `/etc/hosts`).

To build the image for development (not release), run `source poky/oe-init-build-env "$PWD"/build` from here
after running the setup script. Then run `bitbake <IMAGE>`, where <IMAGE> is one of:

* core-image-base
* artie-image-dev

To turn the build into an SD card image, run `./create-img.sh --image <IMAGE> --machine <MACHINE>`.
