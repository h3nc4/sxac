# Compiler and flags
VERSION = 1.0.1
PREFIX = /usr/local
CC = cc
CFLAGS = -Wall -Wextra -pedantic
LDFLAGS = -lX11 -lXtst
TARGET = sxac
SRCS = sxac.c
OBJS = $(SRCS:.c=.o)

all: $(TARGET)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

$(TARGET): $(OBJS)
	$(CC) $(OBJS) $(LDFLAGS) -o $@

clean:
	rm -f $(OBJS) $(TARGET)

dist: $(TARGET)
	mkdir -p sxac-$(VERSION)
	cp sxac sxac-$(VERSION)
	printf '#!/bin/sh\nset -e\n' >sxac-$(VERSION)/install
	echo 'install -Dm755 sxac ${PREFIX}/bin/sxac' >>sxac-$(VERSION)/install
	chmod +x sxac-$(VERSION)/install
	tar czf sxac.tgz sxac-$(VERSION)
	rm -rf sxac-${VERSION}

install: $(TARGET)
	install -Dm755 $(TARGET) /usr/local/bin/$(TARGET)

uninstall:
	rm -f /usr/local/bin/$(TARGET)

.PHONY: all clean install uninstall dist
