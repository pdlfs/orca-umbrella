#!/usr/bin/env bash

set -eu

CACHE_DIR=cache.0

# message: print an info line
message() {
    echo "-INFO- $@"
}

# die: print an error line and exit non-zero
die() {
    echo "-ERROR- $@" >&2
    exit 1
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

# prompt_build_dir: read and validate build directory
prompt_build_dir() {
    read -r -p "Build directory: " BUILD_DIR
    [ -d "$BUILD_DIR" ] || die "Build dir not found: $BUILD_DIR"
    [ -f "$BUILD_DIR/CMakeCache.txt" ] || die "CMakeCache.txt not found under: $BUILD_DIR"
    check_prefix_dirs_present "$BUILD_DIR" || die "No *-prefix dirs found under: $BUILD_DIR"
}

# check_prefix_dirs_present: true if build dir contains at least one *-prefix dir
check_prefix_dirs_present() {
    local build_dir=$1
    local prefix_dir

    for prefix_dir in "$build_dir"/*-prefix; do
        [ -d "$prefix_dir" ] || continue
        return 0
    done

    return 1
}

# get_cache_tar_name: read expected cache tar filename for one target from CMakeCache.txt
get_cache_tar_name() {
    local dep_name=$1
    local cache_file="$BUILD_DIR/CMakeCache.txt"
    local var_prefix
    local tar_name

    var_prefix=$(printf "%s" "$dep_name" | tr '[:lower:]' '[:upper:]' | tr '-' '_')

    tar_name=$(sed -n "s/^${var_prefix}_TAR:[^=]*=//p" "$cache_file" | head -1)
    if [ -z "$tar_name" ]; then
        tar_name=$(sed -n "s/^${var_prefix}_URLFILE:[^=]*=//p" "$cache_file" | head -1)
    fi

    [ -n "$tar_name" ] || return 1
    printf "%s\n" "$tar_name"
}

# cache_one_prefix: package one ExternalProject source checkout into cache.0
cache_one_prefix() {
    local prefix_dir=$1
    local dep_name
    local src_dir
    local tar_name
    local tar_path

    [ -d "$prefix_dir" ] || die "Prefix dir not found: $prefix_dir"

    dep_name=$(basename "$prefix_dir")
    dep_name=${dep_name%-prefix}
    src_dir="$prefix_dir/src/$dep_name"
    tar_name=$(get_cache_tar_name "$dep_name") || die "No ${dep_name} cache tar variable found in $BUILD_DIR/CMakeCache.txt"
    tar_path="$CACHE_DIR/$tar_name"

    [ -d "$src_dir" ] || die "Source dir not found: $src_dir"

    mkdir -p "$CACHE_DIR"

    message "Caching ${dep_name}: ${src_dir} -> ${tar_path}"
    tar \
        --exclude='.git' \
        --exclude='.github' \
        --exclude='.gitmodules' \
        --exclude='__pycache__' \
        --exclude='*.pyc' \
        -czf "$tar_path" \
        -C "$(dirname "$src_dir")" "$(basename "$src_dir")"
}

# cache_all_prefixes: iterate over every *-prefix dir in build dir
cache_all_prefixes() {
    local prefix_dir

    mkdir -p "$CACHE_DIR"

    for prefix_dir in "$BUILD_DIR"/*-prefix; do
        [ -d "$prefix_dir" ] || continue
        cache_one_prefix "$prefix_dir"
    done
}

# main: generate cache.0 from a user-supplied build directory
main() {
    UMBRELLA_ROOT=$(detect_umbrella_root) || die "Could not detect orca-umbrella root from script path"
    CACHE_DIR="$UMBRELLA_ROOT/cache.0"

    prompt_build_dir
    cache_all_prefixes
}

main "$@"
