/**
 * @file  term.h
 * @brief Utility functions to interact with terminal.
 *
 * Copyright (c) 2012 University of Pennsylvania. All rights reserved.<br />
 * See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */

#pragma once
#ifndef _SBIA_BASIS_TERM_H
#define _SBIA_BASIS_TERM_H


/**
 * @brief Get size of terminal window.
 *
 * @param [out] lines   Maximum number of lines or 0 if it could not be determined.
 * @param [out] columns Maximum number of columns or 0 if it could not be determined.
 */
void get_terminal_size(int& lines, int& columns);

/**
 * @returns Maximum number of lines of terminal window.
 */
int get_terminal_lines();

/**
 * @returns Maximum number of columns of terminal window.
 */
int get_terminal_columns();


#endif // _SBIA_BASIS_TERM_H
