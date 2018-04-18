################################################################################
#
# mesa4d
#
################################################################################

# When updating the version, please also update mesa4d-headers
MESA4D_VERSION = 17.3.6
MESA4D_SOURCE = mesa-$(MESA4D_VERSION).tar.xz
MESA4D_SITE = https://mesa.freedesktop.org/archive
	MESA4D_LICENSE = MIT, SGI, Khronos
	MESA4D_LICENSE_FILES = docs/license.html
	MESA4D_AUTORECONF = YES

MESA4D_INSTALL_STAGING = YES

MESA4D_PROVIDES =

MESA4D_DEPENDENCIES = \
											host-bison \
											host-flex \
											expat \
											libdrm \
											zlib

# Disable assembly usage.
MESA4D_CONF_OPTS = --disable-asm

# Disable static, otherwise configure will fail with: "Cannot enable both static
# and shared."
ifeq ($(BR2_SHARED_STATIC_LIBS),y)
	MESA4D_CONF_OPTS += --disable-static
endif

ifeq ($(BR2_PACKAGE_MESA4D_LLVM),y)
	MESA4D_DEPENDENCIES += host-llvm llvm
	MESA4D_CONF_OPTS += \
											--with-llvm-prefix=$(STAGING_DIR)/usr \
											--enable-llvm-shared-libs \
											--enable-llvm
	else
	# Avoid automatic search of llvm-config
	MESA4D_CONF_OPTS += --disable-llvm
endif

# The Sourcery MIPS toolchain has a special (non-upstream) feature to
# have "compact exception handling", which unfortunately breaks with
# mesa4d, so we disable it here by passing -mno-compact-eh.
ifeq ($(BR2_TOOLCHAIN_EXTERNAL_CODESOURCERY_MIPS),y)
	MESA4D_CONF_ENV += CFLAGS="$(TARGET_CFLAGS) -mno-compact-eh"
	MESA4D_CONF_ENV += CXXFLAGS="$(TARGET_CXXFLAGS) -mno-compact-eh"
endif

ifeq ($(BR2_PACKAGE_XORG7),y)
	MESA4D_DEPENDENCIES += \
												 xproto_xf86driproto \
												 xproto_dri2proto \
												 xproto_glproto \
												 xlib_libX11 \
												 xlib_libXext \
												 xlib_libXdamage \
												 xlib_libXfixes \
												 libxcb
	MESA4D_CONF_OPTS += --enable-glx --disable-mangling
	# quote from mesa4d configure "Building xa requires at least one non swrast gallium driver."
	ifeq ($(BR2_PACKAGE_MESA4D_NEEDS_XA),y)
	MESA4D_CONF_OPTS += --enable-xa
else
	MESA4D_CONF_OPTS += --disable-xa
endif
else
	MESA4D_CONF_OPTS += \
											--disable-glx \
											--disable-xa
	endif

# Drivers

#Gallium Drivers
MESA4D_GALLIUM_DRIVERS-$(BR2_PACKAGE_MESA4D_GALLIUM_DRIVER_ETNAVIV)  += etnaviv imx
MESA4D_GALLIUM_DRIVERS-$(BR2_PACKAGE_MESA4D_GALLIUM_DRIVER_NOUVEAU)  += nouveau
MESA4D_GALLIUM_DRIVERS-$(BR2_PACKAGE_MESA4D_GALLIUM_DRIVER_R600)     += r600
MESA4D_GALLIUM_DRIVERS-$(BR2_PACKAGE_MESA4D_GALLIUM_DRIVER_RADEONSI)     += radeonsi
MESA4D_GALLIUM_DRIVERS-$(BR2_PACKAGE_MESA4D_GALLIUM_DRIVER_SVGA)     += svga
MESA4D_GALLIUM_DRIVERS-$(BR2_PACKAGE_MESA4D_GALLIUM_DRIVER_SWRAST)   += swrast
MESA4D_GALLIUM_DRIVERS-$(BR2_PACKAGE_MESA4D_GALLIUM_DRIVER_VC4)      += vc4
MESA4D_GALLIUM_DRIVERS-$(BR2_PACKAGE_MESA4D_GALLIUM_DRIVER_VIRGL)    += virgl
# DRI Drivers
MESA4D_DRI_DRIVERS-$(BR2_PACKAGE_MESA4D_DRI_DRIVER_SWRAST) += swrast
MESA4D_DRI_DRIVERS-$(BR2_PACKAGE_MESA4D_DRI_DRIVER_I915)   += i915
MESA4D_DRI_DRIVERS-$(BR2_PACKAGE_MESA4D_DRI_DRIVER_I965)   += i965
MESA4D_DRI_DRIVERS-$(BR2_PACKAGE_MESA4D_DRI_DRIVER_NOUVEAU) += nouveau
MESA4D_DRI_DRIVERS-$(BR2_PACKAGE_MESA4D_DRI_DRIVER_RADEON) += radeon
# Vulkan Drivers
MESA4D_VULKAN_DRIVERS-$(BR2_PACKAGE_MESA4D_VULKAN_DRIVER_INTEL)   += intel

ifeq ($(BR2_PACKAGE_MESA4D_GALLIUM_DRIVER),)
	MESA4D_CONF_OPTS += \
											--without-gallium-drivers \
											--disable-gallium-extra-hud
	else
	MESA4D_CONF_OPTS += \
											--enable-shared-glapi \
											--with-gallium-drivers=$(subst $(space),$(comma),$(MESA4D_GALLIUM_DRIVERS-y)) \
											--enable-gallium-extra-hud
	endif

ifeq ($(BR2_PACKAGE_MESA4D_DRI_DRIVER),)
	MESA4D_CONF_OPTS += \
											--without-dri-drivers --disable-dri3
	else
	ifeq ($(BR2_PACKAGE_XLIB_LIBXSHMFENCE)$(BR2_PACKAGE_XPROTO_DRI3PROTO),yy)
	MESA4D_DEPENDENCIES += xlib_libxshmfence xproto_dri3proto xproto_presentproto
	MESA4D_CONF_OPTS += --enable-dri3
else
	MESA4D_CONF_OPTS += --disable-dri3
endif
ifeq ($(BR2_PACKAGE_XLIB_LIBXXF86VM),y)
	MESA4D_DEPENDENCIES += xlib_libXxf86vm
endif
MESA4D_CONF_OPTS += \
										--enable-shared-glapi \
										--enable-driglx-direct \
										--with-dri-drivers=$(subst $(space),$(comma),$(MESA4D_DRI_DRIVERS-y))
endif

ifeq ($(BR2_PACKAGE_MESA4D_VULKAN_DRIVER),)
	MESA4D_CONF_OPTS += \
											--without-vulkan-drivers
	else
	MESA4D_CONF_OPTS += \
											--with-vulkan-drivers=$(subst $(space),$(comma),$(MESA4D_VULKAN_DRIVERS-y))
	endif

# APIs

ifeq ($(BR2_PACKAGE_MESA4D_OSMESA),y)
	MESA4D_CONF_OPTS += --enable-osmesa
else
	MESA4D_CONF_OPTS += --disable-osmesa
endif

# Always enable OpenGL:
#   - it is needed for GLES (mesa4d's ./configure is a bit weird)
MESA4D_CONF_OPTS += --enable-opengl --enable-dri

# libva and mesa4d have a circular dependency
# we do not need libva support in mesa4d, therefore disable this option
MESA4D_CONF_OPTS += --disable-va

# libGL is only provided for a full xorg stack
ifeq ($(BR2_PACKAGE_XORG7),y)
	#MESA4D_PROVIDES += libgl
else
	define MESA4D_REMOVE_OPENGL_HEADERS
	rm -rf $(STAGING_DIR)/usr/include/GL/
	endef

MESA4D_POST_INSTALL_STAGING_HOOKS += MESA4D_REMOVE_OPENGL_HEADERS
endif

ifeq ($(BR2_PACKAGE_MESA4D_DRI_DRIVER),y)
	MESA4D_PLATFORMS = drm
else ifeq ($(BR2_PACKAGE_MESA4D_GALLIUM_DRIVER_VC4),y)
	MESA4D_PLATFORMS = drm
else ifeq ($(BR2_PACKAGE_MESA4D_GALLIUM_DRIVER_ETNAVIV),y)
	MESA4D_PLATFORMS = drm
else ifeq ($(BR2_PACKAGE_MESA4D_GALLIUM_DRIVER_VIRGL),y)
	MESA4D_PLATFORMS = drm
endif
ifeq ($(BR2_PACKAGE_WAYLAND),y)
	MESA4D_DEPENDENCIES += wayland wayland-protocols
	MESA4D_PLATFORMS += wayland
endif
ifeq ($(BR2_PACKAGE_XORG7),y)
	MESA4D_PLATFORMS += x11
endif

MESA4D_CONF_OPTS += \
										--with-platforms=$(subst $(space),$(comma),$(MESA4D_PLATFORMS))

ifeq ($(BR2_PACKAGE_MESA4D_OPENGL_EGL),y)
	#MESA4D_PROVIDES += libegl
	MESA4D_CONF_OPTS += \
											--enable-gbm \
											--enable-egl
	else
	MESA4D_CONF_OPTS += \
											--disable-egl
	endif

ifeq ($(BR2_PACKAGE_MESA4D_OPENGL_ES),y)
	#MESA4D_PROVIDES += libgles
	MESA4D_CONF_OPTS += --enable-gles1 --enable-gles2
else
	MESA4D_CONF_OPTS += --disable-gles1 --disable-gles2
endif

ifeq ($(BR2_PACKAGE_MESA4D_OPENGL_TEXTURE_FLOAT),y)
	MESA4D_CONF_OPTS += --enable-texture-float
	MESA4D_LICENSE_FILES += docs/patents.txt
else
	MESA4D_CONF_OPTS += --disable-texture-float
endif

ifeq ($(BR2_PACKAGE_XLIB_LIBXVMC),y)
	MESA4D_DEPENDENCIES += xlib_libXvMC
	MESA4D_CONF_OPTS += --enable-xvmc
else
	MESA4D_CONF_OPTS += --disable-xvmc
endif

ifeq ($(BR2_PACKAGE_LIBUNWIND),y)
	MESA4D_CONF_OPTS += --enable-libunwind
	MESA4D_DEPENDENCIES += libunwind
else
	MESA4D_CONF_OPTS += --disable-libunwind
endif

ifeq ($(BR2_PACKAGE_LIBVDPAU),y)
	MESA4D_DEPENDENCIES += libvdpau
	MESA4D_CONF_OPTS += --enable-vdpau
else
	MESA4D_CONF_OPTS += --disable-vdpau
endif

ifeq ($(BR2_PACKAGE_LM_SENSORS),y)
	MESA4D_CONF_OPTS += --enable-lmsensors
	MESA4D_DEPENDENCIES += lm-sensors
else
	MESA4D_CONF_OPTS += --disable-lmsensors
endif

$(eval $(autotools-package))
