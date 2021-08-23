$(call PKG_INIT_BIN, 3.0.5)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=efbf362a65bec771bc15ad311f5a982e
$(PKG)_SITE:=https://security.appspot.com/downloads

$(PKG)_BINARY:=$($(PKG)_DIR)/vsftpd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/vsftpd

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_VSFTPD_STATIC
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_VSFTPD_WITH_SSL

ifeq ($(strip $(FREETZ_PACKAGE_VSFTPD_WITH_SSL)),y)
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHLIB_VERSION
$(PKG)_DEPENDS_ON += openssl
$(PKG)_CFLAGS += -DFREETZ_PACKAGE_VSFTPD_WITH_SSL
$(PKG)_EXTRA_LIBS += -lssl -lcrypto
$(PKG)_EXTRA_LIBS += $(if $(FREETZ_PACKAGE_VSFTPD_STATIC),$(OPENSSL_LIBCRYPTO_EXTRA_LIBS))
endif

ifeq ($(strip $(FREETZ_PACKAGE_VSFTPD_STATIC)),y)
$(PKG)_LDFLAGS += -static
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(VSFTPD_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) $(VSFTPD_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS) $(VSFTPD_LDFLAGS)" \
		EXTRA_LIBS="$(VSFTPD_EXTRA_LIBS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(VSFTPD_DIR) clean

$(pkg)-uninstall:
	$(RM) $(VSFTPD_TARGET_BINARY)

$(PKG_FINISH)
