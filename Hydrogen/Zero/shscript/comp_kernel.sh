#!/bin/bash

i686-elf-gcc -c kernel/kernel.c -o kernel/kernel.o -ffreestanding -O2 -Wall -Wextra
