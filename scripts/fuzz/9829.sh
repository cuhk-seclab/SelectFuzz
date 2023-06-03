rm -rf 9829
git clone https://github.com/libming/libming.git 9829
cd 9829/; git checkout 5aa3470
rm -rf obj-aflgo
mkdir obj-aflgo; mkdir obj-aflgo/temp
export SUBJECT=$PWD; export TMP_DIR=$PWD/obj-aflgo/temp
export CC=$AFLGO/afl-clang-fast; export CXX=$AFLGO/afl-clang-fast++
export LDFLAGS=-lpthread
export ADDITIONAL="-targets=$TMP_DIR/BBtargets.txt -outdir=$TMP_DIR -flto -fuse-ld=gold -Wl,-plugin-opt=save-temps"

echo $'parser.c:1656' > $TMP_DIR/real.txt
./autogen.sh;
cd obj-aflgo; CFLAGS="$ADDITIONAL" CXXFLAGS="$ADDITIONAL" ../configure --disable-shared --prefix=`pwd`
make clean; make
cat $TMP_DIR/BBnames.txt | rev | cut -d: -f2- | rev | sort | uniq > $TMP_DIR/BBnames2.txt && mv $TMP_DIR/BBnames2.txt $TMP_DIR/BBnames.txt
cat $TMP_DIR/BBcalls.txt | sort | uniq > $TMP_DIR/BBcalls2.txt && mv $TMP_DIR/BBcalls2.txt $TMP_DIR/BBcalls.txt
cd util; 
export AFL_USE_ASAN=1
$AFLGO/scripts/genDistance.sh $SUBJECT $TMP_DIR listswf
cd -; CFLAGS="-distance=$TMP_DIR/distance.cfg.txt" CXXFLAGS="-distance=$TMP_DIR/distance.cfg.txt" ../configure --disable-shared --prefix=`pwd`
make clean; make
rm -rf in out
mkdir in; 
wget -P in --no-check-certificate http://condor.depaul.edu/sjost/hci430/flash-examples/swf/bumble-bee1.swf
echo ' ' >in/tmp.swf
$AFLGO/afl-fuzz -m none -z exp -c 45m -i in -o out ./util/listswf @@
#$AFLGO/afl-fuzz -i in -o out -m none -t 9999 -d -- ./util/swftophp @@

