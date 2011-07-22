##############################################################################
#! @file  ExecuteProcess.cmake
#! @brief Execute process using CMake script mode.
#!
#! This CMake script can be used as argument for the -P option of cmake, when
#! another command shall be executed by CMake, for example, as custom build
#! command. The advantage of using this script is that all options of the
#! CMake command execute_process() can be used, i.e., a timeout can be
#! specified.
#!
#! The arguments of the execute_process() command have to specified via
#! the -D option on the command line of cmake before the -P <this script>
#! option is given. The name of the CMake variables must be equal the
#! name of the arguments to the execute_process() command.
#!
#! @sa http://www.cmake.org/cmake/help/cmake2.6docs.html#command:execute_process
#!
#! Arguments of execute_process() which are considered:
#!
#! - COMMAND
#! - WORKING_DIRECTORY
#! - TIMEOUT
#! - OUTPUT_FILE
#! - ERROR_FILE
#! - OUTPUT_QUIET
#! - ERROR_QUIET
#! - OUTPUT_STRIP_TRAILING_WHITESPACE
#! - ERROR_STRIP_TRAILING_WHITESPACE
#!
#! Additionally, matching expressions (separated by ';') to identify error messages
#! in the output streams stdout and stderr can be specified by the input argument
#! ERROR_EXPRESSION. When the output of the executed command matches one of
#! the error expressions, a fatal error message is displayed causing CMake to
#! return the exit code 1.
#!
#! Setting VERBOSE to true, enables verbose output messages.
#!
#! When the input argument LOG_ARGS evaluates to true, the values of COMMAND,
#! WORKING_DIRECTORY, and TIMEOUT are added to the top of the output files
#! specified by OUTPUT_FILE and ERROR_FILE.
#!
#! The arguments ARGS and ARGS_FILE can be used to specify (additional) command
#! arguments. The content of the text file ARGS_FILE is read when it this file
#! exists. Separate lines of this file are considered single arguments.
#! The arguments specified by ARGS and ARGS_FILE are concatenated where the
#! arguments given by ARGS follow after the ones read from the ARGS_FILE.
#! All occurences of the string 'ARGS' in the COMMAND are replaced by these
#! arguments. If no such string is present, the arguments are simply passed
#! to the execute_process () command as its ARGS argument.
#! The argument ARGS_SEPARATOR specifies the separator used to separate the
#! arguments given by ARGS and ARGS_FILE when the 'ARGS' string in COMMAND
#! is replaced. By default, it is set to ';'.
#!
#! Example:
#! @code
#! cmake -DCOMMAND='ls -l' -DWORKING_DIRECTORY='/' -DTIMEOUT=60
#!       -P SbiaExecuteProcess.cmake
#! @endcode
#!
#! Copyright (c) 2011 University of Pennsylvania. All rights reserved.
#! See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#!
#! Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#!
#! @ingroup CMakeUtilities
##############################################################################

# parse arguments
if (NOT COMMAND)
  message (FATAL_ERROR "No command specified for execute_process (): use -DCOMMAND='cmd'")
endif ()

if (NOT ARGS_SEPARATOR)
  set (ARGS_SEPARATOR ";")
endif ()

if (ARGS_FILE)
  include ("${ARGS_FILE}" OPTIONAL)

  if (ARGS AND DEFINED ${ARGS})
    set (ARGS "${${ARGS}}")
  else ()
    set (ARGS "")
  endif ()
endif ()

if ("${COMMAND}" MATCHES "ARGS")
  string (REPLACE ";" "${ARGS_SEPARATOR}" TMP "${ARGS}")
  string (REPLACE "ARGS" "${ARGS_SEPARATOR}${TMP}" COMMAND "${COMMAND}")
  set (ARGS)
endif ()

set (EXECUTE_PROCESS_ARGS "COMMAND" "${COMMAND}")

if (ARGS)
  list (APPEND EXECUTE_PROCESS_ARGS "ARGS" "${ARGS}")
endif ()

list (APPEND EXECUTE_PROCESS_ARGS "RESULT_VARIABLE" "RETVAL")

if (TIMEOUT)
  list (APPEND EXECUTE_PROCESS_ARGS "TIMEOUT" "${TIMEOUT}")
endif ()

if (WORKING_DIRECTORY)
  list (APPEND EXECUTE_PROCESS_ARGS "WORKING_DIRECTORY" "${WORKING_DIRECTORY}")
endif ()

if (OUTPUT_FILE)
  list (APPEND EXECUTE_PROCESS_ARGS "OUTPUT_FILE" "${OUTPUT_FILE}")
endif ()

if (ERROR_FILE)
  list (APPEND EXECUTE_PROCESS_ARGS "ERROR_FILE" "${ERROR_FILE}")
endif ()

if (OUTPUT_QUIET)
  list (APPEND EXECUTE_PROCESS_ARGS "OUTPUT_QUIET")
endif ()

if (ERROR_QUIET)
  list (APPEND EXECUTE_PROCESS_ARGS "ERROR_QUIET")
endif ()

if (OUTPUT_STRIP_TRAILING_WHITESPACE)
  list (APPEND EXECUTE_PROCESS_ARGS "OUTPUT_STRIP_TRAILING_WHITESPACE")
endif ()

if (ERROR_STRIP_TRAILING_WHITESPACE)
  list (APPEND EXECUTE_PROCESS_ARGS "ERROR_STRIP_TRAILING_WHITESPACE")
endif ()

if (NOT OUTPUT_FILE)
  list (APPEND EXECUTE_PROCESS_ARGS "OUTPUT_VARIABLE" "STDOUT")
endif ()

if (NOT ERROR_FILE)
  list (APPEND EXECUTE_PROCESS_ARGS "ERROR_VARIABLE"  "STDERR")
endif ()

# execute command
set (CMD)

foreach (ARG ${COMMAND})
  if (CMD)
    set (CMD "${CMD} ")
  endif ()
  if (ARG MATCHES " ")
    set (CMD "${CMD}\"${ARG}\"")
  else ()
    set (CMD "${CMD}${ARG}")
  endif ()
endforeach ()

if (VERBOSE)
  message ("${CMD}")
endif ()

execute_process (${EXECUTE_PROCESS_ARGS})

# read in output from log files
if (OUTPUT_FILE)
  file (READ "${OUTPUT_FILE}" STDOUT)
endif ()

if (ERROR_FILE)
  file (READ "${ERROR_FILE}" STDERR)
endif ()

# parse output for errors
foreach (EXPRESSION ${ERROR_EXPRESSION})
  if (STDOUT MATCHES "${EXPRESSION}" OR STDERR MATCHES "${ERROR_EXPRESSION}")
    set (RETVAL 1)
    break ()
  endif ()
endforeach ()

# prepand command to log file
if (LOG_ARGS)
  if (OUTPUT_FILE)
    set (TMP "Command: ${CMD}\n\nWorking directory: ${WORKING_DIRECTORY}\n\nTimeout: ${TIMEOUT}\n\nOutput:\n\n${STDOUT}")
    file (WRITE "${OUTPUT_FILE}" "${TMP}")
    set (TMP)
  endif ()

  if (ERROR_FILE AND NOT ERROR_FILE STREQUAL OUTPUT_FILE)
    set (TMP "Command: ${CMD}\n\nWorking directory: ${WORKING_DIRECTORY}\n\nTimeout: ${TIMEOUT}\n\nOutput:\n\n${STDERR}")
    file (WRITE "${ERROR_FILE}" "${TMP}")
    set (TMP)
  endif ()
endif ()

# print error message (and exit with exit code 1) on error
if (NOT RETVAL EQUAL 0)
  if (STDOUT STREQUAL STDERR)
    message (
      FATAL_ERROR "
Command: ${CMD}
Working directory: ${WORKING_DIRECTORY}
Timeout: ${TIMEOUT}
Output:
${STDOUT}")
  else ()
    message (
      FATAL_ERROR "
Command: ${CMD}
Working directory: ${WORKING_DIRECTORY}
Timeout: ${TIMEOUT}
Output (stdout):
${STDOUT}
Output (stderr):
${STDERR}")
  endif ()
endif ()

