BUILD_DIR := "config_default"
PLATFORM  := "stm/stm32mp257f_ev1"
PROFILE   := "profile_medium"

DTS_EXT_DIR      := "/home/marco/Documents/Projects/RND/stm32mp2/dt-stm32mp"

DTS_REL_PATH_BL2 := "stm32mp2/m33-td/mcuboot/stm32mp257f-ev1-cm33tdcid-ostl-sdcard-bl2.dts"
DTS_REL_PATH_S   := "stm32mp2/m33-td/tfm/stm32mp257f-ev1-cm33tdcid-ostl-sdcard-s.dts"
DTS_REL_PATH_NS  := "stm32mp2/m33-td/tfm/stm32mp257f-ev1-cm33tdcid-ostl-ns.dts"

default:
    @just --list

configure:
    cmake -S . -B {{BUILD_DIR}} \
       -DTFM_PLATFORM={{PLATFORM}} \
       -DTFM_TOOLCHAIN_FILE=toolchain_GNUARM.cmake \
       -DTFM_PROFILE={{PROFILE}} \
       -DSTM32_BOOT_DEV=sdmmc1 \
       -DSTM32_M33TDCID=ON \
       -DCMAKE_BUILD_TYPE=Relwithdebinfo \
       -G "Unix Makefiles" \
       -DNS=OFF \
       -DDTS_EXT_DIR={{DTS_EXT_DIR}} \
       -DDTS_BOARD_BL2={{DTS_REL_PATH_BL2}} \
       -DDTS_BOARD_S={{DTS_REL_PATH_S}} \
#        -DDEBUG_AUTHENTICATION=FULL

build:
    cmake --build {{BUILD_DIR}}

install:
    cmake --install {{BUILD_DIR}}

clean:
    rm -rf {{BUILD_DIR}}

rebuild: clean configure build
