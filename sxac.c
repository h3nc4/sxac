/* See LICENSE file for copyright and license details.
 * Copyright (C) 2023-2024  Henrique Almeida <me@h3nc4.com> */

#include <X11/Xlib.h>
#include <X11/extensions/XTest.h>
#include <unistd.h>
#include <stdio.h>
#include <signal.h>
#include <stdlib.h>
#include <getopt.h>

volatile int running = 1;

void handle_signal(int signal)
{
	running = 0;
}

void print_usage(const char *progname)
{
	fprintf(stderr, "Usage: %s [-b button_number] [-h]\n", progname);
	fprintf(stderr, "  -b button_number   Simulate button press (1-3)\n");
	fprintf(stderr, "  -h                 Show this help message\n");
}

int main(int argc, char *argv[])
{
	signal(SIGINT, handle_signal);
	signal(SIGTERM, handle_signal);

	int button = 1;
	int delay = 100000;

	int opt;
	while ((opt = getopt(argc, argv, "b:h")) != EOF)
	{
		switch (opt)
		{
		case 'b':
			button = atoi(optarg);
			if (button < 1 || button > 3)
			{
				fprintf(stderr, "%s: invalid button number '%d'\n", argv[0], button);
				return EXIT_FAILURE;
			}
			break;
		case 'h':
			print_usage(argv[0]);
			return 0;
		default:
			print_usage(argv[0]);
			return EXIT_FAILURE;
		}
	}

	Display *display = XOpenDisplay(NULL);

	if (!display)
	{
		fprintf(stderr, "Unable to open X display\n");
		return EXIT_FAILURE;
	}

	while (running)
	{
		XTestFakeButtonEvent(display, button, True, CurrentTime);
		XFlush(display);
		XTestFakeButtonEvent(display, button, False, CurrentTime);
		XFlush(display);
		usleep(delay);
	}

	XCloseDisplay(display);
	return 0;
}
