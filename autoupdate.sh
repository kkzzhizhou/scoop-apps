#!/bin/bash
###
 # @Author: zzz
 # @Date: 2021-03-03 05:13:39
 # @LastEditTime: 2021-03-03 07:48:38
 # @Description: autoupdate bucket:scoop-apps
 # @FilePath: /data/scoop-apps/autoupdate.sh
### 

# setting working dir
script_dir=$(cd $(dirname $0) && pwd)
cd $script_dir

buckets=$(cat bucket.config)

# check env
echo "check cache dir"
if [ ! -d "cache" ]
then
    mkdir -p cache
fi

# download bucket
for bucket in ${buckets[@]}
do
    bucket_dir=$(echo $bucket | sed 's@/@-@g')
    if [ ! -d "cache/$bucket_dir" ]
    then
        echo "clone bucket:$bucket"
        git clone https://github.com/$bucket cache/$bucket_dir
    fi
done

# merge bucket
rm -f cache/file_ids && touch cache/file_ids
for bucket in ${buckets[@]}
do
    bucket_dir=$(echo $bucket | sed 's@/@-@g')
    files=$(find cache/$bucket_dir -type f -name *.json -not -path "cache/$bucket_dir/.vscode/*")
    for file in ${files[@]}
    do
        file_name=$(echo $file | awk -F'/' '{print $NF}')
        file_id=$(echo $file_name | tr 'A-Z' 'a-z')
        check_file_id=$(cat cache/file_ids | grep $file_id | wc -l)
        if [ "$check_file_id" -eq 0 ]
        then
            # record file_id
            echo $file_id >> cache/file_ids
            cp -f $file ./bucket/$file_name
        else
            # rename file
            owner=$(echo $bucket | awk -F'/' '{print $1}')
            new_name=$(echo $file_name | sed "s/.json/$owner.json/")
            cp -f $file ./bucket/$new_name
        fi
    done
done
