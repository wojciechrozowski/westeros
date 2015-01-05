TARGET   ?=i586-elf
LINKER   ?=link.ld
SRCFILES := $(shell find . boot ipc kernel lib mm -maxdepth 1 -type f -name "*.c" -o -name "*.S")
OBJECTS  :=$(SRCFILES:.c=.o)
OBJECTS  :=$(OBJECTS:.S=.o) 
OBJECTS  := $(OBJECTS)
AS       :=$(TARGET)-as
CC       :=$(TARGET)-gcc
LD       :=$(TARGET)-gcc
EM       :=qemu-system-$(ARCH)
ASFLAGS  := 
CFLAGS   := -std=gnu99 -ffreestanding -O2 -Wall  -Wextra -nostdlib -lgcc -D$(ARCH) -I../include
LDFLAGS  :=-ffreestanding -O2 -nostdlib -lgcc


all: rmlog $(OBJECTS) link iso test

link:
	$(LD) -T $(LINKER) -o build/boot/kernel.elf $(LDFLAGS) $(OBJECTS)
test:
	@$(EM) $(EMUFLAGS) -cdrom bootable.iso -serial file:kernel.log -m 16M
.S.o:
	@$(AS) $(ASFLAGS) -o $*.o $<
.c.o:
	$(CC) $(CFLAGS) -c -o $*.o $<
clean:
	-@rm $(OBJECTS) .build/boot/kernel.elf
iso:
	genisoimage -R -b boot/grub/stage2_eltorito -no-emul-boot -boot-load-size 4 -boot-info-table -o bootable.iso build
rmlog:
	-rm kernel.log
	
	