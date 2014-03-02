#!/bin/bash

#######################################################################
#
# Nhom SV:
# 1. Nguyen Hoang Duong
# 2. Nguyen Quang Giang
# 3. Nguyen Cong Dieu

# De tai 11: Cap nhat, tim kiem va hien thi thong tin ve ALBUM
#######################################################################



# Cac thu tuc trong chuong trinh

# Thu tuc hien menu
mainMenu() {
	echo $'\n============ MAIN MENU ================='
	echo ' 1. Them album'
	echo ' 2. Tim kiem album'
	echo ' 3. Thong ke album'
	echo ' 0. Thoat chuong trinh'
	echo '============ MAIN MENU ================='
	printf 'Nhap menu: '; read menu
	case $menu in
	'1')
		addTextAlbum;;
	'2')
		findTextAlbumMenu;;
	'3')
		'Chua lam!!!!!!!!!!';;
	'0')
		echo 'Thoat chuong trinh'
		return 0;;
	*)
		echo 'Menu khong hop le.';;
	esac
	mainMenu
}

findTextAlbumMenu() {
	echo $'\n====== TIM KIEM ALBUM ======'
	echo '1. Tim kiem theo ma album'
	echo '2. Tim kiem theo ten album'
	#echo '3. Tim kiem theo theo loai ALBUM'
	#echo '4. Tim kiem theo NXB'
	echo '0. Quay lai menu chinh'
	printf 'Nhap menu: '; read m
	case $m in
		'1')
			findTextAlbumById;;
		'2')
			findTextAlbumByName;;
		'0')
			return;;
		*)
			echo 'Menu khong hop le.';;
	esac
	findTextAlbumMenu
}

manageTextAlbumMenu() {
echo $'\n'
	echo $'==== MENU QUAN LY ALBUM ===='
	echo '1. Xem thong tin ve album'
	echo '2. Sua thong tin album'
	echo '3. Xoa album'
	echo '4. Them bai hat'
	echo '0. Quay lai tim kiem album '
	printf 'Nhap menu: '; read m
	case $m in
		'1')
			displayTextAlbumInfo;;
		'2')
			editTextAlbum
			return;;
		'3')
			deleteTextAlbum
			return;;
		'4')
			addSong;;
		'0')
			return;;
		*)
			echo 'Menu khong hop le';;
	esac
	echo $'\n'	
	manageTextAlbumMenu
	
}

# Thu tuc Them ALBUM
addTextAlbum() {
	echo '----- THEM ALBUM -----'
	echo 'Nhap thong tin album moi:'
	echo 'Ma album:'; read Id
	echo 'Ten album:'; read Title
	echo 'The loai album:'; read Type
	echo 'Nam XB:'; read Composer
	checkExistTexAlbumId $Id
	code=$?
	if [ $code -eq 1 ]; then
		echo "Ma Album '$Id' da ton tai!"
		return 1
	fi
	echo "$Id">>$_TEXTALBUM
	echo "$Title">>$_TEXTALBUM
	echo "$Type">>$_TEXTALBUM
	echo "$Composer">>$_TEXTALBUM
	echo 'Them Album thanh cong!'
	return 0
}

editTextAlbum() {
echo $'\n'
	echo '----- SUA ALBUM ------'
	echo 'Nhap thong tin moi cho Album:'
	echo '(Bo trong neu khong muon thay doi)'
	echo 'Ma Album moi:'; read Id
	echo 'Ten Album moi:'; read Title
	echo 'The loai Album moi:'; read Type
	echo 'Nam XB moi:'; read Composer
	if [ "$Id" ]; then
		checkExistTexAlbumId $Id
		code=$?
		if [ $code -eq 1 ]; then
			echo "Ma ALBUM '$Id' da ton tai!"
			return 1
		fi
	fi
	# rewrite
	local lineNum=0
	local newFile="temp_$_TEXTALBUM"
	while read line; do
		lineNum=$(($lineNum+1))
		if [ $lineNum == $_TEXTALBUM_LINE ]; then
			if [ "$Id" ]; then
				echo "$Id">>$newFile
			else
				echo "$line">>$newFile
			fi
		elif [ $lineNum == $(($_TEXTALBUM_LINE+1)) ]; then
			if [ "$Title" ]; then
				echo "$Title">>$newFile
			else
				echo "$line">>$newFile
			fi
		elif [ $lineNum == $(($_TEXTALBUM_LINE+2)) ]; then
			if [ "$Type" ]; then
				echo "$Type">>$newFile
			else
				echo "$line">>$newFile
			fi
		elif [ $lineNum == $(($_TEXTALBUM_LINE+3)) ]; then
			if [ "$Composer" ]; then
				echo "$Composer">>$newFile
			else
				echo "$line">>$newFile
			fi
		else
			echo "$line">>$newFile
		fi
	done < $_TEXTALBUM
	rm $_TEXTALBUM
	mv $newFile $_TEXTALBUM
	echo 'Sua ALBUM thanh cong!'
}

deleteTextAlbum() {
	echo 'Ban co thuc su muon xoa ALBUM khong? [y/n]'; read c
	if [ $c = 'y' ]; then
		# rewrite
		local lineNum=0
		local newFile="temp_$_TEXTALBUM"
		while read line; do
			lineNum=$(($lineNum+1))
			if [ $lineNum -lt "${_TEXTALBUM_INFO[4]}" ] || [ $lineNum -gt $((${_TEXTALBUM_INFO[4]}+3)) ]; then
				echo "$line">>$newFile
			fi
		done < $_TEXTALBUM
		if [ ! -e $newFile ]; then
			echo -n ''>$newFile
		fi
		rm $_TEXTALBUM
		mv $newFile $_TEXTALBUM
		echo 'Xoa ALBUM thanh cong!'
	fi
}

displayTextAlbumInfo() {
echo $'\n'
	echo '----Thong tin ALBUM----  '
	echo "Ma ALBUM: ${_TEXTALBUM_INFO[0]}"
	echo "Ten ALBUM: ${_TEXTALBUM_INFO[1]}"
	echo "The loai ALBUM: ${_TEXTALBUM_INFO[2]}"
	echo "Nam XB: ${_TEXTALBUM_INFO[3]}"
}

# Ham kiem tra su ton tai cua ma ALBUM
checkExistTexAlbumId() {
	local code=0
	local lineNum=0
	local mod=0
	while read line; do
		lineNum=$(($lineNum+1))
		mod=`expr $lineNum % 4`
		if [ $mod -eq 1 ] && [ $line = $1 ]; then
			code=1
		fi
	done < $_TEXTALBUM
	return $code
}

findTextAlbumById() {
	local found=0
	local lineNum=0
	local mod=0
	local b=( '' '' '' '' '' )
	echo 'Nhap ma ALBUM can tim kiem:'; read Id
	while read line; do
		lineNum=$(($lineNum+1))
		mod=`expr $lineNum % 4`
		if [ $mod -eq 1 ]; then
			if [ $line = $Id ]; then
				found=1
				_TEXTALBUM_LINE=$lineNum
				b[1]=$line
			fi
		elif [ $found -eq 1 ]; then
			b[$mod]=$line
			if [ $mod -eq 0 ]; then
				break
			fi
		fi
	done < $_TEXTALBUM
	if [ $found -eq 1 ]; then
		# luu thong tin giao trinh tim dc
		line=$(($lineNum-3))
		setTextbookInfo "${b[1]}" "${b[2]}" "${b[3]}" "${b[0]}" "$line"
		echo 'Da tim thay ALBUM '
		echo $'\n'
		manageTextAlbumMenu
	else
		echo "Khong tim thay ALBUM co ma '$Id'"
	fi
	return 0
}

findTextAlbumByName() {
	echo 'Coming soon!';
}

# Thu tuc them Bai Hai cho ALBUM
addSong() {
echo $'\n'
	echo '----- THEM BAI HAT ------'
	echo 'Nhap thong tin cua bai hat:'
	echo 'So thu tu bai hat trong ALBUM:'; read PageNo
	echo ' Ten ca si';read CaSi
	echo 'Ten Bai Hat:'; read Title
	#write
	echo "${_TEXTALBUM_INFO[0]}">>$_SONG
	echo "$PageNo">>$_SONG
	echo "CaSi">>$_SONG
	echo "$Title">>$_SONG
	echo 'Them BAI HAT thanh cong!'
	echo 'Ban co muon them BAI HAT khac nua khong? [y/n]'; read c
	if [ $c = 'y' ]; then
		addSong
	fi
	return 0
}

setTextbookInfo() {
	_TEXTALBUM_INFO[0]="$1" #Id
	_TEXTALBUM_INFO[1]="$2" #Title
	_TEXTALBUM_INFO[2]="$3" #Type
	_TEXTALBUM_INFO[3]="$4" #Composer
	_TEXTALBUM_INFO[4]="$5" #line
}

# Chuong trinh chinh
clear
echo 'Nhom SV'
echo '1. Nguyen Hoang Duong'
echo '2. Nguyen Quang Giang'
echo '3. Nguyen Cong Dieu'
echo $'\n'
echo 'De tai 11: Cap nhat, tim kiem va hien thi thong tin ve ALBUM'

# Bat dau chuong trinh
_TEXTALBUM='album.txt'
_SONG='song.txt'
_TEXTALBUM_INFO=( '' '' '' '' '' ) # id title type composer line
_SONG_INFO=( '' '' '' '') # textbook pageNo title line
mainMenu

exit 0

