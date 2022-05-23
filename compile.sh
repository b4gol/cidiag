#!/usr/bin/bash
# Written by: cyberknight777
# Build Author
msg() {
	echo
    echo -e "\e[1;32m$*\e[0m"
    echo
}
##----------------------------------------
# Update && Upgrade
msg "|| Update && Upgrade Package ||"	
apt update               \
 && apt -y -q upgrade        \
 && apt -y -q install        \
    bc                           \
    binutils-arm-linux-gnueabihf \
    build-essential              \
    ccache                       \
    git                          \
    libncurses-dev               \
    libssl-dev                   \
    u-boot-tools                 \
    wget                         \
    xz-utils                     \
    python2 \
    curl \
    pv  \
    zip -y
    
      
msg "|| Cloning Kernel ||"
git clone -j8 -b android-10.0 https://github.com/RandomiDn/android_kernel_realme_mt6765 --single-branch KERNEL
cd KERNEL
export token=$token
# Update && Upgrade
export DEBIAN_FRONTEND=noninteractive	
export TZ=Asia/Jakarta	
export TIME=$(date +"%S-%F")	
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime	
dpkg-reconfigure --frontend noninteractive tzdata
    KDIR=$PWD
       export KDIR
export CONFIG=RMX2185_defconfig
export LINKER=ld.lld
export DEVICE="Realme C12/C15"
export CODENAME="karashi"
export BUILDER="B4gol"
export REPO_URL="into"
COMMIT_HASH=$(git rev-parse --short HEAD)
export COMMIT_HASH
export SILENT=0
export CHATID=-1001267809228
PROCS="$(nproc --all)"
export $PROCS
export COMPILER=gcc

if [[ "${COMPILER}" = gcc ]]; then
	if [ ! -d "${KDIR}/gcc64" ]; then
		wget -O "${KDIR}"/64.zip https://github.com/mvaisakh/gcc-arm64/archive/1a4410a4cf49c78ab83197fdad1d2621760bdc73.zip
		unzip "${KDIR}"/64.zip
		mv "${KDIR}"/gcc-arm64-1a4410a4cf49c78ab83197fdad1d2621760bdc73 "${KDIR}"/gcc64
fi
	KBUILD_COMPILER_STRING=$("${KDIR}"/gcc64/bin/aarch64-elf-gcc --version | head -n 1)
	export KBUILD_COMPILER_STRING
	export PATH="${KDIR}"/gcc32/bin:"${KDIR}"/gcc64/bin:"${KDIR}"/aarch64-elf/bin/:/usr/bin/:${PATH}
	MAKE+=(
		ARCH=arm64
		O=out
		CROSS_COMPILE=aarch64-elf-
		CROSS_COMPILE_ARM32=arm-eabi-
		LD="${LINKER}"
		AR=aarch64-elf-ar
		OBJCOPY=aarch64-elf-objcopy
		STRIP=aarch64-elf-strip
		CC=aarch64-elf-gcc
	)
elif [[ "${COMPILER}" = clang ]]; then
	if [ ! -d "${KDIR}/clang" ]; then
git clone --depth=1 https://github.com/crdroidandroid/android_prebuilts_clang_host_linux-x86_clang-5484270 -b 9.0 clang
		#
	fi
	KBUILD_COMPILER_STRING=$("${KDIR}"/clang/bin/clang -v 2>&1 | head -n 1 | sed 's/(https..*//' | sed 's/ version//')
	export KBUILD_COMPILER_STRING
	export PATH=$KDIR/clang/bin/:/usr/bin/:${PATH}
	MAKE+=(
		ARCH=arm64
		O=out
		CROSS_COMPILE=aarch64-linux-gnu-
		CROSS_COMPILE_ARM32=arm-linux-gnueabi-
		LD="${LINKER}"
		AR=llvm-ar
		AS=llvm-as
		NM=llvm-nm
		OBJDUMP=llvm-objdump
		STRIP=llvm-strip
		CC=clang
	)
fi

if [ "${ci}" != 1 ];then
    if [ -z "${kver}" ]; then
	echo -e "\e[1;31m[!] Pass kver=<version number> before running script! \e[0m"
	exit 1
    else
	export KBUILD_BUILD_VERSION=${kver}
    fi
    if [ -z "${zipn}" ]; then
	echo -e "\e[1;31m[✗] Pass zipn=<zip name> before running script! \e[0m"
	exit 1
    fi
else
    export KBUILD_BUILD_VERSION=$(make kernelversion)
    export KBUILD_BUILD_HOST=$(uname -a | awk '{print $2}')
    export CI_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    export DISTRO=$(cat /etc/issue)
    export KBUILD_BUILD_USER=$BUILDER
    export VERSION=$version
    HOST=$KBUILD_BUILD_HOST
    kver=$KBUILD_BUILD_VERSION
    zipn=goldoppo-karashi-6765
    export zipn
fi
ANYKER=anykernel3
  export $ANYKER
if [ ! -d "${ANYKER}/" ]; then
	git clone --depth=1 https://github.com/RandomiDn/AnyKernel3Q -b karashi anykernel3
		
fi

exit_on_signal_SIGINT() {
	echo -e "\n\n\e[1;31m[✗] Terima-nasib - out \e[0m"
	exit 0
}
trap exit_on_signal_SIGINT SIGINT

tg() {
	if [[ "${SILENT}" != "1" ]]; then
		curl -sX POST https://api.telegram.org/bot"${token}"/sendMessage -d chat_id="${CHATID}" -d parse_mode=Markdown -d disable_web_page_preview=true -d text="$1" &>/dev/null
	fi
}

tgs() {
	MD5=$(md5sum "$1" | cut -d' ' -f1)
	if [[ "${SILENT}" != "1" ]]; then
		curl -fsSL -X POST -F document=@"$1" https://api.telegram.org/bot"${token}"/sendDocument \
			-F "chat_id=${CHATID}" \
			-F "parse_mode=Markdown" \
			-F "caption=$2 | *MD5*: \`$MD5\`"
	fi
}

clean() {
	echo -e "\n\e[1;93m[*] Bersih2 dan outdir \e[0m" | pv -qL 30
	make clean && make mrproper && rm -rf "${KDIR}"/out
}

mcfg() {
	echo -e "\e[1;93m[*] Ngedit config \e[0m" | pv -qL 30
	make "${MAKE[@]}" $CONFIG | tee log.txt
	make "${MAKE[@]}" menuconfig
	cp -rf "${KDIR}"/out/.config "${KDIR}"/arch/arm64/configs/$CONFIG
	echo -e "\n\e[1;32m[✓] Simpan \e[0m"  | vp -qL 30
}
img() {
	tg "
Pembuat: \`${BUILDER}\`
Host|Ver: \`$HOST|#${kver}\`
Distro: \`$DISTRO`\
CI: \`$CI_BRANCH``\
Perangkat: \`${DEVICE} [${CODENAME}]\`
Kernel: \`$(make kernelversion 2>/dev/null)\`
Tanggal: \`$TIME\`
Alat: \`${KBUILD_COMPILER_STRING}\`
Jalur: \`$(${LINKER} -v | head -n1 | sed 's/(Cocok [^)]*)//' |
		head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')\`
Commit: [${COMMIT_HASH}](${REPO_URL}/commit/${COMMIT_HASH})
"

	echo -e "\n\e[1;93m[*] Bikin Kernel \e[0m" | pv -qL 30
	BUILD_START=$(date +"%s")
	make "${MAKE[@]}" $CONFIG \
		LD=$LINKER
 time make -j"$PROCS" "${MAKE[@]}" Image Image.gz-dtb Image-dtb dtbs 2>&1 | tee log.txt
	BUILD_END=$(date +"%s")
	DIFF=$((BUILD_END - BUILD_START))
	if [ -f "${KDIR}/out/arch/arm64/boot/Image" ]; then
		tg "Setelah $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)*"
		echo -e "\n\e[1;32m[✓] Bikin Kernel \e[0m" | pv -qL 30
	else
		tgs "log.txt" "Error kampret..."
		echo -e "\n\e[1;32m[✗] Gagal \e[0m"
		exit 1
	fi
}
dtb() {
	echo -e "\n\e[1;32m[*] Bikin dtbs \e[0m" | pv -qL 30
	python2 "$KDIR/tools/dct/DrvGen.py" \
		make "${MAKE[@]}" $CONFIG \
	time make -j"$PROCS" "${MAKE[@]}" oppo6765 mt6765 dtbs dtbo.img dtb.img 
					create "$KDIR/out/arch/arm64/boot/dtbo.img" --page_size=4096 "$KDIR/out/arch/arm64/boot/dts/mediatek/dtbo.img"
	echo -e "\n\e[1;32m[✓] Bikin dtbs \e[0m" | pv -qL 30
}
mod() {
	tg "Bikin Modules"
	echo -e "\n\e[1;32m[*] Bikin Modules \e[0m" | pv -qL 30
	mkdir -p "${KDIR}"/out/modules
	make "${MAKE[@]}" modules_prepare
	make -j"$PROCS" "${MAKE[@]}" modules INSTALL_MOD_PATH="${KDIR}"/out/modules
	make "${MAKE[@]}" modules_install INSTALL_MOD_PATH="${KDIR}"/out/modules
	findo "${KDIR}"/out/modules -type f -iname '*.ko' -exec cp {} "$ANYKER"/modules/system/lib/modules/ \;
	echo -e "\n\e[1;32m[✓] Bikin Modules \e[0m" | pv -qL 30
}
mkzip() {
	tg "Tunggu zip file"
	echo -e "\n\e[1;32m[*] Tunggu zip file \e[0m" | pv -qL 30
	cp "${KDIR}"/out/arch/arm64/boot/dts/mediatek/oppo6765 "${ANYKER}"
		cp "${KDIR}"/out/arch/arm64/boot/dts/mediatek/mt6765 "${ANYKER}"
	cp "${KDIR}"/out/arch/arm64/boot/dts/mediatek/Image-dtb "${ANYKER}"
		cp "${KDIR}"/out/arch/arm64/boot/dts/mediatek/dtbo.img "${ANYKER}"
	cp "${KDIR}"/out/arch/arm64/boot/dts/mediatek/Image.gz-dtb "${ANYKER}"
	cp "${KDIR}"/out/arch/arm64/boot/dts/mediatek/drb.img "${ANYKER}"
	
	cd "${ANYKER}" || exit 1
	zip -r9 "$zipn".zip . -x ".git*" -x "README.md" -x "LICENSE" -x "*.zip"
	echo -e "\n\e[1;32m[✓] Bungkus file \e[0m" | pv -qL 30
	tgs "${zipn}.zip" "*#${kver} ${KBUILD_COMPILER_STRING}*"
}

obj() {
	make "${MAKE[@]}" $CONFIG
        time make -j"$PROCS" "${MAKE[@]}" "$1"
}

rgn() {
    make "${MAKE[@]}" $CONFIG
    cp -rf "${KDIR}"/out/.config "${KDIR}"/arch/arm64/configs/$CONFIG
}

upr() {
    "${KDIR}"/scripts/config --file "${KDIR}"/arch/arm64/configs/$CONFIG --set-str CONFIG_LOCALVERSION "-gold-${1}"
    rgn
if [ "${ci}" != 1 ];then
    git add arch/arm64/configs/$CONFIG
    git commit -S -s -m "golmod_defconfig: Bump to \`${1}\`"
fi
}

helpmenu() {
	echo -e "\e[1m
usage: kver=<version number> zipn=<zip name> ./kramel.sh <arg>
example: kver=69 zipn=Kernel-Beta ./kramel.sh mcfg
example: kver=4 zipn=goldoppo-karashi-6765 bash kramel.sh mcfg dtb mkzip
example: kver=69420 zipn=Kernel-Beta ./kramel.sh mcfg img mkzip
example: kver=1 zipn=Kernel-Beta ./kramel.sh --obj=drivers/android/binder.o
example: kver=2 zipn=Kernel-Beta ./kramel.sh --obj=kernel/sched/
example: kver=3 zipn=goldmod-karashi- ./kram.sh --upr=r16

	 mcfg   Runs make menuconfig
	 img    Builds Kernel
	 dtb    Builds dtb(o).img
	 mod    Builds out-of-tree modules
	 mkzip  Builds anykernel3 zip
	 --obj  Builds specific driver/subsystem
	 rgn    Regenerates defconfig
	 --upr  Uprevs kernel version in defconfig
\e[0m"
}

if [ "${ci}" == 1 ];then
	upr "${version}"
fi

if [[ -z $* ]]; then
	helpmenu
	exit 1
fi

for arg in "$@"; do
	case "${arg}" in
	"mcfg")
		mcfg
		;;
	"img")
		img
		;;
	"dtb")
		dtb
		;;
	"mod")
		mod
		;;
	"mkzip")
		mkzip
		;;
	"--obj="*)
        ABC="${arg#*=}"
        if [[ -z "$ABC" ]]
        then
            echo "Use --obj=something"
            exit 1
        fi
                obj "$ABC"
		;;
	"rgn")
	        rgn
	        ;;

	"--upr="*)
	A="${arg#*=}"
	if [[ -z "$A" ]]
	then
	    echo "Use --upr=something"
	    exit 1
	fi
	        upr "$A"
	        ;;

	"help")
		helpmenu
		exit 1
		;;
	*)
		helpmenu
		exit 1
		;;
	esac
done
