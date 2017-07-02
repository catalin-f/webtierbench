#!/bin/bash

#TODO find a way to compute a sleep value
perf record -F 99 -ag -o ${PERF_FILENAME} -- sleep 1 &