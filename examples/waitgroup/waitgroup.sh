#!/usr/bin/env bash

. waitgroup.h

waitgroup wg
wg.limit = 5

for i in {1..100}; do
    wg.run sleep $((RANDOM % 3))
    echo "Launched job $i"
done

echo "All jobs launched, waiting..."
wg.wait
echo "All jobs complete!"
