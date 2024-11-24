#!/bin/bash
mkdir release
cp openFPGALoader-build/openFPGALoader.js release/
cp openFPGALoader-build/openFPGALoader.wasm release/
tar cvfz release.tgz release
