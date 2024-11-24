# OpenFPGALoader online

This repo allows compiling openFPGALoader for the web, without requiring `SharedArrayBuffer` or thread supports.

This is based on the amazing [YoWASP project](http://yowasp.org/) and more specifically the [OpenFPGALoader-web](https://github.com/YoWASP/openFPGALoader-web) repo, and also of course the great [openFPGALoader](https://github.com/trabucayre/openFPGALoader) project. Other key dependencies are [libusb](https://github.com/libusb/libusb), [libftdi](https://www.intra2net.com/en/developer/libftdi/) and [zlib](https://github.com/madler/zlib).

## How to build

Run `./build-no-phtread.sh`

Result `openFPGALoader.js` and `openFPGALoader.wasm` are in the `openFPGALoader-build` folder.

## How to use?

For now I created a simple test case in the `test` directory. See the [dedicated README](./test/README.md).

## Why?

It is great to be able to program a board directly from a webpage, without any complex installation process. Unfortunately, `libusb` compiles with `pthread`, and as a result emscripten builds a javascript/wasm that requires `ShareArryBuffer` support. This, in turns, requires specific extensions/authorizations to run on e.g. Chrome. This is especially unfortunate as, in fact, threads are not used!

This repo uses a fork of `libusb` that can be compiled *without* pthread support, and avoids `ShareArryBuffer` entirely.
