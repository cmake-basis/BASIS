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
    reFunctionStart = re.compile (r"function\s*\((?P<name>\w+)(?P<args>.*)\)\s*$")
    reFunctionEnd   = re.compile (r"endfunction\s\(.*\)\s*$")
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

    # parse line-by-line in output pseudo C++ code to stdout
    previousBlock = '' # name of previous CMake code block
    currentBlock  = '' # name of current CMake code block
    for line in f:
        line = line.strip ()
        if currentBlock == 'function':
            m = reFunctionEnd.match (line)
            if m is not None:
                sys.stdout.write ("\n")
                previousBlock = currentBlock
                currentBlock = ''
            continue
        if currentBlock == 'macro':
            m = reMacroEnd.match (line)
            if m is not None:
                sys.stdout.write ("\n")
                previousBlock = currentBlock
                currentBlock = ''
            continue
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
                # continue processing of line below
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
        if currentBlock == '':
            m = reFunctionStart.match (line)
            if m is not None:
                name = m.group ('name')
                args = m.group ('args').strip ()
                if args != '':
                    argv = reArgs.split (args)
                else:
                    argv = []
                sys.stdout.write (name + " (")
                for i in range (0, len (argv)):
                    if i > 0:
                        sys.stdout.write (", ")
                    sys.stdout.write ("Variable " + argv [i])
                if len (argv) > 0:
                    sys.stdout.write (", ")
                sys.stdout.write ("Variable ARGN")
                sys.stdout.write (");\n")
                currentBlock = 'function'
                continue
            m = reMacroStart.match (line)
            if m is not None:
                name = m.group ('name')
                args = m.group ('args').strip ()
                if args != '':
                    argv = reArgs.split (args)
                else:
                    argv = []
                sys.stdout.write (name + " (")
                for i in range (0, len (argv)):
                    if i > 0:
                        sys.stdout.write (", ")
                    sys.stdout.write ("Variable " + argv [i])
                if len (argv) > 0:
                    sys.stdout.write (", ")
                sys.stdout.write ("Variable ARGN")
                sys.stdout.write (");\n")
                currentBlock = 'macro'
                continue
            m = reCommentLine.match (line)
            if m is not None:
                comment = m.group ('comment')
                sys.stdout.write ("///" + comment + "\n")
                currentBlock = 'comment'
                continue
            # global (documented) variable
            m = reSetStart.match (line)
            if m is not None and previousBlock == 'comment':
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
            # all unhandled blocks
            if line != '':
                previousBlock = ''
    # close input file
    f.close ()
    # done
    sys.exit (0)
