/**
 * @file  term.cxx
 * @brief Utility functions to interact with terminal.
 *
 * Copyright (c) 2012 University of Pennsylvania. All rights reserved.<br />
 * See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */

#include <sbia/basis/config.h> // WINDOWS macro

#include <stdlib.h>            // getenv()

#if WINDOWS
#  include <windows.h>         // GetConsoleScreenBufferInfo()
#else
#  include <unistd.h>          // STDOUT_FILENO
#  include <sys/ioctl.h>       // ioctl()
#endif

#include <sbia/basis/term.h>


// ---------------------------------------------------------------------------
void get_terminal_size(int& lines, int& columns)
{
    lines   = 0;
    columns = 0;
    #if WINDOWS
        CONSOLE_SCREEN_BUFFER_INFO csbi;
        if (GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &csbi)) {
            columns = csbi.dwSize.X;
            lines   = csbi.dwSize.Y;
        }
    #else
        struct winsize w;
        if (ioctl(STDOUT_FILENO, TIOCGWINSZ, &w) == 0) {
            columns = w.ws_col;
            lines   = w.ws_row;
        }
    #endif
    if (columns == 0) {
        const char* COLUMNS = getenv("COLUMNS");
        if (COLUMNS) columns = atoi(COLUMNS);
    }
    if (lines == 0) {
        const char* LINES = getenv("LINES");
        if (LINES) columns = atoi(LINES);
    }
}

// ---------------------------------------------------------------------------
int get_terminal_lines()
{
    int lines, columns;
    get_terminal_size(lines, columns);
    return lines;
}

// ---------------------------------------------------------------------------
int get_terminal_columns()
{
    int lines, columns;
    get_terminal_size(lines, columns);
    return columns;
}
