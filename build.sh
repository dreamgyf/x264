# Linux 交叉编译 Android 库脚本
if [[ -z $ANDROID_NDK ]]; then
    echo 'Error: Can not find ANDROID_NDK path.'
    exit 1
fi

echo "ANDROID_NDK path: ${ANDROID_NDK}"

OUTPUT_DIR="_output_"

rm -rf ${OUTPUT_DIR}
mkdir ${OUTPUT_DIR} && cd ${OUTPUT_DIR}

OUTPUT_PATH=`pwd`

API=21
TOOLCHAIN=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64

function build {
    ABI=$1

    if [[ $ABI == "armeabi-v7a" ]]; then
        TRIPLE="armv7a-linux-androideabi"
    elif [[ $ABI == "arm64-v8a" ]]; then
        TRIPLE="aarch64-linux-android"
    elif [[ $ABI == "arm64-v8a" ]]; then
        TRIPLE="x86"
    elif [[ $ABI == "x86-64" ]]; then
        TRIPLE="x86_64-linux-android"
    else
        echo "Unsupported ABI ${ABI}!"
        exit 1
    fi

    echo "Build ABI ${ABI}..."

    rm -rf ${ABI}
    mkdir ${ABI} && cd ${ABI}

    PREFIX=${OUTPUT_PATH}/product/$ABI

    export CC=$TOOLCHAIN/bin/${TRIPLE}${API}-clang
    export CFLAGS="-g -DANDROID -fdata-sections -ffunction-sections -funwind-tables -fstack-protector-strong -no-canonical-prefixes -D_FORTIFY_SOURCE=2 -Wformat -Werror=format-security  -O0 -DNDEBUG  -fPIC --gcc-toolchain=$TOOLCHAIN --target=${TRIPLE}${API}"

    ../../configure \
        --host=${TRIPLE} \
        --prefix=$PREFIX \
        --enable-static \
        --enable-shared \
        --enable-pic \
        --disable-lavf \
        --sysroot=$TOOLCHAIN/sysroot

    make clean && make -j`nproc` && make install

    cd ..
}

build armeabi-v7a
build arm64-v8a
