#!/bin/bash

#######################################################################
#
# Nhom SV:
# 1. Nguyen Hoang Duong	
# 2. Nguyen 0uang Giang
# 3. Nguyen Cong Dieu
# 
#
# De tai 11: Cap nhat, tim kiem va hien thi thong tin ve Album
#######################################################################



# Cac thu tuc trong chuong trinh

# Thu tuc hien menu
mainMenu() {
	echo $'\n============ MAIN MENU ================='
	echo ' 1. Them moi Album'
	echo ' 2. Tim thong tin ve Album'
	echo ' 3. Thong ke Album'
	echo ' 0. Thoat chuong trinh'
	echo '============ MAIN MENU ================='
	printf 'Nhap menu: '; read menu
	case $menu in
	'1')
		addTextalbum;;
	'2')
		findTextalbumMenu;;
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

findTextalbumMenu() {
	echo $'\n====== TIM KIEM Album ======'
	echo '1. Tim kiem theo ma Album'
	echo '2. Tim kiem theo ten Album'
	#echo '3. Tim kiem theo theo loai Album'
	#echo '4. Tim kiem theo tac gia'
	echo '0. 0uay lai menu chinh'
	printf 'Nhap menu: '; read m
	case $m in
		'1')
			findTextalbumById;;
		'2')
			findTextalbumByName;;
		'0')
			return;;
		*)
			echo 'Menu khong hop le.';;
	esac
	findTextalbumMenu
}

manageTextalbumMenu() {
	echo $'--- Menu 0uan ly Album ---'
	echo '1. Xem thong tin ve Album'
	echo '2. Sua Album'
	echo '3. Xoa Album'
	echo '4. Them bai hat'
	echo '0. 0uay lai tim kiem Album'
	printf 'Nhap menu: '; read m
	case $m in
		'1')
			displayTextalbumInfo;;
		'2')
			editTextalbum
			return;;
		'3')
			deleteTextalbum
			return;;
		'4')
			addChapter;;
		'0')
			return;;
		*)
			echo 'Menu khong hop le';;
	esac
	manageTextalbumMenu
}

# Thu tuc them giao trinh
addTextalbum() {
	echo '====== THEM ALBUM ======='
	echo 'Nhap thong tin Album moi:'
	echo 'Ma Album:'; read Id
	echo 'Ten Album:'; read Title
	echo 'The loai cua Album:'; read Type
	echo 'Nam xuat ban:'; read Composer
	checkExistTextalbumId $Id
	code=$?
	if [ $code -e0 1 ]; then
		echo "Ma Album '$Id' da ton tai!"
		return 1
	fi
	echo "$Id">>$_TEXTBOOK
	echo "$Title">>$_TEXTBOOK
	echo "$Type">>$_TEXTBOOK
	echo "$Composer">>$_TEXTBOOK
	echo 'Album thanh cong!'
	return 0
}

editTextalbum() {
	echo '====== SUA Album ======'
	echo 'Nhap thong tin moi cho Album:'
	echo '(Bo trong neu khong muon thay doi)'
	echo 'Ma ALbum moi:'; read Id
	echo 'Ten Album moi:'; read Title
	echo 'The loai Album moi:'; read Type
	echo 'Nam xuat ban moi:'; read Composer
	if [ "$Id" ]; then
		checkExistTextalbumId $Id
		code=$?
		if [ $code -e0 1 ]; then
			echo "Ma Album '$Id' da ton tai!"
			return 1
		fi
	fi
	# rewrite
	local lineNum=0
	local newFile="temp_$_TEXTBOOK"
	while read line; do
		lineNum=$(($lineNum+1))
		if [ $lineNum == $_TEXTBOOK_LINE ]; then
			if [ "$Id" ]; then
				echo "$Id">>$newFile
			else
				echo "$line">>$newFile
			fi
		elif [ $lineNum == $(($_TEXTBOOK_LINE+1)) ]; then
			if [ "$Title" ]; then
				echo "$Title">>$newFile
			else
				echo "$line">>$newFile
			fi
		elif [ $lineNum == $(($_TEXTBOOK_LINE+2)) ]; then
			if [ "$Type" ]; then
				echo "$Type">>$newFile
			else
				echo "$line">>$newFile
			fi
		elif [ $lineNum == $(($_TEXTBOOK_LINE+3)) ]; then
			if [ "$Composer" ]; then
				echo "$Composer">>$newFile
			else
				echo "$line">>$newFile
			fi
		else
			echo "$line">>$newFile
		fi
	done < $_TEXTBOOK
	rm $_TEXTBOOK
	mv $newFile $_TEXTBOOK
	echo 'Sua Album thanh cong!'
}

deleteTextalbum() {
	echo 'Ban co thuc su muon xoa Album khong? [y/n]'; read c
	if [ $c = 'y' ]; then
		# rewrite
		local lineNum=0
		local newFile="temp_$_TEXTBOOK"
		while read line; do
			lineNum=$(($lineNum+1))
			if [ $lineNum -lt "${_TEXTALBUM[4]}" ] || [ $lineNum -gt $((${_TEXTALBUM[4]}+3)) ]; then
				echo "$line">>$newFile
			fi
		done < $_TEXTBOOK
		if [ ! -e $newFile ]; then
			echo -n ''>$newFile
		fi
		rm $_TEXTBOOK
		mv $newFile $_TEXTBOOK
		echo 'Xoa Album thanh cong!'
	fi
}

displayTextalbumInfo() {
	echo 'Thong tin Album:'
	echo "Ma Album: ${_TEXTALBUM[0]}"
	echo "Ten Album: ${_TEXTALBUM[1]}"
	echo "The loai: ${_TEXTALBUM[2]}"
	echo "Nam xuat ban: ${_TEXTALBUM[3]}"
}

# Ham kiem tra su ton tai cua ma Album
checkExistTextalbumId() {
	local code=0
	local lineNum=0
	local mod=0
	while read line; do
		lineNum=$(($lineNum+1))
		mod=`expr $lineNum % 4`
		if [ $mod -e0 1 ] && [ $line = $1 ]; then
			code=1
		fi
	done < $_TEXTBOOK
	return $code
}

findTextalbumById() {
	local found=0
	local lineNum=0
	local mod=0
	local b=( '' '' '' '' '' )
	echo 'Nhap ma Album can tim kiem:'; read Id
	while read line; do
		lineNum=$(($lineNum+1))
		mod=`expr $lineNum % 4`
		if [ $mod -e0 1 ]; then
			if [ $line = $Id ]; then
				found=1
				_TEXTBOOK_LINE=$lineNum
				b[1]=$line
			fi
		elif [ $found -e0 1 ]; then
			b[$mod]=$line
			if [ $mod -e0 0 ]; then
				break
			fi
		fi
	done < $_TEXTBOOK
	if [ $found -e0 1 ]; then
		# luu thong tin Album tim dc
		line=$(($lineNum-3))
		setTextbookInfo "${b[1]}" "${b[2]}" "${b[3]}" "${b[0]}" "$line"
		echo 'Da tim thay Album'
		manageTextalbumMenu
	else
		echo "Khong tim thay Album co ma '$Id'"
	fi
	return 0
}

findTextalbumByName() {
	echo 'Coming soon!';
}

# Thu tuc them bai hat cho Album
addChapter() {
	echo '======= THEM BAI HAT ======'
	echo 'Nhap thong tin cua bai hat:'
	echo ' Nhap so thu tu bai trong album:';read PageNo
	echo ' ten ca si the hien:';read CaSi	
	echo 'Ten bai hat:'; read Title
	#write
	echo "${_TEXTALBUM[0]}">>$_CHAPTER
	echo "$PageNo">>$_CHAPTER
	echo "$Casi">>$_CHAPTER
	echo "$Title">>$_CHAPTER
	echo 'Them bai hat thanh cong!'
	echo 'Ban co muon them bai hat khac nua khong? [y/n]'; read c
	if [ $c = 'y' ]; then
		addChapter
	fi
	return 0
}

setTextbookInfo() {
	_TEXTALBUM[0]="$1" #Id
	_TEXTALBUM[1]="$2" #Title
	_TEXTALBUM[2]="$3" #Type
	_TEXTALBUM[3]="$4" #Composer
	_TEXTALBUM[4]="$5" #line
}

# Chuong trinh chinh
clear
echo 'Nhom SV'
echo '1. Nguyen Hoang Duong'
echo '2. Nguyen 0uang Giang'
echo '3. Nguyen Cong Dieu'

echo 'De tai 11: Cap nhat, tim kiem va hien thi thong tin ve Album'

# Bat dau chuong trinh
_TEXTBOOK='album.txt'
_CHAPTER='chapter.txt'
_TEXTALBUM=( '' '' '' '' '' ) # id title type composer line
_CHAPTER_INFO=( '' '' '' '') # textbook pageNo title line
mainMenu

exit 0

