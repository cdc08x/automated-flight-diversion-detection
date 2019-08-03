#!/bin/bash

PARALLEL_THREADS=16


BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

invocationtemplates=(
"python detect.py --svmfolder \"$BASE_DIR/SVMs/SVMs_interval-120/SVM-%s_interval-120_nu-006_gamma-8\" --interval 120 --threshold 8 \"%s\""
"python detect.py --svmfolder \"$BASE_DIR/SVMs/SVMs_interval-135/SVM-%s_interval-135_nu-006_gamma-4\" --interval 135 --threshold 7 \"%s\""
"python detect.py --svmfolder \"$BASE_DIR/SVMs/SVMs_interval-150/SVM-%s_interval-150_nu-006_gamma-4\" --interval 150 --threshold 7 \"%s\""
"python detect.py --svmfolder \"$BASE_DIR/SVMs/SVMs_interval-165/SVM-%s_interval-165_nu-002_gamma-2\" --interval 165 --threshold 4 \"%s\""
"python detect.py --svmfolder \"$BASE_DIR/SVMs/SVMs_interval-180/SVM-%s_interval-180_nu-002_gamma-8\" --interval 180 --threshold 6 \"%s\""
"python detect.py --svmfolder \"$BASE_DIR/SVMs/SVMs_interval-195/SVM-%s_interval-195_nu-002_gamma-4\" --interval 195 --threshold 4 \"%s\""
"python detect.py --svmfolder \"$BASE_DIR/SVMs/SVMs_interval-210/SVM-%s_interval-210_nu-003_gamma-4\" --interval 210 --threshold 4 \"%s\""
"python detect.py --svmfolder \"$BASE_DIR/SVMs/SVMs_interval-225/SVM-%s_interval-225_nu-001_gamma-2\" --interval 225 --threshold 3 \"%s\""
"python detect.py --svmfolder \"$BASE_DIR/SVMs/SVMs_interval-240/SVM-%s_interval-240_nu-001_gamma-1\" --interval 240 --threshold 3 \"%s\""
"python detect.py --svmfolder \"$BASE_DIR/SVMs/SVMs_interval-255/SVM-%s_interval-255_nu-001_gamma-2\" --interval 255 --threshold 3 \"%s\""
"python detect.py --svmfolder \"$BASE_DIR/SVMs/SVMs_interval-270/SVM-%s_interval-270_nu-001_gamma-2\" --interval 270 --threshold 4 \"%s\""
"python detect.py --svmfolder \"$BASE_DIR/SVMs/SVMs_interval-285/SVM-%s_interval-285_nu-007_gamma-1\" --interval 285 --threshold 4 \"%s\""
"python detect.py --svmfolder \"$BASE_DIR/SVMs/SVMs_interval-300/SVM-%s_interval-300_nu-003_gamma-4\" --interval 300 --threshold 4 \"%s\""
# 
# "python detect.py --svmfolder \"$BASE_DIR/SVMs/SVMs_interval-120/SVM-%s_interval-120_nu-006_gamma-8\" --interval 120 --threshold 6 \"%s\""
# "python detect.py --svmfolder \"$BASE_DIR/SVMs/SVMs_interval-135/SVM-%s_interval-135_nu-011_gamma-4\" --interval 135 --threshold 7 \"%s\""
# "python detect.py --svmfolder \"$BASE_DIR/SVMs/SVMs_interval-150/SVM-%s_interval-150_nu-011_gamma-8\" --interval 150 --threshold 7 \"%s\""
# "python detect.py --svmfolder \"$BASE_DIR/SVMs/SVMs_interval-165/SVM-%s_interval-165_nu-002_gamma-2\" --interval 165 --threshold 4 \"%s\""
# "python detect.py --svmfolder \"$BASE_DIR/SVMs/SVMs_interval-180/SVM-%s_interval-180_nu-008_gamma-4\" --interval 180 --threshold 6 \"%s\""
# "python detect.py --svmfolder \"$BASE_DIR/SVMs/SVMs_interval-195/SVM-%s_interval-195_nu-005_gamma-8\" --interval 195 --threshold 5 \"%s\""
# "python detect.py --svmfolder \"$BASE_DIR/SVMs/SVMs_interval-210/SVM-%s_interval-210_nu-01_gamma-2\" --interval 210 --threshold 5 \"%s\""
# "python detect.py --svmfolder \"$BASE_DIR/SVMs/SVMs_interval-225/SVM-%s_interval-225_nu-001_gamma-2\" --interval 225 --threshold 3 \"%s\""
# "python detect.py --svmfolder \"$BASE_DIR/SVMs/SVMs_interval-240/SVM-%s_interval-240_nu-006_gamma-2\" --interval 240 --threshold 4 \"%s\""
# "python detect.py --svmfolder \"$BASE_DIR/SVMs/SVMs_interval-255/SVM-%s_interval-255_nu-003_gamma-2\" --interval 255 --threshold 3 \"%s\""
# "python detect.py --svmfolder \"$BASE_DIR/SVMs/SVMs_interval-270/SVM-%s_interval-270_nu-005_gamma-2\" --interval 270 --threshold 3 \"%s\""
# "python detect.py --svmfolder \"$BASE_DIR/SVMs/SVMs_interval-285/SVM-%s_interval-285_nu-013_gamma-2\" --interval 285 --threshold 4 \"%s\""
# "python detect.py --svmfolder \"$BASE_DIR/SVMs/SVMs_interval-300/SVM-%s_interval-300_nu-01_gamma-2\" --interval 300 --threshold 4 \"%s\""
# "python detect.py --svmfolder \"$BASE_DIR/SVMs/SVMs_interval-360/SVM-%s_interval-360_nu-004_gamma-4\" --interval 360 --threshold 3 \"%s\""
# "python detect.py --svmfolder \"$BASE_DIR/SVMs/SVMs_interval-420/SVM-%s_interval-420_nu-003_gamma-1\" --interval 420 --threshold 2 \"%s\""
# "python detect.py --svmfolder \"$BASE_DIR/SVMs/SVMs_interval-480/SVM-%s_interval-480_nu-004_gamma-1\" --interval 480 --threshold 2 \"%s\""
# "python detect.py --svmfolder \"$BASE_DIR/SVMs/SVMs_interval-540/SVM-%s_interval-540_nu-005_gamma-1\" --interval 540 --threshold 2 \"%s\""
# "python detect.py --svmfolder \"$BASE_DIR/SVMs/SVMs_interval-600/SVM-%s_interval-600_nu-003_gamma-1\" --interval 600 --threshold 2 \"%s\""
# "python detect.py --svmfolder \"$BASE_DIR/SVMs/SVMs_interval-660/SVM-%s_interval-660_nu-001_gamma-2\" --interval 660 --threshold 2 \"%s\""
# "python detect.py --svmfolder \"$BASE_DIR/SVMs/SVMs_interval-720/SVM-%s_interval-720_nu-003_gamma-025\" --interval 720 --threshold 2 \"%s\""
)

python_script_folder="$BASE_DIR/src"

foldercounter=0
okcodes=(
  "1234"
  "1235"
  "1245"
  "1345"
  "2345"
)

testfolders=()
testokfolders[1234]="$BASE_DIR/flights/OK_6"
testokfolders[1235]="$BASE_DIR/flights/OK_6"
testokfolders[1245]="$BASE_DIR/flights/OK_6"
testokfolders[1345]="$BASE_DIR/flights/OK_6"
testokfolders[2345]="$BASE_DIR/flights/OK_6"

nokfolders=(
  "$BASE_DIR/flights/NOK_1" # let us use it for validation
  "$BASE_DIR/flights/NOK_2" # let us use it for testing
)
testnokfolder=()
testnokfolders[1234]="${nokfolders[0]}"
testnokfolders[1235]="${nokfolders[0]}"
testnokfolders[1245]="${nokfolders[0]}"
testnokfolders[1345]="${nokfolders[0]}"
testnokfolders[2345]="${nokfolders[0]}"

testnokfolder=${nokfolders[1]}

cd "$python_script_folder"

threadscounter=0

i=0

for okcode in ${okcodes[@]}
do
  for (( j=0;j<${#invocationtemplates[@]};j++ ))
  do
    invocationtemplate=${invocationtemplates[$j]}
    printf -v okinvoc -- "${invocationtemplate}" "$okcode" "${testokfolders[$okcode]}"
    printf -v nokinvoc -- "${invocationtemplate}" "$okcode" "${testnokfolders[$okcode]}"

    ## The following line makes for a maximum of $PARALLEL_THREADS parallel threads before proceeding
    ((threadscounter=threadscounter%PARALLEL_THREADS)); ((threadscounter++==0)) && wait

    ( \
       eval "${okinvoc} && ${nokinvoc}"
    ) &
    i=`expr $i + 2`
  done
done

echo "$i runs done"

exit 0
