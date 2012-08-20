/**
 * @file  basis/stdio.h
 * @brief Standard I/O functions.
 *
 * This module defines standard I/O functions for the input and output of
 * messages from STDIN or to STDOUT/STDERR, respectively. In particular,
 * it includes the cstdio header file of the standard C library as well
 * as the iostream header file of the standard C++ library. Besides these
 * common functions of the standard C/C++ libraries, it provides some
 * additional useful auxiliary functions. Therefore, this header file
 * may be included instead of cstdio, stdio.h, or iostream.
 *
 * Copyright (c) 2012 University of Pennsylvania. All rights reserved.<br />
 * See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */

#pragma once
#ifndef _BASIS_STDIO_H
#define _BASIS_STDIO_H


#include <cstdio>   // standard C   I/O library
#include <iostream> // standard C++ I/O library
#include <string>   // C++ string class


namespace basis {


/// @addtogroup BasisCxxUtilities
/// @{


/**
 * @brief Get size of terminal window.
 *
 * @param [out] lines   Maximum number of lines or 0 if it could not be determined.
 * @param [out] columns Maximum number of columns or 0 if it could not be determined.
 */
void get_terminal_size(int& lines, int& columns);

/**
 * @brief Get maximum number of lines of terminal window.
 *
 * @returns Maximum number of lines of terminal window.
 */
int get_terminal_lines();

/**
 * @brief Get maximum number of columns of terminal window.
 *
 * @returns Maximum number of columns of terminal window.
 */
int get_terminal_columns();

/**
 * @brief Print text, wrapped at a fixed maximum number of columns.
 *
 * This function is inspired by the TCLAP::StdOutput::spacePrint()
 * method written by Michael E. Smoot.
 *
 * @param [out] os     Output stream.
 * @param [in]  text   Text to be printed.
 * @param [in]  width  Maximum width of each line.
 *                     Set to a value less or equal to disable automatic wrapping.
 * @param [in]  indent Indent of text on each line.
 * @param [in]  offset Additional indent of all lines except the first one.
 */
std::ostream& print_wrapped(std::ostream&      os,
                            const std::string& text,
                            int                width,
                            int                indent,
                            int                offset);

/// @}
// Doxygen group


} // namespace basis


#endif // _BASIS_STDIO_H
