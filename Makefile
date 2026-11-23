# Compiler and flags
VERSION = 1.0.1
PREFIX = /usr/local
MANPREFIX = $(PREFIX)/share/man
CC = cc
WARNINGS = -Wall -Wextra -pedantic
CPPFLAGS =
CFLAGS =
LDFLAGS =
LDLIBS = -lX11 -lXtst
TARGET = sxac
SRCS = sxac.c
OBJS = $(SRCS:.c=.o)

all: $(TARGET)

%.o: %.c
	$(CC) $(WARNINGS) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) $(OBJS) $(LDLIBS) -o $@

clean:
	rm -f $(OBJS) $(TARGET)

dist: $(TARGET)
	mkdir -p sxac-$(VERSION)
	cp sxac sxac-$(VERSION)
	printf '#!/bin/sh\nset -e\n' >sxac-$(VERSION)/install
	echo 'install -Dm755 sxac ${PREFIX}/bin/sxac' >>sxac-$(VERSION)/install
	chmod +x sxac-$(VERSION)/install
	tar czf sxac.tar.gz sxac-$(VERSION)
	rm -rf sxac-${VERSION}

install: $(TARGET)
	install -Dm755 $(TARGET) $(DESTDIR)$(PREFIX)/bin/$(TARGET)
	mkdir -p $(DESTDIR)$(MANPREFIX)/man1
	sed 's/VERSION/$(VERSION)/g' <$(TARGET).1 >$(DESTDIR)$(MANPREFIX)/man1/$(TARGET).1
	chmod 644 $(DESTDIR)$(MANPREFIX)/man1/$(TARGET).1

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/$(TARGET) $(DESTDIR)$(MANPREFIX)/man1/$(TARGET).1

.PHONY: all clean install uninstall dist
