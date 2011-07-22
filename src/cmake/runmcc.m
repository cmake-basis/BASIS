%! @file  runmcc.m
%! @brief Used to invoke MATLAB Compiler in MATLAB mode.
%!
%! Copyright (c) 2011 University of Pennsylvania. All rights reserved.
%! See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
%!
%! Contact: SBIA Group <sbia-software at uphs.upenn.edu>
%!
%! @ingroup CMakeHelpers

%! @brief Invoke the MATLAB Compiler and optionally exit MATLAB when finished.
%!
%! Invokes the MATLAB Compiler with the arguments given by varargin. See the
%! documentation of the MATLAB Compiler mcc for a summary of the arguments.
%! Further, when the option -q is given, this function quits the MATLAB
%! interpreter when the MATLAB Compiler is finished.
%!
%! @param [in] varargin Arguments to MATLAB Compiler and option -q if
%!                      MATLAB interpreter should be quit when finished.
%!
%! @returns Nothing.
%!
%! @ingroup CMakeHelpers

function runmcc (varargin)
% runmcc (varargin)  Invokes the MATLAB Compiler with the arguments
%                    given by varargin. See the documentation of mcc
%                    for a summary of the arguments. Further, when the
%                    option -q is given, this function quits the MATLAB
%                    interpreter on return.
%
% Contact: SBIA Group <sbia-software at uphs.upenn.edu>

% parse arguments and append create mcc command
cmd = 'mcc';
q   = 0;

for k = 1:size (varargin, 2)
  if (strcmp(varargin{k}, '-q'))
    q = 1;
  else
    cmd = [cmd ' ' varargin{k}];
  end
end

% execute mcc
try
  eval (cmd);
catch exception
  % do nothing, the output of the CMake command has to be
  % parsed for occurrences of 'Error' messages to detect
  % a failure during the build step with mcc
end

% quit MATLAB interpreter
if (q)
  quit;
end

