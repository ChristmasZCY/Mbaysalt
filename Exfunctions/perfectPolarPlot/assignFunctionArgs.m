%% Extract Function Arguments
% This is a script (not a function) that will assign various
% function argument-value pairs or default values.
%
% Example usage
%
% function output = myFun(data1, data2, varargin)
% 
% This part gets the names of the input variables to the function
%   fa = who; 
%
% This part is a list of all the allowable arguments. In this example, just
% the variables and thier default values are listed.
%   %% Extract Function Arguments
%   % Default values, unless over-ridden in varagin
%   inputArgs   = who; % This is required by assignFunctionArgs.m
%   funArgs    = struct([]);
%   figNum     = 0;   % figure number for plot
%   plotDir    = '';  % directory to put plot in
%   latexPath  = './; % path for plot in latex code
%   spcArgs    = {};  % Arguments that go with special plot types
%
%   % Cannot use input names : 'inputArgs', 'kArg', 'defArgs'
%   % 'funArgs' will be created containing all defaults and inputs
%   assignFunctionArgs;
%
%   myFun(data, data2, ...
%          'figNum',   2, ...
%          'plotDir', 'C:\temp');
%
%
% Eric Thornhill, April 2018


% Get list of arguments and defaults
defArgs = setdiff(who, [inputArgs,;{'inputArgs'}]);
clear inputArgs;

if ismember(defArgs, {'inputArgs', 'kArg', 'defArgs', 'varargin'})
  error('forbidden variable name');
end

if exist('funArgs','var') && ~isempty(funArgs)
  error("default value for 'funArgs' be: funArgs = [];");
end

% First check to see if funArg is given in function arguments. 
%  e.g.   output = function('arg1', val1, .... 'funArgs', funArgs)
tempArg = find(strcmpi('funArgs',varargin) == 1);
if ~isempty(tempArg)
  funArgs = varargin{tempArg+1};
  varargin(tempArg:tempArg+1) = [];
else
  funArgs = struct([]);
end
clear tempArg

if isempty(funArgs)
   funArgs = struct([]);
end

if ~isstruct(funArgs) && length(funArgs) == 1
  error("funArgs must be a structure or struct([])");
end

% Cycle through each defArg and assign default value. If 'funArgs' is given, 
% then assign value from there. Lastly if value is supplied explicitly in
% varargin, than that value is assigned (taken precedence over the others).
for kArg = 1:length(defArgs)
  
  % The default values for the various arguments were assigned first. So
  % as of this point in the function there are already defined and
  % assigned.
  
  % But, if funArgs is given in varargin and the argument field exists,
  % then the value there will override the default and be assigned.
  if isfield(funArgs, defArgs{kArg})
    
    eval([defArgs{kArg},' = funArgs.(defArgs{kArg});']);
    funArgs = rmfield(funArgs, defArgs{kArg});
    
  end
  
  % Then, if this specific argument was also explicity given in the
  % varargin argument list, then it takes precedance over the default and
  % any the value in funArgs
  tempArg = find(strcmpi(varargin, defArgs{kArg}) == 1);
  if ~isempty(tempArg)

    eval([defArgs{kArg},' = varargin{tempArg+1};']);
    varargin(tempArg:tempArg+1) = [];
  
  end 

end
clear xArg 

% if ~isempty(fieldnames(funArgs))
%   fieldnames(funArgs)
%   error('unrecognized funargs input arguments');
% end

if ~isempty(varargin)
  celldisp(varargin, 'varargin');
  error('unrecognized input arguments');
end

% Now, create funArgs using all the current argument values
clear funArgs
for kArg = 1:length(defArgs)
  eval(['funArgs.(defArgs{kArg}) = ',defArgs{kArg},';']);
end
clear kArg defArgs 

clear varargin