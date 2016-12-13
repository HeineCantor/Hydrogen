#!/bin/bash

i686-elf-gcc -T linker.ld -o bin/hydrogen.bin -ffreestanding -O2 -nostdlib bootstrap/boot.o kernel/kernel.o -lgcc
