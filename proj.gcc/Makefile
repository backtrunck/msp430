
OBJECTS=blink.o

GCC_DIR =/home/lcreina/msp430-gcc-6.4.0.32_source-full/install/usr/local/bin/msp430-elf-gcc 

SUPPORT_FILE_DIRECTORY = ../../../include

# Please set your device here
 DEVICE = msp430X
 CC  = $(GCC_DIR)/msp430-elf-gcc
 GDB  = $(GCC_DIR)/msp430-elf-gdb
 CFLAGS = -I $(SUPPORT_FILE_DIRECTORY) -mmcu=$(DEVICE) -O2 -g
 LFLAGS = -L $(SUPPORT_FILE_DIRECTORY) -T $(DEVICE).ld

all: ${OBJECTS}
 	$(CC) $(CFLAGS) $(LFLAGS) $? -o $(DEVICE).out
 debug: all
 	$(GDB) $(DEVICE).out
