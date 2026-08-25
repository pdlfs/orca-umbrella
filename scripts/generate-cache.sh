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

UMBRELLA_ROOT=$(detect_umbrella_root) || die "Could not detect orca-umbrella root from script path"
CACHE_DIR="$UMBRELLA_ROOT/cache.0"

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
    local -a package_excludes=()

    [ -d "$prefix_dir" ] || die "Prefix dir not found: $prefix_dir"

    dep_name=$(basename "$prefix_dir")
    dep_name=${dep_name%-prefix}
    src_dir="$prefix_dir/src/$dep_name"
    tar_name=$(get_cache_tar_name "$dep_name") || die "No ${dep_name} cache tar variable found in $BUILD_DIR/CMakeCache.txt"
    tar_path="$CACHE_DIR/$tar_name"

    [ -d "$src_dir" ] || die "Source dir not found: $src_dir"

    mkdir -p "$CACHE_DIR"

    if [ "$dep_name" = "orca-utils" ]; then
        package_excludes+=(--exclude='orca-utils/ext')
    fi

    message "Caching ${dep_name}: ${src_dir} -> ${tar_path}"
    tar \
        --exclude='.git' \
        --exclude='.github' \
        --exclude='.gitmodules' \
        --exclude='__pycache__' \
        --exclude='*.pyc' \
        "${package_excludes[@]}" \
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

# run_generate_cache: generate cache.0 from a user-supplied build directory
run_generate_cache() {
    prompt_build_dir
    cache_all_prefixes
}

# run_upload_release: package cache.0 with committed sources and publish a release
run_upload_release() {
    local version=$1

    # Validate release inputs.
    [[ "$version" =~ ^v?[0-9]+\.[0-9]+\.[0-9]+$ ]] || \
        die "Version must be semantic, for example: v1.0.1"
    command -v gh >/dev/null 2>&1 || die "gh CLI not found"
    command -v sha256sum >/dev/null 2>&1 || die "sha256sum not found"
    [ -d "$CACHE_DIR" ] || die "Cache dir not found: $CACHE_DIR"
    find "$CACHE_DIR" -mindepth 1 -print -quit | grep -q . || die "Cache dir is empty: $CACHE_DIR"

    # Require the release commit to be clean.
    git -C "$UMBRELLA_ROOT" diff --quiet || die "Tracked worktree changes must be committed before upload"
    git -C "$UMBRELLA_ROOT" diff --cached --quiet || die "Staged changes must be committed before upload"

    local head=$(git -C "$UMBRELLA_ROOT" rev-parse HEAD)

    # Name release outputs from the requested version.
    local artifact_name="orca-umbrella-${version}"
    local archive_name="${artifact_name}.tar.gz"
    local checksum_name="${archive_name}.sha256"
    local output_dir=$(dirname "$UMBRELLA_ROOT")
    local archive_path="$output_dir/$archive_name"
    local checksum_path="$output_dir/$checksum_name"

    # Package committed sources with the generated cache.
    local staging_dir=$(mktemp -d)
    trap 'rm -rf "$staging_dir"' RETURN

    mkdir -p "$staging_dir/$artifact_name"
    git -C "$UMBRELLA_ROOT" archive HEAD | tar -xf - -C "$staging_dir/$artifact_name"
    cp -a "$CACHE_DIR/." "$staging_dir/$artifact_name/cache.0/"

    message "Packaging release: $archive_path"
    tar -czf "$archive_path" -C "$staging_dir" "$artifact_name"
    (
        cd "$output_dir"
        sha256sum "$archive_name" > "$checksum_name"
    )

    # Publish the archive and checksum under the matching release tag.
    message "Uploading GitHub release: $version"
    gh release create "$version" \
        "$archive_path" \
        "$checksum_path" \
        --repo "$(git -C "$UMBRELLA_ROOT" remote get-url origin)" \
        --target "$head" \
        --title "$artifact_name" \
        --notes "ORCA SC26 AD/AE artifact $version."
}

# usage: print command-line help
usage() {
    cat <<EOF
Usage:
  $0 --cache
  $0 --upload VERSION
EOF
}

# Dispatch cache generation and release upload independently.
case "${1:-}" in
    --cache)
        [ "$#" -eq 1 ] || die "--cache takes no arguments"
        run_generate_cache
        ;;
    --upload)
        [ "$#" -eq 2 ] || die "--upload requires one VERSION argument"
        run_upload_release "$2"
        ;;
    -h|--help)
        usage
        ;;
    *)
        usage >&2
        exit 1
        ;;
esac
