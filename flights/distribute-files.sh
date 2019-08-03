#!/bin/bash

OK_DIVID=6
NOK_DIVID=2
NOK_DIR="/home/claudio/BigData/FR24/flights/NOK"
OK_DIR="/home/claudio/BigData/FR24/flights/OK"
OK_DIV_DIR_PREFIX="/home/claudio/BigData/FR24/flights/OK_"
NOK_DIV_DIR_PREFIX="/home/claudio/BigData/FR24/flights/NOK_"

cd "$OK_DIR"
okkount=`ls -l | tail -n +2 | wc | sed -e 's/ *\([0-9][0-9]*\).*/\1/g'`
okdivid=`expr $okkount / $OK_DIVID`

foldercount=1
partialcount=1
dir="$OK_DIV_DIR_PREFIX$foldercount"

if [ ! -d "$dir" ]
then
  mkdir "$dir"
#else
#  echo "Suca"
fi

for file in `ls $OK_DIR/*.* | shuf`
# for (( filecount=1; filecount<=$oktotake; filecount++ ))
do
  if [ "$partialcount" -gt "$okdivid" ]
  then
    partialcount=1
    foldercount=`expr $foldercount + 1`
#  else
  fi
  dir="$OK_DIV_DIR_PREFIX$foldercount"

  if [ ! -d "$dir" ]
  then
    mkdir "$dir"
  fi

  echo "Copying: $partialcount/$okkount => $foldercount ($file => $dir)"
  cp -n "$file" "$dir"

  partialcount=`expr $partialcount + 1`
done

foldercount=1
partialcount=1
dir="$NOK_DIV_DIR_PREFIX$foldercount"

cd "$NOK_DIR"
nokkount=`ls -l | tail -n +2 | wc | sed -e 's/ *\([0-9][0-9]*\).*/\1/g'`
nokdivid=`expr $nokkount / $NOK_DIVID`

for file in `ls $NOK_DIR/*.*| shuf`
# for (( filecount=1; filecount<=$oktotake; filecount++ ))
do
  if [ "$partialcount" -gt "$nokdivid" ]
  then
    partialcount=1
    foldercount=`expr $foldercount + 1`
#  else
  fi
  dir="$NOK_DIV_DIR_PREFIX$foldercount"

  if [ ! -d "$dir" ]
  then
    mkdir "$dir"
  fi

  echo "Copying: $partialcount/$nokkount => $foldercount ($file => $dir)"
  cp -n "$file" "$dir"

  partialcount=`expr $partialcount + 1`
done

