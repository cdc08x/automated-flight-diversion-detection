#!/bin/bash

echo "Counting directories' files"
echo "dir;files;EU;US"
for dir in *
do
  if [ -d $dir ]
  then
    cd $dir
    dirname="$dir"
    filesnum=`ls -l | tail -n +2 | wc | sed -e 's/ *\([0-9][0-9]*\).*/\1/g'` # count files
    eufilesnum=`ls | grep -e '^[0-9][0-9]*.xml$' | wc | sed -e 's/ *\([0-9][0-9]*\).*/\1/g'`
    usfilesnum=`echo "${filesnum} - ${eufilesnum}" | bc -l`
    echo "$dirname;$filesnum;$eufilesnum;$usfilesnum"
    cd ..
  fi
done
