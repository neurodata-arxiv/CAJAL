classdef OCPNetwork < handle
    %OCPNetwork ************************************************
    % Provides network based methods for database interfacing
    %
    % Usage:
    %
    %  ocpNet = OCPNetwork(); Creates object
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
        %% Properties
        % Location to store server error pages.  Temp location automatically created if empty.
        errorPageLocation = [];
    end
    
    properties(SetAccess = 'private', GetAccess = 'private')
        %% Java Network Class
        % Java class provides the ability to post HDF5 files and better
        % error handling than matlab can provide natively
        jUrl = [];
        disposed = false;
    end
    
    methods( Access = public )
        %% Methods - General
        function this = OCPNetwork(varargin)
            % This class handles network communication.  You may need to
            % change the "reliableUrl" address.  It is used to verify network connectivity
            % and may not work if you are running on a LAN without
            % internet connectivity.  Change to something you know will
            % resolve as long as you are connected to the network.
            %
            %
            % this = OCPNetwork() - no semaphore (default case)
            % this = OCPNetwork(String server, int port, 
			%        String read_name, int max_permits_read, int timeout_seconds_read,
			%        String write_name, int max_permits_write, int timeout_seconds_write)
            %
            % IMPORTANT: YOU MUST HAVE A REDIS DATABASE INSTALLED AND
            % RUNNING FOR THE DISTRIBUTED SEMAPHORE TO WORK.  SERVER SHOULD
            % POINT TO THE HOST.
            %
            % ex: this = OCPNetwork("darkhelmet.jhuapl.edu",3679,"readQ",
            %                           10,0,"writeQ",20,100);
            %
            % Note:
            %   - If timeout value is 0 the class will wait forever
            %   - If read and write semaphore names are the same they will
            %     behave as a single semaphore
            
            reliableUrl = 'http://www.google.com';
            
            % Check internet connection
            cnt = 1;
            while cnt <= 5
                try
                    urlread(reliableUrl);
                    break;
                    
                catch ME
                    if cnt == 5
                        rethrow(ME);
                    end
                    warning('OCPNetwork:OCPNetwork','Internet connectivity check %d failed. \nError: %s',cnt,ME.message);
                    pause(10*cnt);
                    cnt = cnt + 1;
                end
            end
            
            
            % Setup Java network interface class
            try
                % Set up network interface class
                import me.openconnecto.*    
                switch nargin
                    case 0
                        % No semaphore
                        this.jUrl = me.openconnecto.OcpUrl();
                        
                    case 1
                        % Distributed Semaphore via Network Config
                        
                        % Load default settings/server location info
                        if exist(fullfile(fileparts(which('cajal3d')),'api','matlab','ocp','semaphore_settings.mat'),'file') == 2
                            load(fullfile(fileparts(which('cajal3d')),'api','matlab','ocp','semaphore_settings.mat'));
                        else
                            error('OCPNetwork:MissingConfig','No semaphore_settings.mat file found. Cannot connect to Redis server. Counld not create OCPNetwork instance');                            
                        end
                        
                        try
                             % Set up redis client
                             import redis.clients.*                             
                             jedisCli = jedis.Jedis(ocp_settings.server,ocp_settings.port);                             
                         catch jErr
                             fprintf('%s\n',jErr.identifier);
                             ex = MException('OCPNetwork:JavaImportError','Could not load redis java library.');
                             throw(ex);                             
                         end
                        
                        
                        % Check server for semaphore config
                        bRead = jedisCli.exists('read_semaphore');
                        if bRead.booleanValue == 0
                            error('OCPNetwork:MissingConfig','Server side configuration not found.  Use SemaphoreTool in /tools/distributed_semaphore to configure server.'); 
                        end
                        bWrite = jedisCli.exists('write_semaphore');
                        if bWrite.booleanValue == 0
                            error('OCPNetwork:MissingConfig','Server side configuration not found.  Use SemaphoreTool in /tools/distributed_semaphore to configure server.'); 
                        end
                        
                        % Load config
                        ocp_settings.read_semaphore = char(jedisCli.get('read_semaphore'));
                        ocp_settings.max_read_permits = str2double(jedisCli.get('max_read_permits'));
                        ocp_settings.read_timeout_seconds = str2double(jedisCli.get('read_timeout_seconds'));
                        ocp_settings.write_semaphore = char(jedisCli.get('write_semaphore'));
                        ocp_settings.max_write_permits = str2double(jedisCli.get('max_write_permits'));
                        ocp_settings.write_timeout_seconds = str2double(jedisCli.get('write_timeout_seconds'));

                        % Check semaphore is setup
                        bRead = jedisCli.exists([ocp_settings.read_semaphore ':EXISTS']);
                        if bRead.booleanValue == 0
                            error('OCPNetwork:NotInitialized','Read semaphore has not been initialized. Use SemaphoreTool in /tools/distributed_semaphore to configure server.'); 
                        end
                        bWrite = jedisCli.exists([ocp_settings.write_semaphore ':EXISTS']);
                        if bWrite.booleanValue == 0
                            error('OCPNetwork:NotInitialized','Write semaphore has not been initialized. Use SemaphoreTool in /tools/distributed_semaphore to configure server.'); 
                        end
                        
                        % Construct
                        this.jUrl = OcpUrl(ocp_settings.server,ocp_settings.port,...
                            ocp_settings.read_semaphore,ocp_settings.max_read_permits,...
                            ocp_settings.read_timeout_seconds,...
                            ocp_settings.write_semaphore,ocp_settings.max_write_permits,...
                            ocp_settings.write_timeout_seconds);
                        
                    case 8
                        % Distributed Semaphore Enabled
                        this.jUrl = OcpUrl(varargin{1},varargin{2},...
                            varargin{3},varargin{4},varargin{5},varargin{6},...
                            varargin{7},varargin{8});
                       
                    otherwise
                        ex = MException('OCPNetwork:InvalidConstructor','Invalid params to the constructor.');
                        throw(ex);
                end 
                
                this.disposed = false;
            catch jErr  
                fprintf('%s\n',jErr.identifier);
                ex = MException('OCPNetwork:JavaImportError','Could not load cajal3d.jar or create OcpUrl object. \nDepending on your OS and MATLAB version, you may need to run "setupEnvironment"\nin the tools directory to add this jar file to your static path.\n\n%s',jErr.message);
                throw(ex);
            end
                
        end
        
        function delete(this)
            % destroy java object
            if this.disposed == false
                this.jUrl.dispose();
                this.jUrl = 0;
                this.disposed = true;
            end
        end
        
        function this = setErrorPageLocation(this,loc)
            % This method sets the path to save server errors pages to
            this.errorPageLocation = loc;
        end
        
        %% Methods - Semaphore
        function num = numReadPermits(this)
           num = this.jUrl.num_read_permits();    
        end        
        
        function num = numWritePermits(this)
           num = this.jUrl.num_write_permits();    
        end
        
        % Reset methods clear and reset the semaphore.  These should be
        % used with CAUTION!
        function resetReadSemaphore(this)
           this.jUrl.reset_read_semaphore();    
        end
        function resetWriteSemaphore(this)
           this.jUrl.reset_write_semaphore();    
        end
        function resetSemaphores(this)
           this.jUrl.reset_semaphores();    
        end
        
        
		% Select non-default database index if desired.  
		% Run this AFTER creating object but BEFORE a reset or lock.
        function selectDatabaseIndex(this,index)
            this.jUrl.select_database_index(index)
        end
        
        %% Query with REST args, Return PNG File
        function image = queryImage(this,urlStr)
            try
                % Get the data
                responseCode = this.jUrl.read(urlStr,false);
                if responseCode == 200
                    image = imread(char(this.jUrl.output));
                else
                    % Server errored
                    errorMessage = sprintf('Server Response %d - %s \n Error Page: <a href="%s">%s</a>\n',...
                        responseCode, char(this.jUrl.responseMessage),...
                        char(this.jUrl.output),char(this.jUrl.output));
                    
                    if ispc
                        %need to fix \
                        errorMessage = strrep(errorMessage,'\','\\');
                    end
                    
                    ex = MException('OCPNetwork:InternalServerError',errorMessage);
                    throw(ex);
                end
                
            catch err1
                try
                    urlread('http://www.google.com');
                catch err2
                    rethrow(err2); %MATLAB:urlread:ConnectionFailed
                end
                ex = MException('OCPNetwork:BadQuery', 'Query Failed.  Internet connection OK.  Check parameters.\n\nAttempted Query: %s \n\nError Message: %s\n\n',urlStr, err1.message);
                throw(ex);
            end
        end
        
        %% test URL
        function testUrl(this,urlStrBase)
            % urlStr already has a trailing / 
            urlStr = strcat(urlStrBase, 'ocp/accounts/login/');
            try
                % Get the data
                responseCode = this.jUrl.read(urlStr,false);
                % allow 404 response code, means a web server exists 
                if responseCode ~= 200
                    % Server errored
                    errorMessage = sprintf('Server Response %d - %s \n Error Page: <a href="%s">%s</a>\n',...
                        responseCode, char(this.jUrl.responseMessage),...
                        char(this.jUrl.output),char(this.jUrl.output));
                    
                    if ispc
                        %need to fix \
                        errorMessage = strrep(errorMessage,'\','\\');
                    end
                    
                    ex = MException('OCPNetwork:InternalServerError',errorMessage);
                    throw(ex);
                end
                
            catch err1                
                try
                    urlread('http://www.google.com');
                catch err2
                    rethrow(err2); %MATLAB:urlread:ConnectionFailed
                end
                ex = MException('OCPNetwork:BadQuery', 'Query Failed.  Internet connection OK.  Check parameters.\n\nAttempted Query: %s \n\nError Message: %s\n\n',urlStr, err1.message);
                throw(ex);
            end
        end
        
        %% Read/Write Queries 
        function output = read(this,urlStr,hdfFile)
        % This method queries a RESTful web service to read data
        % It also supports posting an HDF5 file with the request.
            
            if ~exist('hdfFile','var')                
                output = this.processQueryResponse(this.jUrl.read(urlStr,false));
            else              
                output = this.processQueryResponse(this.jUrl.read(urlStr,hdfFile,false));
            end
        end
        
        function output = write(this,urlStr,hdfFile)
        % This method queries a RESTful web service to write data
        % It supports posting an HDF5 file with the request.
            if ~exist('hdfFile','var')                
                output = this.processQueryResponse(this.jUrl.write(urlStr,false));
            else              
                output = this.processQueryResponse(this.jUrl.write(urlStr,hdfFile,false));
            end
        end
        
        function output = readCached(this,urlStr,hdfFile)
        % This method queries a RESTful web service to read data
        % It also supports posting an HDF5 file with the request.
        %
        % This method has ALL CACHING ENABLED.  Use this for getting
        % stable data only (i.e. image databases).  There is a
        % possiblity that if serverside data changes you will NOT see
        % it.
        
            if ~exist('hdfFile','var')                
                output = this.processQueryResponse(this.jUrl.read(urlStr,true));
            else              
                output = this.processQueryResponse(this.jUrl.read(urlStr,hdfFile,true));
            end
        end
        
        
        %% Process query response
        function output = processQueryResponse(this, responseCode)
            if responseCode ~= 200
                % Some error Occured - Write out debug info
                if isempty(this.errorPageLocation)
                    errorPagePath = char(this.jUrl.output);
                else
                    errorPagePath = fullfile(this.errorPageLocation,[datestr(now,30) '.html']);
                    copyfile(char(this.jUrl.output),errorPagePath);
                end
                
                errorMessage = sprintf('Server Response %d - %s \n Error Page: <a href="%s">%s</a>\n',...
                    responseCode, char(this.jUrl.responseMessage),...
                    errorPagePath,errorPagePath);
                
                if ispc
                    %need to fix \
                    errorMessage = strrep(errorMessage,'\','\\');
                end
                
                ex = MException('OCPNetwork:InternalServerError',errorMessage);
                throw(ex);
                
            else
                % Looks Good
                output = char(this.jUrl.output);
            end
        end
        
        %% Send HTTP DELETE request on a URL
        function output = deleteRequest(this,urlStr)
            % This method sends a url using a delete request
            
            % Do delete
            responseCode = this.jUrl.delete(urlStr);
            
            
            if responseCode ~= 200
                % Some error Occured - Write out debug info
                if isempty(this.errorPageLocation)
                    errorPagePath = char(this.jUrl.output);
                else
                    errorPagePath = fullfile(this.errorPageLocation,[datestr(now,30) '.html']);
                    copyfile(char(this.jUrl.output),errorPagePath);
                end
                
                errorMessage = sprintf('Server Response %d - %s \n Error Page: <a href="%s">%s</a>\n',...
                    responseCode, char(this.jUrl.responseMessage),...
                    errorPagePath,errorPagePath);
                
                if ispc
                    %need to fix \
                    errorMessage = strrep(errorMessage,'\','\\');
                end
                
                ex = MException('OCPNetwork:InternalServerError',errorMessage);
                throw(ex);
                
            else
                % Looks Good
                output = char(this.jUrl.output);
            end            
        end
    end
end
