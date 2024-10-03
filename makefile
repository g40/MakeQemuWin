#
# makefile for building QEMU on Windows using msys2 MINGW64
#
# *must* be run inside an MSYS64 shell.
#
# directory structure assumes 3 peers (inside msys) so Git is siloed:
# ..
# MakeQemuWin
# qemu
# build
#
# and an external Windows directory for the binaries and dependencies
# 

# number of jobs to run
JOB=4

# QEMU repository
QREPO=https://github.com/qemu/qemu.git
# version we want to build
# QVER=v9.0.0-rc4
QVER?=v9.1.0
# where binaries will live to keep path short
QDIR=/r/apps/qemu-x

# target machines. I'm only interested in ARM stuff for this build
TARGETS=arm aarch64 x86_64


# out of tree build dir.
BDIR=../build
# source folder.
SDIR=../qemu
# assemble target machines
SPACE=$(subst ,, )
# contains spaces ...
S_LIST:=$(foreach EL,$(TARGETS),$(EL)-softmmu,)
# so remove them.
TARGET_LIST:=$(subst $(SPACE),,$(S_LIST))
# create a list of .exe files
EXE_LIST:=$(foreach EL,$(TARGETS), $(BDIR)/qemu-system-$(EL).exe)

.PHONY: deps nuked nukes build clone update loop

#
all:
	-@echo "make world: runs setup build install version"
	-@echo "make do: runs build install version"
	-@echo "make msys: ensure pacman updates and installs build requirements"
	-@echo "make clone: Get source tree into $(SDIR)"
	-@echo "make setup: configure QEMU build: $(TARGETS)"
	-@echo "make build: runs make on QEMU source tree ($(SDIR))"
	-@echo "make install: copies built binaries and runtime DLLs etc. to target folder ($(QDIR))"
	-@echo "make update: copies new binaries to target folder ($(QDIR))"
	-@echo "make version: checks installed binaries for version string ($(QDIR))"
	-@echo "make nukes: delete all build artefacts, including directory and configuration $(BDIR)"

# make sure msys environment is up to date
msys:
	pacman -Suy --noconfirm
	pacman -Sy --noconfirm base-devel ninja pkg-config glib2-devel mingw-w64-x86_64-gcc git python mingw-w64-x86_64-glib2 
	pacman -Sy --noconfirm mingw-w64-x86_64-glib2 mingw-w64-x86_64-gtk3 mingw-w64-x86_64-SDL2

# clone and checkout 
clone:
	# get the repo
	git clone $(QREPO) $(SDIR)
	# get the branch
	git -C $(SDIR) checkout $(QVER)
	
pull:
	# get the repo
	git -C $(SDIR) pull $(QREPO) $(QVER)
	# get the branch
	git -C $(SDIR) checkout $(QVER)


# setup+configure
setup:
	mkdir -p $(BDIR)
	cd $(BDIR) && $(SDIR)/configure --target-list=$(TARGET_LIST) --disable-capstone --disable-gtk --disable-sdl

# actually build binaries. adjust jobs to suit
build:
	make -C $(BDIR) -j $(JOBS)

# copy QEMU binaries and runtime DLL files etc. This could be automated and improved!
install:
# clean
	rm -rf $(QDIR)
	mkdir -p $(QDIR)
	cp $(BDIR)/*.exe $(QDIR)
# get dependencies for each binary
	$(foreach EL,$(EXE_LIST),strace $(EL) -machine mps2-an500 | grep msys64 | cut -d' ' -f 5 >> .deps-b;)
# de-dup list
	cat .deps-b | sort | uniq > .deps-l
# finally copy to QDIR replacing \path\to with /path/to
	cat .deps-l | sed 's/\\/\//g' | xargs -I % cp % $(QDIR)
	rm -f .deps-*

# just copy the binaries we built
update:
	cp $(BDIR)/*.exe $(QDIR)

# check version etc and that it runs
version:
	@ls -has $(QDIR)
	$(foreach EL,$(TARGETS), $(QDIR)/qemu-system-$(EL).exe --version;)

# caution will delete all build artefacts including config
nukes:
	rm -f .deps-*
	rm -rf $(BDIR)
	rm -f $(QDIR)/*.*
	mkdir $(BDIR)

# configuration onwards
world: setup build install version

# build onwards
do: build install version
	
# just checking!
loop:	
	@echo target list is: $(TARGET_LIST)
	@echo dep list is: $(EXE_LIST)
