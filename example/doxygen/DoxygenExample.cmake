##############################################################################
# @file  DoxygenExample.cmake
# @brief Example CMake file documented with Doxygen comments.
#
# This file is processed by the doxyfilter command using the
# SBIA::Doxygen::CMakeFilter in order to convert it into pseudo C code that is
# understood by Doxgyen. From this converted pseudo C code, Doxygen generates
# a documentation in either one of the selected output formats, i.e., HTML in
# most cases.
#
# The code is intentionally uncommonly formatted to test whether the Doxygen
# filter correctly handles these cases. Do not adapt this obfuscating code
# formatting for your own CMake code!
#
# Copyright (c) 2012 University of Pennsylvania. All rights reserved.
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

include (SomeModule)
	include(	"/this/module.cmake")	   

## @addtogroup CMakeExample
# @{

## @brief Option available to user.
option( OPT1  "This is an option for the configuration."     ON)

## @brief Option on multiple lines.
option (OPT2 
   "Some option the user can set" 
        OFF
)

## @brief Some uncached constant value.
set (CONSTANT1 "This is a uncached constant")

## @brief A more complicated uncached example defined over multiple lines.
set (CONSTANT2
          "Value of constant.")

## @brief Uncached constant with value and closing parentheses on separate lines.
set (CONSTANT3
          "Value of constant."
    )

## @brief Uncached constant with name and value on separate line.
	set(
    CONSTANT4 		"The value of the constant."
)

## @brief Uncached constant with all parts of set() on separate lines.
set (     
 CONSTANT5
        "Value of constant."
)

## @brief Example set() with parentheses in value.
set (
   CONSTANT6     "
    ) # misleading closing parentheses in value
    set (DUMMY to_something) # still in string argument to actual set()!
 ")

## @brief Some cached constant value.
if (COND)
  set (CCONSTANT1 "This constant is cached" CACHE STRING "Some constant.")
else ()
  set (CCONSTANT1 "") # only the if-then block considered by Doxygen filter
endif ()

## @brief A more complicated cached example defined over multiple lines.
set 	(CCONSTANT2
          "Value of constant."
   CACHE STRING "docstring goes here."
  FORCE )

## @brief Cached constant with value and closing parentheses on separate lines.
set (CCONSTANT3
          "Value of constant."
    )

## @brief Cached constant with name and value on separate line.
set(
    CCONSTANT4       "The value of the constant." CACHE
           PATH
   "Comment here."
)

## @brief Cached constant with all parts of set() on separate lines.
set (     
 CCONSTANT5
        "Value of constant."
   CACHE
         INTERNAL
      "Docstring."
)

## @brief Example function with only one parameter.
#
# @param [out] ARG Name of variable which is set to the string "Hello!".
function (foo ARG)
  set (${ARG} "Hello!" PARENT_SCOPE)
endfunction ()


## @brief Example macro with a variable number of arguments.
#
# @param ARGN Arbitrary number of arguments.
#
# @retval BAR_STR Set to a space delimited string of the input arguments @p ARGN.
macro(bar)
  set (BAR_STR)
  foreach (ARG IN LISTS ARGN)
    set (BAR_STR "${BAR_STR} ${ARG}")
  endforeach ()
endmacro()

## @brief Function definition with arguments declared on separate lines.
function	(justdoit    A
  B C
            D E
    F G)
  include(ShallBeIgnoedByFilter)
  message ("Already done!")
endfunction (
  the fillter will just
    ignore anything in
  here)


## @}
# end of Doxygen comment
