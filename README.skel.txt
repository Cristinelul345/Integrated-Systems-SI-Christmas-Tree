-------------------------------------------------------------------------------
Instrucțiuni Schelet Tema 2 SI 2022-2023 (v0.1):
-------------------------------------------------------------------------------

1. Puteți folosi scripturile incluse în Makefile pentru a genera arhiva cu
soluțiile:

  * `make bin_archive`: generează arhiva binară;
  * `make bin_checksum`: suprascrie fișierul CHECKSUM cu noul checksum;
  * `make source_archive`: generează arhiva cu fișierele sursă din directorul
    curent (exceptând, desigur, orice e binar);

Atenție: scripturile nu funcționează decât dacă ați folosit structura de
directoare a lui `kas`, adică layerele descărcate prin git în `layers/` și
binarele în `build/tmp/deploy/` etc. (toate, desigur, ignorate la `make
source_archive`).

INSPECTAȚI MANUAL CONȚINUTUL ACESTEIA pentru a vedea că v-a inclus tot ce
doriți să trimiteți.

2. Testare folosind qemu:
==========================

Varianta de lucru, în Yocto:
  > source ./layers/poky/oe-init-build-env
  > runqemu qemuarm nographic slirp

Varianta finală:
  > make bin_archive  # generăm arhiva
  > ls -l build/tmp/bin_archive  # aici se află fișierele din arhiva binară
  > ./launch_bin.sh  # testăm dacă pornește bine

În caz că rămâneți blocați în qemu, mai citim o dată laboratorul:
https://ocw.cs.pub.ro/courses/si/laboratoare/06

