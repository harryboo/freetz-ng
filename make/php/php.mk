$(call PKG_INIT_BIN, 5.2.5)
$(PKG)_SOURCE:=php-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://freetz.magenbrot.net
#$(PKG)_SITE:=http://museum.php.net/php5
$(PKG)_BINARY:=$($(PKG)_DIR)/sapi/cgi/php-cgi
$(PKG)_TARGET_BINARY:=$(APACHE_TARGET_DIR)/cgi-bin/php

ifeq ($(strip $(FREETZ_PHP_STATIC)),y)
PHP_STATIC:= -all-static
else
PHP_STATIC:=
endif

$(PKG)_DEPENDS_ON := uclibcxx

$(PKG)_CONFIG_SUBOPTS += FREETZ_PHP_STATIC

$(PKG)_CONFIGURE_ENV += ac_cv_prog_gxx="no"
$(PKG)_CONFIGURE_OPTIONS += --disable-libxml
$(PKG)_CONFIGURE_OPTIONS += --disable-dom
$(PKG)_CONFIGURE_OPTIONS += --without-iconv
$(PKG)_CONFIGURE_OPTIONS += --disable-simplexml
$(PKG)_CONFIGURE_OPTIONS += --disable-xml
$(PKG)_CONFIGURE_OPTIONS += --disable-xmlreader
$(PKG)_CONFIGURE_OPTIONS += --disable-xmlwriter
$(PKG)_CONFIGURE_OPTIONS += --without-pear
$(PKG)_CONFIGURE_OPTIONS += --without-pdo-sqlite
$(PKG)_CONFIGURE_OPTIONS += --without-sqlite
$(PKG)_CONFIGURE_OPTIONS += --disable-ipv6
$(PKG)_CONFIGURE_OPTIONS += --enable-force-cgi-redirect
$(PKG)_CONFIGURE_OPTIONS += --enable-discard-path
$(PKG)_CONFIGURE_OPTIONS += --enable-fastcgi
$(PKG)_CONFIGURE_OPTIONS += --enable-exif
$(PKG)_CONFIGURE_OPTIONS += --with-config-file-path=php.ini


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(PHP_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(PHP_DIR) clean
	rm -f $(PHP_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	rm -f $(PHP_TARGET_BINARY)

$(PKG_FINISH)
