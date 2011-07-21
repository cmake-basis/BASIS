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
    reArgs          = re.compile (r"\W+")
    reCommentLine   = re.compile (r"#!(?P<comment>.*)")

    # parse line-by-line in output pseudo C++ code to stdout
    currentBlock = '' # name of current CMake code block
                      # For example, "function" while inside CMake function definition
                      # or "macro" while inside CMake macro definition.
    for line in f:
        line = line.strip ()
        if currentBlock == 'function':
            m = reFunctionEnd.match (line)
            if m is not None:
                sys.stdout.write ("\n")
                currentBlock = ''
        elif currentBlock == 'macro':
            m = reMacroEnd.match (line)
            if m is not None:
                sys.stdout.write ("\n")
                currentBlock = ''
        elif currentBlock == 'comment':
            m = reCommentLine.match (line)
            if m is not None:
                comment = m.group ('comment')
                sys.stdout.write ("///" + comment + "\n")
            else:
                sys.stdout.write ("\n")
                currentBlock = ''
        else:
            m = reFunctionStart.match (line)
            if m is not None:
                name = m.group ('name')
                args = m.group ('args').strip ()
                if args != '':
                    argv = reArgs.split (args)
                else:
                    argv = []
                sys.stdout.write ("void " + name + " (")
                for i in range (0, len (argv)):
                    if i > 0:
                        sys.stdout.write (", ")
                    sys.stdout.write ("const std::string &" + argv [i])
                if len (argv) > 0:
                    sys.stdout.write (", ")
                sys.stdout.write ("const std::list <std::string> &ARGN")
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
                sys.stdout.write ("void " + name + " (")
                for i in range (0, len (argv)):
                    if i > 0:
                        sys.stdout.write (", ")
                    sys.stdout.write ("const std::string &" + argv [i])
                if len (argv) > 0:
                    sys.stdout.write (", ")
                sys.stdout.write ("const std::list <std::string> &ARGN")
                sys.stdout.write (");\n")
                currentBlock = 'macro'
                continue
            m = reCommentLine.match (line)
            if m is not None:
                comment = m.group ('comment')
                sys.stdout.write ("///" + comment + "\n")
                currentBlock = 'comment'
                continue
    # close input file
    f.close ()
    # done
    sys.exit (0)
