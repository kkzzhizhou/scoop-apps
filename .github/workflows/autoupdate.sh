#!/bin/bash
# @Description: autoupdate bucket:scoop-apps

# get bucket from rasa/scoop-directory
gen_bucket_config(){
    rm -f bucket.config
    # import bucket-recommand.txt
    cp -f "bucket-recommand.txt" bucket.config
    # get bucket from rasa/scoop-directory
    wget https://github.com/rasa/scoop-directory/raw/master/scoop_directory.db
    if [ $? -eq 0 ];then
        count=$(sqlite3 ./scoop_directory.db "select count(1) from buckets");
        for((i=1;i<=$count;i++))
        do
            date_recode=$(sqlite3 ./scoop_directory.db "select updated from buckets where id = $i" | recode html)
            sqlite3 ./scoop_directory.db "UPDATE buckets SET updated = '$date_recode' where id = $i"
        done
        check_date=$(date +"%y-%m-%d" -d '1 month ago')
        bucket_urls=$(sqlite3 ./scoop_directory.db "select bucket_url from buckets where packages >= 10 and stars >= 5 and updated > '$check_date' and bucket_url not like '%ScoopInstaller/Main%' order by stars desc, updated desc, stars desc")
        for bucket_url in ${bucket_urls[@]}; do
            bucket_name=$(echo $bucket_url | awk -F'/' '{print $(NF-1)"/"$NF}')
            echo "add bucket:$bucket_name"
            echo "$bucket_name" >> bucket.config
        done
    fi
    # bucket remove duplicate
    awk ' !x[$0]++' bucket.config
    # remove bucket-not-recommand.txt
    not_recommand_buckets=$(cat bucket-not-recommand.txt)
    for bucket in ${not_recommand_buckets[@]}
    do
        echo "remove bucket:$bucket"
	grep -n "$bucket" bucket.config | awk -F':' '{print $1}' | xargs -n 1 -I num sed -i  'numd' bucket.config
    done
}

# download bucket
download_bucket(){
    buckets=$(cat bucket.config)
    script_buckets=$(tac bucket.config)
    confuses=$(cat $script_dir/app.confuse)
    for bucket in ${buckets[@]}
    do
        bucket_dir=$(echo $bucket | sed 's@/@-@g')
        if [ ! -d "${cache_dir}/$bucket_dir" ]
        then
            echo "clone bucket:$bucket"
            git clone --depth=1 https://github.com/$bucket ${cache_dir}/$bucket_dir
        fi
    done
}
# merge scripts
merge_scripts(){
    rm -rf scripts/*
    for bucket in ${script_buckets[@]}
    do
        bucket_dir=$(echo $bucket | sed 's@/@-@g')
        if [ -d "${cache_dir}/${bucket_dir}/scripts" ]
        then
            cp -rf ${cache_dir}/${bucket_dir}/scripts/* ./scripts/
        fi
    done
}
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
        echo "$file_name,$bucket" >> app-contributor-list.csv
}

# init main bucket
init_main(){
    clean_workspace
    rm -rf ${cache_dir}/Main
    git clone --depth=1 https://github.com/ScoopInstaller/Main  ${cache_dir}/Main
    files=$(find ${cache_dir}/Main -type f -name *.json -not -path "${cache_dir}/$bucket_dir/.vscode/*")
    for file in ${files[@]}
    do
        file_name=$(echo $file | awk -F'/' '{print $NF}')
        echo $file_name | tr 'A-Z' 'a-z' >> ${cache_dir}/main_file_ids
    done
}

# version compare
version_gt() {
    test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" != "$1";
}

check_cli_exist(){
    command -v $1 > /dev/null
    if [ "$?" != "0" ]
    then
        sudo apt-get -y update && sudo apt-get -y install $1
    else
        echo "环境检查：$1已安装"
    fi
}

apt_init() {
    check_cli_exist jq
    check_cli_exist recode
    check_cli_exist sqlite3
}

clean_workspace() {
    rm -f bucket/*.json
    cat /dev/null > ${cache_dir}/main_file_ids
    cat /dev/null > ${cache_dir}/file_ids
    cat /dev/null > ${cache_dir}/file_md5
    cat /dev/null > ${cache_dir}/file_id_name
    echo "name,bucket" > app-contributor-list.csv
    echo "清理工作空间: bucket/*.json file_ids file_md5 file_id_name app-contributor-list.csv"
}

# setting working dir
setting_working_dir(){
    script_dir=$(cd $(dirname $0) && pwd)
    cd $script_dir
    cd ../../
    echo "当前脚本工作路径: $PWD"
}

# create cache dir
create_cache_dir(){
    cache_dir=`mktemp -d`
    echo "当前缓存工作路径(cache_dir):$cache_dir"
}

# merge buckets
merge_buckets(){
    buckets=$(cat bucket.config)
    for bucket in ${buckets[@]}
    do
        bucket_dir=$(echo $bucket | sed 's@/@-@g')
        owner=$(echo $bucket | awk -F'/' '{print $1}')
        echo "正在处理仓库: $bucket 仓库名:$bucket_dir 仓库github账号:$owner 时间: $(date '+%Y-%m-%d %H:%M:%S')"
        files=$(find ${cache_dir}/${bucket_dir} -type f -name *.json ! -name ".*" -not -path "${cache_dir}/$bucket_dir/.vscode/*" )
        files_array=(${files})
        if [ ${#files_array[*]} -gt 2000 -a $owner != "ScoopInstaller" ]
        then
            echo "仓库描述文件过多，忽略: $bucket 仓库名:$bucket_dir 仓库github账号:$owner"
            continue
        fi
        for file in ${files[@]}
        do
            file_name=$(echo $file | awk -F'/' '{print $NF}') # json文件名
            new_name=$(echo $file_name | sed "s/.json/_$owner.json/") # id重复时的文件名
            file_id=$(echo $file_name | tr 'A-Z' 'a-z') # json文件id
            check_main_file_id=$(cat ${cache_dir}/main_file_ids | grep -E "^$file_id$" | wc -l) # 检查文件id是否与main仓库重复
            if [ "$check_main_file_id" != "0" ];then
                echo "${file_id}与main仓库同名"
                add_to_bucket "$file" "$new_name" "$bucket"
                continue
            fi
            file_md5=$(md5sum $file | awk '{print $1}') # json文件md5
            jq -e . >/dev/null 2>&1 <<< $(cat ${file}) # 检验json文件格式
            if [ "$?" -eq 0 ]
            then
                app_version=$([ -f "${file}" ] && cat "${file}" | jq -r '.version' || echo "0")
                if [ ${app_version} == "nightly" -o ${app_version} == "latest" ]
                then
                    app_version="0"
                fi
            else
                app_version='0.0.0'
            fi
            check_file_id=$(cat ${cache_dir}/file_ids | grep -E "^$file_id$" | wc -l) # 检查文件id是否已经存在
            check_file_md5=$(cat ${cache_dir}/file_md5 | grep -E "^$file_md5$" | wc -l) # 检查文件md5是否已经存在
            if [ "$check_file_md5" -eq 0 ]
            then
                echo $file_md5 >> ${cache_dir}/file_md5
                if [ "$check_file_id" -eq 0 ]
                then
                    echo $file_id >> ${cache_dir}/file_ids
                    echo "$file_id $new_name" >> ${cache_dir}/file_id_name
                    add_to_bucket "$file" "$file_name" "$bucket"
                else
                    bucket_app_name=$(ls bucket | grep -Ei "^$file_id$" | head -n 1)
                    if [ -f "bucket/${bucket_app_name}" ]
                    then
                        jq -e . >/dev/null 2>&1 <<< $(cat "bucket/${bucket_app_name}")
                        if [ "$?" -eq 0 ]
                        then
                            bucket_app_version=$([ -f "bucket/${bucket_app_name}" ] && cat "bucket/${bucket_app_name}" | jq -r '.version' || echo "0")
                            if [ ${bucket_app_version} == "nightly" -o ${bucket_app_version} == "latest" ]
                            then
                                bucket_app_version="0"
                            fi
                        else
                            bucket_app_version="0"
                        fi
                        bucket_app_new_name=$(cat ${cache_dir}/file_id_name | grep -E "^$file_id "| awk '{print $2}')
                        version_gt ${app_version} ${bucket_app_version}
                        if [ $? -eq 0 ]
                        then
                            echo "bucket_app_name:${bucket_app_name}  bucket_app_version:${bucket_app_version} bucket_app_new_name:${bucket_app_new_name} app_version:${app_version} app_bucket:${bucket}"
                            mv -f bucket/${bucket_app_name} bucket/${bucket_app_new_name}
                            sed -i "s/${bucket_app_new_name}/${new_name}/" ${cache_dir}/file_id_name
                            add_to_bucket "$file" "$file_name" "$bucket"
                        else
                            add_to_bucket "$file" "$new_name" "$bucket"
                        fi
                    else
                        echo "${file_id} no found"
                        #ls bucket
                    fi
                fi
            # else
                # ignore duplicate file
                # echo "duplicate file:$bucket   $file"
            fi
        done
        echo "完成处理仓库: $bucket 仓库名:$bucket_dir 仓库github账号:$owner 时间: $(date '+%Y-%m-%d %H:%M:%S')"
    done
}

# fix confuse manifest
fix_confuse_manifest(){
    for confuse in ${confuses[@]}
    do
        realapp=$(echo $confuse | awk -F'=' '{print $1}')
        confuse_names=$(echo $confuse | awk -F'=' '{print $2}' | sed 's/,/ /g')
        for confuse_name in ${confuse_names[@]}
        do
            cat ./bucket/$realapp.json > ./bucket/$confuse_name.json
        done
    done
}

# update README.md
update_readme(){
    sed -i '/^## 合并仓库列表/,$d' README.md
    echo -e "## 合并仓库列表\n" >> README.md
    for bucket in ${buckets[@]}
    do
        echo "- $bucket" >> README.md
    done
}

# fix nothing commit
fix_nothing_submit(){
    echo "最近更新时间：`date`" > latest.update
    rm -f 1
}

main(){
    setting_working_dir
    create_cache_dir
    apt_init
    init_main # 生成用于过滤main仓库的file_id列表
    gen_bucket_config
    download_bucket
    merge_scripts
    merge_buckets
    fix_confuse_manifest
    update_readme
    fix_nothing_submit
}

main
