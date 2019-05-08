PROJECT = rr-btrace
BUILD_DIR = bin

#SHARED_DIR = ../my-common-code
CFILES = usart_console.c clock.c

CSTD=-std=c11
INCLUDES=-I/home/vladimir/projects/backtrace/include/
TGT_CFLAGS += -mpoke-function-name -funwind-tables -fno-omit-frame-pointer -fmessage-length=0 -fsigned-char
TGT_LDFLAGS += --specs=rdimon.specs -L/home/vladimir/projects/backtrace/build/release/backtrace
LDLIBS += -lbacktrace

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
