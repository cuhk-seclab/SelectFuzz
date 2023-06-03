mkdir obj-aflgo; cd obj-aflgo
export TMP_DIR=$PWD/temp
export ADDITIONAL="-targets=$TMP_DIR/BBtargets.txt -outdir=$TMP_DIR -flto -fuse-ld=gold -Wl,-plugin-opt=save-temps"
../configure --disable-shared --prefix=`pwd` --cc=$AFLGO/afl-clang-fast --host-cflags="$ADDITIONAL" --disable-doc
