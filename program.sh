#!/bin/bash

mainMenu() {
	echo $'\n============ MAIN MENU ================='
	echo ' 1. Them giao trinh'
	echo ' 2. Tim giao trinh'
	echo ' 3. Thong ke giao trinh'
	echo ' 0. Thoat chuong trinh'
	echo '============ MAIN MENU ================='
	printf 'Nhap menu: '; read menu
	case "$menu" in
	'1')
		addTextbook;;
	'2')
		findTextbookMenu;;
	'3')
		textbookStatsMenu;;
	'0')
		echo 'Thoat chuong trinh'
		return 0;;
	*)
		echo 'Menu khong hop le.';;
	esac
	mainMenu
}

findTextbookMenu() {
	echo $'\n====== TIM KIEM GIAO TRINH ======'
	echo '1. Tim kiem theo ma giao trinh'
	echo '2. Tim kiem theo ten giao trinh'
	#echo '3. Tim kiem theo theo loai giao trinh'
	#echo '4. Tim kiem theo tac gia'
	echo '3. Duyet tung giao trinh'
	echo '0. Quay lai menu chinh'
	printf 'Nhap menu: '; read m
	case "$m" in
		'1')
			findTextbookById;;
		'2')
			findTextbookByName;;
		'3')
			browseTextbook;;
		'0')
			return;;
		*)
			echo 'Menu khong hop le.';;
	esac
	findTextbookMenu
}

manageTextbookMenu() {
	echo $'\n--- Menu quan ly giao trinh ---'
	echo '1. Xem thong tin ve giao trinh'
	echo '2. Sua giao trinh'
	echo '3. Xoa giao trinh'
	echo '4. Xem thong tin chuong muc'
	echo '5. Them chuong muc'
	echo '6. Xoa toan bo chuong muc'
	echo '0. Quay lai tim kiem giao trinh'
	printf 'Nhap menu: '; read m
	case "$m" in
		'1')
			displayTextbookInfo;;
		'2')
			editTextbook
			return;;
		'3')
			deleteTextbook
			return;;
		'4')
			displayChaptersInfo "${_TEXTBOOK_INFO[0]}";;
		'5')
			addChapter;;
		'6')
			deleteChapters "${_TEXTBOOK_INFO[0]}"
			echo "Xoa toan bo chuong muc thanh cong!";;
		'0')
			return;;
		*)
			echo 'Menu khong hop le';;
	esac
	manageTextbookMenu
}

manageChapterMenu() {
	echo $'\n--- Menu quan ly chuong muc ---'
	echo '1. Xem thong tin ve chuong muc'
	echo '2. Sua chuong muc'
	echo '3. Xoa chuong muc'
	echo '0. Quay lai menu quan ly giao trinh'
	printf 'Nhap menu: '; read m
	case "$m" in
		'1')
			displayChapterInfo
			manageChapterMenu;;
		'2')
			editChapter;;
		'3')
			deleteChapter;;
		'0')
			return;;
		*)
			echo 'Menu khong hop le'
			manageChapterMenu;;
	esac
}

# menu thong ke giao trinh
textbookStatsMenu() {
	echo $'\n===== THONG KE GIAO TRINH ====='
	echo '1. Thong ke giao trinh theo the loai'
	echo '0. Quay lai menu chinh'
	printf 'Nhap menu: '; read m
	case "$m" in
		'1')
			textbookStatsByType;;
		'0')
			return;;
		*)
			echo 'Menu khong hop le';;
	esac
	textbookStatsMenu
}

# Thu tuc them giao trinh
addTextbook() {
	echo $'\n====== THEM GIAO TRINH ======='
	echo 'Nhap thong tin giao trinh moi:'
	echo 'Ma giao trinh:'; read Id
	echo 'Ten giao trinh:'; read Title
	echo 'The loai cua giao trinh:'; read Type
	echo 'Tac gia:'; read Composer
	echo "$Id">>$_TEXTBOOK
	echo "$Title">>$_TEXTBOOK
	echo "$Type">>$_TEXTBOOK
	echo "$Composer">>$_TEXTBOOK
	echo '[INFO]===> Them giao trinh thanh cong!'
	return 0
}

editTextbook() {
	echo $'\n====== SUA GIAO TRINH ======'
	echo 'Nhap thong tin moi cho giao trinh:'
	echo '(Bo trong neu ban khong muon thay doi)'
	echo 'Ma giao trinh moi:'; read Id
	echo 'Ten giao trinh moi:'; read Title
	echo 'The loai giao trinh moi:'; read Type
	echo 'Tac gia moi:'; read Composer
	# rewrite
	local lineNum=0
	local newFile="temp_$_TEXTBOOK"
	while read line; do
		lineNum=$(($lineNum+1))
		if [ $lineNum == ${_TEXTBOOK_INFO[4]} ]; then
			if [ "$Id" ]; then
				echo "$Id">>$newFile
				oldId="$line"
			else
				echo "$line">>$newFile
			fi
		elif [ $lineNum == $((${_TEXTBOOK_INFO[4]}+1)) ]; then
			if [ "$Title" ]; then
				echo "$Title">>$newFile
			else
				echo "$line">>$newFile
			fi
		elif [ $lineNum == $((${_TEXTBOOK_INFO[4]}+2)) ]; then
			if [ "$Type" ]; then
				echo "$Type">>$newFile
			else
				echo "$line">>$newFile
			fi
		elif [ $lineNum == $((${_TEXTBOOK_INFO[4]}+3)) ]; then
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
	echo 'Sua giao trinh thanh cong!'
}

deleteTextbook() {
	echo $'\nXoa giao trinh'
	echo 'Ban co thuc su muon xoa giao trinh va cac chuong muc cua no khong? [y/n]'; read c
	if [ "$c" = 'y' ]; then
		# rewrite
		local lineNum=0
		local newFile="temp_$_TEXTBOOK"
		while read line; do
			lineNum=$(($lineNum+1))
			if [ $lineNum -lt ${_TEXTBOOK_INFO[4]} ] || [ $lineNum -gt $((${_TEXTBOOK_INFO[4]}+3)) ]; then
				echo "$line">>$newFile
			fi
		done < $_TEXTBOOK
		if [ ! -e $newFile ]; then
			echo -n ''>$newFile
		fi
		rm $_TEXTBOOK
		mv $newFile $_TEXTBOOK
		deleteChapters "${_TEXTBOOK_INFO[0]}"
		echo 'Xoa giao trinh thanh cong!'
	fi
}

displayTextbookInfo() {
	echo $'\nThong tin giao trinh:'
	echo "Ma giao trinh: ${_TEXTBOOK_INFO[0]}"
	echo "Ten giao trinh: ${_TEXTBOOK_INFO[1]}"
	echo "The loai: ${_TEXTBOOK_INFO[2]}"
	echo "Tac gia: ${_TEXTBOOK_INFO[3]}"
}

findTextbookById() {
	echo $'\nTim giao trinh theo ma so'
	local found=0
	local lineNum=0
	local mod=0
	local b=( '' '' '' '' '' )
	echo 'Nhap ma giao trinh can tim kiem:'; read Id
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
	done < $_TEXTBOOK
	if [ $found -eq 1 ]; then
		setTextbookInfo "${b[1]}" "${b[2]}" "${b[3]}" "${b[0]}" "${b[4]}"
		echo "Da tim thay giao trinh co ma '$Id'"
		manageTextbookMenu
	else
		echo "Khong tim thay giao trinh co ma '$Id'"
	fi
	return 0
}

findTextbookByName() {
	echo $'\nTim giao trinh theo ten'
	local count=0
	local lineNum=0
	local mod=0
	local b=( '' '' '' '' '' )
	echo 'Nhap ten giao trinh can tim kiem'
	echo 'Luu y: tim kiem tuong doi theo ten'
	read name
	echo 'Ket qua tim kiem:'
	while read line; do
		lineNum=$(($lineNum+1))
		mod=$(($lineNum%4))
		b[$mod]="$line"
		if [ $mod -eq 0 ] && [[ "${b[2]}" =~ "$name" ]]; then
			count=$(($count+1))
			echo "$count. ${b[2]} [${b[1]}]"
		fi
	done < $_TEXTBOOK
	if [ $count -eq 0 ]; then
		echo "Khong tim thay giao trinh nao co ten chua '$name'"
	else
		echo "Tim thay $count giao trinh co ten chua '$name'"
		echo 'Nhap so thu tu cua sach ban muon quan ly'
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
						setTextbookInfo "${b[1]}" "${b[2]}" "${b[3]}" "${b[0]}" "$lineNum"
						break
					fi
				fi
			done < $_TEXTBOOK
			manageTextbookMenu
		fi
		
	fi
}

browseTextbook() {
	echo $'\nDuyet tung giao trinh'
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
		done < $_TEXTBOOK
		if [ ! "${b[1]}" ]; then
			echo '[INFO]===> Khong con giao trinh nao de duyet'
			return
		fi
		echo ''
		echo "Thong tin giao trinh thu $(($index+1))"
		echo "Ma: ${b[1]}"
		echo "Ten: ${b[2]}"
		echo "Theo loai: ${b[3]}"
		echo "Tac gia: ${b[0]}"
		echo 'Menu:'
		echo '1. Quan ly giao trinh nay'
		echo '2. Giao trinh tiep theo'
		echo '0. Quay lai menu tim kiem giao trinh'
		read m
		case "$m" in
			'1')
				lineNum=$(($lineNum-3))
				setTextbookInfo "${b[1]}" "${b[2]}" "${b[3]}" "${b[0]}" "$lineNum"
				manageTextbookMenu
				break;;
			'0')
				return;;
		esac
		
		index=$(($index+1))
	done
}

# Thu tuc them chuong muc cho giao trinh
addChapter() {
	echo $'\n======= THEM CHUONG MUC ======'
	echo 'Nhap thong tin cua chuong muc:'
	echo 'So hieu trang (vi tri) cua chuong:'; read PageNo
	echo 'Ten chuong:'; read Title
	#write
	echo "${_TEXTBOOK_INFO[0]}">>$_CHAPTER
	echo "$PageNo">>$_CHAPTER
	echo "$Title">>$_CHAPTER
	echo '[INFO]===> Them chuong muc thanh cong!'
	echo 'Ban co muon them chuong muc khac nua khong? [y/n]'; read c
	if [ "$c" = 'y' ]; then
		addChapter
	fi
	return 0
}

editChapter() {
	echo $'\nSua chuong muc'
	echo '(Bo trong neu ban khong muon thay doi)'
	echo 'So hieu trang (vi tri) moi cua chuong muc:'; read pageNo
	echo 'Ten moi cua chuong muc:'; read Title
	local lineNum=0
	local newFile="temp_$_CHAPTER"
	while read line; do
		lineNum=$(($lineNum+1))
		if [ $lineNum -eq $((${_CHAPTER_INFO[3]}+1)) ]; then
			if [ "$pageNo" ]; then
				echo "$pageNo">>$newFile
			else
				echo "$line">>$newFile
			fi
		elif [ $lineNum -eq $((${_CHAPTER_INFO[3]}+2)) ]; then
			if [ "$Title" ]; then
				echo "$Title">>$newFile
			else
				echo "$line">>$newFile
			fi
		else
			echo "$line">>$newFile
		fi
	done < $_CHAPTER
	rm $_CHAPTER
	mv $newFile $_CHAPTER
	echo '[INFO]===> Sua chuong muc thanh cong!'
}

deleteChapter() {
	echo '[CONFIRM]===> Ban co thuc su muon xoa chuong muc? [y/n]'; read c
	if [ "$c" != 'y' ]; then
		echo '[INFO]===> Huy xoa chuong muc'
		return
	fi
	local lineNum=0
	local newFile="temp_$_CHAPTER"
	while read line; do
		lineNum=$(($lineNum+1))
		if [ $lineNum -lt ${_CHAPTER_INFO[3]} ] || [ $lineNum -gt ${_CHAPTER_INFO[3]} ]; then
			echo "$line">>$newFile
		fi
	done < $_CHAPTER
	if [ ! -e $newFile ]; then
		echo -n ''>$newFile
	fi
	rm $_CHAPTER
	mv $newFile $_CHAPTER
	echo '[INFO]===> Xoa chuong muc thanh cong!'
}

# xoa chuong muc bang ma giao trinh
deleteChapters() {
	local found=0
	local lineNum=0
	local mod=0
	local count=0
	local newFile="temp_$_CHAPTER"
	while read line; do
		lineNum=$(($lineNum+1))
		mod=$(($lineNum%3))
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
	done < $_CHAPTER
	if [ ! -e $newFile ]; then
		echo -n ''>$newFile
	fi
	rm $_CHAPTER
	mv $newFile $_CHAPTER
	return $count
}

displayChaptersInfo() {
	local found=0
	local lineNum=0
	local mod=0
	local count=0
	local chapter=( '' '' '' )
	echo $'\nDanh sach chuong muc:'
	while read line; do
		lineNum=$(($lineNum+1))
		mod=$(($lineNum%3))
		if [ $mod -eq 1 ]; then
			if [ "$line" = "$1" ]; then
				found=1
				count=$(($count+1))
				chapter[1]="$line"
			fi
		elif [ $found -eq 1 ]; then
			chapter[$mod]="$line"
			if [ $mod -eq 0 ]; then
				found=0
				echo "$count. ${chapter[0]} [${chapter[2]}]"
			fi
		fi
	done < $_CHAPTER
	if [ $count -eq 0 ]; then
		echo 'Giao trinh khong co chuong muc nao!'
	else
		echo "Tong so chuong muc: $count chuong"
		echo 'Nhap so thu tu cua chuong muc ban muon quan ly'
		echo 'Nhap 0 de quay lai'
		read m
		if [ "$m" -gt 0 ] && [ "$m" -le $count ]; then
			lineNum=0
			count=0
			while read line; do
				lineNum=$(($lineNum+1))
				mod=$(($lineNum%3))
				chapter[$mod]="$line"
				if [ $mod -eq 0 ] && [ "${chapter[1]}" = "$1" ]; then
					count=$(($count+1))
					if [ $count -eq "$m" ]; then
						lineNum=$(($lineNum-2))
						setChapterInfo "${chapter[1]}" "${chapter[2]}" "${chapter[0]}" "$lineNum"
						break
					fi
				fi
			done < $_CHAPTER
			manageChapterMenu
		fi
	fi
}

displayChapterInfo() {
	echo $'\nThong tin chuong muc:'
	echo "Ma giao trinh: ${_CHAPTER_INFO[0]}"
	echo "So hieu (vi tri) cua chuong: ${_CHAPTER_INFO[1]}"
	echo "Ten chuong: ${_CHAPTER_INFO[2]}"
	#echo "Line: ${_CHAPTER_INFO[3]}"
}

textbookStatsByType() {
	echo $'\nThong ke giao trinh theo the loai';
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
	done < $_TEXTBOOK
	if [ $i -eq 0 ]; then
		echo '[INFO]===> Chua co giao trinh nao!'
	else
		j=0
		while [ $j -lt $i ]; do
			echo "$(($j+1)). ${type[$j]}  [${count[$j]} giao trinh]"
			j=$(($j+1))
		done
		echo "Tong: $i the loai, $total giao trinh"
		echo 'Nhap so thu thu cua the loai de xem danh sach cac giao trinh'
		echo 'Nhap 0 de quay lai'
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
					echo "$j. ${b[2]} [${b[1]}]"
				fi
			done < $_TEXTBOOK
		fi
	fi

}

setTextbookInfo() {
	_TEXTBOOK_INFO[0]="$1" #Id
	_TEXTBOOK_INFO[1]="$2" #Title
	_TEXTBOOK_INFO[2]="$3" #Type
	_TEXTBOOK_INFO[3]="$4" #Composer
	_TEXTBOOK_INFO[4]="$5" #line
}

setChapterInfo() {
	_CHAPTER_INFO[0]="$1" #Id textbook
	_CHAPTER_INFO[1]="$2" #pageNo
	_CHAPTER_INFO[2]="$3" #title
	_CHAPTER_INFO[3]="$4" #line
}

# Chuong trinh chinh
# clear
echo $'\n\nNhom SV'
echo '1. Ho Van Tuan'
echo '2. Dau Van Thai'
echo '3. Nguyen Dinh Minh'
echo '4. Luong Ngoc Tu'
echo $'\nDe tai 2: Cap nhat, tim kiem va hien thi thong tin ve giao trinh\n\n'

# Bat dau chuong trinh
_TEXTBOOK='book.txt'
_CHAPTER='chapter.txt'
_TEXTBOOK_INFO=( '' '' '' '' 0 ) # id title type composer line
_CHAPTER_INFO=( '' '' '' 0) # textbook pageNo title line
mainMenu

exit 0

