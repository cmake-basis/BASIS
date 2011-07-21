#! /usr/bin/env python

import sys
import re

if __name__ == "__main__":
    # parse arguments
    if len (sys.argv) != 2:
        sys.stderr.write ("No file specified to process!\n")
        sys.exit (1)
    fileName = sys.argv [1]
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
    reSetStart      = re.compile (r"set\s*\((?P<name>\w*)|set\s*$")
    reSetVarName    = re.compile (r"(?P<name>\w+)")
    reSetEnd        = re.compile (r".*\)\s*$")
    reOptionStart   = re.compile (r"option\s*\((?P<name>\w*)|option\s*$")
    reOptionName    = re.compile (r"(?P<name>\w+)")
    reOptionEnd     = re.compile (r".*\)\s*$")
    reArgs          = re.compile (r"\W+")
    reCommentLine   = re.compile (r"#!(?P<comment>.*)")
    reIfClauseStart = re.compile (r"if\s*\(")
    reIfClauseEnd   = re.compile (r"else\s*\(|elseif\s*\(|endif\s*\(")

    # parse line-by-line in output pseudo C++ code to stdout
    ifClauseDepth = 0     # current depth of if-clauses
    commentDepth  = 0     # if-clause depth where comment was encountered
    previousBlock = ''    # name of previous CMake code block
    currentBlock  = ''    # name of current CMake code block
    for line in f:
        line = line.strip ()
        # next comment line,
        if currentBlock == 'comment':
            m = reCommentLine.match (line)
            if m is not None:
                comment = m.group ('comment')
                sys.stdout.write ("///" + comment + "\n")
                continue
            else:
                sys.stdout.write ("\n")
                previousBlock = currentBlock
                currentBlock = ''
                # continue processing of this (yet unhandled) line
        # inside function definition
        if currentBlock == 'function':
            m = reFunctionEnd.match (line)
            if m is not None:
                sys.stdout.write ("\n")
                previousBlock = currentBlock
                currentBlock = ''
            continue
        # inside macro definition
        if currentBlock == 'macro':
            m = reMacroEnd.match (line)
            if m is not None:
                sys.stdout.write ("\n")
                previousBlock = currentBlock
                currentBlock = ''
            continue
        # inside brackets of multi-line set() command
        if currentBlock == 'set':
            m = reSetEnd.match (line)
            if m is not None:
                sys.stdout.write ("\n")
                previousBlock = currentBlock
                currentBlock = ''
            continue
        if currentBlock == 'set-no-name':
            m = reSetVarName.match (line)
            if m is not None:
                name = m.group ('name')
                sys.stdout.write (name + ";\n")
                currentBlock = 'set'
                m = reSetEnd.match (line)
                if m is not None:
                    sys.stdout.write ("\n")
                    previousBlock = currentBlock
                    currentBlock = ''
            continue
        # inside brackets of multi-line options command
        if currentBlock == 'option':
            m = reOptionEnd.match (line)
            if m is not None:
                sys.stdout.write ("\n")
                previousBlock = currentBlock
                currentBlock = ''
            continue
        if currentBlock == 'option-no-name':
            m = reOptionName.match (line)
            if m is not None:
                name = m.group ('name')
                sys.stdout.write ("option " + name + ";\n")
                currentBlock = 'option'
                m = reOptionEnd.match (line)
                if m is not None:
                    sys.stdout.write ("\n")
                    previousBlock = currentBlock
                    currentBlock = ''
            continue
        # look for new comment block or block following a comment
        if currentBlock == '':
            # include
            m = reInclude.match (line)
            if m is not None:
                module = m.group ('module')
                module = module.replace ("\"", "")
                module = module.replace ("${CMAKE_CURRENT_LIST_DIR}/", "")
                sys.stdout.write ("#include \"" + module + "\"\n")
                continue
            # enter if-clause
            m = reIfClauseStart.match (line)
            if m is not None:
                ifClauseDepth = ifClauseDepth + 1
                continue
            # leave if-clause
            if ifClauseDepth > 0:
                m = reIfClauseEnd.match (line)
                if m is not None:
                    ifClauseDepth = ifClauseDepth - 1
                    if commentDepth > ifClauseDepth:
                        previousBlock = ''
                        currentBlock  = ''
            # Doxygen comment
            m = reCommentLine.match (line)
            if m is not None:
                comment = m.group ('comment')
                sys.stdout.write ("///" + comment + "\n")
                currentBlock = 'comment'
                commentDepth = ifClauseDepth
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
                    if len (argv) > 0:
                        sys.stdout.write (", ")
                    sys.stdout.write ("in ARGN")
                    sys.stdout.write (");\n")
                    currentBlock = 'function'
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
                    if len (argv) > 0:
                        sys.stdout.write (", ")
                    sys.stdout.write ("in ARGN")
                    sys.stdout.write (");\n")
                    currentBlock = 'macro'
                    continue
                # setting of global variable/constant
                m = reSetStart.match (line)
                if m is not None:
                    name = m.group ('name')
                    if name == '':
                        currentBlock = 'set-no-name'
                        continue
                    sys.stdout.write (name + ";\n")
                    m = reSetEnd.match (line)
                    if m is None:
                        currentBlock = 'set'
                    else:
                        previousBlock = 'set'
                        sys.stdout.write ("\n")
                    continue
                # option
                m = reOptionStart.match (line)
                if m is not None:
                    name = m.group ('name')
                    if name == '':
                        currentBlock = 'option-no-name'
                        continue
                    sys.stdout.write ("option " + name + ";\n")
                    m = reOptionEnd.match (line)
                    if m is None:
                        currentBlock = 'option'
                    else:
                        previousBlock = 'option'
                        sys.stdout.write ("\n")
                    continue
            if line != '':
                if previousBlock == 'comment':
                    # prevent comments that are not associated with any
                    # processed block to be merged with subsequent comments
                    sys.stdout.write ("class COMMENT_DUMPED_BY_DOXYGEN_FILTER;\n")
                    sys.stdout.write ("\n")
                previousBlock = ''
    # close input file
    f.close ()
    # done
    sys.exit (0)
