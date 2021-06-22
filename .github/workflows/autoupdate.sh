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
cd ../../

buckets=$(cat $script_dir/bucket.config)
confuses=$(cat $script_dir/app.confuse)

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
        git clone https://github.com/$bucket cache/$bucket_dir --depth==1
    fi
done

# merge bucket
rm -f bucket/*.json
rm -f cache/file_ids && touch cache/file_ids
rm -f app-contributor-list.txt
echo "name    bucket" > app-contributor-list.txt
for bucket in ${buckets[@]}
do
    bucket_dir=$(echo $bucket | sed 's@/@-@g')
    echo $bucket_dir
    files=$(find cache/$bucket_dir -type f -name *.json -not -path "cache/$bucket_dir/.vscode/*")
    for file in ${files[@]}
    do
        file_name=$(echo $file | awk -F'/' '{print $NF}')
        file_id=$(echo $file_name | tr 'A-Z' 'a-z')
        check_file_id=$(cat cache/file_ids | grep -E "^$file_id$" | wc -l)
        if [ "$check_file_id" -eq 0 ]
        then
            # record file_id
            echo $file_id >> cache/file_ids
            cp -f $file ./bucket/$file_name
	    # record app-contributor-list.txt
	    echo "$file_name    $bucket" >> app-contributor-list.txt 
        else
            # rename file
            owner=$(echo $bucket | awk -F'/' '{print $1}')
            new_name=$(echo $file_name | sed "s/.json/_$owner.json/")
            cp -f $file ./bucket/$new_name
	    # record app-contributor-list.txt
	    echo "$new_name    $bucket" >> app-contributor-list.txt 
        fi
    done
done

# fix confuse manifest
for confuse in ${confuses[@]}
do
    realapp=$(echo $confuse | awk -F'=' '{print $1}')
    confuse_names=$(echo $confuse | awk -F'=' '{print $2}' | sed 's/,/ /g')
    for confuse_name in ${confuse_names[@]}
    do
        cat ./bucket/$realapp.json > ./bucket/$confuse_name.json
    done
done

# update README.md

sed -i '/^# 合并仓库列表/,$d' README.md
echo -e "# 合并仓库列表\n" >> README.md
for bucket in ${buckets[@]}
do
    echo "- $bucket" >> README.md
done


# fix nothing commit
echo "最近更新时间：`date`" > latest.update
