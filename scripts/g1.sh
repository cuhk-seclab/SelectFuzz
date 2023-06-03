#!/bin/bash
if [ $# -lt 2 ]; then
  echo "Usage: $0 <binaries-directory> <temporary-directory> [fuzzer-name]"
  echo ""
  exit 1
fi

BINARIES=$(readlink -e $1)
TMPDIR=$(readlink -e $2)
AFLGO="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
fuzzer=""
if [ $# -eq 3 ]; then
  fuzzer=$(find $BINARIES -name "$3.0.0.*.bc" | rev | cut -d. -f5- | rev)
  if [ $(echo "$fuzzer" | wc -l) -ne 1 ]; then
    echo "Couldn't find bytecode for fuzzer $3 in folder $BINARIES."
    exit 1
  fi
fi

SCRIPT=$0
ARGS=$@

#SANITY CHECKS
if [ -z "$BINARIES" ]; then echo "Couldn't find binaries folder ($1)."; exit 1; fi
if ! [ -d "$BINARIES" ]; then echo "No directory: $BINARIES."; exit 1; fi
if [ -z "$TMPDIR" ]; then echo "Couldn't find temporary directory ($3)."; exit 1; fi

binaries=$(find $BINARIES -name "*.0.0.*.bc" | rev | cut -d. -f5- | rev)
if [ -z "$binaries" ]; then echo "Couldn't find any binaries in folder $BINARIES."; exit; fi

if [ -z $(which python) ] && [ -z $(which python3) ]; then echo "Please install Python"; exit 1; fi
#if python -c "import pydotplus"; then echo "Install python package: pydotplus (sudo pip install pydotplus)"; exit 1; fi
#if python -c "import pydotplus; import networkx"; then echo "Install python package: networkx (sudo pip install networkx)"; exit 1; fi

FAIL=0
STEP=1

RESUME=$(if [ -f $TMPDIR/state ]; then cat $TMPDIR/state; else echo 0; fi)

function next_step {
  echo $STEP > $TMPDIR/state
  if [ $FAIL -ne 0 ]; then
    tail -n30 $TMPDIR/step${STEP}.log
    echo "-- Problem in Step $STEP of generating $OUT!"
    echo "-- You can resume by executing:"
    echo "$ $SCRIPT $ARGS $TMPDIR"
    exit 1
  fi
  STEP=$((STEP + 1))
}


#-------------------------------------------------------------------------------
# Construct control flow graph and call graph
#-------------------------------------------------------------------------------
if [ $RESUME -le $STEP ]; then

  cd $TMPDIR/dot-files

  if [ -z "$fuzzer" ]; then
    for binary in $(echo "$binaries"); do

      echo "($STEP) Constructing CG for $binary.."
      while ! opt -dot-callgraph $binary.0.0.*.bc >/dev/null 2> $TMPDIR/step${STEP}.log ; do
        echo -e "\e[93;1m[!]\e[0m Could not generate call graph. Repeating.."
      done
      opt -load /selectfuzz/libDFUZZPASS.so -DFUZZPASS $binary.0.0.preopt.bc -targets=$TMPDIR/BBtargets.txt -outdir=$TMPDIR

      #Remove repeated lines and rename
      awk '!a[$0]++' callgraph.dot > callgraph.$(basename $binary).dot
      rm callgraph.dot
    done

    #Integrate several call graphs into one
    $AFLGO/merge_callgraphs.py -o callgraph.dot $(ls callgraph.*)
    echo "($STEP) Integrating several call graphs into one."

  else

    #crtDir = $PWD
    #pushd /temporal-specialization/SVF
     
    rm ./indirect.txt
    /selectfuzz/temporal-specialization/SVF/Release-build/bin/wpa -print-fp -ander -dump-callgraph $fuzzer.0.0.preopt.bc
    mv ./indirect.txt $TMPDIR/
    

    echo "($STEP) Constructing CG for $fuzzer.."
    while ! opt -dot-callgraph $fuzzer.0.0.*.bc >/dev/null 2> $TMPDIR/step${STEP}.log ; do
      echo -e "\e[93;1m[!]\e[0m Could not generate call graph. Repeating.."
    done

    opt -load /selectfuzz/libDFUZZPASS.so -DFUZZPASS $fuzzer.0.0.preopt.bc -targets=$TMPDIR/BBtargets.txt -outdir=$TMPDIR

    #Remove repeated lines and rename
    awk '!a[$0]++' callgraph.dot > callgraph.1.dot
    mv callgraph.1.dot callgraph.dot

  fi
fi
next_step

#-------------------------------------------------------------------------------
# Generate config file keeping distance information for code instrumentation
#-------------------------------------------------------------------------------
next_step

echo ""
echo "----------[DONE]----------"
echo ""
echo "Now, you may wish to compile your sources with "
echo "CC=\"$AFLGO/../afl-clang-fast\""
echo "CXX=\"$AFLGO/../afl-clang-fast++\""
echo "CFLAGS=\"\$CFLAGS -distance=$(readlink -e $TMPDIR/distance.cfg.txt)\""
echo "CXXFLAGS=\"\$CXXFLAGS -distance=$(readlink -e $TMPDIR/distance.cfg.txt)\""
echo ""
echo "--------------------------"
