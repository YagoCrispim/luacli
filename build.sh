#!/bin/bash

# build
echo 'Cloning luabundler'
git clone https://github.com/YagoCrispim/luabundler.git --depth 1
cp luabundler/bundler.lua ./bundler.lua

echo ''
echo 'Generating "cli.lua"'
lua bundle.lua

# clean
rm ./bundler.lua