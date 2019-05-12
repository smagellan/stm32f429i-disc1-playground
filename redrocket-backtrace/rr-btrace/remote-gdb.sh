#! /bin/bash

/opt/gcc-arm-none-eabi-8-2018-q4-major/bin/arm-none-eabi-gdb rr-btrace.elf \
	-ex 'target remote localhost:3333' \
	-ex 'monitor reset halt';

