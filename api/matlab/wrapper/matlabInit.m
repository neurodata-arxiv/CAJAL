function matlabInit(varargin)
    % This method is used to call all matlab code when using the LONI pipeline.
    %  It automatically provides proper error handling and matlab interpreter
    %  control so LONI gets properly exposed to the streams from inside the
    %  interpreter, and the interpreter exits when it should.
    %
    %  The debug flag, if set to true, will open a workspace and editor window
    %  on the LOCAL machine.  Unless you are working locally you may have to
    %  VNC into the processing node to debug.
    %
    %  All arguments come in as strings and should be entered as pairs with
    %  identifier information for type conversion:
    %
    %  Supported IDs:
    %   -s = String
    %   -d = Double
    %   -l = Logical either 1/0 or true/false
    %   -m = Matrix of doubles - be careful of syntax!
    %   -b = deBug flag
    %
    %  Example:
    %   matlabInit('functionToRun','-s','test string','-d','9','-m','[2,3;5,3]');
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
    
    %% If you are running on LONI and want matlab to auto-exit set to true
    if ispc
        % System call does not wait for process in windows so work is
        % needed here to have use of this wrapper even make sense
         ex = MException('MatlabInit:OSUnsupported',...
                'Currently the matlab wrapper is only tested and supported on Linux and OSX');
         throw(ex);
    end
    
    autoExit = true;
    [~,hostname]= system('hostname');
    fprintf('\nSystem Host Name: %s\n\n',hostname);
    fprintf('\nFunction Called: %s\n\n',varargin{1});
    
    try
        
        %% Parse out function handle
        [~, name, ~] = fileparts(varargin{1});
        
        if isempty(which(name))
            error('MatlabInit:FunctionNotFound','The function %s is not found on the MATLAB search path',varargin{1});
        end
        
        if ~strcmp(which(name),which(varargin{1})) %TODO: relative path fix
            error('MatlabInit:FunctionHidden','Another function appears to be hidding the method are are attempting to execute on the MATLAB search path.  Please verify.  Result of which: %s',which(name));
        end
        
        fhandle = eval(sprintf('@%s',name));
        
        %% Parse the arguments to the function call
        tempArgIn = varargin;
        % Remove function handle since already extraced
        tempArgIn(1) = [];
        % Split args and identifiers
        identifiers = tempArgIn(1:2:end);
        arguments = tempArgIn(2:2:end);
        
        if ~isempty(tempArgIn)
            % Check for flags for each arg if there are args
            ind = strfind(identifiers, '-');   
            ind = cellfun(@isempty,ind);

            if sum(ind) == length(ind)
                error('MATLABINIT:NOIDENTIFIERS','You must provide an argument indentifier for each argument! No flags have been parsed.');
            end

            if length(identifiers) ~= length(arguments) || sum(ind) ~= 0
                error('MATLABINIT:IDENTIFIERMISMATCH','You must provide an argument indentifier for each argument!\n# of IDs: %d\n# of Arguments: %d',...
                    length(identifiers),length(arguments));
            end
        end
        
        %% Convert Strings to proper Matlab Types
        for ii = 1:length(identifiers)
            switch identifiers{ii}
                case '-s'
                    convertedArgs{ii} = arguments{ii}; %#ok<*AGROW>
                case '-d'
                    convertedArgs{ii} = str2double(arguments{ii}); %#ok<*AGROW>                
                case '-l'
                    if length(arguments{ii}) > 1
                        if strcmpi(arguments{ii},'true')
                            convertedArgs{ii} = true; %#ok<*AGROW>
                        elseif strcmpi(arguments{ii},'false')
                            convertedArgs{ii} = false; %#ok<*AGROW>
                        else
                            error('Invalid logical parameter %s, must be true/false/1/0',arguments{ii});
                        end
                    else
                        convertedArgs{ii} = logical(str2double(arguments{ii})); %#ok<*AGROW>
                    end
                case '-m'
                    convertedArgs{ii} = eval(arguments{ii}); %#ok<*AGROW>
                case '-b'
                    debugMode = str2double(arguments{ii});
                otherwise
                    errstr = sprintf('Unsupported argument type indentifier: %s\n\n',varargin{ii + 1});
                    errstr = sprintf('%sSupported indentifiers:\n',errstr);
                    errstr = sprintf('%sstring\ndouble\nmatrix',errstr);
                    error('MATLABINIT:BADIDENTIFIER',errstr); %#ok<SPERR>
            end
        end
        
        %% If debug mode is not set, default to off.
        if ~exist('debugMode','var')
            debugMode = 0;
        end
        
        %% If Debug mode is set start editor and workspace
        if debugMode == 1
            % Open Workspace
            workspace
            % Open Editor
            edit matlabInit
            % Set breakpoint
            dbstop in matlabInit at 145
            dbstop in matlabInit at 149
        end
        
        %% Make function call
        if exist('convertedArgs','var')            
            % IF YOU ARE IN DEBUG MODE STEP INTO THE FEVAL COMMAND (F11)
            feval(fhandle,convertedArgs{:});
            % IF YOU ARE IN DEBUG MODE STEP INTO THE FEVAL COMMAND (F11)
        else           
            % IF YOU ARE IN DEBUG MODE STEP INTO THE FEVAL COMMAND (F11)
            feval(fhandle);
            % IF YOU ARE IN DEBUG MODE STEP INTO THE FEVAL COMMAND (F11)
        end
        
    catch ME
        %% If error occured send to error handler
        errorHandler(ME);
        
        % Exit matlab if flag is set
        if autoExit == true
            exit;
        end
    end
    
    %% Exit matlab if flag is set
    if autoExit == true
        exit;
    end
    
end