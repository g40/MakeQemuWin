#
# makefile for building QEMU on Windows using msys2 MINGW64
#
# directory structure assumes 3 peers so Git is siloed:
# ..
# MakeQemuWin
# qemu
# build
#

# QEMU repository
QREPO=https://github.com/qemu/qemu.git
# version we want to build
QVER=v9.0.0-rc4
# where binaries will live to keep path short
QDIR=/r/apps/qemu9

# target machines. I'm only interested in ARM stuff for this build
T_ARM=arm-softmmu,aarch64-softmmu

# out of tree build dir.
BDIR=../build
# source folder.
SDIR=../qemu

#
all:
	-@echo "make clone: Get source tree into $(SDIR)"
	-@echo "make setup: configure QEMU build. arm and aarch64 in this case"
	-@echo "make build: runs make on QEMU source tree ($(SDIR))"
	-@echo "make update: copies binaries to target folder ($(QDIR))"
	-@echo "make nuke: delete all build artefacts, including directory and configuration $(BDIR)cd ../qemu9"
	-@echo "make install: copies built binaries and runtime DLLs etc. to target folder ($(QDIR))"

# clone and checkout 
clone:
	git clone $(QREPO) $(SDIR)
	git -C $(SDIR) checkout $(QVER)
	
# setup+configure
setup:
	mkdir -p $(BDIR)
	cd $(BDIR) && $(SDIR)/configure --target-list=$(T_ARM) --disable-capstone

# actually build binaries. adjust jobs to suit
build:
	make -C $(BDIR) -j 6

# just copy the binaries we built
update:
	cp $(BDIR)/*.exe $(QDIR)

# check version etc and that it runs
version:
	$(QDIR)/qemu-system-arm --version
	$(QDIR)/qemu-system-aarch64 --version

# copy QEMU binaries and runtime DLL files etc. This could be automated and improved!
install:
	rm -rf $(QDIR)
	mkdir -p $(QDIR)
	cp $(BDIR)/*.exe $(QDIR)
	cp /mingw64/bin/{libatk-1.0-0.dll,libbz2-1.dll,libcairo-2.dll,libcairo-gobject-2.dll,libdatrie-1.dll,libepoxy-0.dll,libexpat-1.dll,libffi-6.dll,libfontconfig-1.dll,libfreetype-6.dll,libfribidi-0.dll,libgcc_s_seh-1.dll,libgdk_pixbuf-2.0-0.dll,libgdk-3-0.dll,libgio-2.0-0.dll,libglib-2.0-0.dll,libgmodule-2.0-0.dll,libgobject-2.0-0.dll,libgraphite2.dll,libgtk-3-0.dll,libharfbuzz-0.dll,libiconv-2.dll,libintl-8.dll,libjpeg-8.dll,liblzo2-2.dll,libpango-1.0-0.dll,libpangocairo-1.0-0.dll,libpangoft2-1.0-0.dll,libpangowin32-1.0-0.dll,libpcre-1.dll,libpixman-1-0.dll,libpng16-16.dll,libssp-0.dll,libstdc++-6.dll,libthai-0.dll,libwinpthread-1.dll,SDL2.dll,zlib1.dll} $(QDIR)

# caution will delete all build artefacts
nuke:
	rm -rf $(BDIR)
	mkdir $(BDIR)
