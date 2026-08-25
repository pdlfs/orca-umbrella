**Download, build, and install ORCA (and its dependencies) in a single step.**

orca-umbrella
=============

## Overview

This package is designed for quickly setting up ORCA on computing platforms ranging from commodity clusters to HPC systems. The package provides an automated CMake-based build that downloads, builds, and installs ORCA together with the dependencies needed by the selected build profile.

ORCA is a real-time observability and control system for HPC applications. ORCA is implemented in C++ and Rust, and uses Apache DataFusion internally for in-situ SQL-style processing. Build profiles select which parts of the ORCA stack and supporting applications are installed.

## Modules

The list of primary modules used by orca-umbrella is selected in `CMakeLists.txt` through `UMBRELLA_PROFILE`. The corresponding package include files live under `umbrella/umbrella`.

Supported profiles:

- `DEPS`: dependencies needed to build ORCA out-of-tree
- `FULL`: ORCA + ORCA utility scripts
- `ADAE`: `FULL` + ORCA-enabled AMR code and guided demo
- `EVAL`: `ADAE` + tracing/evaluation packages
- `XTRA`: `FULL` + packages for experimental ORCA utilities

## Installation

ORCA requires standard build tools including a C/C++ compiler, `make`, `cmake`, `autoconf`, `automake`, `libtool`, `pkg-config`, and `git`, along with a recent Rust toolchain. Rust dependencies including DataFusion will be automatically downloaded by `cargo` during the build. The guided install script can be used to assist with setting up a Rust toolchain if not present. A working MPI installation is also required.

### Ubuntu

On Ubuntu systems, common build requirements can be installed with:

```bash
sudo apt-get install gcc g++ make cmake autoconf automake libtool pkg-config git
```

If using a custom MPI installation, ensure that its compiler wrappers and launcher are on `PATH`, for example:

```bash
export MPI_HOME=/path/to/mpi
export PATH=$MPI_HOME/bin:$PATH
```

### Guided build

After cloning this repository, the guided build script can configure and build ORCA from the local checkout.

```bash
git clone https://github.com/pdlfs/orca-umbrella.git
cd orca-umbrella
./scripts/guided-build.sh
```

### Manual build

To configure and install ORCA manually under a specific prefix:

```bash
mkdir -p $OR_BUILD_DIR $OR_INSTALL_DIR
cd $OR_BUILD_DIR

cmake -DCMAKE_INSTALL_PREFIX=$OR_INSTALL_DIR \
      -DCMAKE_BUILD_TYPE=RelWithDebInfo \
      -DUMBRELLA_PROFILE=<PROFILE> \
      ../

make -j<nproc>
```

A guided ORCA tour is available when the selected profile installs Phoebus.

```bash
<install-prefix>/scripts/run_orca_demo.sh
```

## Using `cache.0`

The source archives provided in `cache.0/` can be used instead of fetching the
corresponding repositories and release archives. Activate them after cloning or
extracting `orca-umbrella`, but before configuring the build:

```bash
mkdir -p cache
cp cache.0/* cache/

# Confirm that the source archives are available to the build.
ls cache
```

CMake will report the detected tar cache directory during configuration and use
matching archives from `cache/`. Cargo-managed Rust dependencies are not included
and still require internet access.

`./scripts/generate-cache.sh` can populate `cache.0/` from an existing umbrella
build tree.

---

### License

The ORCA umbrella build scripts and CMake files are released under the MIT License. See [LICENSE](LICENSE).

Third-party packages downloaded, built, or cached by this project are distributed under their own upstream licenses.

This software was developed, in part, under US government contract 89233218CNA000001, for Los Alamos National Laboratory (LANL), which is operated by Triad National Security, LLC for the US Department of Energy/National Nuclear Security Administration.
