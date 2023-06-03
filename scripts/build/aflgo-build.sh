# build clang & LLVM
LLVM_DEP_PACKAGES="build-essential make cmake ninja-build git subversion python2.7 binutils-gold binutils-dev curl wget"
sudo apt-get install -y $LLVM_DEP_PACKAGES
mkdir ~/build; cd ~/build
mkdir llvm_tools; cd llvm_tools
wget http://releases.llvm.org/4.0.0/llvm-4.0.0.src.tar.xz
wget http://releases.llvm.org/4.0.0/cfe-4.0.0.src.tar.xz
wget http://releases.llvm.org/4.0.0/compiler-rt-4.0.0.src.tar.xz
wget http://releases.llvm.org/4.0.0/libcxx-4.0.0.src.tar.xz
wget http://releases.llvm.org/4.0.0/libcxxabi-4.0.0.src.tar.xz
tar xf llvm-4.0.0.src.tar.xz
tar xf cfe-4.0.0.src.tar.xz
tar xf compiler-rt-4.0.0.src.tar.xz
tar xf libcxx-4.0.0.src.tar.xz
tar xf libcxxabi-4.0.0.src.tar.xz
mv cfe-4.0.0.src ~/build/llvm_tools/llvm-4.0.0.src/tools/clang
mv compiler-rt-4.0.0.src ~/build/llvm_tools/llvm-4.0.0.src/projects/compiler-rt
mv libcxx-4.0.0.src ~/build/llvm_tools/llvm-4.0.0.src/projects/libcxx
mv libcxxabi-4.0.0.src ~/build/llvm_tools/llvm-4.0.0.src/projects/libcxxabi
mkdir -p build-llvm/llvm; cd build-llvm/llvm
cmake -G "Ninja" \
      -DLIBCXX_ENABLE_SHARED=OFF -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
      -DCMAKE_BUILD_TYPE=Release -DLLVM_TARGETS_TO_BUILD="X86" \
      -DLLVM_BINUTILS_INCDIR=/usr/include ~/build/llvm_tools/llvm-4.0.0.src
ninja; sudo ninja install
cd ~/build/llvm_tools
mkdir -p build-llvm/msan; cd build-llvm/msan
cmake -G "Ninja" \
      -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ \
      -DLLVM_USE_SANITIZER=Memory -DCMAKE_INSTALL_PREFIX=/usr/msan/ \
      -DLIBCXX_ENABLE_SHARED=OFF -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
      -DCMAKE_BUILD_TYPE=Release -DLLVM_TARGETS_TO_BUILD="X86" \
       ~/build/llvm_tools/llvm-4.0.0.src
ninja cxx; sudo ninja install-cxx
# install LLVMgold in bfd-plugins
sudo mkdir /usr/lib/bfd-plugins
sudo cp /usr/local/lib/libLTO.so /usr/lib/bfd-plugins
sudo cp /usr/local/lib/LLVMgold.so /usr/lib/bfd-plugins
# install some packages
export LC_ALL=C
sudo apt-get update
sudo apt install -y python-dev python3 python3-dev python3-pip autoconf automake libtool-bin python-bs4 libclang-4.0-dev
sudo python3 -m pip install --upgrade pip
sudo python3 -m pip install networkx pydot pydotplus
# build AFLGo
cd $HOME; git clone https://github.com/selectfuzz/selectfuzz.git
cd aflgo; make clean all; cd llvm_mode; make clean all
export AFLGO=$HOME/selectfuzz
