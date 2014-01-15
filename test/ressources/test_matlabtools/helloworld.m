% @file  helloworld.m
% @brief Test executable implemented in MATLAB.
%
% This executable is compiled using the MATLAB Compiler. It is used to
% test the correct compilation of files like this one by basis_add_executable().
%
% Copyright (c) 2011-2012 University of Pennsylvania. <br />
% Copyright (c) 2013-2014 Andreas Schuh.              <br />
% All rights reserved.                                <br />
%
% See http://opensource.andreasschuh.com/cmake-basis/download.html#software-license
% or COPYING file for license information.
%
% Contact: Andreas Schuh <andreas.schuh.84@gmail.com>,
%          report issues at https://github.com/schuhschuh/cmake-basis/issues

function helloworld()
% This is the main function of the program.
echo('Hello, World!'); % own MEX-function
end
