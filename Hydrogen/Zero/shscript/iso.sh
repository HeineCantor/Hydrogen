#!/bin/bash

mkdir -p isodir/boot/grub
cp bin/hydrogen.bin isodir/boot/hydrogen.bin
cp grub.cfg isodir/boot/grub/grub.cfg
grub-mkrescue -o iso/hydrogen.iso isodir
