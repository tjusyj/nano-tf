CC = /home/tjusyj/nano/buildroot-2017.08/output/host/bin/arm-none-linux-gnueabi-gcc
TARBALL = InfoNES097J

# InfoNES
.CFILES =	./../K6502.cpp \
		./../InfoNES.cpp \
		./../InfoNES_Mapper.cpp \
		./../InfoNES_pAPU.cpp \
		./InfoNES_System_SDL.cpp

.OFILES	=	$(.CFILES:.cpp=.o)

CCFLAGS = `/home/tjusyj/nano/buildroot-2017.08/output/host/arm-buildroot-linux-gnueabi/sysroot/usr/bin/sdl-config --cflags` -O3 -pipe
CCFLAGS_NOOPT = -O0 -pipe
LDFLAGS = `/home/tjusyj/nano/buildroot-2017.08/output/host/arm-buildroot-linux-gnueabi/sysroot/usr/bin/sdl-config --libs` 
all: InfoNES

InfoNES: $(.OFILES)
	$(CC) $(INCLUDES) -o $@ $(.OFILES) $(LDFLAGS)

# To avoid the gcc optimization bug
./../InfoNES_pAPU.o: ./../InfoNES_pAPU.cpp
	$(CC) $(INCLUDES) -c $(CCFLAGS_NOOPT) ./../InfoNES_pAPU.cpp -o ./../InfoNES_pAPU.o 

.cpp.o:
	$(CC) $(INCLUDES) -c $(CCFLAGS) $*.cpp  -o $@

clean:
	rm -f $(.OFILES) ../*~ ../*/*~ core

# End of Makefile
