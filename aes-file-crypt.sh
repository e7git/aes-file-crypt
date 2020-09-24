#!/bin/bash
#
# AES文件加解密小工具
# 基于CentOS Linux release 7.8.2003 (Core) OpenSSL 1.1.1g
# 使用方法：将脚本和需要加密的文件放到同一文件夹下，然后执行脚本
# 注意！该脚本会递归处理文件夹下所有的文件
# @version v1.0
#

KEY="c4ca4238a0b923820dcc509a6f75849bc4ca4238a0b923820dcc509a6f75849b" # 密钥，注意！这里是密钥不是密码，密钥是64位16进制数，通过其他算法获取，例如：KEY=strtolower(md5(密码))
IV=${KEY: 0 :32} # 偏移量，32位16进制数，这里取密钥前32位
DIR="."

#
# 加密文件夹下所有文件
#
aes_encrypt(){
    file_self=$DIR"/"$0
    file_count=0
    OLDIFS=$IFS
    IFS=$'\n'
    for file in `find $DIR -type f`
    do  
        if [ "$file" != "$file_self" ]
        then
            file_enc="$file"".enc"
            echo "[E] ""$file"
            openssl enc -e -aes-256-cbc -nosalt -K $KEY -iv $IV -in "$file" -out "$file_enc"
            rm -f "$file"
            let file_count=$file_count+1
        fi
    done
    IFS=$OLDIFS
    echo "Encryption complete! "$file_count" files."
    
}

#
# 解密文件夹下所有文件
#
aes_decrypt(){
    file_count=0
    OLDIFS=$IFS
    IFS=$'\n'
    for file in `find $DIR -type f`
    do  
        if [ ${file##*.} == "enc" ]
        then
            file_dec=${file%.*}
            echo "[D] ""$file"
            openssl enc -d -aes-256-cbc -nosalt -K $KEY -iv $IV -in "$file" -out "$file_dec"
            rm -f "$file"
            let file_count=$file_count+1
        fi
    done
    IFS=$OLDIFS
    echo "Decryption complete! "$file_count" files."
}

#
# 打印帮助信息
#
print_help(){
    echo "Command List:"
    echo " 	-e   加密文件夹下所有文件"
    echo " 	-d   解密文件夹下所有文件"
    exit 1
}


# 入口函数
run_main(){
    if [ $# == 0 ]
    then
        print_help
    fi

    case $1 in
        "-e")
            aes_encrypt
            ;;
        "-d")
            aes_decrypt
            ;;
        *)
            print_help
    esac
}

run_main $1
