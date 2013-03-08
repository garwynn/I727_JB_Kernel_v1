#!/bin/bash
make distclean
# Directory "extras" must be available in top kernel directory. Sign scripts must also be available at ~/.gnome2/nautilus-scripts/SignScripts/
# Edit CROSS_COMPILE to mirror local path. Edit "version" to any desired name or number but it cannot have spaces. 
pwd=`readlink -f .`
export CROSS_COMPILE=~/Kernel/toolchain/prebuilt/arm-eabi-4.4.3/bin/arm-eabi-
export ARCH=arm
export version=Garwynn_I727_JB_v0.0.1

# Determines the number of available logical processors and sets the work thread accordingly
export JOBS="(expr 4 + $(grep processor /proc/cpuinfo | wc -l))"

loc=~/.gnome2/nautilus-scripts/SignScripts/
date=$(date +%Y%m%d-%H:%M:%S)

# Check for a log directory in ~/ and create if its not there
[ -d ~/logs ] || mkdir -p ~/logs

# Setting up environment
rm out -R
mkdir -p out
cp -r kernel-extras/mkboot $pwd
cp -r kernel-extras/zip $pwd

# Build entire kernel and create build log
make garwynn_defconfig
make headers_install
# make modules
time make -j8 CC="ccache $pwd/kernel-extras/arm-eabi-4.4.3/bin/arm-eabi-gcc" 2>&1 | tee ~/logs/$version.txt

echo "Copy zImage"
cp arch/arm/boot/zImage mkboot/
echo "Copy Modules"
find -name '*.ko' -exec cp -av {} mkboot/ramdisk-i727-tw/lib/modules \;
echo "Making boot image..."
cd mkboot
./img-i727-tw.sh
cd ..

echo "making tar.md5 version"
export TMPNM=$version".tar"
export TMPNM2=$version".tar.md5"
rm ../out/$TMPNM
rm ../out/$TMPNM2
cd mkboot
tar -H ustar -c boot.img > $TMPNM
md5sum -t $TMPNM >> $TMPNM
mv $TMPNM $TMPNM2
mv $TMPNM2 ../../

#echo "making signed zip"
#rm -rf zip/$version
#mkdir -p zip/$version
#mkdir -p zip/$version/system/lib/modules

# Find all modules that were just built and copy them into the working directory
#find -name '*.ko' -exec cp -av {} $pwd/zip/$version/system/lib/modules/ \;
#mv mkboot/boot.img zip/$version
#cp -R zip/META-INF-l900-gar zip/$version
#cd zip/$version
#mv META-INF-l900-gar META-INF
#zip -r ../tmp.zip ./
#cd ..
#java -classpath "$loc"testsign.jar testsign "tmp.zip" "$version"-"$date"-signed.zip
#rm tmp.zip
#mv *.zip ../out
#echo "Popped kernel available in the out directory"
#echo "Build log is avalable in ~/logs"
echo "Cleaning kernel directory"
# Clean up kernel tree
cd $pwd
rm -rf mkboot 
rm -rf zip
make clean
make distclean
make mrproper
echo "Done"

# geany ~/logs/$version.txt || exit 1
