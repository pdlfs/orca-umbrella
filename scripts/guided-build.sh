#!/usr/bin/env bash

set -eu

# message: print an info line
message() {
    echo "-INFO- $@"
}

# die: print an error line and exit non-zero
die() {
    echo "-ERROR- $@" >&2
    exit 1
}

# check_basic_build_tools: ensure standard build tools are available
check_basic_build_tools() {
    local cmd
    local missing=""

    for cmd in gcc g++ make autoconf automake libtool pkg-config git; do
        message "Checking if ${cmd} is available"
        command -v "$cmd" >/dev/null 2>&1 || missing="${missing} ${cmd}"
    done

    if [ -n "$missing" ]; then
        message "Missing basic build tools:${missing}"
        message "On Ubuntu/Debian, install with:"
        message "  sudo apt-get install gcc g++ make cmake autoconf automake libtool pkg-config git"
        return 1
    fi
}

# ensure_cmake_present: ensure cmake is present, warn on unsupported version
ensure_cmake_present() {
    local version
    local major
    local minor
    local reply

    command -v cmake >/dev/null 2>&1 || die "cmake not found on PATH"
    version=$(cmake --version | awk 'NR==1 {print $3}')
    major=${version%%.*}
    minor=${version#*.}
    minor=${minor%%.*}

    if [ "$major" -eq 3 ] && [ "$minor" -ge 22 ]; then
        message "cmake: $(command -v cmake) (${version})"
        return 0
    fi

    message "CMake version check did not pass."
    message "Detected: $(cmake --version | head -1)"
    message "Expected: cmake >= 3.22 and < 4"
    read -r -p "  Continue anyway? [y/N]: " reply

    case "$reply" in
        y|Y|yes|YES)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# check_mpi_present: ensure mpicc and mpirun are on PATH
check_mpi_present() {
    command -v mpicc  >/dev/null 2>&1 || return 1
    command -v mpirun >/dev/null 2>&1 || return 1
    message "mpicc:  $(command -v mpicc)"
    message "mpirun: $(command -v mpirun)"
}

# check_rust_present: ensure cargo and rustc are on PATH
check_rust_present() {
    command -v cargo >/dev/null 2>&1 || return 1
    command -v rustc >/dev/null 2>&1 || return 1
    message "cargo: $(command -v cargo) ($(cargo --version 2>/dev/null))"
    message "rustc: $(command -v rustc) ($(rustc --version 2>/dev/null))"
}

# check_python_polars_present: ensure python and polars are available
check_python_polars_present() {
    command -v python >/dev/null 2>&1 || return 1
    python -c "import polars" >/dev/null 2>&1 || return 1
    message "python: $(command -v python)"
    message "polars: available"
}

# setup_python_polars_tmpenv: install uv and polars into a temporary env
setup_python_polars_tmpenv() {
    local user=${USER:-$(id -un)}
    local pyroot=${ORCA_PYENV_ROOT:-/tmp/orca-python.${user}}
    local uv_dir="${pyroot}/uv"
    local uv_bin="${uv_dir}/uv"
    local venv_dir="${pyroot}/venv"
    local uv_installer="${pyroot}/install-uv.sh"

    command -v curl >/dev/null 2>&1 || die "curl not found; needed to download uv"

    mkdir -p "${pyroot}" "${uv_dir}"

    if [ ! -x "${uv_bin}" ]; then
        message "Downloading uv into ${uv_dir}"
        curl -LsSf https://astral.sh/uv/install.sh -o "${uv_installer}"
        UV_INSTALL_DIR="${uv_dir}" sh "${uv_installer}"
    fi

    [ -x "${uv_bin}" ] || die "uv install failed: ${uv_bin} not found"

    message "Creating temporary Python environment: ${venv_dir}"
    "${uv_bin}" venv "${venv_dir}"
    "${uv_bin}" pip install --python "${venv_dir}/bin/python" polars

    PATH="${venv_dir}/bin:${PATH}"
    export PATH

    message "Temporary Python env active for this build script."
    message "For later demo runs, activate it with:"
    message "  source ${venv_dir}/bin/activate"

    check_python_polars_present
}

# ensure_python_polars_present: ensure python/polars exists, optionally creating a temp env
ensure_python_polars_present() {
    local reply

    check_python_polars_present && return 0

    message "python/polars not found."
    message "Polars is needed for demo trace analytics."
    message "This script can create a temporary Python env under \${ORCA_PYENV_ROOT:-/tmp/orca-python.\$USER}."
    message "This may download uv, Python, and polars."
    read -r -p "  Create temporary Python environment now? [y/N]: " reply

    case "$reply" in
        y|Y|yes|YES)
            setup_python_polars_tmpenv
            ;;
        *)
            return 1
            ;;
    esac
}

# install_rust: install a rust toolchain via rustup
install_rust() {
    message "Installing Rust stable via rustup"
    message "Rust will be installed under \$HOME/.cargo and \$HOME/.rustup"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
    # shellcheck disable=SC1091
    . "${HOME}/.cargo/env"
    message "rustc: $(rustc --version)"
}

# ensure_rust_present: ensure rust exists, optionally installing it
ensure_rust_present() {
    local reply

    check_rust_present && return 0

    message "Rust not found."
    message "You can install Rust yourself and rerun this script."
    message "Or this script can install Rust stable via rustup under \$HOME/.cargo and \$HOME/.rustup."
    read -r -p "  Install Rust stable now? [y/N]: " reply

    case "$reply" in
        y|Y|yes|YES)
            install_rust
            check_rust_present
            ;;
        *)
            return 1
            ;;
    esac
}

# perform_checks: run all environment preflight checks (read-only)
perform_checks() {
    message "Running preflight checks"
    check_basic_build_tools || die "Missing basic build tools"
    ensure_cmake_present || die "Aborting due to CMake version check"
    check_mpi_present || die "MPI not found; export MPI_HOME and PATH=\$MPI_HOME/bin:\$PATH"
    ensure_python_polars_present || die "python/polars not found; install polars or create a temporary env"
    ensure_rust_present || die "Rust not found; install Rust and source \$HOME/.cargo/env"
}

# prompt_var: iteratively configure a variable
prompt_var() {
    local var_name=$1
    local default_value=$2
    local desc=$3
    local cur_value=${!var_name:-$default_value}
    local new_value

    echo
    message "Configuring ${var_name} (desc: ${desc})"
    echo

    while true; do
        printf -- "-INFO- Currently %s=%s. [Press ENTER to accept, or new value to update]\n" "$var_name" "$cur_value"
        read -r -p " ${var_name}=" new_value

        if [ -z "$new_value" ]; then
            printf -v "$var_name" '%s' "$cur_value"
            return
        fi

        cur_value=$new_value
        printf -v "$var_name" '%s' "$cur_value"
    done
}

# prompt_umbrella_profile: select CMake UMBRELLA_PROFILE
prompt_umbrella_profile() {
    local reply

    echo
    message "Select umbrella build profile"
    echo "  1. DEPS - Dependencies needed to build ORCA out-of-tree"
    echo "  2. FULL - ORCA + ORCA utils"
    echo "  3. ADAE - FULL + AD/AE AMR code and demo artifacts"
    echo "  4. EVAL - ADAE + tracing/evaluation packages"
    echo "  5. XTRA - FULL + experimental ORCA utility packages"
    echo
    read -r -p "  Build profile [1-5, default: 3]: " reply

    case "${reply:-3}" in
        1) UMBRELLA_PROFILE=DEPS ;;
        2) UMBRELLA_PROFILE=FULL ;;
        3) UMBRELLA_PROFILE=ADAE ;;
        4) UMBRELLA_PROFILE=EVAL ;;
        5) UMBRELLA_PROFILE=XTRA ;;
        *) die "Invalid build profile: ${reply}" ;;
    esac

    message "Selected build profile: ${UMBRELLA_PROFILE}"
}

# detect_umbrella_root: walk upward from this script to find orca-umbrella root
detect_umbrella_root() {
    local script_dir
    local cur

    script_dir=$(dirname "$(realpath "$0")")
    cur=$script_dir

    while [ "$cur" != "/" ]; do
        if [ -f "$cur/CMakeLists.txt" ] && [ -f "$cur/umbrella/umbrella-init.cmake" ]; then
            printf "%s\n" "$cur"
            return 0
        fi
        cur=$(dirname "$cur")
    done

    return 1
}

# main: guided configure + build of the local orca-umbrella tree
main() {
    local UMBRELLA_ROOT
    local BUILD_PREFIX
    local INSTALL_PREFIX
    local UMBRELLA_PROFILE
    local BUILD_JOBS

    message "ORCA umbrella guided build"
    cat <<EOF

This script configures and builds ORCA from the local orca-umbrella checkout.
Estimated time: 20 minutes, but variable.

If running demos across multiple nodes, set the install prefix to a shared path.
For a single-node demo, the install prefix does not need to be shared.

EOF
    perform_checks

    UMBRELLA_ROOT=$(detect_umbrella_root) || die "Could not detect orca-umbrella root from script path"
    message "Umbrella root: ${UMBRELLA_ROOT}"

    prompt_var BUILD_PREFIX   "${UMBRELLA_ROOT}/build"   "CMake build directory"
    prompt_var INSTALL_PREFIX "${UMBRELLA_ROOT}/install" "ORCA install prefix"
    prompt_var BUILD_JOBS     "16"                       "parallel build jobs"
    prompt_umbrella_profile

    mkdir -p "${BUILD_PREFIX}" "${INSTALL_PREFIX}"

    message "Configuring (install prefix: ${INSTALL_PREFIX}, profile: ${UMBRELLA_PROFILE})"
    ( cd "${BUILD_PREFIX}" && cmake -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" -DUMBRELLA_PROFILE="${UMBRELLA_PROFILE}" "${UMBRELLA_ROOT}" )

    message "Building with make -j${BUILD_JOBS}"
    ( cd "${BUILD_PREFIX}" && /usr/bin/make -j"${BUILD_JOBS}" )

    message "Done. Install: ${INSTALL_PREFIX}"
}

main
