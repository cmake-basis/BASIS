% @file  helloworld.m
% @brief Test executable implemented in MATLAB.
%
% This executable is compiled using the MATLAB Compiler. It is used to
% test the correct compilation of files like this one by basis_add_executable().
%
% Copyright (c) 2011 University of Pennsylvania. All rights reserved.
% See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
%
% Contact: SBIA Group <sbia-software at uphs.upenn.edu>

function main()
% This is the main function of the program.

if (nargin != 0)
  print_help();
  exit(1);
end

fprintf('Hello, World!');
exit(0);
