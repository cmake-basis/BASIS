/**
 * @file  dummy_command.cxx
 * @brief Dummy executable used to test Subprocess module.
 *
 * Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
 * See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
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
