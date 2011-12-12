#! /usr/bin/env python

##
# @file  doxyfilter-cmake.py
# @brief Doxygen filter for CMake and CTest scripts.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup Tools

import sys
import re

if __name__ == "__main__":
    # parse arguments
    if len (sys.argv) != 2:
        sys.stderr.write ("No file specified to process!\n")
        sys.exit (1)
    fileName = sys.argv [1]
    # package name
    packageName = '__Pkg__'
    m = re.search ('(^|/)(?P<pkg>\w+)Config(Version)?\.cmake', fileName)
    if m: packageName = m.group('pkg')
    else:
        m = re.search ('(^|/)(?P<pkg>\w+)Use\.cmake', fileName)
        if m: packageName = m.group('pkg')
    # open input file
    f = open (fileName, 'r')
    if not f:
        sys.stderr.write ("Failed to open file " + fileName + " for reading!\n")
        sys.exit (1)
    # compile regular expressions
    reInclude       = re.compile (r"include\s*\((?P<module>.+)\)\s*$")
    reFunctionStart = re.compile (r"function\s*\((?P<name>\w+)(?P<args>.*)\)\s*$")
    reFunctionEnd   = re.compile (r"endfunction\s*\(.*\)\s*$")
    reMacroStart    = re.compile (r"macro\s*\((?P<name>\w+)(?P<args>.*)\)\s*$")
    reMacroEnd      = re.compile (r"endmacro\s*\(.*\)\s*$")
    reSetStart      = re.compile (r"(?P<cmd>set|basis_set_if_empty|basis_set_script_path|basis_set_config)\s*(\((?P<name>\w*)|$)")
    reSetVarName    = re.compile (r"(?P<name>\w+)")
    reSetEnd        = re.compile (r".*\)\s*$")
    reOptionStart   = re.compile (r"option\s*\((?P<name>\w*)|option\s*$")
    reOptionName    = re.compile (r"(?P<name>\w+)")
    reOptionEnd     = re.compile (r".*\)\s*$")
    reArgs          = re.compile (r"\W+")
    reCommentStart  = re.compile (r"##+(?P<comment>.*)")
    reCommentLine   = re.compile (r"#+(?P<comment>.*)")
    reOptParamDoc   = re.compile (r"[\@\\]param\s*(\[[inout,\s]+\])?\s+(?P<param>ARG(N|V[0-9]?))")
    reIfClauseStart = re.compile (r"if\s*\(")
    reIfClauseEnd   = re.compile (r"else\s*\(|elseif\s*\(|endif\s*\(")

    # parse line-by-line and output pseudo C++ code to stdout
    ifClauseDepth = 0     # current depth of if-clauses
    commentDepth  = 0     # if-clause depth where comment was encountered
    previousBlock = ''    # name of previous CMake code block
    currentBlock  = ''    # name of current CMake code block
    currentCmd    = ''    # used in particular to distinguish set() commands
    optParams     = []    # documented optional function/macro parameters
    for line in f:
        line = line.strip ()
        # next comment line,
        if currentBlock == 'comment':
            m = reCommentLine.match (line)
            if m is not None:
                comment = m.group ('comment')
                sys.stdout.write ("///" + comment + "\n")
                m = reOptParamDoc.search (line)
                if m is not None:
                    optParams.append (m.group ('param'))
                continue
            else:
                previousBlock = currentBlock
                currentBlock = ''
                # continue processing of this (yet unhandled) line
        # inside function definition
        if currentBlock == 'function':
            m = reFunctionEnd.match (line)
            if m is not None:
                previousBlock = currentBlock
                currentBlock = ''
            sys.stdout.write ("\n")
            continue
        # inside macro definition
        if currentBlock == 'macro':
            m = reMacroEnd.match (line)
            if m is not None:
                previousBlock = currentBlock
                currentBlock = ''
            sys.stdout.write ("\n")
            continue
        # inside brackets of multi-line set() command
        if currentBlock == 'set':
            m = reSetEnd.match (line)
            if m is not None:
                previousBlock = currentBlock
                currentBlock = ''
            sys.stdout.write ("\n")
            continue
        if currentBlock == 'set-no-name':
            m = reSetVarName.match (line)
            if m is not None:
                name = m.group ('name')
                if currentCmd == 'basis_set_config':
                    name = '_'.join([packageName, name])
                sys.stdout.write (name + ";\n")
                currentBlock = 'set'
                m = reSetEnd.match (line)
                if m is not None:
                    previousBlock = currentBlock
                    currentBlock = ''
            else:
                sys.stdout.wirte ("\n")
            continue
        # inside brackets of multi-line options command
        if currentBlock == 'option':
            m = reOptionEnd.match (line)
            if m is not None:
                previousBlock = currentBlock
                currentBlock = ''
            sys.stdout.write ("\n")
            continue
        if currentBlock == 'option-no-name':
            m = reOptionName.match (line)
            if m is not None:
                name = m.group ('name')
                sys.stdout.write ("option " + name + ";\n")
                currentBlock = 'option'
                m = reOptionEnd.match (line)
                if m is not None:
                    previousBlock = currentBlock
                    currentBlock = ''
            else:
                sys.stdout.write ("\n")
            continue
        # look for new comment block or block following a comment
        if currentBlock == '':
            currentCmd = ''
            # include
            m = reInclude.match (line)
            if m is not None:
                module = m.group ('module')
                module = module.replace ("\"", "")
                module = module.replace ("${CMAKE_CURRENT_LIST_DIR}/", "")
                module = module.replace ("${BASIS_MODULE_PATH}/", "")
                module = module.replace ("@BASIS_MODULE_PATH@/", "")
                module = module.replace ("${${NS}MODULE_PATH}/", "")
                module = module.replace (" OPTIONAL", "")
                module = module.replace (" NO_POLICY_SCOPE", "")
                sys.stdout.write ("#include \"" + module + "\"\n")
                continue
            # enter if-clause
            m = reIfClauseStart.match (line)
            if m is not None:
                ifClauseDepth = ifClauseDepth + 1
                sys.stdout.write ("\n")
                continue
            # leave if-clause
            if ifClauseDepth > 0:
                m = reIfClauseEnd.match (line)
                if m is not None:
                    ifClauseDepth = ifClauseDepth - 1
                    if commentDepth > ifClauseDepth:
                        previousBlock = ''
                        currentBlock  = ''
                    sys.stdout.write ("\n")
                    continue
            # Doxygen comment
            m = reCommentStart.match (line)
            if m is not None:
                comment = m.group ('comment')
                sys.stdout.write ("///" + comment + "\n")
                currentBlock = 'comment'
                commentDepth = ifClauseDepth
                m = reOptParamDoc.search (line)
                if m is not None:
                    optParams.append (m.group ('param'))
                continue
            # if previous block was a Doxygen comment process
            # supported following blocks such as variable setting
            # and function definition optionally only the one
            # inside the if-case of an if-else-clause
            if previousBlock == 'comment':
                # function
                m = reFunctionStart.match (line)
                if m is not None:
                    name = m.group ('name')
                    args = m.group ('args').strip ()
                    if args != '':
                        argv = reArgs.split (args)
                    else:
                        argv = []
                    sys.stdout.write ("function " + name + " (")
                    for i in range (0, len (argv)):
                        if i > 0:
                            sys.stdout.write (", ")
                        sys.stdout.write ("in " + argv [i])
                    for i in range (0, len (optParams)):
                        if i > 0 or len (argv) > 0:
                            sys.stdout.write (", ")
                        sys.stdout.write ("in " + optParams [i])
                    sys.stdout.write (");\n")
                    currentBlock = 'function'
                    optParams = []
                    continue
                # macro
                m = reMacroStart.match (line)
                if m is not None:
                    name = m.group ('name')
                    args = m.group ('args').strip ()
                    if args != '':
                        argv = reArgs.split (args)
                    else:
                        argv = []
                    sys.stdout.write ("macro " + name + " (")
                    for i in range (0, len (argv)):
                        if i > 0:
                            sys.stdout.write (", ")
                        sys.stdout.write ("in " + argv [i])
                    for i in range (0, len (optParams)):
                        if i > 0 or len (argv) > 0:
                            sys.stdout.write (", ")
                        sys.stdout.write ("in " + optParams [i])
                    sys.stdout.write (");\n")
                    currentBlock = 'macro'
                    optParams = []
                    continue
                # setting of global variable/constant
                m = reSetStart.match (line)
                if m is not None:
                    currentCmd = m.group ('cmd')
                    name       = m.group ('name')
                    if name == '':
                        currentBlock = 'set-no-name'
                        sys.stdout.write ("\n")
                        continue
                    if currentCmd == 'basis_set_config':
                        name = '_'.join([packageName, name])
                    sys.stdout.write (name + ";\n")
                    m = reSetEnd.match (line)
                    if m is None:
                        currentBlock = 'set'
                    else:
                        previousBlock = 'set'
                    continue
                # option
                m = reOptionStart.match (line)
                if m is not None:
                    name = m.group ('name')
                    if name == '':
                        currentBlock = 'option-no-name'
                        sys.stdout.write ("\n")
                        continue
                    sys.stdout.write ("option " + name + ";\n")
                    m = reOptionEnd.match (line)
                    if m is None:
                        currentBlock = 'option'
                    else:
                        previousBlock = 'option'
                    continue
            if line != '':
                if previousBlock == 'comment':
                    # prevent comments that are not associated with any
                    # processed block to be merged with subsequent comments
                    sys.stdout.write ("class COMMENT_DUMPED_BY_DOXYGEN_FILTER;\n")
                else:
                    sys.stdout.write ("\n")
                previousBlock = ''
            else:
                sys.stdout.write ("\n")
        else:
            sys.stdout.write ("\n")
    # close input file
    f.close ()
    # done
    sys.exit (0)
