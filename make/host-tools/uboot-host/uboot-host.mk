$(call TOOLS_INIT, 2024.10)
$(PKG)_SOURCE_DOWNLOAD_NAME:=v$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE:=$(pkg_short)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=6c99df5f9402d05b5a5cfc60f941f0a584d0d9355fce46261bef008487a0f6c4
$(PKG)_SITE:=https://github.com/u-boot/u-boot/archive/refs/tags
### CHANGES:=https://github.com/u-boot/u-boot/tags
### CVSREPO:=https://github.com/u-boot/u-boot
### SUPPORT:=fda77

$(PKG)_DESTDIR:=$(FREETZ_BASE_DIR)/$(TOOLS_DIR)/fit

$(PKG)_DEPENDS_ON+=patchelf-host
$(PKG)_DEPENDS_ON+=openssl-host

$(PKG)_BINARIES            := dumpimage fdtgrep mkimage
$(PKG)_BINARIES_BUILD_DIR  := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/tools/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DESTDIR)/%)

$(PKG)_MAKE_VARS += HOSTCFLAGS="-I$(OPENSSL_HOST_INSTALLDIR)/include"
$(PKG)_MAKE_VARS += HOSTLDFLAGS="-L$(OPENSSL_HOST_INSTALLDIR)/lib"


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)

$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/.unpacked
	$(TOOLS_SUBMAKE) -C $(UBOOT_HOST_DIR) \
		tools-only_defconfig
	touch $@

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(UBOOT_HOST_DIR) \
		$(UBOOT_HOST_MAKE_VARS) \
		tools-only

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DESTDIR)/%: $($(PKG)_DIR)/tools/%
	$(INSTALL_FILE)

$($(PKG)_DIR)/.installed: $($(PKG)_BINARIES_TARGET_DIR)
	$(call UBOOT_HOST_FIXHARDCODED)
	@touch $@

define $(PKG)_FIXHARDCODED
	@for binfile in $(UBOOT_HOST_BINARIES_TARGET_DIR); do \
	for libfile in libcrypto libssl; do \
	$(PATCHELF) --replace-needed $(1)$${libfile}.so.3 $(OPENSSL_HOST_DESTDIR)/$${libfile}.so.3 $${binfile} ;\
	done ;\
	done ;
endef

$(pkg)-fixhardcoded:
	$(call UBOOT_HOST_FIXHARDCODED,$(TOOLS_HARDCODED_DIR)/lib/)

$(pkg)-precompiled: $($(PKG)_DIR)/.installed


$(pkg)-clean:
	-$(MAKE) -C $(UBOOT_HOST_DIR) clean
	$(RM) $(UBOOT_HOST_DIR)/.{configured,compiled,fixhardcoded}

$(pkg)-dirclean:
	$(RM) -r $(UBOOT_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) \
		$(UBOOT_HOST_BINARIES_TARGET_DIR)

$(TOOLS_FINISH)
