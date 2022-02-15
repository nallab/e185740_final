FILE="1g_dummy.txt"
FILE_NAME="1g_dummy_split"
split -b 100m $FILE "${FILE_NAME}"
for f in ${FILE_NAME}??;do mv $f $f.txt;done
array=`find ./  -type f  -name "${FILE_NAME}*.txt" | sort`
time (
 echo $array | xargs -n 1 -P 100 sh mec_curl.sh
)
