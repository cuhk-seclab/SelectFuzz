#! /bin/sh
mkdir asan
export AFL_USE_ASAN=1
export ASAN_OPTIONS="log_path=asan/asan.log"
make clean all

i=1
for file in `ls ./out/crashes/`:
do
        echo $file > ./asan/$i
        i=$(($i+1));
        ./util/swftophp ./out/crashes/$file
done
