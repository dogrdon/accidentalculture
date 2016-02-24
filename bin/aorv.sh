#!/bin/sh

#######
## Tell it which subdirecotory v(ideo), a(udio), a(udio)v(ideo) containing a set of dpla .gz
## bulk data files you want and it will extract that type to a new file. 
## command should also ensure that the json is valid, but is not currently working on posix
#######

if [ -z "$1" ]; then
  echo "you need to specify 'audio' or 'video' as an argument"
  exit 1
else
  PROCESS="$1"
fi

if [ -z "$2" ]; then
  echo "specify which directory [a, v, av]"
  exit 1
else
  FOLDER="$2"
fi

if [ $PROCESS = "video" ]; then
  TYPE="moving image"
elif [ $PROCESS = "audio" ]; then
  TYPE="sound"
else
  echo "you can only specify 'audio' or 'video', no weird stuff. try again."
fi

DIR=$(dirname "$PWD")
FILES=$DIR/data/$FOLDER/*.gz
for f in $FILES
do
  echo "Processing \""$TYPE"\" types in $f"
  IFS="." read -a ARR <<< "$f"
  o="${ARR[0]}_$PROCESS.json"
  l="${ARR[0]}.log"

  zcat < $f | 
  (time jq -cn --stream "fromstream(1|truncate_stream(inputs))" | 
  jq -c "select(any(._source.sourceResource; .type==\"${TYPE}\"))" >> $o) &> $l #&& 
  #sed -i"" -e 's/$/,/g' -e '$s/,$//' -e '1i\
  #[' -e '$a\
  #]' $o
done

