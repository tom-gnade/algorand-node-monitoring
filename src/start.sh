#!/bin/bash

gosu 65534:65534 goal kmd start
exec gosu 65534:65534 algod -d /algod/data