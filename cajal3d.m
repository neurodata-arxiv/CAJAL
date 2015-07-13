classdef cajal3d
    %% cajal3d - CAJAL3D Framework utility Class
    % This function is provided to perform basic configuration, help, and
    % bug reporting tasks.
    %
    % Supported Uses:
    %
    % Add framework to MATALB search path and setup:
    % >> cajal3d
    %    - or -
    % >> cajal3d.setSearchPath
    %
    % Note: If you have not set your MATLAB installation to automatically
    % add the CAJAL3D framework to the search path at startup either
    % manually, or using the 'setupEnvironment' script, you must run this 
    % everytime MATLAB start before you can use the CAJAL3D framework.
    %
    % Set the current MATLAB folder to the framework path:
    % >> cajal3d.setCurrentFolder
    %
    % Get the framework path:
    % >> cajal3d.getRootDir
    %
    % Install a CAJAL3D toolbox where toolbox_path = path to startup script
    % for the toolbox you wish to add.
    % >> cajal3d.installToolbox(toolbox_path)
    %
    % List installed toolboxes:
    % >> cajal3d.listInstalledToolboxes()
    %
    % Remove an installed toolbox:
    % >> cajal3d.uninstallToolbox()
    %
    % Print information to be included in a bug report:
    % >> cajal3d.bugReport
    %
    % Note: Run this command immediately after the error has occured!
    %
    % Get the framework version:
    % >> cajal3d.version
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
        version = '1.8.0 RC2';
        POC = 'ocp-support@googlegroups.com';
    end
    
    methods
        function this = cajal3d
            % set up search path on constructor
            pathstr = cajal3d.setSearchPath;
            this.frameworkRoot = pathstr;
            
            % set up any installed CAJAL3D toolboxes
            if exist(fullfile(cajal3d.getRootDir(),'cajal3d_toolboxes.mat'),'file')
                load(fullfile(cajal3d.getRootDir(),'cajal3d_toolboxes.mat'));
                for ii = 1:length(toolbox_setup) %#ok<USENS>
                    run(toolbox_setup{ii});
                end
            end
            
            % set up dynamic class path
            javaaddpath(fullfile(cajal3d.getRootDir,'api','matlab','ocp','jedis-2.1.0.jar'));
            javaaddpath(fullfile(cajal3d.getRootDir,'api','matlab','ocp','cajal3d.jar'));   
            warning('off','MATLAB:Java:DuplicateClass');
        end
    end
    
    
    methods (Static)
        function bugReport
            err = lasterror; %#ok<LERR>
            clc
            bugStr = sprintf('* Please copy and paste the following report into an email addressed to <a href="mailto:%s?subject=CAJAL3D_Bug_Report">%s</a> *\n',...
                cajal3d.POC,cajal3d.POC);
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
            [pathstr, ~, ~] = fileparts(which('cajal3d'));
            bugStr = sprintf('%sFramework Directory: %s\n\n',bugStr,pathstr);
            bugStr = sprintf('%sFramework Version: %s\n\n',bugStr,cajal3d.version);
            
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
            
            
            bugStr = sprintf('%s\nPlease copy and paste the above report into an email addressed to  <a href="mailto:%s?subject=CAJAL3D_Bug_Report">%s</a>.\n\n\n',...
                bugStr,cajal3d.POC,cajal3d.POC);
            
            fprintf('%s',bugStr);
        end
        
        function pathstr = setSearchPath
            [pathstr, ~, ~] = fileparts(which('cajal3d'));
            new_path = genpath(pathstr);
            
            addpath(new_path);            
        end
        
        function setCurrentFolder
            [pathstr, ~, ~] = fileparts(which('cajal3d'));
            cd(pathstr);            
        end
        
        function path = getRootDir
            [path, ~, ~] = fileparts(which('cajal3d'));
        end
        
        function installToolbox(path)
            % This method "installs" a CAJAL3D toolbox by saving the
            % provided path to its setup method.  This will be run
            % when "cajal3d" gets called either at the command prompt
            % or automatically in startup.m
            if exist(fullfile(cajal3d.getRootDir(),'cajal3d_toolboxes.mat'),'file')
                load(fullfile(cajal3d.getRootDir(),'cajal3d_toolboxes.mat'));
                
                toolbox_setup(length(toolbox_setup)+1) = {path}; %#ok<NODEF,NASGU>
                
            else
                toolbox_setup = {path}; %#ok<NASGU>
            end
            
           save(fullfile(cajal3d.getRootDir(),'cajal3d_toolboxes.mat'),'toolbox_setup');
            
        end
        
        function uninstallToolbox()
            count = cajal3d.listInstalledToolboxes();
            if count ~=0
                question = sprintf('Which toolbox should be removed? [1-%d]\n',count);
                resp = input(question);
                
                load(fullfile(cajal3d.getRootDir(),'cajal3d_toolboxes.mat'));
                toolbox_setup(resp) = [];
                if ~isempty(toolbox_setup)
                    save(fullfile(cajal3d.getRootDir(),'cajal3d_toolboxes.mat'),'toolbox_setup');
                else
                    delete(fullfile(cajal3d.getRootDir(),'cajal3d_toolboxes.mat'));
                end
                
            end
        end
        
        function count = listInstalledToolboxes()
            if exist(fullfile(cajal3d.getRootDir(),'cajal3d_toolboxes.mat'),'file')
                load(fullfile(cajal3d.getRootDir(),'cajal3d_toolboxes.mat'));
                count = length(toolbox_setup); %#ok<USENS>
                
                fprintf('Installed CAJAL3D toolbox startup methods:\n');
                for ii = 1:length(toolbox_setup)
                    fprintf('[%d] %s\n',ii,toolbox_setup{ii});
                end
            else
                fprintf('No CAJAL3D toolboxes installed.\n');
                count = 0;
            end
        end
    end
    
end

