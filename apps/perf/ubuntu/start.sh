#!/bin/bash

perf record -F 99 -ag -o ${PERF_FILENAME} -- sleep 7200