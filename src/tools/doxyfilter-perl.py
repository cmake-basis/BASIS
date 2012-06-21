#! /usr/bin/env python

##############################################################################
# @file  doxyfilter-perl.py
# @brief Doxygen filter for Perl modules.
#
# Copyright (c) 2012 University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup Tools
##############################################################################

import sys
import re

if __name__ == "__main__":
    # parse arguments
    if len(sys.argv) != 2:
        sys.stderr.write("No file specified to process!\n")
        sys.exit(1)
    fileName = sys.argv[1]
    # open input file
    f = open(fileName, 'r')
    if not f:
        sys.stderr.write("Failed to open file " + fileName + " for reading!\n")
        sys.exit(1)
    # compile regular expressions
    reShaBang       = re.compile(r"#!\s*/usr/bin/env\s+perl$|#!\s*/usr/bin/perl$")
    reConstant      = re.compile(r"use\s+constant\s+(?P<name>\w+)(\s+.*|;)?$")
    reInclude       = re.compile(r"use\s+(?P<module>[a-zA-Z:]+)(\s+.*|;)?$")
    reFunctionStart = re.compile(r"sub\s*(?P<name1>\w+)\s*{?$")
    reFunctionEnd   = re.compile(r"}$")
    reCommentStart  = re.compile(r"##+(?P<comment>.*)$")
    reCommentLine   = re.compile(r"#+(?P<comment>.*)$")
    reParamDoc      = re.compile(r"[\@\\]param\s*(\[\s*(?P<inout>in|out|in\s*,\s*out|out\s*,\s*in)\s*\]|\s*)\s+(?P<type>[$%@]\$?)?(?P<param>\w+)")
    # parse line-by-line and output pseudo C++ code to stdout
    previousBlock = '' # name of previous code block
    currentBlock  = '' # name of current code block
    params        = []
    for line in f:
        line = line.strip()
        # skip sha-bang directive
        if reShaBang.match(line) is not None:
            sys.stdout.write("\n")
            continue
        # next comment line,
        if currentBlock == 'comment':
            m = reCommentLine.match(line)
            if m is not None:
                comment = m.group('comment')
                m = reParamDoc.search(line)
                if m is not None:
                    inout   = m.group('inout')
                    argtype = m.group('type')
                    param   = m.group('param')
                    params.append([inout, argtype, param])
                    comment = comment.replace(argtype + param, param)
                sys.stdout.write("///" + comment + "\n")
                continue
            else:
                previousBlock = currentBlock
                currentBlock = ''
                # continue processing of this (yet unhandled) line
        # inside function definition
        if currentBlock == 'function':
            m = reFunctionEnd.match(line)
            if m is not None:
                previousBlock = currentBlock
                currentBlock = ''
            sys.stdout.write("\n")
            continue
        # look for new comment block or block following a comment
        if currentBlock == '':
            # constant - before include match
            m = reConstant.match(line)
            if m is not None:
                name = m.group('name')
                sys.stdout.write("const " + name + ";\n")
                continue
            # include
            m = reInclude.match(line)
            if m is not None:
                module = m.group('module')
                if module in ('strict', 'warnings', 'constant'):
                    sys.stdout.write('\n')
                else:
                    module = module.replace('::', '/')
                    sys.stdout.write("#include \"" + module + ".pm\"\n")
                continue
            # Doxygen comment
            m = reCommentStart.match(line)
            if m is not None:
                comment = m.group('comment')
                sys.stdout.write("///" + comment + "\n")
                currentBlock = 'comment'
                m = reParamDoc.search (line)
                if m is not None:
                    param = m.group('param')
                    params.append(param)
                continue
            # if previous block was a Doxygen comment process
            # supported following blocks such as variable setting
            # and function definition optionally only the one
            # inside the if-case of an if-else-clause
            if previousBlock == 'comment':
                # function
                m = reFunctionStart.match(line)
                if m is not None:
                    name = m.group('name1')
                    if not name:
                        name = m.group('name2')
                    sys.stdout.write("sub " + name + "(")
                    for i in range(0, len(params)):
                        if i > 0:
                            sys.stdout.write(", ")
                        inout   = params[i][0]
                        argtype = params[i][1]
                        param   = params[i][2]
                        if inout:
                            if   'out' in inout and 'in' in inout: inout = 'inout'
                            elif 'out' in inout:                   inout = 'out'
                            else:                                  inout = 'in'
                        else: inout = 'in'
                        if argtype:
                            if   argtype == '$':  argtype = 'scalar'
                            elif argtype == '@':  argtype = 'array'
                            elif argtype == '%':  argtype = 'hash'
                            elif argtype == '$$': argtype = 'scalarref'
                            elif argtype == '@$': argtype = 'arrayref'
                            elif argtype == '%$': argtype = 'hashref'
                            else: argtype = None
                        if not argtype: argtype = inout
                        sys.stdout.write(' '.join([argtype, param]))
                    sys.stdout.write(");\n")
                    currentBlock = 'function'
                    params = []
                    continue
            # unhandled lines...
            if line != '':
                if previousBlock == 'comment':
                    # prevent comments that are not associated with any
                    # processed block to be merged with subsequent comments
                    sys.stdout.write("class COMMENT_DUMPED_BY_DOXYGEN_FILTER;\n")
                else:
                    sys.stdout.write("\n")
                previousBlock = ''
            else:
                sys.stdout.write("\n")
        else:
            sys.stdout.write("\n")
    # close input file
    f.close()
    # done
    sys.exit(0)
