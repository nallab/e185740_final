TEXT=$1
FILE_NAME="1g_dummy_split"
array=(`find ./  -type f -name "${FILE_NAME}*.txt" | sort`)
echo $TEXT
number=${#array[@]}
curl -b cookie.txt -X POST -F sort_file="${FILE_NAME}" -F merge_file="1g_dummy.txt" -F number="${number}"  -F file="@${TEXT}" https://www.shinya-tan.de/posts