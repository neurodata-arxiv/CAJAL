%setupEnvironment ************************************************
% Script to set up classpath.txt and startup.m for your matlab installation
% to support the CAJAL3D framwork.
%
%
%
% Author: Dean Kleissas
%        dean.kleissas@jhuapl.edu
%                           Revision History
% Author            Date             Comment
% D.Kleissas    13-MAR-2012      Initial creation
% D.Kleissas    22-MAY-2012      Fixed to handle linux vs mac/windows
% D.Kleissas    30-SEPT-2012     Updates to make more robust.  Fixes for
%                                cross platform
% D.Kleissas    04-DEC-2012      Added hazelcast.jar
% D.Kleissas    08-JAN-2013      Removed hazelcast.jar. Added jedis-2.1.0.jar
% D.Kleissas    10-MAR-2014      Removed static class path editing
%
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
    

clc
%% Verify dir

% Make sure you are running from /tools/matlab_install/
if isempty(strfind(pwd,fullfile('tools','matlab_install')))
    error('Please run setup script from /tools/matlab_install/ relative to the framework directory.');
end

%% Choose install type
loopflag = 1;
questStr = sprintf('\nWould you like to change your startup.m file so that CAJAL3D API \ngets added to the MATLAB search path at startup?  (Y or N): ');
strResponse = input(questStr, 's');

while loopflag == 1
    switch strResponse
        case {'Y','y'}
            loopflag = 0;
            autoStartup = 1;
        case {'N','n'}
            autoStartup = 0;
            loopflag = 0;
        otherwise
            strResponse = input('Please enter either "Y" for yes or "N" for no:', 's');
    end
end


%% Overwrite warning
if autoStartup == 1
    loopflag = 1;
    questStr = sprintf('\n*** Warning: This will update your existing startup.m file.  Do you wish to continue?? (Y or N):');
    strResponse = input(questStr, 's');
    
    while loopflag == 1
        switch strResponse
            case {'Y','y'}
                loopflag = 0;
                autoStartup = 1;
            case {'N','n'}
                autoStartup = 0;
                loopflag = 0;
            otherwise
                strResponse = input('Please enter either "Y" for yes or "N" for no:', 's');
        end
    end
end
%% Common Setup

% Get path info
frameworkRoot = pwd;
ind = strfind(frameworkRoot,filesep);
frameworkRoot(ind(end-1):end) = [];

%% Check OS/OS specific setup
str = computer('arch');
switch str
    case {'maci64'}
        %% Setup OSX/Windows
        if isempty(which('startup'))
            p = userpath;
            startupFilePath = strtok(p,':');
        else
            startupFilePath = which('startup');
            [startupFilePath, ~, ~] = fileparts(startupFilePath);
        end
        
        startupString = sprintf('run(''%s/cajal3d'');\n',frameworkRoot);
        
    case {'win64','win32'}
        %% Setup OSX/Windows
        if isempty(which('startup'))
            p = userpath;
            startupFilePath = strtok(p,';');
        else
            startupFilePath = which('startup');
            [startupFilePath, ~, ~] = fileparts(startupFilePath);
        end
        
        startupString = sprintf('run(''%s\\cajal3d'');\n',frameworkRoot);
    case {'glnx86','glnxa64'}
        %% Setup linux
        if isempty(which('startup'))
            p = userpath;
            startupFilePath = p(1:end-1);
        else
            startupFilePath = which('startup');
            [startupFilePath, ~, ~] = fileparts(startupFilePath);
        end
        
        startupString = sprintf('run(''%s/cajal3d'');\n',frameworkRoot);
    otherwise
        error('Unsupported OS: %s\n',str);
end

%% Write Startup File if you can
if autoStartup == 1
    
    fprintf('\nAttempting to update Matlab Startup File - Method 1: ');
    try
                
        if exist(fullfile(startupFilePath,'startup.m'), 'file') == 2
            % If a startup.m file already exists read it in 
            
            % Open file
            fid = fopen(fullfile(startupFilePath,'startup.m'),'r');
            
            if fid == -1
                error('could not open startup.m to read');
            end
            
            
            % Read all of the file in.
            clear startupData
            tline = fgets(fid);
            startupData{1} = tline;
            cnt = 2;
            while ischar(tline)
                tline = fgets(fid);
                startupData{cnt} = tline;  %#ok<SAGROW>
                cnt = cnt + 1;
            end
            if startupData{end} == -1
                startupData(end) = [];
            end
            
            % If cajal3d already in there, update.
            ind = strfind(startupData,'cajal3d');
            ind = ~cellfun(@isempty,ind);
            ind = find(ind == 1);
            
            if length(ind) > 1
                % More than one instance of cajal3d found so don't know
                % what to do.
                error('Don''t know where to write.');
                
            elseif isempty(ind)
                % Nothing there so append.
                startupData{end + 1} = startupString;
                
            else
                % One line found.  Update it.
                startupData{ind} = startupString;
            end
            
            % Close file so you can back it up and then write it
            fclose(fid);
            
            % Back up file
            copyfile(fullfile(startupFilePath,'startup.m'),fullfile(startupFilePath,['startup_backup_' datestr(now,30)]));
            
        else
            % The file doesn't exist yet so just write it.
            startupData{1} = startupString;
        end
        
        % Write out file
        fid = fopen(fullfile(startupFilePath,'startup.m'),'w+');
        
        if fid == -1
            error('could not open startup.m to write');
        end
        
        for ii = 1:length(startupData)
            fprintf(fid,'%s',startupData{ii});
        end
        fclose(fid);
        
        
        fprintf('Success\n');
        
    catch ME
        % if you don't have write permissions, you must do it as admin
        fprintf('Failed');
        
        fprintf('\n\n%s\n\nStartup File: %s\nAdd Line: %s\n\n%s\n\n','If you''d like to auto-configure on startup add the following line to your startup.m:',...
            fullfile(startupFilePath,'startup.m'),startupString,'Otherwise call ''cajal3d'' (located in the framework root) before using API classes');
    end
else
    fprintf('\n\n%s\n\nStartup File: %s\nAdd Line: %s\n\n%s\n\n','If you''d like to auto-configure on startup add the following line to your startup.m:',...
        fullfile(startupFilePath,'startup.m'),startupString,'Otherwise call ''cajal3d'' (located in the framework root) before using API classes');
end


%% Close MATLAB
fprintf('Setup Complete!\n\n *** You must restart MATLAB for changes to take effect ***\n\n');



