#!/bin/bash
# declare STRING variablfor

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
	echo
	echo
	echo $'\n============ MAIN MENU ================='
	echo
	echo ' 1. Them album'
	echo ' 2. Tim kiem album'
	echo ' 3. Thong ke album'
	echo ' 4. Hien thi thong tin ve cac album'
	echo ' 5. Hien thi danh sach cac bai hat'
	echo ' 0. Thoat chuong trinh'
	echo
	echo '============ MAIN MENU ================='
	printf 'Nhap menu: '; read menu
	case $menu in
	'1')
		addAlbum;;
	'2')
		findTextAlbumMenu;;
	'3')
		fStats;;
	'4')
			hienthiDsAlbum;;
	'5')
			hienthiDsBaiHat;;
	'0')
		echo 'Thoat chuong trinh'
		return 0;;
	*)
		echo 'Menu khong hop le.';;
	esac
	mainMenu
}

# ham thong ke
fStats() {
clear
	echo '----THONG KE ALBUM THEO THE LOAI----';
	echo
	lineNum=0
	type=()
	count=()
	exist=0
	i=0
	j=0
	total=0
	while read line; do
		lineNum=$(($lineNum+1))
		if [ $(($lineNum%4)) -eq 3 ]; then
			total=$(($total+1))
			j=0
			exist=0
			while [ $j -lt $i ]; do
				if [ "${type[$j]}" = "$line" ]; then
					count[$j]=$((${count[$j]}+1))
					exist=1
				break
				fi	
				j=$(($j+1))
			done
			if [ $exist -eq 0 ]; then
				type[$i]="$line"
				count[$i]=1
				i=$(($i+1))
			fi
		fi
	done < 'album.txt'
	if [ $i -eq 0 ]; then
		echo 'Chua co album nao!'
	else
		j=0
		while [ $j -lt $i ]; do
			echo " The Loai: ${type[$j]}           Co: ${count[$j]} album"
			j=$(($j+1))
		done
		echo "Tong: $i the loai, $total album"
	fi
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
			 findAlbumByName;;
		'0')
			return;;
		*)
			echo 'Menu khong hop le.';;
	esac
	findTextAlbumMenu
	clear
}
#tim kiem album theo id
findTextAlbumById() {
echo
	local found=0
	local lineNum=0
	local mod=0
	local b=( '' '' '' '' '' )
	echo '----Nhap ma ALBUM can tim kiem:----'; read Id
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
		# luu thong tin album tim dc
		line=$(($lineNum-3))
		setAlbumInfo "${b[1]}" "${b[2]}" "${b[3]}" "${b[0]}" "$line"
		echo 'Da tim thay ALBUM '
		echo $'\n'
		manageAlbumMenu
	else
		echo "Khong tim thay ALBUM co ma '$Id'"
	fi
	return 0
}
# tin kien album theo ten
function findAlbumByName
{
	clear
	echo "Nhap ten Album can tim kiem: "
	read TitleAlbum
	file=album.txt;
	dong=0;
	chisokt=1;
	timkiem=0;
	dongtimkiem=0;
	while read banghi; do
		if [ $dong -eq $chisokt ]
		then
#			echo "$banghi"
			chisokt=$(($chisokt+4))	
			case $banghi in #Dong 50
			"TitleAlbum: $TitleAlbum") echo "Reply: Album : $TitleAlbum ton tai trong tep album.txt "
			dongtimkiem=$dong
			timkiem="1"
			;;*)			
			esac
		fi
		dong=$(($dong+1))
	done <$file
#	echo "So dong: $dong"
	if [ $timkiem != 1 ]
	then
		echo "Reply: Album $TitleAlbum khong ton tai trong tep album.txt"
	else
		dong=0;
		while read banghi; do
		if [ $dong -ge $dongtimkiem ] 
		then
			if [ $dong -le $(($dongtimkiem+3)) ]
			then
				echo "$banghi"
			fi
		fi
		dong=$(($dong+1))
		done <$file
	fi
	

}

#hien thi thong tin tat ca danh sach album
function hienthiDsAlbum
{
	
	echo "-----DANH SACH CAC ALBUM-----"
	file=album.txt;	
	while read banghi; do
		echo "$banghi"
	done <$file
	mainMenu
}

function hienthiDsBaiHat
{

	echo "-----DANH SACH CAC BAI HAT------"
	file=song.txt;	
	while read banghi; do
		echo "$banghi"
	done <$file
	mainMenu
}

manageAlbumMenu() {
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
	manageAlbumMenu
	
}

#hien thi thong tin Album
displayTextAlbumInfo() {
echo $'\n'
	echo '----Thong tin ALBUM----  '
	echo "Ma ALBUM: ${_TEXTALBUM_INFO[0]}"
	echo "Ten ALBUM: ${_TEXTALBUM_INFO[1]}"
	echo "The loai ALBUM: ${_TEXTALBUM_INFO[2]}"
	echo "Nam XB: ${_TEXTALBUM_INFO[3]}"
}

editTextAlbum() {

echo $'\n'
	echo '----- SUA ALBUM ------'
	echo 'Nhap thong tin moi cho Album:'
	echo '(Bo trong neu khong muon thay doi)'
	echo 'Ma Album moi:'; read Id
	echo 'Ten Album moi:'; read TitleAlbum
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
			if [ "$TitleAlbum" ]; then
				echo "$TitleAlbum">>$newFile
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
echo
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

# Thu tuc Them ALBUM
addAlbum() {
clear
echo
	echo '----- THEM ALBUM -----'
	echo 'Nhap thong tin album moi:'
	echo 'Ma album:'; read Id
	echo 'Ten album:'; read TitleAlbum
	echo 'The loai album:'; read Type
	echo 'Nam XB:'; read Composer
	checkExistTexAlbumId $Id
	code=$?
	if [ $code -eq 1 ]; then
		echo "Ma Album '$Id' da ton tai!"
		return 1
	fi
	echo "$Id">>$_TEXTALBUM
	echo "$TitleAlbum">>$_TEXTALBUM
	echo "$Type">>$_TEXTALBUM
	echo "$Composer">>$_TEXTALBUM
	echo 'Them Album thanh cong!'
	return 0
}

# Thu tuc them Bai Hat cho ALBUM
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

setAlbumInfo() {
	_TEXTALBUM_INFO[0]="$1" #Id
	_TEXTALBUM_INFO[1]="$2" #TitleAlbum
	_TEXTALBUM_INFO[2]="$3" #Type
	_TEXTALBUM_INFO[3]="$4" #Composer
	_TEXTALBUM_INFO[4]="$5" #line
}

# Chuong trinh chinh
clear
echo 'Nhom sinh vien thuc hien'
echo
echo '1. Nguyen Hoang Duong'
echo '2. Nguyen Quang Giang'
echo '3. Nguyen Cong Dieu'
echo $'\n'
echo 'De tai 11: Cap nhat, tim kiem va hien thi thong tin ve ALBUM'
sleep 4
clear
# Bat dau chuong trinh
_TEXTALBUM='album.txt'
_SONG='song.txt'
_TEXTALBUM_INFO=( '' '' '' '' '' ) # id title type composer line
_SONG_INFO=( '' '' '' '') # textbook pageNo title line
mainMenu

exit 0

