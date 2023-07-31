# Installation:

## Manual installation
1. Run export AFLGO=selectfuzz_installation_dir
2. Under folder selectfuzz: make clean all
3. Under folder selectfuzz/llvm-mode: make clean all, error message "recipe for target 'test_build' failed" can be ignored.

## Docker (Recommended)

Alternatively, you can use our provided [docker image](https://hub.docker.com/r/selectivefuzz1/selectfuzz).

We have installed all required dependencies in Docker. You thus do NOT need to install it yourself.

**Important:**

We use a lab proxy in Docker. To run the scripts, you must unset the proxy so that you can access network and download seeds!

```tex
unset https_proxy
unset http_proxy
```

# Run SelectFuzz:

Under the folder selectfuzz/scripts/fuzz: run *.sh to fuzz the programs. 

You can also write shell scripts to fuzz other programs by following the samples.

We also provide shell scripts to help check the fuzzing results (you need to check if the program crashes at the "target location").
Copy run.sh to target_dir/obj-aflgo(or obj-dist)/ and run run.sh

## Artifacts: 

You can check the artifacts [here](https://drive.google.com/file/d/1tAJlUKXkn-Z_mHu9gIS2ysDVyja9bIqu/view?usp=sharing). 
The folder names are the CVE numbers we tested.
If the folder contains obj-dist, then check the fuzzing results (e.g., the time used and the crash PoCs) in obj-dist/out;
Otherwise, check the results in obj-aflgo/out;

# QAs:

1. Why is SelectFuzz effective?

SelectFuzz tests only relevant code (a small portion of reachable code) and greatly narrows down the exploration scope of directed fuzzing.

2. When is SelectFuzz not effective?

SelectFuzz is not effective when the path constraints to fuzzing targets are difficult to satisfy, as it currently uses random mutation and does not incorporate input mutation techniques like symbolic execution and taint tracking. 

3. How to improve SelectFuzz's efficiency?

We leveraged [1] to perform inter-procedural data-flow analysis and find relevant code. The more advanced data-flow analysis will definitely improve SelectFuzz's performance.

[1] Temporal system call specialization for attack surface reduction, Usenix Security Symposium 2020.

4. __Important: How do I check if the fuzzer runs correctly__?

SelectFuzz would NOT report errors. To see if the fuzzer runs correctly, you can check the distance files, e.g., /selectfuzz/scripts/fuzz/libming-CVE-2018-8807/obj-aflgo/temp/distance.cfg.txt if you run CVE-2018-8807. The distance file should contain some distance information if things run correctly.

If there is no distance information, it means there are something wrong. Please check /selectfuzz/scripts/fuzz/CVE/obj-aflgo/temp/real.txt. If it starts with $, delete $ in the scripts (e.g., the first $ in "echo $'decompile.c:349' > $TMP_DIR/real.txt" in /selectfuzz/scripts/fuzz/libming-CVE-2018-8807.sh). If it does not work or if you meet other issues, please contact me at <chluo@cse.cuhk.edu.hk>.

## License

SelectFuzz is under [Apache License](LICENSE).

# Publication

You can find more details in our [Oakland 2023 paper](https://www.computer.org/csdl/proceedings-article/sp/2023/933600b050/1Js0DBwgpwY).

```tex
@inproceedings{luo2023selectfuzz,
    title       = {SelectFuzz: Efficient Directed Fuzzing with Selective Path Exploration},
    author      = {Changhua Luo, Wei Meng, and Penghui Li},
    booktitle   = {2023 IEEE Symposium on Security and Privacy (SP)},
    year = {2023}
}
```

## Contacts

- Changhua Luo (<chluo@cse.cuhk.edu.hk>)
- Wei Meng (<wei@cse.cuhk.edu.hk>)
- Penghui Li (<phli@cse.cuhk.edu.hk>)

