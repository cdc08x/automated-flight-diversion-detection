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

okfolders=(
  "$BASE_DIR/flights/OK_1:$BASE_DIR/flights/OK_2:$BASE_DIR/flights/OK_3:$BASE_DIR/flights/OK_4"
  "$BASE_DIR/flights/OK_1:$BASE_DIR/flights/OK_2:$BASE_DIR/flights/OK_3:$BASE_DIR/flights/OK_5"
  "$BASE_DIR/flights/OK_1:$BASE_DIR/flights/OK_2:$BASE_DIR/flights/OK_4:$BASE_DIR/flights/OK_5"
  "$BASE_DIR/flights/OK_1:$BASE_DIR/flights/OK_3:$BASE_DIR/flights/OK_4:$BASE_DIR/flights/OK_5"
  "$BASE_DIR/flights/OK_2:$BASE_DIR/flights/OK_3:$BASE_DIR/flights/OK_4:$BASE_DIR/flights/OK_5"
)
foldercounter=0
okcodes=(
  "1234"
  "1235"
  "1245"
  "1345"
  "2345"
)

nokfolders=(
  "$BASE_DIR/flights/NOK-1"
  "$BASE_DIR/flights/NOK-2"
)
nokcodes=(
  "1"
  "2"
)

cd "$python_script_folder"

threadscounter=0

i=0
for (( okcounter=0; okcounter<${#okfolders[@]} && okcounter<${#okcodes[@]}; okcounter++ ))
do
  okfolder=${okfolders[$okcounter]}
  okcode=${okcodes[$okcounter]}
  for interval_min in $interval_mins
  do
    interval=`expr $interval_min \* 60`
    svmswrapperfolder=`printf "$svmswrapperfoldertemplate" "$interval"`
    if [ ! -d "$svmswrapperfolder" ]; then mkdir "$svmswrapperfolder"; fi
#    for threshold in $thresholds
      for nu_cent in $nu_cents
      do
        nu=`echo "0.01 * ${nu_cent}" | bc -l | sed -e 's/00*$//' -e 's/^\./0./' | tr -d '\n'`
#        printf -v nu "0.%02d\n" "$nu_cent"
#        echo "nu = $nu"
        for gamma_exp in $gamma_exps
        do
          gamma=`echo "2 ^ ${gamma_exp}" | bc -l | sed -e 's/00*$//' -e 's/^\./0./' | tr -d '\n'`
#          echo "gamma = $gamma"
          svmfolder=`printf "$svmsfoldertemplate" ${interval} $okcode ${interval} ${nu//\./} ${gamma//\./}`
          ## The following line makes for a maximum of $PARALLEL_THREADS parallel threads before proceeding
          ((threadscounter=threadscounter%PARALLEL_THREADS)); ((threadscounter++==0)) && wait
          ( \
            if [ ! -d "$svmfolder" ]; then mkdir "$svmfolder"; fi && \
            python train.py --nu ${nu} --gamma ${gamma} --interval ${interval} --trainingfolders $okfolder --svmfolder $svmfolder \
          ) &
          i=`expr $i + 1`
##          if [[ i -gt 8 ]]; then exit 0; fi
        done
      done
#  done
  done
done

echo "$i runs operated in total"

exit 0

for i in {1..10}
do
  ((j=j%PARALLEL_THREADS)); ((j++==0)) && wait
  (sleep `expr $i` && echo "DONE $i") &
done

wait

exit 0
