/**
 * @file  dummy_command.cxx
 * @brief Dummy executable used to test Subprocess module.
 *
 * Copyright (c) 2011-2012 University of Pennsylvania. <br />
 * Copyright (c) 2013-2014 Andreas Schuh.              <br />
 * All rights reserved.                                <br />
 *
 * See http://opensource.andreasschuh.com/cmake-basis/download.html#software-license
 * or COPYING file for license information.
 *
 * Contact: Andreas Schuh <andreas.schuh.84@gmail.com>,
 *          report issues at https://github.com/schuhschuh/cmake-basis/issues
 */

#include <iostream> // cout, endl
#include <cstdlib>  // exit, atoi
#include <cstring>  // strcmp

#include <basis/config.h>

#if WINDOWS
#  include <windows.h>
#  define SLEEP(sec) Sleep(sec * 1000)
#else
#  include <unistd.h>
#  define SLEEP(sec) sleep(sec)
#endif

using namespace std;


int main(int argc, char *argv[])
{
    for (int i = 1; i < argc; ++i) {
        if (strcmp(argv[i], "--sleep") == 0) {
            SLEEP(atoi(argv[++i]));
        } else if (strcmp(argv[i], "--name") == 0) {
            cout << argv[0];
            exit(0);
        } else if (strcmp(argv[i], "--greet") == 0) {
            cout << "Hello, BASIS!" << endl;
        } else if (strcmp(argv[i], "--warn") == 0) {
            cerr << "WARNING: Cannot greet in other languages!" << endl;
        } else if (strcmp(argv[i], "--exit") == 0) {
            exit(atoi(argv[++i]));
        }
    }

    return 0;
}
