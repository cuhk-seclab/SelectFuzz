rm -rf obj-aflgo
mkdir obj-aflgo; cd obj-aflgo
mkdir temp
export TMP_DIR=$PWD/temp
export ADDITIONAL="-targets=$TMP_DIR/BBtargets.txt -outdir=$TMP_DIR -flto -fuse-ld=gold -Wl,-plugin-opt=save-temps"
#export ADDITIONAL="-targets=$TMP_DIR/BBtargets.txt -outdir=$TMP_DIR"
../configure --disable-shared --prefix=`pwd` --cc=$AFLGO/afl-clang-fast --extra-cflags="$ADDITIONAL" --disable-doc
