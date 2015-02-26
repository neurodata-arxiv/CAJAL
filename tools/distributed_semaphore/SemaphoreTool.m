classdef SemaphoreTool
    %SEMTOOL Summary of this class goes here
    %   Detailed explanation goes here
    
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
    
    
    properties
        jedisCli = [];
        settings = [];
        disposed = false;
    end
    
    methods
        function this = SemaphoreTool()
            % Setup Java network interface class
            try
                % Set up redis client
                javaaddpath(fullfile(cajal3d.getRootDir,'api','matlab','ocp','cajal3d.jar'));
                javaaddpath(fullfile(cajal3d.getRootDir,'api','matlab','ocp','jedis-2.1.0.jar'));
                import redis.clients.*
                
                load(fullfile(fileparts(which('cajal3d')),'api','matlab','ocp','semaphore_settings.mat'));
                this.settings = ocp_settings;
                this.jedisCli = jedis.Jedis(ocp_settings.server,ocp_settings.port);
            
            catch jErr
                fprintf('%s\n',jErr.identifier);
                ex = MException('SemaphoreTool:JavaImportError','Could not load redis java library.');
                throw(ex);
                
            end
            
            % Load settings - defaults have already been loaded by file. if
            % there are settings on the server they override the defaults
            this = this.load_settings();
            
            this.disposed = false;            
        end
        
        function this = delete(this)
            % destroy java object
            if this.disposed == false
                this.jedisCli.quit();
                this.jedisCli = 0;
                this.disposed = true;
            end
        end
        
        function info(this)
            infostr = this.jedisCli.info();
            fprintf('\n######### REDIS INFO:\n\n%s\n\n',char(infostr));
        end
        
        function flushAll(this)
            response = this.jedisCli.flushDB();
            fprintf('\n Flush ALL Keys:%s\n\n',char(response));
        end
        
        function selectDatabaseIndex(this,index)
            this.jedisCli.select(index);
        end
        
        
        function status(this)            
            
            % Check if semaphores exist
            rExist = this.jedisCli.exists([this.settings.read_semaphore ':EXISTS']);
            wExist = this.jedisCli.exists([this.settings.write_semaphore ':EXISTS']);
            
            % Check available permits
            if rExist.booleanValue
                rPermits = this.jedisCli.llen([this.settings.read_semaphore ':LIST']);
                rStr = sprintf('%d of %d Permits Available',double(rPermits),this.settings.max_read_permits);
            else
                rStr = 'Not Configured';
            end
            
            if wExist.booleanValue
                wPermits = this.jedisCli.llen([this.settings.write_semaphore ':LIST']);
                wStr = sprintf('%d of %d Permits Available',double(wPermits),this.settings.max_write_permits);
            else
                wStr = 'Not Configured';
            end
            
            % Print Status
            fprintf('Read  Semaphore Status: %s\n',rStr);
            fprintf('Write Semaphore Status: %s\n\n',wStr);
            
        end
        
        function monitor(this)                     
            while(1)
                
                % Check if semaphores exist
                rExist = this.jedisCli.exists([this.settings.read_semaphore ':EXISTS']);
                wExist = this.jedisCli.exists([this.settings.write_semaphore ':EXISTS']);
                
                % Check available permits
                if rExist.booleanValue
                    rPermits = this.jedisCli.llen([this.settings.read_semaphore ':LIST']);
                    rStr = sprintf('%d of %d Permits Available',double(rPermits),this.settings.max_read_permits);
                else
                    rStr = 'Not Configured';
                end
                
                if wExist.booleanValue
                    wPermits = this.jedisCli.llen([this.settings.write_semaphore ':LIST']);
                    wStr = sprintf('%d of %d Permits Available',double(wPermits),this.settings.max_write_permits);
                else
                    wStr = 'Not Configured';
                end
                
                % Print Status
                clc
                fprintf('Read  Semaphore Status: %s\n',rStr);
                fprintf('Write Semaphore Status: %s\n\n',wStr);
                fprintf('Press CNTL+C to stop...');
                
                pause(1)                
            end     
        end
        
        function resetRead(this)
            % Clear Old keys
            this.jedisCli.del([this.settings.read_semaphore ':EXISTS']);
            this.jedisCli.del([this.settings.read_semaphore ':LIST']);
            
            % create list key
            for ii = 1:this.settings.max_read_permits
                this.jedisCli.rpush([this.settings.read_semaphore ':LIST'],num2str(ii));
            end            
            
            % Create exists key
            this.jedisCli.set([this.settings.read_semaphore ':EXISTS'],'yes');
        end
        
        function resetWrite(this)
            % Clear Old keys
            this.jedisCli.del([this.settings.write_semaphore ':EXISTS']);
            this.jedisCli.del([this.settings.write_semaphore ':LIST']);
            
            % create list key
            for ii = 1:this.settings.max_write_permits
                this.jedisCli.rpush([this.settings.write_semaphore ':LIST'],num2str(ii));
            end
            
            % Create exists key
            this.jedisCli.set([this.settings.write_semaphore ':EXISTS'],'yes');
        end
        
        function resetAll(this)
            % Update Redis DB
            this.flushAll();
            this.load_settings();
            resetRead(this)
            resetWrite(this)
        end
        
        function saveAsDefault(this)
            % Check if you want to do it
            fprintf('Current Server Config: \n');
            fprintf(' Read Semaphore Key: %s\n Max Read Permits: %d\n Read Timeout Seconds: %d\n',...
                this.settings.read_semaphore,this.settings.max_read_permits,this.settings.read_timeout_seconds);
            fprintf(' Write Semaphore Key: %s\n Max Write Permits: %d\n Write Timeout Seconds: %d\n\n\n',...
                this.settings.write_semaphore,this.settings.max_write_permits,this.settings.write_timeout_seconds);
            
            loopflag = 1;
            questStr = sprintf('\nDo you want to save the current server configuration as your new default settings?\n: ');
            strResponse = input(questStr, 's');
            
            while loopflag == 1
                switch strResponse
                    case {'Y','y'}
                        loopflag = 0;
                    case {'N','n'}
                        fprintf('Save cancelled...\n');
                        return
                    otherwise
                        strResponse = input('Please enter either "Y" for yes or "N" for no:', 's');
                end
            end
            
            % Backup old settings
            copyfile(fullfile(fileparts(which('cajal3d')),'api','matlab','ocp','semaphore_settings.mat'),...
                fullfile(fileparts(which('cajal3d')),'api','matlab','ocp',['semaphore_settings_' datestr(now,30) '.mat']));
            
            % Save current settings (which have been loaded from the server
            % if they exist)
            ocp_settings = this.settings; %#ok<NASGU>
            save(fullfile(fileparts(which('cajal3d')),'api','matlab','ocp','semaphore_settings.mat'),'ocp_settings');            
        end
        
        function this = setReadPermits(this, num)
            % function to dynamically set the number of read permits on the
            % server. If you do a reset changes will be lost!
            this.settings.max_read_permits = num;
            this.resetRead
        end
        
        function this = setWritePermits(this, num)
            % function to dynamically set the number of write permits on the
            % server. If you do a reset changes will be lost!
            this.settings.max_write_permits = num;
            this.resetWrite
        end
        
        
        function this = configure(this)            
            % Check if you want to do it
            loopflag = 1;
            questStr = sprintf('\nDo you want to change the distributed semaphore configuration?\nWARNING: THIS WILL RESET THE SERVER SEMAPHORE AND CAN CAUSE PROBLEMS IF PROCESSING IS CURRENTLY RUNNING  (Y or N): ');
            strResponse = input(questStr, 's');
            
            while loopflag == 1
                switch strResponse
                    case {'Y','y'}
                        loopflag = 0;
                    case {'N','n'}
                        fprintf('Configuration cancelled...\n');
                        return
                    otherwise
                        strResponse = input('Please enter either "Y" for yes or "N" for no:', 's');
                end
            end
            
            % Get new values
            fprintf('Enter new values, press return to accept current value in parentheses...\n\n')
            questStr = sprintf('Server (%s): ',this.settings.server);
            response = input(questStr, 's');
            if isempty(response)
                newSettings.server = this.settings.server;
            else
                newSettings.server = response;
            end
            
            questStr = sprintf('Port (%d): ',this.settings.port);
            response = input(questStr, 's');
            if isempty(response)
                newSettings.port = this.settings.port;
            else
                newSettings.port = str2double(response);
            end
            
            questStr = sprintf('Read Semaphore Name (%s): ',this.settings.read_semaphore);
            response = input(questStr, 's');
            if isempty(response)
                newSettings.read_semaphore = this.settings.read_semaphore;
            else
                newSettings.read_semaphore = response;
            end
            
            questStr = sprintf('Max Read Permits (%d): ',this.settings.max_read_permits);
            response = input(questStr, 's');
            if isempty(response)
                newSettings.max_read_permits = this.settings.max_read_permits;
            else
                newSettings.max_read_permits = str2double(response);
            end
            
            questStr = sprintf('Read Timeout in Seconds (%d): ',this.settings.read_timeout_seconds);
            response = input(questStr, 's');
            if isempty(response)
                newSettings.read_timeout_seconds = this.settings.read_timeout_seconds;
            else
                newSettings.read_timeout_seconds = str2double(response);
            end
            
            questStr = sprintf('Write Semaphore Name (%s): ',this.settings.write_semaphore);
            response = input(questStr, 's');
            if isempty(response)
                newSettings.write_semaphore = this.settings.write_semaphore;
            else
                newSettings.write_semaphore = response;
            end
            
            questStr = sprintf('Max Write Permits (%d): ',this.settings.max_write_permits);
            response = input(questStr, 's');
            if isempty(response)
                newSettings.max_write_permits = this.settings.max_write_permits;
            else
                newSettings.max_write_permits = str2double(response);
            end
            
            questStr = sprintf('Write Timeout in Seconds (%d): ',this.settings.write_timeout_seconds);
            response = input(questStr, 's');
            if isempty(response)
                newSettings.write_timeout_seconds = this.settings.write_timeout_seconds;
            else
                newSettings.write_timeout_seconds = str2double(response);
            end
            
            
            % Display result and check if you want to commit changes
            fprintf('\n\nNew Settings:\n\n');
            disp(newSettings);
            
            loopflag = 1;
            questStr = sprintf('\nDo you want to commit these changes to the local file system (new default settings) and Redis Server? (Y or N): ');
            strResponse = input(questStr, 's');
            
            while loopflag == 1
                switch strResponse
                    case {'Y','y'}
                        loopflag = 0;
                    case {'N','n'}
                        fprintf('Configuration cancelled...\n');
                        return
                    otherwise
                        strResponse = input('Please enter either "Y" for yes or "N" for no:', 's');
                end
            end
            
            % Update class
            this.settings = newSettings;
            
            % Backup old settings
            copyfile(fullfile(fileparts(which('cajal3d')),'api','matlab','ocp','semaphore_settings.mat'),...
                fullfile(fileparts(which('cajal3d')),'api','matlab','ocp',['semaphore_settings_' datestr(now,30) '.mat']));
            
            % Update File
            ocp_settings = newSettings; %#ok<NASGU>
            save(fullfile(fileparts(which('cajal3d')),'api','matlab','ocp','semaphore_settings.mat'),'ocp_settings');
            
            % Update Redis DB
            this.flushAll();
            this.load_settings();
            this.resetAll();
        end
    end
    
    methods(Access = private)
        function this = load_settings(this)         
            
            % Load Settings from server if they exist
            bRead = this.jedisCli.exists('read_semaphore');
            if bRead.booleanValue
                fprintf('Loading Read Semaphore settings from server.\n');
                % Settings exist on the server
                this.settings.read_semaphore = char(this.jedisCli.get('read_semaphore'));
                this.settings.max_read_permits = str2double(this.jedisCli.get('max_read_permits'));
                this.settings.read_timeout_seconds = str2double(this.jedisCli.get('read_timeout_seconds'));
            else
                % Settings do not exist on the server. Load from file.
                fprintf('No server config fount. Loading Read Semaphore DEFAULT settings from file.\n');
                %warning('SemaphoreTool:NoServerConfig','There are no read_semaphore settings on the server.  Loading defaults from semaphore_settings.mat');
                this.jedisCli.set('read_semaphore',this.settings.read_semaphore);
                this.jedisCli.set('max_read_permits',num2str(this.settings.max_read_permits));
                this.jedisCli.set('read_timeout_seconds',num2str(this.settings.read_timeout_seconds));
            end
            fprintf('Read Semaphore Key: %s\nMax Read Permits: %d\nRead Timeout Seconds: %d\n',...
                this.settings.read_semaphore,this.settings.max_read_permits,this.settings.read_timeout_seconds);
            
            bWrite = this.jedisCli.exists('write_semaphore');
            if bWrite.booleanValue
                fprintf('Loading Write Semaphore settings from server.\n');
                % Settings exist on the server
                this.settings.write_semaphore = char(this.jedisCli.get('write_semaphore'));
                this.settings.max_write_permits = str2double(this.jedisCli.get('max_write_permits'));
                this.settings.write_timeout_seconds = str2double(this.jedisCli.get('write_timeout_seconds'));
            else
                % Settings do not exist on the server. Load from file.
                fprintf('No server config fount. Loading Read Semaphore DEFAULT settings from file.\n');
                %warning('SemaphoreTool:NoServerConfig','There are no read_semaphore settings on the server.  Loading defaults from semaphore_settings.mat');
                this.jedisCli.set('write_semaphore',this.settings.write_semaphore);
                this.jedisCli.set('max_write_permits',num2str(this.settings.max_write_permits));
                this.jedisCli.set('write_timeout_seconds',num2str(this.settings.write_timeout_seconds));
            end
            fprintf('Write Semaphore Key: %s\nMax Write Permits: %d\nWrite Timeout Seconds: %d\n',...
                this.settings.write_semaphore,this.settings.max_write_permits,this.settings.write_timeout_seconds);
        end
        
    end
end
