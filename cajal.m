classdef cajal
    %% cajal - CAJAL Framework utility Class
    % This function is provided to perform basic configuration, help, and
    % bug reporting tasks.
    %
    % Supported Uses:
    %
    % Add framework to MATALB search path and setup:
    % >> cajal
    %    - or -
    % >> cajal.setSearchPath
    %
    % Note: If you have not set your MATLAB installation to automatically
    % add the CAJAL framework to the search path at startup either
    % manually, or using the 'setupEnvironment' script, you must run this 
    % everytime MATLAB start before you can use the CAJAL framework.
    %
    % Set the current MATLAB folder to the framework path:
    % >> cajal.setCurrentFolder
    %
    % Get the framework path:
    % >> cajal.getRootDir
    %
    % Install a CAJAL toolbox where toolbox_path = path to startup script
    % for the toolbox you wish to add.
    % >> cajal.installToolbox(toolbox_path)
    %
    % List installed toolboxes:
    % >> cajal.listInstalledToolboxes()
    %
    % Remove an installed toolbox:
    % >> cajal.uninstallToolbox()
    %
    % Print information to be included in a bug report:
    % >> cajal.bugReport
    %
    % Note: Run this command immediately after the error has occured!
    %
    % Get the framework version:
    % >> cajal.version
    %
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
    
    
    properties(SetAccess = 'private', GetAccess = 'public')
        frameworkRoot = '';
    end
    
    properties(Constant = true)
        version = '1.7.1 beta';
        POC = 'ocp-support@googlegroups.com';
    end
    
    methods
        function this = cajal
            % set up search path on constructor
            pathstr = cajal.setSearchPath;
            this.frameworkRoot = pathstr;
            
            % set up any installed CAJAL toolboxes
            if exist(fullfile(cajal.getRootDir(),'cajal_toolboxes.mat'),'file')
                load(fullfile(cajal.getRootDir(),'cajal_toolboxes.mat'));
                for ii = 1:length(toolbox_setup) %#ok<USENS>
                    run(toolbox_setup{ii});
                end
            end
            
            % set up dynamic class path
            javaaddpath(fullfile(cajal.getRootDir,'api','matlab','ocp','jedis-2.1.0.jar'));
            javaaddpath(fullfile(cajal.getRootDir,'api','matlab','ocp','cajal3d.jar'));   
            warning('off','MATLAB:Java:DuplicateClass');
        end
    end
    
    
    methods (Static)
        function bugReport
            err = lasterror; %#ok<LERR>
            clc
            bugStr = sprintf('* Please copy and paste the following report into an email addressed to <a href="mailto:%s?subject=cajal_Bug_Report">%s</a> *\n',...
                cajal.POC,cajal.POC);
            bugStr = sprintf('%s* In addition to your contact information, feel free to include *\n* any additional comments and/or attachments that may help debug the issue. *\n\n',bugStr);
            bugStr = sprintf('%s\n<><><><><>  BUG REPORT <><><><><>\n\n',bugStr);
            bugStr = sprintf('%sUserpath Env Var: %s\n\n',bugStr,getenv('MATLAB_USE_USERPATH'));
            bugStr = sprintf('%sArch: %s\n\n',bugStr,computer('arch'));
            bugStr = sprintf('%sOS String: %s\n\n',bugStr,system_dependent('getos'));
            
            if ispc
                platform = [system_dependent('getos'),' ',system_dependent('getwinsys')];
            elseif ismac
                [fail, input] = unix('sw_vers');
                if ~fail
                    platform = strrep(input, 'ProductName:', '');
                    platform = strrep(platform, sprintf('\t'), '');
                    platform = strrep(platform, sprintf('\n'), ' ');
                    platform = strrep(platform, 'ProductVersion:', ' Version: ');
                    platform = strrep(platform, 'BuildVersion:', 'Build: ');
                else
                    platform = system_dependent('getos');
                end
            else
                platform = system_dependent('getos');
            end
            
            % display version
            bugStr = sprintf('%sMATLAB Version: %s\n',bugStr,version);
            
            % display Matlab license number
            bugStr = sprintf('%sMATLAB License Number: %s\n',bugStr,license);
            
            % display os
            bugStr = sprintf('%sOperating System: %s\n',bugStr,platform);
            
            % display first line of Java VM version info
            bugStr = sprintf('%sJava VM Version: %s\n',bugStr,...
                char(strread(version('-java'),'%s',1,'delimiter','\n')));
            
            % toolbox info
            bugStr = sprintf('%s\nToolboxes: \n',bugStr);
            v = ver;
            for k=1:length(v)
                bugStr = sprintf('%s  %s -  Version %s\n', ...
                    bugStr,v(k).Name, v(k).Version);
            end
            
            % system info
            bugStr = sprintf('%s\nCPU: %s\n',bugStr,system_dependent('GetCPU'));
            bugStr = sprintf('%sNum Cores: %d\n',bugStr,system_dependent('NumCores'));
            bugStr = sprintf('%sNum Threads: %d\n',bugStr,system_dependent('NumThreads'));
            
            % pwd
            bugStr = sprintf('%s\nCurrent Working Directory: %s\n',bugStr,pwd);
            [pathstr, ~, ~] = fileparts(which('cajal'));
            bugStr = sprintf('%sFramework Directory: %s\n\n',bugStr,pathstr);
            bugStr = sprintf('%sFramework Version: %s\n\n',bugStr,cajal.version);
            
            % error info
            errStr = sprintf('Last Error:\n');
            errStr = sprintf('%s Identifier: %s\n',errStr,err.identifier);
            errStr = sprintf('%s Message: %s\n',errStr,err.message);
            errStr = sprintf('%s Cause:\n',errStr);
            
            s = err.stack;
            errStr = sprintf('%s Stack:\n',errStr);
            for ii = 1:length(s)
                fstr = strrep(s(ii).file,'\','\\');
                errStr = sprintf('%s\n  File: %s \n',errStr,fstr);
                errStr = sprintf('%s  Method: %s \n',errStr,s(ii).name);
                errStr = sprintf('%s  Line: %d \n',errStr,s(ii).line);
            end
            
            bugStr = sprintf('%s%s\n\n',bugStr,errStr);
            
            bugStr = sprintf('%sDescription of Problem: \n\n',bugStr);
            bugStr = sprintf('%s   - - Please fill out in email - - \n\n',bugStr);
            
            
            bugStr = sprintf('%sComments: \n\n',bugStr);
            bugStr = sprintf('%s   - - Please fill out in email - - \n\n',bugStr);
            
            
            bugStr = sprintf('%s\nPlease copy and paste the above report into an email addressed to  <a href="mailto:%s?subject=CAJAL_Bug_Report">%s</a>.\n\n\n',...
                bugStr,cajal.POC,cajal.POC);
            
            fprintf('%s',bugStr);
        end
        
        function pathstr = setSearchPath
            [pathstr, ~, ~] = fileparts(which('cajal'));
            new_path = genpath(pathstr);
            
            addpath(new_path);            
        end
        
        function setCurrentFolder
            [pathstr, ~, ~] = fileparts(which('cajal'));
            cd(pathstr);            
        end
        
        function path = getRootDir
            [path, ~, ~] = fileparts(which('cajal'));
        end
        
        function installToolbox(path)
            % This method "installs" a CAJAL toolbox by saving the
            % provided path to its setup method.  This will be run
            % when "cajal" gets called either at the command prompt
            % or automatically in startup.m
            if exist(fullfile(cajal.getRootDir(),'cajal_toolboxes.mat'),'file')
                load(fullfile(cajal.getRootDir(),'cajal_toolboxes.mat'));
                
                toolbox_setup(length(toolbox_setup)+1) = {path}; %#ok<NODEF,NASGU>
                
            else
                toolbox_setup = {path}; %#ok<NASGU>
            end
            
           save(fullfile(cajal.getRootDir(),'cajal_toolboxes.mat'),'toolbox_setup');
            
        end
        
        function uninstallToolbox()
            count = cajal.listInstalledToolboxes();
            if count ~=0
                question = sprintf('Which toolbox should be removed? [1-%d]\n',count);
                resp = input(question);
                
                load(fullfile(cajal.getRootDir(),'cajal_toolboxes.mat'));
                toolbox_setup(resp) = [];
                if ~isempty(toolbox_setup)
                    save(fullfile(cajal.getRootDir(),'cajal_toolboxes.mat'),'toolbox_setup');
                else
                    delete(fullfile(cajal.getRootDir(),'cajal_toolboxes.mat'));
                end
                
            end
        end
        
        function count = listInstalledToolboxes()
            if exist(fullfile(cajal.getRootDir(),'cajal_toolboxes.mat'),'file')
                load(fullfile(cajal.getRootDir(),'cajal_toolboxes.mat'));
                count = length(toolbox_setup); %#ok<USENS>
                
                fprintf('Installed cajal toolbox startup methods:\n');
                for ii = 1:length(toolbox_setup)
                    fprintf('[%d] %s\n',ii,toolbox_setup{ii});
                end
            else
                fprintf('No cajal toolboxes installed.\n');
                count = 0;
            end
        end
    end
    
end
