WAYLAND_PROTOCOLS=$(shell pkg-config --variable=pkgdatadir wayland-protocols)
WAYLAND_SCANNER=$(shell pkg-config --variable=wayland_scanner wayland-scanner)

CFLAGS ?= -g -O0 -Wall -Wextra -Wno-unused-parameter -Wno-sign-compare
CFLAGS += -Werror -I. -DWLR_USE_UNSTABLE

PKGS = wlroots wayland-server xkbcommon wayland-client
CFLAGS += $(foreach p,$(PKGS),$(shell pkg-config --cflags $(p)))
LDLIBS += $(foreach p,$(PKGS),$(shell pkg-config --libs $(p)))


# wayland-scanner is a tool which generates C headers and rigging for Wayland
# protocols, which are specified in XML. wlroots requires you to rig these up
# to your build system yourself and provide them in the include path.
# xdg-shell-protocol.h:
# 	$(WAYLAND_SCANNER) server-header \
# 		$(WAYLAND_PROTOCOLS)/stable/xdg-shell/xdg-shell.xml $@

xdg-shell-protocol.c:
	$(WAYLAND_SCANNER) private-code \
		$(WAYLAND_PROTOCOLS)/stable/xdg-shell/xdg-shell.xml $@

xdg-shell-protocol.h:
	$(WAYLAND_SCANNER) server-header \
		$(WAYLAND_PROTOCOLS)/stable/xdg-shell/xdg-shell.xml $@

%-protocol.c: protocol/%.xml
	$(WAYLAND_SCANNER) private-code $^ $@

%-protocol.h: protocol/%.xml
	$(WAYLAND_SCANNER) server-header $^ $@

config.h: | config.def.h
	cp config.def.h $@

dwl.o: config.h xdg-shell-protocol.h wlr-layer-shell-unstable-v1-protocol.h

dwl: xdg-shell-protocol.o wlr-layer-shell-unstable-v1-protocol.o

clean:
	rm -f dwl *.o xdg-shell-protocol.h xdg-shell-protocol.c wlr-layer-shell-unstable-v1-protocol.h wlr-layer-shell-unstable-v1-protocol.c

.DEFAULT_GOAL=all
.PHONY: all clean

all: dwl
