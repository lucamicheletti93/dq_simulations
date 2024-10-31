#!/bin/bash

error=0

#find ./ \( -name "*.log*" -o -name "*mergerlog*" -o -name "*serverlog*" -o -name "*workerlog*" \) | tar -czvf debug_log_archive.tgz -T -
#find ./ \( -name "*.log*" -o -name "*mergerlog*" -o -name "*serverlog*" -o -name "*workerlog*" \) | tar cfJ debug_log_archive.xz -T -

readarray -t dirs < <(find . -mindepth 1 -maxdepth 1 -type d -printf '%P\n'|grep tf)
dirs+=(.)

(
echo "* *****************************************************"
echo "* AliRoot Validation Script V3.0                      *"
echo "* Time:    `date`"
echo "* Dir:     $validateout"
echo "* Workdir: $validateworkdir"
echo "* PATH: $PATH"
echo "* LD_LIBRARY_PATH: $LD_LIBRARY_PATH"
echo "* ----------------------------------------------------*"

echo "Found ${#dirs[@]} subdirectories"

echo "Listing output"
ls -lh ./*

echo "du -h --max-depth=1 ."
du -h --max-depth=1 .

echo "* ----------------------------------------------------*"
) >> stdout

if [ ${#dirs[@]} = 0 ]; then
  error=2
fi

for dir in ./; do
# for dir in "${dirs[@]}"; do
    echo "Search path $dir" >> stdout
    if [ -f $dir/AO2D.root ]; then
      echo "  [OK] AO2D.root found in $dir" >> stdout
#      echo $dir/AO2D.root >> inputfile.txt
    else
      echo "  [FAILED] AO2D.root not found in $dir!" >> stdout
      error=1
    fi
done

###
### error log
###
##errstring="Detected critical problem in logfile"
##
##if grep -q "$errstring" stdout ; then
##  error=3
##  found=$(grep "$errstring" stdout)
##  logfile=${found##*' '}
##  logbase=${logfile%%.*}
##  tfid=tf${logbase##*'_'}
##
##  #echo "Offending log file $tfid/$logfile"
##  echo "cat $tfid/$logfile"
##  cat $tfid/$logfile
##fi

(
if [ $error = 0 ] ; then
  echo "* ----------------  Job Validated  -------------------*"

#  echo "*   Moving tf*/AO2D.root into parent folder"
##  for dir in "${dirs[@]}"; do
##    id=$(printf %03d $(echo $dir|cut -c3-))
##    mv -v $dir/AO2D.root AO2D_${id}.root
##  done
#  echo "inputfile.txt"
#  cat inputfile.txt
#  # 10 GB root folders
#  o2-aod-merger --input inputfile.txt --max-size 10000000000 
#  # 100 MB root folders
#  o2-aod-merger --input inputfile.txt --max-size 100000000

else
  echo "* ----------------  Job not validated!  -------------*"
  echo "*   Error = $error"
  if [ $error = 1 ]; then
    echo "*     Not all the AO2D.root files were registered in output"
  elif [ $error = 2 ]; then
    echo "*     Not any AO2D.root files found in output"
  elif [ $error = 3 ]; then
    echo "*     Detected critical problem in one of the logs"
  fi
fi
echo "* ----------------------------------------------------*"
echo "*******************************************************"
) >> stdout


echo "===> return error code $error"
exit $error

