#!/bin/bash

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

invocationtemplate="python detect.py --svmfolder \"$BASE_DIR/SVMs/SVMs_interval-240/SVM-1234_interval-240_nu-001_gamma-1\" --interval 240 --threshold 3 \"%s\""

python_script_folder="$BASE_DIR/src"

foldercounter=0

nokfolders=(
  "$BASE_DIR/flights/NOK_1" # let us use it for validation
  "$BASE_DIR/flights/NOK_2" # let us use it for testing
)

cd "$python_script_folder"

i=0

for nokfolder in ${nokfolders[@]}
do
  printf -v nokinvoc -- "${invocationtemplate}" "${nokfolder}"
  eval "${nokinvoc}"
  i=`expr $i + 1`
done

echo "$i runs done"

exit 0
