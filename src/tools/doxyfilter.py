#! /usr/bin/env python

"""

    @file  doxyfilter.py
    @brief Main Doxygen filter.

    This script simply executes the proper Doxygen filter depending on the
    file name extension of the given input file.

    Copyright (c) 2012 University of Pennsylvania. All rights reserved.
    See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.

    Contact: SBIA Group <sbia-software at uphs.upenn.edu>

"""

from os.path          import splitext
from re               import match
from sys              import argv, stdout, stderr, exit
from sbia.basis.basis import execute

# ----------------------------------------------------------------------------
def main(path):
    """Execute proper Doxygen filter depending on file name or shebang directive, respectively.

    @param [in] path Path of source code file to filter.

    """
    lang   = None
    status = -1
    # get file name extension
    ext = splitext(path)[1]
    # select filter according to file extension
    if   ext in ['.pl', '.pm']: lang = 'perl'
    elif ext == '.sh': lang = 'bash'
    elif ext in ['.cmake', '.ctest']: lang = 'cmake'
    elif ext == '.m': lang = 'matlab'
    # otherwise, consider shebang directive if given
    if not lang:
        # read first line of file, which may be a shebang directive
        fp = open(path, 'r')
        shebang = fp.readline()
        fp.close()
        # match first line against common shebang directives
        m = match(r'#!\s*(/usr/bin/|/bin/|/usr/bin/env\s+)(perl|bash)', shebang)
        if m: lang = m.group(2)
    if lang:
        cmd = ["doxyfilter-%s" % lang]
        if lang == 'python': cmd.append('-f')
        cmd.append(path)
        status = execute(cmd, allow_fail=True)
    # otherwise, just pass input through unfiltered
    if status != 0:
        fp = open(path, 'r')
        stdout.write(fp.read())
        fp.close()

# ----------------------------------------------------------------------------
if __name__ == '__main__':
    if len(argv) != 2:
        stderr.write("Usage: %s <file>\n" % argv[0])
        exit(1)
    main(argv[1])
