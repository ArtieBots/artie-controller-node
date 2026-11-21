# artie-controller-node - Agent Guidelines

## Overview

This repository contains the Yocto build configuration for the Artie controller node - the SBC
in the robot that runs its low‑level services and the k3s compute agent. It builds on
[meta-artie](https://github.com/ArtieBots/meta-artie), the layer every Artie image shares, and
does not assume a particular board: the board is chosen with `MACHINE`.

## Layer Structure

- `meta-controller-node/` - the controller node's layer, on top of meta-artie:
  - `classes/artie-controller-node-image.bbclass` - the controller node's image base
    (meta-artie's `artie-image`, plus the LED daemon).
  - `recipes-core/images/` - `artie-image-dev` and `artie-image-release`.
  - `recipes-apps/` - packages only a controller node needs (the LED daemon, the dev compose file).
  - `conf/artie-boards/<MACHINE>.conf` - one per supported board: which peripherals the
    controller node needs on it, in that board's terms. Its presence is what makes a board
    supported.
  - `dynamic-layers/<bsp collection>/` - board-specific appends, parsed only when that BSP layer
    is in the build.
- `build/conf/` - templates for `bblayers.conf` and `local.conf`, which `setup.sh` copies and
  completes.

Anything every Artie image needs belongs in meta-artie, not here.

## Build Process

TODO: Migrate to kas instead of the hand-rolled scripts for managing the build

```bash
./setup.sh --machine raspberrypi4-64   # pull required layers, write the build config
source poky/oe-init-build-env "$PWD"/build
bitbake artie-image-dev   # development image
bitbake artie-image-release  # production image
./create-img.sh --image artie-image-dev --machine raspberrypi4-64   # SD card image
```

## Key Recipes

- `artie-image-dev.bb` – includes debugging tools and source code.
- `artie-image-release.bb` – minimal image for deployment.
- `led‑daemon_0.1.bb` – systemd service controlling status LEDs.

## Development

- Add new packages by creating a `.bb` or `.bbappend` in the appropriate `recipes-*` directory.
- Never assume a board outside `conf/artie-boards/` and `dynamic-layers/`.
- Never write generated files into a layer; build-time inputs are variables in `local.conf`
  (`setup.sh` writes `MACHINE`, `ARTIE_INSECURE_REGISTRIES` and `ARTIE_EXTRA_HOSTS`).
- Keep `meta-controller-node/conf/layer.conf` up‑to‑date with any new dependencies.
- Run `bitbake -c devshell <recipe>` for interactive debugging.

## Contribution Guidelines

- All changes must be testable with `bitbake -c check` or by building the image.
- Document new recipes in `README.md` and, if user‑facing, in `docs/` (currently none).
- Follow Yocto Project coding style (use `LICENSE` headers, avoid absolute paths).
