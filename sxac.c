/* See LICENSE file for copyright and license details.
 * Copyright (C) 2023-2024  Henrique Almeida <me@h3nc4.com> */

#include <X11/Xlib.h>
#include <X11/extensions/XTest.h>
#include <unistd.h>
#include <stdio.h>
#include <signal.h>
#include <stdlib.h>

volatile int running = 1;

void handle_signal(int signal)
{
	running = 0;
}

int main()
{
	signal(SIGINT, handle_signal);
	signal(SIGTERM, handle_signal);
	Display *display = XOpenDisplay(NULL);

	if (!display)
	{
		fprintf(stderr, "Unable to open X display\n");
		return 1;
	}

	int delay = 100000;

	while (running)
	{
		XTestFakeButtonEvent(display, 1, True, CurrentTime);
		XFlush(display);
		XTestFakeButtonEvent(display, 1, False, CurrentTime);
		XFlush(display);
		usleep(delay);
	}

	XCloseDisplay(display);
	return 0;
}
