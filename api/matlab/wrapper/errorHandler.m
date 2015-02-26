function errorHandler(ME)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2015 The Johns Hopkins University / Applied Physics Laboratory 
% All Rights Reserved. 
% Contact the JHU/APL Office of Technology Transfer for any additional rights.  
% www.jhuapl.edu/ott
%  
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%  
%     http://www.apache.org/licenses/LICENSE-2.0
%  
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Capture and print erro so it gets sent to the standard out stream
errorTime = datestr(now);

errStr = sprintf('\n@@@ MATLAB ERROR - %s @@@\n\n', errorTime);
errStr = sprintf('%sIdentifier: %s\n',errStr,ME.identifier);
errStr = sprintf('%sMessage: %s\n',errStr,ME.message);
errStr = sprintf('%sCause:\n',errStr);
for ii = 1:length(ME.cause)
    errStr = sprintf('%s %s\n',errStr,ME.cause{ii});
end

s = ME.stack;
errStr = sprintf('%sStack:\n',errStr);
for ii = 1:length(s)
    fstr = strrep(s(ii).file,'\','\\');
    errStr = sprintf('%s\n File: %s \n',errStr,fstr);
    errStr = sprintf('%s Method: %s \n',errStr,s(ii).name);
    errStr = sprintf('%s Line: %d \n',errStr,s(ii).line);
end

errStr = sprintf('%s\n@@@ MATLAB ERROR - %s @@@\n\n',errStr,errorTime);

fprintf(errStr);


end