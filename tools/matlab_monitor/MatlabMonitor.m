classdef MatlabMonitor
    %MatlabMonitor Tool to monitor MATLAB apps running in LONI
    %   Due to MATLAB limitations, you cannot access the command window
    %   text or errors from a MATLAB interpreter until execution has
    %   completed.  This makes monitoring long running processes very
    %   difficult.  The MatlabMonitor class fixes this, but letting you
    %   assign status to a key inside your app and monitoring from your
    %   laptop.
    %
    %   Note: Uses redis DB 2
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
        database_id = 2;
    end
    
    methods
        function this = MatlabMonitor()
            % Setup Java network interface class
            try
                % Set up redis client
                javaaddpath(fullfile(cajal3d.getRootDir,'api','matlab','ocp','cajal3d.jar'));
                javaaddpath(fullfile(cajal3d.getRootDir,'api','matlab','ocp','jedis-2.1.0.jar'));
                import redis.clients.*
                
                load(fullfile(fileparts(which('cajal3d')),'api','matlab','ocp','semaphore_settings.mat'));
                this.settings = ocp_settings;
                this.jedisCli = jedis.Jedis(ocp_settings.server,ocp_settings.port);
                
                % Set Database
                this.selectDatabaseIndex(this.database_id);
            
            catch jErr
                fprintf('%s\n',jErr.identifier);
                ex = MException('SemaphoreTool:JavaImportError','Could not load redis java library.');
                throw(ex);
                
            end
            
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
        
        function clearAllStatusKeys(this)
            response = this.jedisCli.flushDB();
            fprintf('\n Flush ALL Keys in DB:%s\n\n',char(response));
        end
        
        function reset(this,key)
            this.jedisCli.del(key);
            response = this.jedisCli.set(key, '');
            fprintf('\n Reset Key %s: %s\n\n',key, char(response));
        end
        
        function selectDatabaseIndex(this,index)
            this.jedisCli.select(index);
        end
        
        function update(this, key, status)  
            % Add time and newline
            status = sprintf('%s :: %s\n',datestr(now),status);          
            % Append
            this.jedisCli.append(key,status);        
        end
        
                
        function dump(this, key) 
            % Get key
            data = this.jedisCli.get(key); 
            
            % Print
            fprintf('### %s ###\n',key);
            fprintf('%s',char(data));
            
        end
        
        function monitor(this, key) 
            % start by dumping key
            fprintf('Monitoring %s: Press CTRL+C to quit.\n',key);
            this.dump(key);
            key_len = double(this.jedisCli.strlen(key));
            while(1) 
                new_len = double(this.jedisCli.strlen(key));
                if key_len == new_len
                    % no update
                    pause(1);
                    continue;
                end
                newline = this.jedisCli.getrange(key,key_len,new_len-1);
                key_len = new_len;
                
                % Print
                fprintf('%s',char(newline));                                
            end     
        end
    end  
      
end
