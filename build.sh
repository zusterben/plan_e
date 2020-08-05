#!/bin/sh

MODULE=ssserver
VERSION=2.4
TITLE="ss-server"
DESCRIPTION="ss-server"
HOME_URL=Module_ssserver.asp
arch_list="mips mipsle arm armng arm64"

do_build() {
	if [ "$VERSION" = "" ]; then
		echo "version not found"
		exit 3
	fi
	echo $VERSION > $MODULE/version
	rm -f ${MODULE}.tar.gz
	rm -f $MODULE/.DS_Store
	rm -f $MODULE/*/.DS_Store
	rm -rf $MODULE/bin/obfs-server
	rm -rf $MODULE/bin/ss-server
	cp -rf ./bin_arch/$1/obfs-server $MODULE/bin/
	cp -rf ./bin_arch/$1/ss-server $MODULE/bin/
	tar -zcvf ${MODULE}.tar.gz $MODULE
	md5value=`md5sum ${MODULE}.tar.gz|tr " " "\n"|sed -n 1p`
	cat > ./version <<-EOF
	$VERSION
	$md5value
	EOF
	cat version
	
	DATE=`date +%Y-%m-%d_%H:%M:%S`
	cat > ./config.json.js <<-EOF
	{
	"build_date":"$DATE",
	"description":"$DESCRIPTION",
	"home_url":"$HOME_URL",
	"md5":"$md5value",
	"name":"$MODULE",
	"tar_url": "https://raw.githubusercontent.com/zusterben/plan_e/master/bin/$1/ssserver.tar.gz", 
	"title":"$TITLE",
	"version":"$VERSION"
	}
	EOF
	cp -rf version ./bin/$1/version
	cp -rf config.json.js ./bin/$1/config.json.js
	cp -rf ssserver.tar.gz ./bin/$1/ssserver.tar.gz
}

do_backup(){
	HISTORY_DIR="./history_package/$1"
	# backup latested package after pack
	backup_version=`cat version | sed -n 1p`
	backup_tar_md5=`cat version | sed -n 2p`
	echo backup VERSION $backup_version
	cp ${MODULE}.tar.gz $HISTORY_DIR/${MODULE}_$backup_version.tar.gz
	sed -i "/$backup_version/d" "$HISTORY_DIR"/md5sum.txt
	echo $backup_tar_md5 ${MODULE}_$backup_version.tar.gz >> "$HISTORY_DIR"/md5sum.txt
}

for arch in $arch_list
do
do_build $arch
do_backup $arch
done
rm version config.json.js ssserver.tar.gz

