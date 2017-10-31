#!/bin/bash

tinyvpn -s -l 0.0.0.0:8989 --mode 0 &

ss-server -s 0.0.0.0 -p 8989 -m chacha20 -k 131415 --fast-open
