
# Gramado Kernel
# License: BSD License
# Compiling on gcc 11.4.0
# Linking on ld 2.38

BASE    = base
#DEP_B1  = ../de/commands
#DEP_B2  = ../de/ui
#DEP_B3  = ../3ddemo
#DEP_B10 = ../guest0
#DEP_B11 = ../guest1

# Make variables (CC, etc...)
AS      = as
LD      = ld
CC      = gcc
AR      = ar
MAKE    = make
NASM    = nasm
PYTHON  = python
PYTHON2 = python2
PYTHON3 = python3

#
# Config
#

# verbose
# Quiet compilation or not.
ifndef CONFIG_USE_VERBOSE
	CONFIG_USE_VERBOSE = 1
endif

ifeq ($(CONFIG_USE_VERBOSE),1)
	Q =
else
	Q = @
endif

# --------------------------------------
# == Start ====
# build: User command.
PHONY := all
all:  \
virtual-disk \
mbr-backup \
bootmanager \
bootmanager2 \
bootloader \


	@echo "Done?"


# options: 
# main.asm and main2.asm
# O mbr só consegue ler o root dir para pegar o BM.BIN
# See: stage1.asm
# O BM.BIN só consegue ler o root dir pra pegar o BL.BIN
# See: main.asm
# the kernel image
# O BL.BIN procura o kernel no diretorio GRAMADO/
# See: fs/loader.c

#----------------------------------
# (1) boot/

PHONY := virtual-disk  
virtual-disk:     

# Create the virtual disk 0.
	$(Q)$(NASM) boot/vd/fat/main.asm \
	-I boot/vd/fat/ \
	-o GRAMHV.VHD 

PHONY := mbr-backup  
mbr-backup:     

# Create backup for MBR 0.
	$(Q)$(NASM) boot/vd/fat/stage1.asm \
	-I boot/vd/fat/ \
	-o MBR0.BIN
	cp MBR0.BIN  $(BASE)/

PHONY := bootmanager  
bootmanager:     

# ::Build BM.BIN. (legacy, no dialog)
	$(Q)$(MAKE) -C boot/x86/bm/ 
# Copy to the target folder.
	cp boot/x86/bin/BM.BIN  $(BASE)/

PHONY := bootmanager2  
bootmanager2:     

# #BUGBUG 
# Suspended!
# Something is affecting the window server,
# if we enter in the graphics mode without entering
# the shell first. There are two routines 
# to initialize the gui mode. Only one is good.
# ::Build BM2.BIN. (Interface with dialog)
	$(Q)$(MAKE) -C boot/x86/bm2/ 
# Copy to the target folder.
	cp boot/x86/bin/BM2.BIN  $(BASE)/

PHONY := bootloader  
bootloader:     

# ::Build BL.BIN.
	$(Q)$(MAKE) -C boot/x86/bl/ 
# Copy to the target folder.
	cp boot/x86/bin/BL.BIN  $(BASE)/

clean:
#todo
	-rm *.o
	-rm *.BIN
	@echo "~clean"

# --------------------------------------
# Clean up all the mess.
clean-all: clean

	-rm *.o
	-rm *.BIN
	-rm *.VHD
	-rm *.ISO

# ==================
# (1) boot/
# Clear boot images
	-rm -rf boot/x86/bin/*.BIN

# ==================
# Clear the disk cache
	-rm -rf $(BASE)/*.BIN 
	-rm -rf $(BASE)/*.BMP
	-rm -rf $(BASE)/EFI/BOOT/*.EFI 
	-rm -rf $(BASE)/GRAMADO/*.BIN 
	-rm -rf $(BASE)/PROGRAMS/*.BIN 
	-rm -rf $(BASE)/USERS/*.BIN 

	@echo "~clean-all"

# --------------------------------------
# Usage instructions.
usage:
	@echo "Building everything:"
	@echo "make all"
	@echo "Clear the mess to restart:"
	@echo "make clean-all"
	@echo "Testing on qemu:"

# End

