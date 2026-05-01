#!/bin/bash
read -p "Path to IncludeOS (repro qemu programs): " INCLUDEOS_PATH

read -p "Run benchmark on Linux VM? (yes|other[IncludeOS]): " USE_LINUX
if [ "$USE_LINUX" = "yes" ]; then
    USE_LINUX=true
else
    USE_LINUX=false
fi

ls -l | grep benchmark
read -p "What benchmark do you want to run: " BENCHMARK

# Results directory
RESULTS="./results"
if [ ! -d "$RESULTS" ]; then
    mkdir "$RESULTS"
fi

# Setting up tmpfs
TMP_DIR=$(mktemp -d -p /tmp virtiofs_share.XXXXXX)
SHARED_DIR=$TMP_DIR/shared
mkdir $SHARED_DIR
echo "Sharing directory ${SHARED_DIR} with guest"

sudo mount -t tmpfs -o mode=777,size=4G tmpfs "$SHARED_DIR"

# Copying material folder contents if exists
if [ -d "$BENCHMARK/material" ]; then
    echo "Copying material contents"
    cp -vvv $BENCHMARK/material/* ${SHARED_DIR}
fi

# Start system
if [ "$USE_LINUX" = true ]; then
    echo "Building benchmark program ${BENCHMARK}/linux_drv.nix"
    nix-build $BENCHMARK/linux_drv.nix --argstr includeos_path $INCLUDEOS_PATH
    cp ./result/bin/virtiofs_bench $SHARED_DIR
    nix-shell --argstr includeos_path $INCLUDEOS_PATH --run "./run_linux.py $SHARED_DIR"
else
    echo "Building unikernel ${BENCHMARK}/includeos_drv.nix"
    nix-build $BENCHMARK/includeos_drv.nix --argstr includeos_path $INCLUDEOS_PATH
    cp ./result/bin/virtiofs_bench $SHARED_DIR
    nix-shell --argstr includeos_path $INCLUDEOS_PATH --run "./run_includeos.py $SHARED_DIR"
fi

rm -rf ./result
rm -rf ./results
mkdir results
cp -v -r $SHARED_DIR/*.csv results
cp -v -r $SHARED_DIR/*.yuv results
cp -v -r $SHARED_DIR/*_copy.bin results
cp $SHARED_DIR/syncio_testing_file.chksum results

# Cleanup
sudo umount "$SHARED_DIR"
rm -rf "$TMP_DIR"
