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

# generate bucket.config
echo "kkzzhizhou/scoop-zapps" > bucket.config

# clone rasa/scoop-directory
temp_dir=`mktemp -d`
[ -d "$temp_dir/scoop-directory" ] || git clone --depth=1 https://github.com/rasa/scoop-directory $temp_dir/scoop-directory
buckets=$(cat ${temp_dir}/scoop-directory/by-stars.md | sed '/###/, /$d/d' | grep "name=" | sed "s/<[^>]*>//g" | sed 's/_//g' | awk -F'[][]' '{print $4","$6","$8}' | grep -v 'kkzzhizhou/scoop-zapps' | grep -v 'ScoopInstaller/Main')
for bucket in ${buckets[@]}; do
    bucket_name=$(echo $bucket | awk -F',' '{print $1}')
    app_num=$(echo $bucket | awk -F',' '{print $2}')
    star_num=$(echo $bucket | awk -F',' '{print $3}')
    if [ "$app_num" -gt 10 -a "$star_num" -gt 5 ];then
        echo "$bucket_name" >> bucket.config
    fi
done

buckets=$(cat bucket.config)
script_buckets=$(tac bucket.config)
confuses=$(cat $script_dir/app.confuse)

# create cache dir
cache_dir=`mktemp -d`

# download bucket
for bucket in ${buckets[@]}
do
    bucket_dir=$(echo $bucket | sed 's@/@-@g')
    if [ ! -d "${cache_dir}/$bucket_dir" ]
    then
        echo "clone bucket:$bucket"
        git clone --depth=1 https://github.com/$bucket ${cache_dir}/$bucket_dir
    fi
done

# merge scripts
rm -rf scripts/*
for bucket in ${script_buckets[@]}
do
    bucket_dir=$(echo $bucket | sed 's@/@-@g')
    if [ -d "${cache_dir}/${bucket_dir}/scripts" ]
    then
        cp -rf ${cache_dir}/${bucket_dir}/scripts/* ./scripts/
    fi
done

# merge bucket
rm -f bucket/*.json
rm -f ${cache_dir}/file_ids && touch ${cache_dir}/file_ids
rm -f ${cache_dir}/file_md5 && touch ${cache_dir}/file_md5
rm -f app-contributor-list.txt
echo "name    bucket" > app-contributor-list.txt
for bucket in ${buckets[@]}
do
    bucket_dir=$(echo $bucket | sed 's@/@-@g')
    echo $bucket_dir
    files=$(find ${cache_dir}/${bucket_dir} -type f -name *.json -not -path "${cache_dir}/$bucket_dir/.vscode/*")
    for file in ${files[@]}
    do
        file_name=$(echo $file | awk -F'/' '{print $NF}')
        file_id=$(echo $file_name | tr 'A-Z' 'a-z')
        file_md5=$(md5sum $file | awk '{print $1}')
        check_file_id=$(cat ${cache_dir}/file_ids | grep -E "^$file_id$" | wc -l)
        check_file_md5=$(cat ${cache_dir}/file_md5 | grep -E "^$file_md5$" | wc -l)
        if [ "$check_file_id" -eq 0 ]
        then
            # record file_id
            echo $file_id >> ${cache_dir}/file_ids
            # record file_md5
            echo $file_md5 >> ${cache_dir}/file_md5
            # copy file to bucket
            cp -f $file ./bucket/$file_name
	        # record app-contributor-list.txt
	        echo "$file_name    $bucket" >> app-contributor-list.txt
        elif [ "$check_file_md5" -eq 0 ]
        then
            # rename file
            owner=$(echo $bucket | awk -F'/' '{print $1}')
            new_name=$(echo $file_name | sed "s/.json/_$owner.json/")
            # record file_md5
            echo $file_md5 >> ${cache_dir}/file_md5
	        # record app-contributor-list.txt
	        echo "$new_name    $bucket" >> app-contributor-list.txt
            # copy file to bucket
            cp -f $file ./bucket/$new_name
        else
           # ignore duplicate file
           echo "duplicate file:$bucket   $file"
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
