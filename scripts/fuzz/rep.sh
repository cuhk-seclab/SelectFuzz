
#!/bin/bash
export AFL_USE_ASAN=1
cd $1
make clean 
make
echo 1
for file in ./out/crashes/*
do
	./util/swftophp $file 	
done 
