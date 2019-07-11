#!/bin/bash

config_file=
pwd=`pwd`

echo 
echo 

if [ $1 ]; then
	if [ ! -e $1 ]; then
		echo "plese select a right config file."
		exit 1
	else
		config_file=$1
	fi	
else
	echo "use default config file."
	config_file=git_url_list.conf
fi

echo "=============================================="
echo "-- sync repository form gitee"
echo "-- config file: $config_file"
echo "=============================================="
echo 

url=
path=

origin_branch=
branch=
total_cnt=0

cat $config_file | while read line
do
	##line=`echo $line | tr -s [ ]`

	if [[ -z $line || $line != g* ]]
	then
		continue
	fi

	echo "--------------------------------"
	let total_cnt=total_cnt+1
	echo "@ $total_cnt"

	url=`echo $line | cut -d' ' -f 1`
	path=`echo $line | cut -d' ' -f 2`

	## 如果没有填写path 则使用url中的path信息
	if [[ -z $path || $path == $url ]];then
		path=`basename $url`
		path=`echo $path | cut -d'.' -f 1`	
	fi
	
	echo $path
	echo "--------------------------------"
	echo "$url ==> $path"

	if [ ! -d $path ]; then
		git clone $url $path
	fi

	cd $path

	if [ ! -d .git ]; then
		echo -e "warning: this direatory is not a git repo."
		cd ..
		rm -rf $path
		git clone $url $path
		cd $path
	fi

	origin_branch=`git branch -r`
	##origin_branch=`echo $origin_branch | cut -d' ' -f 3-`
	for remote_branch in $origin_branch
	do
		if [[ $remote_branch != o* ]];then
			continue
		fi
		branch=`basename $remote_branch`
		if [[ $branch == HEAD ]];then
			continue
		fi
		echo "$branch <== $remote_branch"
		git checkout -b `basename $remote_branch` $remote_branch 
		git pull
		echo 
	done
	git checkout master
	cd $pwd
	echo "--------------------------------"
	echo	
done 

echo
echo
