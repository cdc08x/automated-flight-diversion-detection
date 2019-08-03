#!/bin/bash

PARALLEL_THREADS=8

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

nu_cents=$(seq 1 16)
gamma_exps=$(seq -4 4)
interval_mins=$(seq 2 8)
thresholds=$(seq 1 10)

svmswrapperfoldertemplate="$BASE_DIR/SVMs/SVMs_interval-%s"
svmsfoldertemplate="$svmswrapperfoldertemplate/SVM-%s_interval-%s_nu-%s_gamma-%s"

python_script_folder="$BASE_DIR/src"

foldercounter=0
okcodes=(
  "1234"
  "1235"
  "1245"
  "1345"
  "2345"
)

validationokfolders=()
validationokfolders[1234]="$BASE_DIR/flights/OK_5"
validationokfolders[1235]="$BASE_DIR/flights/OK_4"
validationokfolders[1245]="$BASE_DIR/flights/OK_3"
validationokfolders[1345]="$BASE_DIR/flights/OK_2"
validationokfolders[2345]="$BASE_DIR/flights/OK_1"

nokfolders=(
  "$BASE_DIR/flights/NOK_1" # let us use it for validation
  "$BASE_DIR/flights/NOK_2" # let us use it for testing
)
validationnokfolder=()
validationnokfolders[1234]="${nokfolders[0]}"
validationnokfolders[1235]="${nokfolders[0]}"
validationnokfolders[1245]="${nokfolders[0]}"
validationnokfolders[1345]="${nokfolders[0]}"
validationnokfolders[2345]="${nokfolders[0]}"

testnokfolder=${nokfolders[1]}

cd "$python_script_folder"

threadscounter=0

i=0

for interval_min in $interval_mins
do
  interval="$interval_min"
  interval=`expr $interval_min \* 60`
  wrapdir=`printf "$svmswrapperfoldertemplate" "$interval"`
  if [ -d "$wrapdir" ]
  then

    for file in "$wrapdir/"SVM*
    do
      if [ -d $file ]
      then
        for threshold in $thresholds
        do
          file=`basename $file`
          interval=`echo "$file" | sed -e 's/^.*interval-\([0-9][0-9]*\).*$/\1/p' -n`
          nu=`echo "$file" | sed -e 's/^.*nu-\([0-9][0-9]*\).*$/\1/p' -n | sed -e 's/^0/0./g'`
          gamma=`echo "$file" | sed -e 's/^.*gamma-\([0-9][0-9]*\).*$/\1/p' -n | sed -e 's/^0/0./g'`
          svmfolder="$wrapdir/$file"
          code=`echo "$file" | sed -e 's/^.*SVM-\([0-9][0-9]*\).*$/\1/p' -n`

          ## The following line makes for a maximum of $PARALLEL_THREADS parallel threads before proceeding
          ((threadscounter=threadscounter%PARALLEL_THREADS)); ((threadscounter++==0)) && wait
        
          ( \
            python detect.py --interval ${interval} --threshold ${threshold} --svmfolder ${svmfolder} ${validationokfolders[$code]} && \
            python detect.py --interval ${interval} --threshold ${threshold} --svmfolder ${svmfolder} ${validationnokfolders[$code]}
          ) &

          i=`expr $i + 2`

#echo "Analysing ${file}: code = $code interval = $interval nu = $nu gamma = $gamma"
#if [[ i -gt 9 ]]; then exit 0; fi

        done
      fi
    done

  fi
done

echo "$i runs executed"

exit 0
