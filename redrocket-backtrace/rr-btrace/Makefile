PROJECT = rr-btrace
BUILD_DIR = bin

#SHARED_DIR = ../my-common-code
CFILES = usart_console.c clock.c stdlib_syscalls.c btrace.c
CXXFILES=CppTest.cpp

CSTD=-std=c11
CXXSTD=-std=c++17
INCLUDES=-I/home/vladimir/projects/backtrace/include/
TGT_CXXFLAGS += -fno-exceptions -fno-rtti
TGT_CFLAGS += -mpoke-function-name -funwind-tables -fno-omit-frame-pointer -fmessage-length=0 -fsigned-char -fstack-protector-strong
TGT_LDFLAGS += -specs=nosys.specs -specs=rdimon.specs -L/home/vladimir/projects/backtrace/build/release/backtrace
LDLIBS += -lbacktrace -lstdc++
OPENCM3_DEFS += -DCONSOLE_UART=USART1 -D_FORTIFY_SOURCE=2

# TODO - you will need to edit these two lines!
DEVICE=stm32f429zit6
#DEVICE=stm32f407vgt6
OOCD_FILE = board/stm32f429disc1.cfg

#OOCD_INTERFACE=stlink-v2-1

# You shouldn't have to edit anything below here.
VPATH += $(SHARED_DIR)
INCLUDES += $(patsubst %,-I%, . $(SHARED_DIR))
OPENCM3_DIR=../../libopencm3

include $(OPENCM3_DIR)/mk/genlink-config.mk
include ../rules.mk
include $(OPENCM3_DIR)/mk/genlink-rules.mk
