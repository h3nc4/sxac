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
	fprintf(stderr, "Usage: %s [-b button_number] [-d delay_in_ms] [-h]\n", progname);
	fprintf(stderr, "  -b button_number   Simulate button press (1-3)\n");
	fprintf(stderr, "  -d delay_in_ms     Set the delay between events\n");
	fprintf(stderr, "  -h                 Show this help message\n");
}

int handle_args(char opt, const char *progname, int *button, int *delay)
{
	switch (opt)
	{
	case 'b':
		*button = atoi(optarg);
		if (*button < 1 || *button > 3)
		{
			fprintf(stderr, "%s: invalid button number '%d'\n", progname, *button);
			return 1;
		}
		break;
	case 'd':
		*delay = atoi(optarg);
		if (*delay < 0)
		{
			fprintf(stderr, "%s: invalid delay '%d'\n", progname, *delay);
			return 1;
		}
		break;
	case 'h':
		print_usage(progname);
		return 1;
	default:
		print_usage(progname);
		return 1;
	}
	return 0;
}

Display *open_display(void)
{
	Display *display = XOpenDisplay(NULL);
	if (!display)
	{
		fprintf(stderr, "Unable to open X display\n");
		exit(EXIT_FAILURE);
	}
	return display;
}

int main(int argc, char *argv[])
{
	signal(SIGINT, handle_signal);
	signal(SIGTERM, handle_signal);

	int button = 1;
	int delay = 100;

	int opt;
	while ((opt = getopt(argc, argv, "b:d:h")) != EOF)
		if (handle_args(opt, argv[0], &button, &delay))
			return EXIT_FAILURE;

	delay *= 1000;
	Display *display = open_display();

	while (running)
	{
		XTestFakeButtonEvent(display, button, True, CurrentTime);
		XFlush(display);
		XTestFakeButtonEvent(display, button, False, CurrentTime);
		XFlush(display);
		usleep(delay);
	}

	XCloseDisplay(display);
	return EXIT_SUCCESS;
}
