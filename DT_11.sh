#!/bin/bash

mainMenu() {
	echo $'\n============ MAIN MENU ================='
	echo ' 1. Them Album'
	echo ' 2. Tim kiem Album'
	echo ' 3. Thong ke Album'
	echo " 4. Hien thi thong tin ve cac album"
	echo " 5. Hien thi danh sach cac bai hat"
	echo ' 0. Thoat chuong trinh'
	echo '============ MAIN MENU ================='
	printf 'Nhap menu: '; read menu
	case "$menu" in
	'1')
		addAlbum;;
	'2')
		findAlbumMenu;;
	'3')
		#AlbumStatsMenu;;
		AlbumStatsByType;;
		4)
			ShowDsAlbum;;
	5)
			ShowDsBaiHat;;
	'0')
		echo 'Thoat chuong trinh'
		return 0;;
	*)
		echo 'Menu khong hop le.';;
	esac
	mainMenu
}
ShowDsBaiHat()
{
	echo "-----DANH SACH CAC BAI HAT------"
	n=0
	while read banghi; do
		n=$(($n+1))
		i=$(($n%4))
		array[$i]="$banghi"
		if [ $i -eq 0 ]; then
			# album: ${array[1]}
			# No: ${array[2]}
			# Casi: ${array[3]}
			# ten: ${array[0]}
			echo "BAI HAT: [ ${array[3]} ]  VI TRI BAI HAT: [ ${array[2]} ]  NAM TRONG ALBUM: [ ${array[1]} ]"
			echo ""
		fi
	done < $FILE_SONG
	echo "Tong so bai hat: $(($n/4)) bai hat"
}

ShowDsAlbum()
{
	echo "-----DANH SACH CAC ALBUM-----"
	array=(	"Ma album:" "Ten album:" "The loai album:" "Nam XB:")
	i=0
	sum=0
	while read banghi; do
		echo "${array[$i]} $banghi"
		if [ $i -eq 3 ]; then
			i=0
			echo ''
		else
			i=$(($i+1))
		fi
		sum=$(($sum+1))
	done < $FILE_ALBUM
	echo " ===> Tong so album: $(($sum/4)) album"
}

findAlbumMenu() {
	echo $'\n====== TIM KIEM ALBUM ======'
	echo '1. Tim kiem theo ma ALBUM'
	echo '2. Tim kiem theo ten ALBUM'
	#echo '3. Tim kiem theo theo loai ALBUM'
	#echo '4. Tim kiem theo tac gia'
	echo '3. Duyet tung ALBUM'
	echo '0. Quay lai menu chinh'
	printf 'Nhap menu: '; read m
	case "$m" in
		'1')
			findAlbumById;;
		'2')
			findAlbumByName;;
		'3')
			browseAlbum;;
		'0')
			return;;
		*)
			echo 'Menu khong hop le.';;
	esac
	findAlbumMenu
}

manageAlbumMenu() {
	echo $'\n--- Menu quan ly ALBUM ---'
	#echo '1. Xem thong tin ve ALBUM'
	echo '2. Sua ALBUM'
	echo '3. Xoa ALBUM'
	echo '4. Xem thong tin Bai Hat'
	echo '5. Them Bai Hat'
	echo '6. Xoa toan bo Bai Hat'
	echo '0. Quay lai tim kiem ALBUM'
	printf 'Nhap menu: '; read m
	case "$m" in
		#'1')
		#	displayAlbumInfo;;
		'2')
			updateAlbum
			return;;
		'3')
			deleteAlbum
			return;;
		'4')
			displaysongsInfo "${FILE_ALBUM_INFO[0]}";;
		'5')
			addsong;;
		'6')
			deleteSongsByIdAlbumByIdAlbum "${FILE_ALBUM_INFO[0]}"
			echo "Xoa toan bo bai hat thanh cong!";;
		'0')
			return;;
		*)
			echo 'Menu khong hop le';;
	esac
	manageAlbumMenu
}

managesongMenu() {
	echo $'\n--- Menu quan ly bai hat ---'
	echo '1. Xem thong tin ve bai hat'
	echo '2. Sua bai hat'
	echo '3. Xoa bai hat'
	echo '0. Quay lai menu quan ly ALBUM'
	printf 'Nhap menu: '; read m
	case "$m" in
		'1')
			displaysongInfo
			managesongMenu;;
		'2')
			updateSong;;
		'3')
			deleteSong;;
		'0')
			return;;
		*)
			echo 'Menu khong hop le'
			managesongMenu;;
	esac
}

# menu thong ke ALBUM
AlbumStatsMenu() {
	echo $'\n===== THONG KE ALBUM ====='
	echo '1. Thong ke ALBUM theo the loai'
	echo '0. Quay lai menu chinh'
	printf 'Nhap menu: '; read m
	case "$m" in
		'1')
			AlbumStatsByType;;
		'0')
			return;;
		*)
			echo 'Menu khong hop le';;
	esac
	AlbumStatsMenu
}

AlbumStatsByType() {
clear
	echo $'\n----THONG KE ALBUM THEO THE LOAI----';
	echo
	local lineNum=0
	local type=()
	local count=()
	local exist=0
	local i=0
	local j=0
	local total=0
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
	done < $FILE_ALBUM
	if [ $i -eq 0 ]; then
		echo '===> Chua co ALBUM nao!'
	else
		j=0
		while [ $j -lt $i ]; do
			echo "$(($j+1)). THE LOAI NHAC: ${type[$j]}          GOM: ${count[$j]} album"
			j=$(($j+1))
		done
		echo
		echo " ===> Tong: $i the loai, $total ALBUM"
		echo
		echo '----Nhap so thu thu cua the loai de xem danh sach cac ALBUM----'
		echo '----Nhap 0 de quay lai----'
		echo
		read m
		if [ "$m" -gt 0 ] && [ "$m" -le $i ]; then
			local b=( '' '' '' '' )
			local mod=0
			lineNum=0
			m=$(($m-1))
			j=0
			while read line; do
				lineNum=$(($lineNum+1))
				mod=$(($lineNum%4))
				b[$mod]="$line"
				if [ $mod -eq 0 ] && [ "${b[3]}" = "${type[$m]}" ]; then
					j=$(($j+1))
					echo "$j. TEN ALBUM THUOC THE LOAI NHAC TREN LA: ${b[2]}    CO MA ALBUM LA: ${b[1]}"
				fi
			done < $FILE_ALBUM
		fi
	fi

}
# Thu tuc Them album
addAlbum() {
	echo $'\n====== Them album ======='
	echo 'Nhap thong tin ALBUM moi:'
	echo 'Ma ALBUM:'; read Id
	echo 'Ten ALBUM:'; read Title
	echo 'The loai cua ALBUM:'; read Type
	echo 'Nam XB:'; read Composer
	checkExistTexAlbumId $Id
	code=$?
	if [ $code -eq 1 ]; then
		echo "Ma Album '$Id' da ton tai. Ban hay nhap ma album khac!"
		return 1
	fi
	echo "$Id">>$FILE_ALBUM
	echo "$Title">>$FILE_ALBUM
	echo "$Type">>$FILE_ALBUM
	echo "$Composer">>$FILE_ALBUM
	echo '===> Them album thanh cong!'
	return 0
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
	done < $FILE_ALBUM
	return $code
}

updateAlbum() {
	echo $'\n====== SUA ALBUM ======'
	echo 'Nhap thong tin moi cho ALBUM:'
	echo '(Bo trong neu ban khong muon thay doi)'
	echo 'Ma ALBUM moi:'; read Id
	echo 'Ten ALBUM moi:'; read Title
	echo 'The loai ALBUM moi:'; read Type
	echo 'Tac gia moi:'; read Composer
	# rewrite
	local lineNum=0
	local newFile="temp_$FILE_ALBUM"
	while read line; do
		lineNum=$(($lineNum+1))
		if [ $lineNum == ${FILE_ALBUM_INFO[4]} ]; then
			if [ "$Id" ]; then
				echo "$Id">>$newFile
				oldId="$line"
			else
				echo "$line">>$newFile
			fi
		elif [ $lineNum == $((${FILE_ALBUM_INFO[4]}+1)) ]; then
			if [ "$Title" ]; then
				echo "$Title">>$newFile
			else
				echo "$line">>$newFile
			fi
		elif [ $lineNum == $((${FILE_ALBUM_INFO[4]}+2)) ]; then
			if [ "$Type" ]; then
				echo "$Type">>$newFile
			else
				echo "$line">>$newFile
			fi
		elif [ $lineNum == $((${FILE_ALBUM_INFO[4]}+3)) ]; then
			if [ "$Composer" ]; then
				echo "$Composer">>$newFile
			else
				echo "$line">>$newFile
			fi
		else
			echo "$line">>$newFile
		fi
	done < $FILE_ALBUM
	rm $FILE_ALBUM
	mv $newFile $FILE_ALBUM
	echo 'Sua ALBUM thanh cong!'
	
}

deleteAlbum() {
	echo $'\nXoa ALBUM'
	echo 'Ban co thuc su muon xoa ALBUM va cac bai hat cua no khong? [y/n]'; read c
	if [ "$c" = 'y' ]; then
		# rewrite
		local lineNum=0
		local newFile="temp_$FILE_ALBUM"
		while read line; do
			lineNum=$(($lineNum+1))
			if [ $lineNum -lt ${FILE_ALBUM_INFO[4]} ] || [ $lineNum -gt $((${FILE_ALBUM_INFO[4]}+3)) ]; then
				echo "$line">>$newFile
			fi
		done < $FILE_ALBUM
		if [ ! -e $newFile ]; then
			echo -n ''>$newFile
		fi
		rm $FILE_ALBUM
		mv $newFile $FILE_ALBUM
		deleteSongsByIdAlbumByIdAlbum "${FILE_ALBUM_INFO[0]}"
		echo 'Xoa ALBUM thanh cong!'
	fi
}

displayAlbumInfo() {
	echo $'\n---Thong tin ve ALBUM:---'
	echo "Ma ALBUM: ${FILE_ALBUM_INFO[0]}"
	echo "Ten ALBUM: ${FILE_ALBUM_INFO[1]}"
	echo "The loai: ${FILE_ALBUM_INFO[2]}"
	echo "Tac gia: ${FILE_ALBUM_INFO[3]}"
}

findAlbumById() {
	echo $'\n----Tim ALBUM theo ma---- '
	local found=0
	local lineNum=0
	local mod=0
	local b=( '' '' '' '' '' )
	echo 'Nhap ma ALBUM can tim kiem:'; read Id
	while read line; do
		lineNum=$(($lineNum+1))
		mod=$(($lineNum%4))
		if [ $mod -eq 1 ]; then
			if [ $line = "$Id" ]; then
				found=1
				b[4]=$lineNum
				b[1]="$line"
			fi
		elif [ $found -eq 1 ]; then
			b[$mod]="$line"
			if [ $mod -eq 0 ]; then
				break
			fi
		fi
	done < $FILE_ALBUM
	if [ $found -eq 1 ]; then
		setAlbumInfo "${b[1]}" "${b[2]}" "${b[3]}" "${b[0]}" "${b[4]}"
		echo "Da tim thay ALBUM co ma '$Id'"
		echo
		displayAlbumInfo
		echo "----------------------------------------"
		manageAlbumMenu
	else
		echo "Khong tim thay ALBUM co ma '$Id'"
	fi
	return 0
}

findAlbumByName() {
	echo $'\n---Tim ALBUM theo ten---'
	local count=0
	local lineNum=0
	local mod=0
	local b=( '' '' '' '' '' )
	echo 'Nhap ten ALBUM can tim kiem :'	
	read name
	echo ' ===> Ket qua tim kiem:'
	while read line; do
		lineNum=$(($lineNum+1))
		mod=$(($lineNum%4))
		b[$mod]="$line"
		if [ $mod -eq 0 ] && [[ "${b[2]}" =~ "$name" ]]; then
			count=$(($count+1))
			echo "$count. ${b[2]} [${b[1]}]"
		fi
	done < $FILE_ALBUM
	if [ $count -eq 0 ]; then
		echo "Khong tim thay ALBUM nao co ten chua '$name'"
	else
		echo "Tim thay: $count ALBUM co ten la '$name'"
		echo 'Nhap so thu tu cua ALBUM ban muon quan ly'			
		echo 'Nhap 0 de quay lai menu tim kiem'
		read m
		if [ "$m" -gt 0 ] && [ "$m" -le $count ]; then
			lineNum=0
			count=0
			while read line; do
				lineNum=$(($lineNum+1))
				mod=$(($lineNum%4))
				b[$mod]="$line"
				if [ $mod -eq 0 ] && [[ "${b[2]}" =~ $name ]]; then
					count=$(($count+1))
					if [ "$count" -eq "$m" ]; then
						lineNum=$(($lineNum-3))
						setAlbumInfo "${b[1]}" "${b[2]}" "${b[3]}" "${b[0]}" "$lineNum"
						displayAlbumInfo
						break
					fi
				fi
			done < $FILE_ALBUM
			manageAlbumMenu
		fi
		
	fi
}

browseAlbum() {
	echo $'\nDuyet tung ALBUM'
	local lineNum=0
	local mod=0
	local b=( '' '' '' '' )
	local index=0
	local m=2
	while [ "$m" -eq 2 ]; do
		lineNum=0
		b=( '' '' '' '' )
		while read line; do
			lineNum=$(($lineNum+1))
			if [ $lineNum -gt $(($index*4)) ] && [ $lineNum -le $(($index*4+4)) ]; then
				mod=$(($lineNum%4))
				b[$mod]="$line"
				if [ $lineNum -eq $(($index*4+4)) ]; then
					break
				fi
			fi
		done < $FILE_ALBUM
		if [ ! "${b[1]}" ]; then
			echo '===> Khong con ALBUM nao de duyet'
			return
		fi
		echo ''
		echo "Thong tin ALBUM thu $(($index+1))"
		echo "Ma: ${b[1]}"
		echo "Ten: ${b[2]}"
		echo "Theo loai: ${b[3]}"
		echo "Tac gia: ${b[0]}"
		echo 'Menu:'
		echo '1. Quan ly ALBUM nay'
		echo '2. ALBUM tiep theo'
		echo '0. Quay lai menu tim kiem ALBUM'
		read m
		case "$m" in
			'1')
				lineNum=$(($lineNum-3))
				setAlbumInfo "${b[1]}" "${b[2]}" "${b[3]}" "${b[0]}" "$lineNum"
				manageAlbumMenu
				break;;
			'0')
				return;;
		esac
		
		index=$(($index+1))
	done
}

# Thu tuc them bai hat cho ALBUM
addsong() {
	echo $'\n======= THEM bai hat ======'
	echo 'Nhap thong tin cua bai hat:'
	echo 'Vi tri bai hat tron Album:'; read PageNo
	echo 'Ten Bai Hat:'; read Title
	echo 'Ten Ca Si:'; read CaSi
	#write
	echo "${FILE_ALBUM_INFO[0]}">>$FILE_SONG
	echo "$PageNo">>$FILE_SONG
	echo "$Title">>$FILE_SONG
	echo "$CaSi">>$FILE_SONG
	echo '===> Them bai hat thanh cong!'
	echo 'Ban co muon them bai hat khac nua khong? [y/n]'; read c
	if [ "$c" = 'y' ]; then
		addsong
	fi
	return 0
}

updateSong() {
	echo $'\n----SUA BAI HAT----'
	echo '(Bo trong neu ban khong muon thay doi)'
	echo 'Vi tri moi cua bai hat trong ALBUM:'; read pageNo
	echo 'Ten moi cua bai hat:'; read Title
	echo 'Ten moi ca si:'; read CaSi
	local lineNum=0
	local newFile="temp_$FILE_SONG"
	while read line; do
		lineNum=$(($lineNum+1))
		if [ $lineNum -eq $((${FILE_SONG_INFO[4]}+1)) ]; then
			if [ "$pageNo" ]; then
				echo "$pageNo">>$newFile
			else
				echo "$line">>$newFile
			fi
		elif [ $lineNum -eq $((${FILE_SONG_INFO[4]}+2)) ]; then
			if [ "$Title" ]; then
				echo "$Title">>$newFile
			else
				echo "$line">>$newFile
			fi
		elif [ $lineNum -eq $((${FILE_SONG_INFO[4]}+3)) ]; then
			if [ "$CaSi" ]; then
				echo "$CaSi">>$newFile
			else
				echo "$line">>$newFile
			fi
		else
			echo "$line">>$newFile
		fi
	done < $FILE_SONG
	rm $FILE_SONG
	mv $newFile $FILE_SONG
	echo '===> Sua bai hat thanh cong!'
}

deleteSong() {
	echo '[CONFIRM]===> Ban co thuc su muon xoa bai hat? [y/n]'; read c
	if [ "$c" != 'y' ]; then
		echo '===> Huy xoa bai hat'
		return
	fi
	local lineNum=0
	local newFile="temp_$FILE_SONG"
	while read line; do
		lineNum=$(($lineNum+1))
		if [ $lineNum -lt ${FILE_SONG_INFO[4]} ] || [ $lineNum -gt ${FILE_SONG_INFO[4]} ]; then
			echo "$line">>$newFile
		fi
	done < $FILE_SONG
	if [ ! -e $newFile ]; then
		echo -n ''>$newFile
	fi
	rm $FILE_SONG
	mv $newFile $FILE_SONG
	echo '===> Xoa bai hat thanh cong!'
}

# xoa bai hat bang ma ALBUM
deleteSongsByIdAlbumByIdAlbum() {
	local found=0
	local lineNum=0
	local mod=0
	local count=0
	local newFile="temp_$FILE_SONG"
	while read line; do
		lineNum=$(($lineNum+1))
		mod=$(($lineNum%4))
		if [ $mod -eq 1 ]; then
			if [ "$line" = "$1" ]; then
				found=1
				count=$(($count+1))
			else
				echo "$line">>$newFile
			fi
		elif [ $found -eq 1 ]; then
			if [ $mod -eq 0 ]; then
				found=0
			fi
		else
			echo "$line">>$newFile
		fi
	done < $FILE_SONG
	if [ ! -e $newFile ]; then
		echo -n ''>$newFile
	fi
	rm $FILE_SONG
	mv $newFile $FILE_SONG
	return $count
}

displaysongsInfo() {
	local found=0
	local lineNum=0
	local mod=0
	local count=0
	local song=( '' '' '' )
	
	echo $'\n --------Danh sach bai hat:----------'
	while read line; do
		lineNum=$(($lineNum+1))
		mod=$(($lineNum%4))
		if [ $mod -eq 1 ]; then
			if [ "$line" = "$1" ]; then
				found=1
				count=$(($count+1))
				song[1]="$line"
			fi
		elif [ $found -eq 1 ]; then
			song[$mod]="$line"
			if [ $mod -eq 0 ]; then
				found=0
				echo "$count. BAI HAT: [ ${song[3]} ]   VI TRI THU: [ ${song[2]} ] TRONG ALBUM"
			fi
		fi
	done < $FILE_SONG
	if [ $count -eq 0 ]; then
		echo 'ALBUM khong co bai hat nao!'
	else
		echo "Tong so bai hat: $count bai hat"
		echo 'Nhap so thu tu cua bai hat ban muon quan ly'
		echo 'Nhap 0 de quay lai'
		read m
		if [ "$m" -gt 0 ] && [ "$m" -le $count ]; then
			lineNum=0
			count=0
			while read line; do
				lineNum=$(($lineNum+1))
				mod=$(($lineNum%4))
				song[$mod]="$line"
				if [ $mod -eq 0 ] && [ "${song[1]}" = "$1" ]; then
					count=$(($count+1))
					if [ $count -eq "$m" ]; then
						lineNum=$(($lineNum-2))
						setsongInfo "${song[1]}" "${song[2]}" "${song[3]}" "${song[0]}" "$lineNum"
						break
					fi
				fi
			done < $FILE_SONG
			managesongMenu
		fi
	fi
}

displaysongInfo() {
	echo $'\nThong tin bai hat:'
	echo "Ma ALBUM: ${FILE_SONG_INFO[0]}"
	echo "Vi tri bai hat trong ALBUM: ${FILE_SONG_INFO[1]}"
	echo "Ten bai hat: ${FILE_SONG_INFO[2]}"
	echo " Cai Si: ${FILE_SONG_INFO[3]}"
}


setAlbumInfo() {
	FILE_ALBUM_INFO[0]="$1" #Id
	FILE_ALBUM_INFO[1]="$2" #Title
	FILE_ALBUM_INFO[2]="$3" #Type
	FILE_ALBUM_INFO[3]="$4" #Composer
	FILE_ALBUM_INFO[4]="$5" #line
}

setsongInfo() {
	FILE_SONG_INFO[0]="$1" #Id textalbum
	FILE_SONG_INFO[1]="$2" #pageNo
	FILE_SONG_INFO[2]="$3" #title
	#
	FILE_SONG_INFO[3]="$4" #casi
	FILE_SONG_INFO[4]="$5" #line
	
	
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
sleep 3
clear

# Bat dau chuong trinh
FILE_ALBUM='album.txt'
FILE_SONG='song.txt'
FILE_ALBUM_INFO=( '' '' '' '' 0 ) # id title type composer line
FILE_SONG_INFO=( '' '' '' '' 0) # textalbum pageNo title line
mainMenu

exit 0

