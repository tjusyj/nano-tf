# Makefile
#
LVGL_DIR =  $(shell pwd)
CC = /home/tjusyj/nano-tf/buildroot-2017.08/output/host/bin/arm-none-linux-gnueabi-gcc
CFLAGS = -Wall -Wshadow -Wundef -Wmaybe-uninitialized
CFLAGS += -O3 -g3 -I./
#LDFLAGS += -lSDL2 -lm
BIN = demo
BUILDDIR=build
VPATH = 
 
MAINSRC = main.c
 
#LIBRARIES
include ./lvgl/lvgl.mk
 
#DRIVERS
include ./lv_drivers/lv_drivers.mk
 
#EXAMPLE
include ./lv_examples/lv_examples.mk
 
OBJEXT ?= .o
 
AOBJS = $(ASRCS:.S=$(OBJEXT))
COBJS = $(CSRCS:.c=$(OBJEXT))
 
MAINOBJ = $(MAINSRC:.c=$(OBJEXT))
 
SRCS = $(ASRCS) $(CSRCS) $(MAINSRC)
OBJS = $(AOBJS) $(COBJS)
 
## MAINOBJ -> OBJFILES
 
all: clean default
 
%.o: %.c
	@$(CC)  $(CFLAGS) -c $< -o $@
	@echo "CC $<"
 
default: $(AOBJS) $(COBJS) $(MAINOBJ)
	$(CC) -o $(BIN) $(MAINOBJ) $(AOBJS) $(COBJS) $(LDFLAGS)
 
clean:
	rm -f $(BIN) $(AOBJS) $(COBJS) $(MAINOBJ)
