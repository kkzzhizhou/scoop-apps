#!/bin/bash
###
 # @Author: zzz
 # @Date: 2021-03-03 05:13:39
# LastEditTime: 2021-12-06 17:15:12
 # @Description: autoupdate bucket:scoop-apps
 # @FilePath: /data/scoop-apps/autoupdate.sh
### 

# setting working dir
script_dir=$(cd $(dirname $0) && pwd)
cd $script_dir
cd ../../
# create cache dir
cache_dir=`mktemp -d`

apt -y update && apt -y install jq recode sqlite3

# generate bucket.config
init_scoop-zapps(){
    git clone --depth=1 https://github.com/kkzzhizhou/scoop-zapps  ${cache_dir}/scoop-zapps
    files=$(find ${cache_dir}/scoop-zapps -type f -name *.json -not -path "${cache_dir}/$bucket_dir/.vscode/*")
    for file in ${files[@]}
    do
        file_name=$(echo $file | awk -F'/' '{print $NF}')
        file_id=$(echo $file_name | tr 'A-Z' 'a-z')
        check_file_id=$(cat ${cache_dir}/file_ids | grep -E "^$file_id$" | wc -l)
        if [ "$check_file_id" -eq 0 ]
        then
            # record file_id
            echo $file_id >> ${cache_dir}/file_ids
        fi
        # record file_md5
        echo $file_md5 >> ${cache_dir}/file_md5
        # copy file to bucket
        cp -f $file ./bucket/$file_name
    done
}

# get bucket from rasa/scoop-directory
rm -f bucket.config
wget https://github.com/rasa/scoop-directory/raw/master/scoop_directory.db
if [ $? -eq 0 ];then
    count=$(sqlite3 ./scoop_directory.db "select count(1) from buckets");
    for((i=1;i<=$count;i++))
    do
        date_recode=$(sqlite3 ./scoop_directory.db "select updated from buckets where id = $i" | recode html)
        sqlite3 ./scoop_directory.db "UPDATE buckets SET updated = '$date_recode' where id = $i"
    done
    check_date=$(date +"%y-%m-%d" -d '1 month ago')
    bucket_urls=$(sqlite3 ./scoop_directory.db "select bucket_url from buckets where packages >= 10 and stars >= 5 and updated > '$check_date' and bucket_url not like '%ScoopInstaller/Main%' and bucket_url not like '%kkzzhizhou/scoop-zapps%' order by stars desc, updated desc, stars desc")
    for bucket_url in ${bucket_urls[@]}; do
        bucket_name=$(echo $bucket_url | awk -F'/' '{print $(NF-1)"/"$NF}')
        echo "add bucket:$bucket_name"
        echo "$bucket_name" >> bucket.config
    done
fi

buckets=$(cat bucket.config)
script_buckets=$(tac bucket.config)
confuses=$(cat $script_dir/app.confuse)

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

# add json
add_to_bucket(){
    local file="$1"
    local file_name="$2"
    local bucket="$3"
    cat $file | jq > /dev/null 2&>1
    if [ $? -eq 0 ];then
        cp -f $file ./bucket/$file_name
    else
        echo "$file is invalid."
    fi
	echo "$file_name    $bucket" >> app-contributor-list.txt
}

# init main
init_main(){
    git clone --depth=1 https://github.com/ScoopInstaller/Main  ${cache_dir}/Main
    files=$(find ${cache_dir}/Main -type f -name *.json -not -path "${cache_dir}/$bucket_dir/.vscode/*")
    for file in ${files[@]}
    do
        file_name=$(echo $file | awk -F'/' '{print $NF}')
        echo $file_name | tr 'A-Z' 'a-z' >> ${cache_dir}/file_ids
    done
}

# merge bucket
rm -f bucket/*.json
rm -f ${cache_dir}/file_ids && touch ${cache_dir}/file_ids
rm -f ${cache_dir}/file_md5 && touch ${cache_dir}/file_md5
rm -f app-contributor-list.txt
echo "name    bucket" > app-contributor-list.txt
init_main
init_scoop-zapps
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
            add_to_bucket "$file" "$file_name" "$bucket"
        elif [ "$check_file_md5" -eq 0 ]
        then
            # rename file
            owner=$(echo $bucket | awk -F'/' '{print $1}')
            new_name=$(echo $file_name | sed "s/.json/_$owner.json/")
            # record file_md5
            echo $file_md5 >> ${cache_dir}/file_md5
            # copy file to bucket
            add_to_bucket "$file" "$new_name" "$bucket"
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
