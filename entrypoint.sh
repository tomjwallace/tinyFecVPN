#!/bin/bash

tinyvpn -s -l0.0.0.0:8989 -f20:10 -k "passwd" --sub-net 10.22.22.0 &

ss-server -s 0.0.0.0 -p 8989 -m chacha20 -k 131415 --fast-open
