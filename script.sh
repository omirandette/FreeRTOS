#!/usr/bin/env bash
set -e

pushd "$(dirname "$0")"

name="sample"

#cleaning

mkdir -p target
rm -rf target/*
rm -rf $name.*

#file definition

cfile=(
./src/ASF/thirdparty/freertos/freertos-7.0.0/source/timers.c
./src/ASF/avr32/boards/evk1100/led.c
./src/ASF/avr32/drivers/gpio/gpio.c
./src/ASF/avr32/drivers/intc/intc.c
./src/ASF/avr32/drivers/pm/pm.c
./src/ASF/avr32/drivers/pm/pm_conf_clocks.c
./src/ASF/avr32/drivers/pm/power_clocks_lib.c
./src/ASF/avr32/drivers/tc/tc.c
./src/ASF/avr32/drivers/usart/usart.c
./main.c
./src/ASF/thirdparty/freertos/demo/common/minimal/AltBlckQ.c
./src/ASF/thirdparty/freertos/demo/common/minimal/AltPollQ.c
./src/ASF/thirdparty/freertos/demo/common/minimal/AltQTest.c
./src/ASF/thirdparty/freertos/demo/common/minimal/BlockQ.c
./src/ASF/thirdparty/freertos/demo/common/minimal/blocktim.c
./src/ASF/thirdparty/freertos/demo/common/minimal/comtest.c
./src/ASF/thirdparty/freertos/demo/common/minimal/countsem.c
./src/ASF/thirdparty/freertos/demo/common/minimal/crflash.c
./src/ASF/thirdparty/freertos/demo/common/minimal/crhook.c
./src/ASF/thirdparty/freertos/demo/common/minimal/death.c
./src/ASF/thirdparty/freertos/demo/common/minimal/dynamic.c
./src/ASF/thirdparty/freertos/demo/common/minimal/flash.c
./src/ASF/thirdparty/freertos/demo/common/minimal/flop.c
./src/ASF/thirdparty/freertos/demo/common/minimal/GenQTest.c
./src/ASF/thirdparty/freertos/demo/common/minimal/integer.c
./src/ASF/thirdparty/freertos/demo/common/minimal/PollQ.c
./src/ASF/thirdparty/freertos/demo/common/minimal/QPeek.c
./src/ASF/thirdparty/freertos/demo/common/minimal/recmutex.c
./src/ASF/thirdparty/freertos/demo/common/minimal/semtest.c
./src/ASF/thirdparty/freertos/freertos-7.0.0/source/croutine.c
./src/ASF/thirdparty/freertos/freertos-7.0.0/source/list.c
./src/ASF/thirdparty/freertos/freertos-7.0.0/source/portable/gcc/avr32_uc3/port.c
./src/ASF/thirdparty/freertos/freertos-7.0.0/source/portable/gcc/avr32_uc3/read.c
./src/ASF/thirdparty/freertos/freertos-7.0.0/source/portable/gcc/avr32_uc3/write.c
./src/ASF/thirdparty/freertos/freertos-7.0.0/source/portable/memmang/heap_3.c
./src/ASF/thirdparty/freertos/freertos-7.0.0/source/queue.c
./src/ASF/thirdparty/freertos/freertos-7.0.0/source/tasks.c
./src/ASF/thirdparty/freertos/freertos-7.0.0/source/timers.c
./src/ASF/avr32/components/display/dip204/dip204.c
./src/ASF/avr32/drivers/spi/spi.c
./src/ASF/avr32/drivers/pwm/pwm.c
)

asmfile=(
./src/ASF/thirdparty/freertos/freertos-7.0.0/source/portable/gcc/avr32_uc3/exception.S
./src/ASF/avr32/utils/startup/trampoline_uc3.S
)

include=(
./src/ASF/avr32/drivers/pwm/
./src/ASF/common/services/delay/
./src/ASF/common/services/clock/
./src/ASF/avr32/drivers/cpu/cycle_counter/
./src/ASF/avr32/components/display/dip204/
./src/ASF/avr32/drivers/adc/
./src/ASF/avr32/drivers/spi/
./src/ASF/thirdparty/freertos/demo/avr32_uc3_example/at32uc3a0512_evk1100
./src/config
./src/ASF/avr32/boards/evk1100
./src/ASF/thirdparty/freertos/demo/common/include
./src/ASF/common/utils
./src/
./src/ASF/avr32/boards
./src/ASF/thirdparty/freertos/demo/avr32_uc3_example
./src/ASF/avr32/drivers/tc
./src/ASF/avr32/drivers/gpio
./src/ASF/thirdparty/freertos/freertos-7.0.0/source/include
./src/ASF/common/boards
./src/ASF/avr32/utils
./src/ASF/avr32/utils/preprocessor
./src/ASF/thirdparty/freertos/freertos-7.0.0/source/portable/gcc/avr32_uc3
./src/ASF/avr32/drivers/pm
./src/ASF/avr32/drivers/usart
./src/ASF/avr32/drivers/flashc
./src/ASF/avr32/drivers/intc
./src/ASF/common/services/usb/class/cdc/device/
./src/ASF/common/services/usb/class/cdc/
./src/ASF/common/services/usb/
./src/ASF/common/services/usb/udc/
./src/ASF/avr32/drivers/usbb/
./src/ASF/common/services/sleepmgr/
./src/ASF/common/services/sleepmgr/uc3/
./src/ASF/common/services/clock/uc3a0_a1/
./AT32UC3A0512
)

#GCC arguments

compilation="-mrelax -Os -fdata-sections -ffunction-sections -masm-addr-pseudos -Wall -mpart=uc3a0512 -c -std=gnu99 -fno-strict-aliasing -Wstrict-prototypes -Wmissing-prototypes -Werror-implicit-function-declaration -Wpointer-arith -mrelax -mno-cond-exec-before-reload"
defines="-DNDEBUG -DBOARD=EVK1100 -D__FREERTOS__"

include_path=" "
for i in ${include[@]}; do
	include_path=$include_path" -I"$i
done

gcc=" "$defines" "$include_path" "$compilation

# compiling the .o file
for i in ${cfile[@]}; do
	filename=$(basename "$i")
	filename_no_ext="${filename%.*}"
	echo "compiling "$filename_no_ext
    avr32-gcc -x c -c $gcc $i -o "target/$filename_no_ext.o"
done

for i in ${asmfile[@])}; do
        filename=$(basename "$i")
        filename_no_ext="${filename%.*}"
        echo "compiling "$filename_no_ext
        avr32-gcc -x assembler-with-cpp -c $gcc $i  -o "target/$filename_no_ext.o"
done

#building the software
echo "building elf and hex files"
avr32-gcc -o $name.elf target/*.o -Wl,-Map="$name.map" -Wl,--start-group -lm  -Wl,--end-group -Wl,--gc-sections --rodata-writable -Wl,--direct-data -mpart=uc3a0512 -Wl,--relax -T./src/ASF/avr32/utils/linker_scripts/at32uc3a/0512/gcc/link_uc3a0512.lds -Wl,-e,_trampoline

avr32-objcopy -O ihex -R .eeprom -R .fuse -R .lock -R .signature "$name.elf" "$name.hex"
avr32-objcopy -j .eeprom  --set-section-flags=.eeprom=alloc,load --change-section-lma .eeprom=0  --no-change-warnings -O ihex "$name.elf" "$name.eep"
avr32-objdump  -h -S "$name.elf" > "$name.lss"
avr32-objcopy -O srec -R .eeprom -R .fuse -R .lock -R .signature -R .user_signatures "$name.elf" "$name.srec"
avr32-size $name.elf

#flashing the board

dfu-programmer at32uc3a0512 erase
dfu-programmer at32uc3a0512 flash ./$name.hex --suppress-bootloader-mem
dfu-programmer at32uc3a0512 start

popd
