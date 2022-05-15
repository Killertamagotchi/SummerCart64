#!/bin/bash

set -e

PACKAGE_FILE_NAME="SC64"

FILES=(
    "./fw/project/lcmxo2/impl1/sc64_impl1.bit"
    "./fw/project/lcmxo2/impl1/sc64_impl1.jed"
    "./hw/ftdi-template.xml"
    "./sw/bootloader/build/bootloader.bin"
    "./sw/controller/build/controller.bin"
    "./sw/controller/build/controller.elf"
    "./sw/pc/helpers.py"
    "./sw/pc/sc64.py"
    "./LICENSE"
    "./README.md"
)

BUILT_BOOTLOADER=false
BUILT_CONTROLLER=false
BUILT_FPGA=false
BUILT_UPDATE=false
BUILT_RELEASE=false

FORCE_CLEAN=false

build_bootloader () {
    if [ "$BUILT_BOOTLOADER" = true ]; then return; fi

    pushd sw/bootloader > /dev/null
    if [ "$FORCE_CLEAN" = true ]; then
        make clean
    fi
    FLAGS="$USER_FLAGS"
    if [ ! -z "${GIT_BRANCH+x}" ]; then FLAGS+=" -DGIT_BRANCH='\"$GIT_BRANCH\"'"; fi
    if [ ! -z "${GIT_TAG+x}" ]; then FLAGS+=" -DGIT_TAG='\"$GIT_TAG\"'"; fi
    if [ ! -z "${GIT_SHA+x}" ]; then FLAGS+=" -DGIT_SHA='\"$GIT_SHA\"'"; fi
    make all -j USER_FLAGS="$FLAGS"
    popd > /dev/null

    BUILT_BOOTLOADER=true
}

build_controller () {
    if [ "$BUILT_CONTROLLER" = true ]; then return; fi

    pushd sw/controller > /dev/null
    if [ "$FORCE_CLEAN" = true ]; then
        make clean
    fi
    make all -j USER_FLAGS="$USER_FLAGS"
    popd > /dev/null

    BUILT_CONTROLLER=true
}

build_fpga () {
    if [ "$BUILT_FPGA" = true ]; then return; fi

    pushd fw/project/lcmxo2 > /dev/null
    if [ "$FORCE_CLEAN" = true ]; then
        rm -rf ./impl1/
    fi
    ./build.sh
    popd > /dev/null

    BUILT_FPGA=true
}

build_update () {
    if [ "$BUILT_UPDATE" = true ]; then return; fi

    build_bootloader
    build_controller
    build_fpga

    BUILT_UPDATE=true
}

build_release () {
    if [ "$BUILT_RELEASE" = true ]; then return; fi

    build_update

    if [ -e "./${PACKAGE_FILE_NAME}.zip" ]; then
        rm -f "./${PACKAGE_FILE_NAME}.zip"
    fi
    zip -j -r "./${PACKAGE_FILE_NAME}.zip" ${FILES[@]}

    BUILT_RELEASE=true
}

print_usage () {
    echo "builder script for SummerCart64"
    echo "usage: ./build.sh [bootloader] [controller] [fpga] [update] [release] [-c] [--help]"
    echo "parameters:"
    echo "  bootloader  - compile N64 bootloader software"
    echo "  controller  - compile ARM controller software"
    echo "  fpga        - compile FPGA design"
    echo "  update      - compile all software and designs"
    echo "  release     - collect and zip files for release (triggers 'update' build)"
    echo "  -c | --force-clean"
    echo "              - clean compilation result directories before build"
    echo "  --help      - print this guide"
}

if test $# -eq 0; then
    echo "error: no parameters provided"
    echo " "
    print_usage
    exit 1
fi

TRIGGER_BOOTLOADER=false
TRIGGER_CONTROLLER=false
TRIGGER_FPGA=false
TRIGGER_UPDATE=false
TRIGGER_RELEASE=false

while test $# -gt 0; do
    case "$1" in
        bootloader)
            TRIGGER_BOOTLOADER=true
            ;;
        controller)
            TRIGGER_CONTROLLER=true
            ;;
        fpga)
            TRIGGER_FPGA=true
            ;;
        update)
            TRIGGER_UPDATE=true
            ;;
        release)
            TRIGGER_RELEASE=true
            ;;
        -c|--force-clean)
            FORCE_CLEAN=true
            ;;
        --help)
            print_usage
            exit 0
            ;;
        *)
            echo "error: unknown parameter \"$1\""
            echo " "
            print_usage
            exit 1
            ;;
    esac
    shift
done

ls /flexlm
cat /flexlm/license.dat

if [ "$TRIGGER_BOOTLOADER" = true ]; then build_bootloader; fi
if [ "$TRIGGER_CONTROLLER" = true ]; then build_controller; fi
if [ "$TRIGGER_FPGA" = true ]; then build_fpga; fi
if [ "$TRIGGER_UPDATE" = true ]; then build_update; fi
if [ "$TRIGGER_RELEASE" = true ]; then build_release; fi
