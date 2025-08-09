#!/usr/bin/env bash

sudo apt-get update
sudo apt-get install pciutils build-essential cmake curl libcurl4-openssl-dev -y
sudo systemctl stop local-llama.service

export CUDACXX=/usr/local/cuda/bin/nvcc
cd /tmp || exit
rm -rf /tmp/llama.cpp
git clone --depth=1 https://github.com/ggml-org/llama.cpp
cmake llama.cpp -B llama.cpp/build -DBUILD_SHARED_LIBS=OFF -DGGML_CUDA=ON -DLLAMA_CURL=ON
cmake --build llama.cpp/build --config Release -j --clean-first --target llama-cli llama-gguf-split llama-server
sudo cp -f llama.cpp/build/bin/llama-* /usr/local/bin
