led_on.bin: led_on.S
	/usr/local/arm/4.3.2/bin/arm-linux-gcc -g -c -o led_on.o led_on.S
	/usr/local/arm/4.3.2/bin/arm-linux-ld -Ttext 0x00000000 -g led_on.o -o led_on_elf
	/usr/local/arm/4.3.2/bin/arm-linux-objcopy -O binary -S led_on_elf led_on.bin

	cp led_on.bin u-boot.bin
clean:
	rm -f led_on.bin \
	      led_on_elf \
	      *.o \
	      u-boot.bin
