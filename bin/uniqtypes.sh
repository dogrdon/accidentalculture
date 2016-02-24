#!/bin/bash

##################
#All this does is go through a directory of compressed dpla data dump files
#and it will extract all the unique object types (based on the search formats for DPLA).
#Then spits that information out in a text file for each provider (or the whole thing, 
#but the process might never finish on a lightweight processor) in the same dir.
##################

DIR=$(dirname "$PWD")
FILES=$DIR/data/parts/*.gz
for f in $FILES
do
  echo "Processing $f"
  IFS="." read -a ARR <<< "$f"
  o="${ARR[0]}_types.txt"
  zcat < $f | jq --stream 'select(.[0][1] == "_source" and .[0][2] == "sourceResource" and .[0][3] == "type") | .[1]' | sort | uniq > $o
done
