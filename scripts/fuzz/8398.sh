#git clone git://sourceware.org/git/binutils-gdb.git CVE-2017-8392
rm -rf ./8398
cp -r /binutils ./8398
cd 8398; git checkout a49abe0bb18e04d3a4b692995fcfae70cd470775
mkdir obj-aflgo; mkdir obj-aflgo/temp
export SUBJECT=$PWD; export TMP_DIR=$PWD/obj-aflgo/temp
export CC=$AFLGO/afl-clang-fast; export CXX=$AFLGO/afl-clang-fast++
export LDFLAGS=-lpthread
export ADDITIONAL="-targets=$TMP_DIR/BBtargets.txt -outdir=$TMP_DIR -flto -fuse-ld=gold -Wl,-plugin-opt=save-temps"
echo $'dwarf.c:483' > $TMP_DIR/BBtargets.txt
echo $'dwarf.c:483' > $TMP_DIR/real.txt
cd obj-aflgo; 
#CFLAGS="-DFORTIFY_SOURCE=2 -fstack-protector-all -fno-omit-frame-pointer -g -Wno-error $ADDITIONAL" LDFLAGS="-ldl -lutil" ../configure --disable-shared --disable-gdb --disable-libdecnumber --disable-readline --disable-sim --disable-ld
ASAN_OPTIONS=detect_odr_violation=0
CFLAGS="-DFORTIFY_SOURCE=2 -fstack-protector-all -fno-omit-frame-pointer -g -Wno-error $ADDITIONAL" ../configure --disable-shared --disable-gdb --disable-libdecnumber --disable-readline --disable-sim
make clean; make
cat $TMP_DIR/BBnames.txt | rev | cut -d: -f2- | rev | sort | uniq > $TMP_DIR/BBnames2.txt && mv $TMP_DIR/BBnames2.txt $TMP_DIR/BBnames.txt
cat $TMP_DIR/BBcalls.txt | sort | uniq > $TMP_DIR/BBcalls2.txt && mv $TMP_DIR/BBcalls2.txt $TMP_DIR/BBcalls.txt
cd binutils; $AFLGO/scripts/genDistance.sh $SUBJECT $TMP_DIR objdump 
cd ../../; mkdir obj-dist; cd obj-dist; # work around because cannot run make distclean
#CFLAGS="-DFORTIFY_SOURCE=2 -fstack-protector-all -fno-omit-frame-pointer -g -Wno-error -distance=$TMP_DIR/distance.cfg.txt" LDFLAGS="-ldl -lutil" ../configure --disable-shared --disable-gdb --disable-libdecnumber --disable-readline --disable-sim --disable-ld
CFLAGS="-DFORTIFY_SOURCE=2 -fstack-protector-all -fsanitize=undefined,address -fno-omit-frame-pointer -g -Wno-error $ADDITIONAL" ../configure --disable-shared --disable-gdb --disable-libdecnumber --disable-readline --disable-sim
make
mkdir in; 
#echo "" > in/in
cp /selectfuzz/scripts/fuzz/test in/in 
$AFLGO/afl-fuzz -m none -c 45m -i in -o out -d -- binutils/objdump -W @@
