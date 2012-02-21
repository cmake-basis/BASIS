#! /usr/bin/env python

"""
  @file  runtest.py
  @brief Helper script for execution of test command.

  Copyright (c) University of Pennsylvania. All rights reserved.
  See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.

  Contact: SBIA Group <sbia-software at uphs.upenn.edu>
"""

import os
import shutil
import socket
import subprocess

# ----------------------------------------------------------------------------
def clean(root):
    """Remove all files and directories from the current working directory."""
    try:
        for root, dirs, files in os.walk(root):
            for f in files:
                os.remove(os.path.join(root, f))
            for d in dirs:
                shutil.rmtree(os.path.join(root, d))
    except:
        sys.stderr.write("Warning: Failed to clear working directory!\n")

# ----------------------------------------------------------------------------
def print_dart_measurements():
    """Output special information for inclusion in submission to CDash."""
    sys.stdout.write("<DartMeasurement name=\"Host Name\" type=\"string\">");
    sys.stdout.write(socket.gethostname());
    sys.stdout.write("</DartMeasurement>\n");
    sys.stdout.write("<DartMeasurement name=\"Working Directory\" type=\"string\">");
    sys.stdout.write(os.getcwd());
    sys.stdout.write("</DartMeasurement>\n");

# ----------------------------------------------------------------------------
if __name__ == "__main__":
    clean_before = False
    clean_after  = False
    dart         = True
    retval = 0
    cmd    = []

    for i in range(0, len(sys.argv)):
        if sys.argv[i] == '--clean-before':
            clean_before = True
        elif sys.argv[i] == '--clean-after':
            clean_after = True
        elif sys.argv[i] == '--nodart':
            dart = False
        elif sys.argv[i] == '--':
            cmd.extend(sys.argv[i+i:])
            break
        else:
            cmd.append(sys.argv[i])

    if not cmd:
        sys.stderr.write("Missing test command!\n")
        sys.exit(1)

    cwd = os.getcwd()
    if dart: print_dart_measurements()
    if clean_before: clean(cwd)
    retval = subprocess.call(cmd)
    if clean_after: clean(cwd)

    sys.exit(retval)
