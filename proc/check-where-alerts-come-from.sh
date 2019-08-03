#!/bin/bash

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

alertsfile="$BASE_DIR/alerts-of-bestfscorers-on-noks.csv"
findstrings=`sed -n -e 's/^.*div-check;\(.*\.xml\).*$/find . -type f -name "\1"/gp' "$alertsfile"`

alertsFromValidationSet=""
alertsFromTestSet=""

while read -r cmd
do
#  echo "$cmd"
  result=`eval "$cmd"`
  alertsFromValidationSet="$alertsFromValidationSet`printf "%s\n" $result | grep -e 'NOK_1' | sed 's/^.*NOK\_1\//\n/g'`" 
  alertsFromTestSet="$alertsFromTestSet`printf "%s\n" $result | grep -e 'NOK_2' | sed 's/^.*NOK\_2\//\n/g'`"
done <<< "$findstrings"

numOfAlertsFromValidationSet=`echo "$alertsFromValidationSet" | wc -l`
numOfAlertsFromTestSet=`echo "$alertsFromTestSet" | wc -l`

alertsFromValidationSet="`echo "$alertsFromValidationSet" | sed 's/^$/Alerts from the validation set:/'``echo Total from the validation set: $numOfAlertsFromValidationSet`"
alertsFromTestSet="`echo "$alertsFromTestSet" | sed 's/^$/Alerts from the test set:/'``echo Total from the test set: $numOfAlertsFromTestSet`"

echo "$alertsFromValidationSet"
echo "$alertsFromTestSet"

exit 0

find . -type f -name "LH471201382.xml"
find . -type f -name "25002881.xml"
find . -type f -name "EV3811201382.xml"
find . -type f -name "24610218.xml"
find . -type f -name "24785369.xml"
find . -type f -name "24877765.xml"
find . -type f -name "24981143.xml"
find . -type f -name "EV5700201382.xml"
find . -type f -name "24887894.xml"
find . -type f -name "24960571.xml"
find . -type f -name "EV6027201382.xml"
find . -type f -name "24786232.xml"
find . -type f -name "DL615201381.xml"
find . -type f -name "24643747.xml"
find . -type f -name "EV4703201382.xml"
find . -type f -name "24903719.xml"
find . -type f -name "VS7201388.xml"
find . -type f -name "24711371.xml"
find . -type f -name "24767743.xml"
find . -type f -name "24652909.xml"
find . -type f -name "24953876.xml"
find . -type f -name "24871421.xml"
find . -type f -name "24738444.xml"
find . -type f -name "24559131.xml"
find . -type f -name "9E3734201382.xml"
find . -type f -name "25011286.xml"
find . -type f -name "24936159.xml"
find . -type f -name "UA605201382.xml"
find . -type f -name "EV4368201382.xml"
find . -type f -name "24787250.xml"
find . -type f -name "1I9432013811.xml"
find . -type f -name "24613132.xml"
find . -type f -name "24729298.xml"
find . -type f -name "24958582.xml"
find . -type f -name "24855206.xml"
find . -type f -name "UA1155201382.xml"
find . -type f -name "24643263.xml"
find . -type f -name "24791773.xml"
find . -type f -name "OO63292013811.xml"
find . -type f -name "24939815.xml"
find . -type f -name "XOJ549201382.xml"
find . -type f -name "24893847.xml"
find . -type f -name "24923099.xml"
find . -type f -name "24869930.xml"
find . -type f -name "24690376.xml"
find . -type f -name "24931662.xml"
find . -type f -name "24780055.xml"
find . -type f -name "24788175.xml"
find . -type f -name "24686477.xml"
find . -type f -name "EV5946201382.xml"
find . -type f -name "24740978.xml"
find . -type f -name "EV5987201382.xml"
find . -type f -name "AX3414201382.xml"
find . -type f -name "24959354.xml"
find . -type f -name "VX69201382.xml"
