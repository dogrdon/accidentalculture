#!/bin/sh

if [ -z "$1" ]; then
  echo "you need to specify 'audio' or 'video' as an argument"
  exit 1
else
  PROCESS="$1"
fi

if [ $PROCESS = "video" ]; then
  TYPE="moving image"
elif [ $PROCESS = "audio" ]; then
  TYPE="sound"
else
  echo "you can only specify 'audio' or 'video', no wierd stuff. try again."
fi

DIR=$(dirname "$PWD")
FILES=$DIR/data/av/*.gz
for f in $FILES
do
  echo "Processing \""$TYPE"\" types in $f"
  IFS="." read -a ARR <<< "$f"
  o="${ARR[0]}_$PROCESS.json"
  time zcat < $f | 
  jq -cn --stream "fromstream(1|truncate_stream(inputs))" | 
  jq ". | select(._source.sourceResource.type==\"${TYPE}\")" >> $o
done

