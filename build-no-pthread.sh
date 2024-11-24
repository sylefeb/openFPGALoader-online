#!/bin/sh -ex

# MinGW tweaks:
# 1/ python SSL CERTs
export SSL_CERT_FILE=$(python -m certifi)
# 2/ Edit emsdk/upstream/emscripten/emconfigure.py and add:
#    args.insert(0,"bash")
# on line 44. This fixes the 'no a win32 executabe' issue
# 3/ Each time build hangs on an EOF complaint, run it again ...

export SOURCE_DATE_EPOCH=$(git log -1 --format=%ct)

cd $(dirname $0)

EMSDK_VERSION="3.1.51"
./emsdk/emsdk install ${EMSDK_VERSION}
./emsdk/emsdk activate ${EMSDK_VERSION}
export PATH=$(pwd)/emsdk:$(pwd)/emsdk/upstream/emscripten:${PATH}
export PKG_CONFIG_PATH=$(pwd)/prefix/lib/pkgconfig

emcmake cmake -S zlib-src -B zlib-build \
    -DCMAKE_BUILD_TYPE=Debug \
    -DCMAKE_INSTALL_PREFIX=$(pwd)/prefix \
    -DINSTALL_PKGCONFIG_DIR=$(pwd)/prefix/lib/pkgconfig \
    -DCMAKE_C_FLAGS="-O2 -fexceptions -no-pthread"
emmake make -C zlib-build install VERBOSE=1 -j16

[ -e ./libusb-src/configure ] || (
    cd ./libusb-src &&
    ./bootstrap.sh)
[ -e ./libusb-build/Makefile ] || (
    mkdir -p libusb-build &&
    cd ./libusb-build &&
    emconfigure ../libusb-src/configure \
        CFLAGS="-O2 -fexceptions -DNO_PTHREAD -no-pthread -Wall" \
        CPPFLAGS="-O2 -fexceptions -DNO_PTHREAD -no-pthread -Wall" \
        --host=wasm32-emscripten \
        --prefix=$(realpath $(pwd)/../prefix))
emmake make -C libusb-build install -j16

emcmake cmake -S libftdi-src -B libftdi-build \
    -DCMAKE_BUILD_TYPE=Debug \
    -DCMAKE_INSTALL_PREFIX="$(pwd)/prefix" \
    -DCMAKE_INSTALL_LIBDIR="$(pwd)/prefix/lib" \
    -DLIBUSB_INCLUDE_DIR="$(pwd)/prefix/include/libusb-1.0" \
    -DLIBUSB_LIBRARIES="-L$(pwd)/prefix/lib -lusb-1.0" \
    -DCMAKE_C_FLAGS="-O2 -fexceptions -no-pthread" \
    -DFTDI_EEPROM=OFF \
    -DEXAMPLES=OFF
emmake make -C libftdi-build install VERBOSE=1 -j16

EMCC_FLAGS=" \
-s ASYNCIFY=1 \
-s ASYNCIFY_STACK_SIZE=1000000 \
-s INVOKE_RUN=0 \
-s EXIT_RUNTIME=1 \
-s NO_EXIT_RUNTIME=0 \
-s MALLOC=emmalloc \
-s INITIAL_MEMORY=33554432 \
-s INCOMING_MODULE_JS_API=preRun,onRuntimeInitialized,print,printErr \
-s EXPORTED_RUNTIME_METHODS=FS,stackAlloc,stringToUTF8OnStack,callMain \
-s EXPORTED_FUNCTIONS=_main,_fflush \
-s TEXTDECODER=1 \
-s WASM_BIGINT=1 -O1 \
-s ASSERTIONS=2 \
-s DISABLE_EXCEPTION_CATCHING=0 \
"
emcmake cmake -S openFPGALoader-src -B openFPGALoader-build \
    -DCMAKE_BUILD_TYPE=Debug \
    -DCMAKE_INSTALL_PREFIX="$(pwd)/prefix" \
    -DCMAKE_CXX_FLAGS="-fexceptions" \
    -DCMAKE_EXE_LINKER_FLAGS="-O2 -no-pthread -lembind ${EMCC_FLAGS}" \
    -DCMAKE_EXECUTABLE_SUFFIX_CXX=".js"
emmake make -C openFPGALoader-build VERBOSE=1 -j16

cp openFPGALoader-build/openFPGALoader.js test/
cp openFPGALoader-build/openFPGALoader.wasm test/
