/**
 * @file  stdio.cxx
 * @brief Standard I/O functions.
 *
 * Copyright (c) 2012 University of Pennsylvania. All rights reserved.<br />
 * See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */

#include <basis/config.h> // WINDOWS macro
#include <basis/assert.h> // assert()

#include <stdlib.h>       // getenv()

#if WINDOWS
#  include <windows.h>    // GetConsoleScreenBufferInfo()
#else
#  include <unistd.h>     // STDOUT_FILENO
#  include <sys/ioctl.h>  // ioctl()
#endif

#include <basis/stdio.h>


// acceptable in .cxx file
using namespace std;


namespace basis {


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

// ---------------------------------------------------------------------------
ostream& print_wrapped(ostream&      os,
                       const string& text,
                       int           width,
                       int           indent,
                       int           offset)
{
    assert(indent + offset < width); // such that allowed_length > 0

    int text_length    = static_cast<int>(text.length());
    int allowed_length = width - indent;
    int start          = 0;

    // Note: Despite of the TCLAP::StdOutput::spacePrint() implementation,
    //       the following while loop is always performed even if the given
    //       text seems to fit on one line. Reason is that the text can
    //       include newline characters itself. In this case, we still need
    //       to take care of the proper indentation of the consecutive lines.

    while (start < text_length) {
        // determine length of next line to be printed
        int line_length = min<int>(text_length - start, allowed_length);
        if (line_length == allowed_length) {
            while (line_length >= 0 &&
                    text[start + line_length] != ' ' && 
                    text[start + line_length] != ',' &&
                    text[start + line_length] != '|' ) {
                line_length--;
            }
        }
        if (line_length <= 0) line_length = allowed_length;
        // truncate line at already present newline (including the newline)
        for (int i = 0; i < line_length; i++) {
            if (text[start + i] == '\n') line_length = i + 1;
        }
        // print the line and add a newline
        for (int i = 0; i < indent; i++ ) os << " ";
        os << text.substr(start, line_length) << endl;
        // adjust indent for lines after the first one
        if (start == 0) {
            indent         += offset;
            allowed_length -= offset;
        }
        // next line
        start += line_length;
        // skip space characters so next line does not start with
        // a further indentation besides the one specified by the indent
        while (text[start] == ' ' && start < text_length) start++;
    }

    return os;
}


} // namespace basis
