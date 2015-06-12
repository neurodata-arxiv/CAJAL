classdef OCP < handle
    %OCP ************************************************
    % Provides easy access to the Open Connectome Project database services
    %
    % Usage:
    %
    %  oo = OCP(); Creates object without distributed semaphore (typical)
    %
    %  Distributed Semaphore enabled (see OCPNetwork for details) with config
    %  loaded from redis server.  See README for setup details.
    %  You only need this when running on a large cluster.
    %	
    %  oo = OCP('semaphore');
    %
    %  Distributed Semaphore enabled with explicit config (see OCPNetwork for details)
    %  You only need this when running on a large cluster.
    %
    %  oo = OCP("myserver.mysite.edu",3679,"readQ",10,0,"writeQ",20,100);     
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
        %% Properties - Server Info
        %Url to server root
        serverLocation = 'http://www.openconnecto.me' 
        
        batchSize = 50; % Number of annotations to group in a batch upload
        maxAnnoSize = 16777216; % Maximum size of annotation in voxels to be uploaded in a single RESTful query
                                % This is 2048x2048x4 which equates to
                                % about 60MB uncompressed. This is a
                                % reliable size to use across varying
                                % internet speeds
        
        %% Properties - Common Public
        defaultResolution = [] % Default resolution of the annotation DB
        
        %% Properties - DB Info
        imageInfo = [] % Dataset Info
        imageChanInfo = [] % Channel (prev Prject) info
        annoInfo = [] % Dataset Info
        annoChanInfo = [] % Channel (prev Project) info 
        
        
    end
    
    % AB TODO change getaccess back to private 
    properties(SetAccess = 'private', GetAccess = 'public')
        %% Properties - Private
        lastQuery = [];
        lastUrl = []
        lastHdfFile = [];
        
        %Token for Image Database
        imageToken = []
        imageChannel = []
        %Token for Annotation Database
        annoToken = []
        annoChannel = []
        
        %% Properties - Utility Classes
        net = [];
    end
    
    methods( Access = public )
        
        %% Methods - General - Constructor
        function this = OCP(varargin)
            % No Semaphore to control OCP server resource access (default case)
            %   this = OCP()
            %
            % Distributed Semaphore (see OCPNetwork for details).  Config
            % Loaded from redis server.  See README for setup details.
            % You only need this when running on a large cluster.
            %	this = OCP('semaphore');
            %
            % Distributed Semaphore Explicit Config(see OCPNetwork for details)
            % You only need this when running on a large cluster.
            %	this = OCP("darkhelmet.jhuapl.edu",3679,"readQ",10,0,"writeQ",20,100);
            
            
            % Set up network interface class
            switch nargin
                case 0
                    % No semaphore
                    this.net = OCPNetwork();
                    
                case 1
                    % Use network semaphore config
                    if strcmpi(varargin{1},'semaphore')
                        this.net = OCPNetwork(varargin{1});
                    else
                       error('OCP:UnsupportedOption','Invalid constructor flag'); 
                    end
                    
                case 8
                    % Distributed semaphore
                    this.net = OCPNetwork(varargin{1},varargin{2},...
                        varargin{3},varargin{4},varargin{5},varargin{6},...
                        varargin{7},varargin{8});
                otherwise
                    ex = MException('OCP:InvalidConstructor','Invalid params to the constructor.');
                    throw(ex);
            end
            
            % Verify server url is valid by setting to self
            this.setServerLocation(this.serverLocation);
        end
        
        %% Methods - Semaphore
        function num = numReadPermits(this)
            num = this.net.numReadPermits();
        end
        function num = numWritePermits(this)
            num = this.net.numWritePermits();
        end
                
        % Select non-default database index if desired.  This lets you work
        % with different semaphores, allowing unit testing/development to
        % occur without conflicting with actual processing.
        % Run this AFTER creating object but BEFORE a reset or lock.
        % Note: Uses OCP class uses redis DB 0 by default.  Main distributed
        % semaphore is stored in db 0.
        function selectDatabaseIndex(this,index)
            this.net.selectDatabaseIndex(index)
        end
        
        %% Methods - General - Setters/Getters
        function channel_cell_array = getChannelList(this)
           % All tokens are multichannel databases. Return cell array
           % listing channels.
           
           % If the image token is a multichannel database then return
           % a cell array listing the available channels
           if (this.imageChanInfo.TYPE == eRAMONDataType.channels16) || ...
                   (this.imageChanInfo.TYPE == eRAMONDataType.channels8)
               channel_cell_array = fieldnames(this.imageInfo.CHANNELS);               
           else
               % not multichannel
               channel_cell_array = [];
           end
        end
        
        function tokens = getPublicTokens(this)
            url = sprintf('%s/ocp/ca/public_tokens/',...
                    this.serverLocation);
            this.lastUrl = url;
            response = this.net.read(url);
            % parse
            inds = strfind(response,'"');
            cnt = 1;
            for ii = 1:2:length(inds)
                tokens{cnt} = response(inds(ii)+1:inds(ii+1)-1); %#ok<AGROW>
                cnt = cnt + 1;
            end
        end
        
        function this = setErrorPageLocation(this,location)
            % This method sets the path to save server errors pages to
            this.net.setErrorPageLocation(location);
        end
        function location = getErrorPageLocation(this)
            % This method gets the path to save server errors pages to
            location = this.net.errorPageLocation;
        end
        
        function this = setDefaultResolution(this,val)
            % This method sets the default resolution to use if a
            % resolution is not specified.  If it is empty and no
            % resolution is provided, an exception will occur
            validateattributes(val,{'numeric'},{'finite','nonnegative','integer','nonnan','real'});
            this.defaultResolution = val;
        end
        
        function this = setBatchSize(this,size)
            % This method sets the batch size.  This is how many
            % annotations will be grouped into a single batch when a cell
            % array of annotations is provided
            validateattributes(size,{'numeric'},{'finite','nonnegative','integer','nonnan','real'});
            this.batchSize = size;
        end
        
        function this = setMaxAnnoSize(this,val)
            % This method sets the maximum size an annotation can be until
            % auto-chunking will occur
            validateattributes(val,{'numeric'},{'finite','nonnegative','integer','nonnan','real'});
            this.maxAnnoSize = val;
        end
        
        function this = setServerLocation(this,val)
            % Verify you can resolve server.
            try
                %Make sure http:// is on the server url
                ind = strfind(val, 'http://');
                if isempty(ind)
                    val = sprintf('http://%s',val);
                end

                %Make sure url does not end with /
                if strcmpi(val(end),'/') ~= 0
                    %val = sprintf('%s/',val);
                    val(end) = '';
                end
                
                this.net.testUrl(val);
                %urlread(val);
            catch err2
                
                if strcmpi(err2.identifier,'MATLAB:Java:GenericException') == 1
                    rethrow(err2);
                end
                
                ex = MException('OCP:ServerConnFail',err2.message);
                throw(ex);
            end
            
            this.serverLocation = val;
        end
        
        function this = setImageToken(this,token)
            % This method sets the image database token to be used
            % It also clears the Image Channel field 
            this.imageChannel = [];
            this.imageChanInfo = [];
            
            % Get DB Info
            this.imageInfo = this.queryDBInfo(token);
            
            % set the token
            this.imageToken = token;
            
            % Search for a default channel and set if we found one
            channelNames = fieldnames(this.imageInfo.CHANNELS);
            for i = 1:numel(channelNames)
                if this.imageInfo.CHANNELS.(channelNames{i}).DEFAULT == 1
                    this.setImageChannel(channelNames{i});
                    msg = sprintf('Using default image channel: %s\n Set using setImageChannel().', channelNames{i});
                    warning('OCP:DefaultImageChannel',msg)
                    break
                end
            end
            if numel(this.imageChannel) == 0
                msg = sprintf('No default image channel. Set image channel before running queries.');
                warning('OCP:NoDefaultImageChannel',msg);
            end
            
            
        end
        function token = getImageToken(this)
            % This method gets the image database token to be used
            
            token = this.imageToken;
        end
        
        function setImageChannel(this, channel)
            % This method sets the image database channel to be used
            
            this.imageChannel = [];
            this.imageChanInfo = [];
            
            if numel(this.imageToken) == 0
                ex = MException('OCP:NoImageToken','Cannot set ImageChannel without first setting ImageToken.');
                throw(ex);  
            end
            channelNames = fieldnames(this.imageInfo.CHANNELS);
            for i = 1:numel(channelNames)
                if strcmpi(channelNames{i}, channel) == 1
                    this.imageChannel = channel;
                    % store the channel info in imageChanInfo
                    this.imageChanInfo = this.imageInfo.CHANNELS.(channel);
                    break;
                end
            end 
            
            if numel(this.imageChannel) == 0
                ex = MException('OCP:InvalidImageChannel','ImageChannel does not exist for this token.');
                throw(ex)
            end
            
        end
        function channel = getImageChannel(this)
            % This method gets the image database channel to be used
            channel = this.imageChannel;
        end
        function PrintImageChannels(this)
           % List all image channels for a particular token. 
           % AB TODO 
        end
        
        function this = setAnnoToken(this,token)
            % This method sets the annotation database token to be used
            % It also clears the AnnoChannel field 
            
            this.annoChannel = [];
            this.annoChanInfo = [];
            
            % Get DB Info
            this.annoInfo = this.queryDBInfo(token);
            
            % set the token
            this.annoToken = token;
            
            % Search for a default channel and set if we found one
            channelNames = fieldnames(this.annoInfo.CHANNELS);
            for i = 1:numel(channelNames)
                if this.annoInfo.CHANNELS.(channelNames{i}).DEFAULT == 1
                    this.setAnnoChannel(channelNames{i});
                    msg = sprintf('Using default anno channel: %s\n Set using setAnnoChannel().', channelNames{i});
                    warning('OCP:DefaultAnnoChannel',msg)
                    break
                end
            end
            
            if numel(this.annoChannel) == 0
                msg = sprintf('No default anno channel. Set anno channel before running queries.');
                warning('OCP:NoDefaultAnnoChannel',msg)
            end
            
            % ABTODO should check readonly for all channels (and all
            % tokens?)
            % right now READONLY is only included for channels 
            % Verify it is a writable DB
            %if this.annoChanInfo.READONLY == 1
            %    warning('OCP:ReadOnlyAnno','The current Annotation DB Token is for a READ ONLY database.');
            %end
            
            
        end
        function token = getAnnoToken(this)
            % This method gets the anno database token to be used
            
            token = this.annoToken;
        end
        
        function setAnnoChannel(this, channel)
            % This method sets the annotation database channel to be used
            
            this.annoChannel = [];
            this.annoChanInfo = [];
            
            if numel(this.annoToken) == 0
                ex = MException('OCP:NoAnnoToken','Cannot set AnnoChannel without first setting AnnoToken.');
                throw(ex);  
            end
            channelNames = fieldnames(this.annoInfo.CHANNELS);
            for i = 1:numel(channelNames)
                if strcmpi(channelNames{i}, channel) == 1
                    this.annoChannel = channel; 
                    this.annoChanInfo = this.annoInfo.CHANNELS.(channel);
                    break;
                end
            end 
            
            if numel(this.annoChannel) == 0
                ex = MException('OCP:InvalidAnnoChannel','AnnoChannel does not exist for this token.');
                throw(ex)
            end
            
        end
        function channel = getAnnoChannel(this)
            % This method gets the annotation database channel to be used
            channel = this.annoChannel;
        end
        function PrintAnnoChannels(this)
           % List all anno channels for a particular token. 
           % AB TODO 
        end
        
        function this = setImageTokenFile(this,file)
            % This method loads a token file and sets the image token
            
            if ~exist('file','var')
                [filename, pathname, ~] = uigetfile( ...
                    {  '*.token','Token (*.token)'}, ...
                    'Pick a Token File', ...
                    'MultiSelect', 'off');
                
                if isequal(filename,0)
                    warning('OCP:FileSelectionCancel','No file was selected.  Token not opened.');
                    return;
                end
                
                file = fullfile(pathname,filename);
            end
            
            % Read file
            fid = fopen(file,'r');
            tline = fgetl(fid);
            fclose(fid);
            
            % Set Token
            this.setImageToken(tline);
        end
        
        function this = setAnnoTokenFile(this,file)
            % This method loads a token file and sets the anno token
            
            if ~exist('file','var')
                [filename, pathname, ~] = uigetfile( ...
                    {  '*.token','Token (*.token)'}, ...
                    'Pick a Token File', ...
                    'MultiSelect', 'off');
                
                if isequal(filename,0)
                    warning('OCP:FileSelectionCancel','No file was selected.  Token not opened.');
                    return;
                end
                
                file = fullfile(pathname,filename);
            end
            
            % Read file
            fid = fopen(file,'r');
            tline = fgetl(fid);
            fclose(fid);
            
            % Set Token
            this.setAnnoToken(tline);
        end
        
        function url = getLastUrl(this)
            % Method to retreive the last URL that was used.  Useful for
            % developers.
            url = this.lastUrl;
        end
        
        function file = getLastHDF5(this)
            % Method to retreive the last HDF5 file that was used
            file = this.lastHdfFile;
        end
        
        %% Methods - Query
        function response = query(this, qObj)
            % This method builds a query and executes it based on the
            % supplied queryObj
            
            if nargin ~= 2
                ex = MException('OCP:ArgError','Incorrect Number of Arguments');
                throw(ex);
            end
            
            
            % Based on Query Type get what yo need!
            switch qObj.type
                case eOCPQueryType.imageDense
                    % If resolution isn't set Set Default and warn.
                    if isempty(qObj.resolution)
                        if isempty(this.defaultResolution)
                            error('OCP:MissingDefaultResolution',...
                                'The provided query is missing the resolution property.  The default resolution has not been set in this OCP object.  Cannot Query Database.');
                        end
                        
                        qObj.setResolution(this.defaultResolution);    
                        warning('OCP:QueryResolutionEmpty',...
                            'Resolution empty in query.  Default value of %d used. Turn off "OCP:QueryResolutionEmpty" to suppress',this.defaultResolution);
                    end
                    
                    % If imageToken hasn't been set stop
                    if isempty(this.imageToken)
                        ex = MException('OCP:MissingImageToken',...
                            'You must specify the image database to read from by setting the "imageToken" property. ');
                        throw(ex);
                    end
                    
                    % If imageChannel hasn't been set throw a warning
                    if isempty(this.imageChannel)
                        warning('OCP:NoImageChannel','Missing image channel. Query failure or unexpected results may occur');
                    end
                    
                    % Verify query
                    [tf, msg] = qObj.validate(this.imageInfo);
                    if tf == 0
                        ex = MException('OCP:BadQuery',sprintf('Query Validation Failed: \n%s',msg));
                        throw(ex);
                    end
                    
                    % Build URL
                    url = this.buildCutoutUrl(qObj);
                    this.lastUrl = url;
                    % Query DB and get HDF5 File
                    hdfFile = OCPHdf(this.net.readCached(url),qObj);
                    this.lastHdfFile = hdfFile.filename;
                    % Convert to RAMONVolume 
                    response = hdfFile.toRAMONVolume(this.imageChannel);
                    % Set dataType
                    if isa(response, 'cell')
                        % multichannel cutout
                        for kk = 1:length(response)
                            response{kk}.setDataType(this.imageChanInfo.TYPE);
                        end
                    else
                        % normal
                        response.setDataType(this.imageChanInfo.DATATYPE);
                        response.setChannelType(this.imageChanInfo.TYPE);
                    end
                    
                case eOCPQueryType.imageSlice
                    % AB TODO match above after testing 
                    % If resolution isn't set Set Default and warn.
                    if isempty(qObj.resolution)
                        if isempty(this.defaultResolution)
                            error('OCP:MissingDefaultResolution',...
                                'The provided query is missing the resolution property.  The default resolution has not been set in this OCP object.  Cannot Query Database.');
                        end
                        
                        qObj.setResolution(this.defaultResolution);
                        warning('OCP:QueryResolutionEmpty',...
                            'Resolution empty in query.  Default value of %d used. Turn off "OCP:QueryResolutionEmpty" to suppress',this.defaultResolution);
                    end
                    
                    % If annoToken hasn't been set stop
                    if isempty(this.imageToken)
                        ex = MException('OCP:MissingImageToken',...
                            'You must specify the image database to read from by setting the "imageToken" property. ');
                        throw(ex);
                    end
                    
                    % Verify query
                    [tf, msg] = qObj.validate(this.imageInfo);
                    if tf == 0
                        ex = MException('OCP:BadQuery',sprintf('Query Validation Failed: \n%s',msg));
                        throw(ex);
                    end
                    % Build URL
                    url = this.buildSliceUrl(qObj);
                    % Query DB and get png File back
                    response = this.net.queryImage(url);
                    
                    
                case {eOCPQueryType.annoDense, eOCPQueryType.probDense}
                    % If resolution isn't set Set Default and warn.
                    if isempty(qObj.resolution)
                        if isempty(this.defaultResolution)
                            error('OCP:MissingDefaultResolution',...
                                'The provided query is missing the resolution property.  The default resolution has not been set in this OCP object.  Cannot Query Database.');
                        end
                        
                        qObj.setResolution(this.defaultResolution);
                        warning('OCP:QueryResolutionEmpty',...
                            'Resolution empty in query.  Default value of %d used. Turn off "OCP:QueryResolutionEmpty" to suppress',this.defaultResolution);
                    end
                    
                    % If annoToken hasn't been set see if image token is
                    % there
                    if isempty(this.annoToken)
                        if ~isempty(this.imageToken)
                            % Warn and use the image token for the anno
                            % token
                            warning('OCP:MissingAnnoToken','The Annotation Token has not been set.  Using Image Token as Annotation Token.');
                            this.setAnnoToken(this.getImageToken());
                            
                            % check for an image channel
                            % If imageChannel hasn't been set throw a warning
                            if isempty(this.imageChannel)
                                warning('OCP:NoImageChannel','Missing image channel. Query failure or unexpected results may occur');
                            else
                                this.setAnnoChannel(this.getImageChannel());
                            end
                            
                        else
                            % There isn't a token. 
                            ex = MException('OCP:MissingAnnoToken',...
                            'You must specify the annotation database to read from by setting the "annoToken" property.');
                            throw(ex);
                        end
                    end
                    
                    % If annoChannel hasn't been set throw a warning
                    if isempty(this.annoChannel)
                        warning('OCP:NoAnnoChannel','Missing anno channel. Query failure or unexpected results may occur');
                    end
                    
                    % Verify query
                    [tf, msg] = qObj.validate(this.annoInfo);
                    if tf == 0
                        ex = MException('OCP:BadQuery',sprintf('Query Validation Failed: \n%s',msg));
                        throw(ex);
                    end
                    % Build URL
                    url = this.buildCutoutUrl(qObj);
                    this.lastUrl = url;
                    % Query DB and get HDF5 File
                    hdfFile = OCPHdf(this.net.read(url),qObj);
                    this.lastHdfFile = hdfFile.filename;
                    % Convert to RAMONVolume
                    response = hdfFile.toRAMONVolume(this.annoChannel());
                    % Set DBType
                    response.setChannelType(this.annoChanInfo.TYPE{1});
                    % set DataType
                    response.setDataType(this.annoChanInfo.DATATYPE{1});
                    
                    
                case eOCPQueryType.annoSlice
                    % If resolution isn't set Set Default and warn.
                    if isempty(qObj.resolution)                        
                        if isempty(this.defaultResolution)
                            error('OCP:MissingDefaultResolution',...
                                'The provided query is missing the resolution property.  The default resolution has not been set in this OCP object.  Cannot Query Database.');
                        end
                        
                        qObj.setResolution(this.defaultResolution);
                        warning('OCP:QueryResolutionEmpty',...
                            'Resolution empty in query.  Default value of %d used. Turn off "OCP:QueryResolutionEmpty" to suppress',this.defaultResolution);
                    end
                    
                    % If annoToken hasn't been set stop
                    if isempty(this.annoToken)
                        ex = MException('OCP:MissingAnnoToken',...
                            'You must specify the annotation database to read from by setting the "annoToken" property. ');
                        throw(ex);
                    end
                    
                    % Verify query
                    [tf, msg] = qObj.validate(this.annoInfo);
                    if tf == 0
                        ex = MException('OCP:BadQuery',sprintf('Query Validation Failed: \n%s',msg));
                        throw(ex);
                    end
                    % Build URL
                    url = this.buildSliceUrl(qObj);
                    this.lastUrl = url;
                    % Query DB and get png File back
                    response = this.net.queryImage(url);
                    
                case eOCPQueryType.overlaySlice
                    % If resolution isn't set Set Default and warn.
                    if isempty(qObj.resolution)
                        if isempty(this.defaultResolution)
                            error('OCP:MissingDefaultResolution',...
                                'The provided query is missing the resolution property.  The default resolution has not been set in this OCP object.  Cannot Query Database.');
                        end
                        
                        qObj.setResolution(this.defaultResolution);
                        warning('OCP:QueryResolutionEmpty',...
                            'Resolution empty in query.  Default value of %d used. Turn off "OCP:QueryResolutionEmpty" to suppress',this.defaultResolution);
                    end
                    
                    % If annoToken hasn't been set stop
                    if isempty(this.annoToken)
                        ex = MException('OCP:MissingAnnoToken',...
                            'You must specify the annotation database to read from by setting the "annoToken" property. ');
                        throw(ex);
                    end
                    
                    % Verify query
                    [tf, msg] = qObj.validate(this.annoInfo);
                    if tf == 0
                        ex = MException('OCP:BadQuery',sprintf('Query Validation Failed: \n%s',msg));
                        throw(ex);
                    end
                    % Build URL
                    url = this.buildOverlayUrl(qObj);
                    this.lastUrl = url;
                    % Query DB and get png File back
                    response = this.net.queryImage(url);
                    
                case {eOCPQueryType.RAMONDense,eOCPQueryType.RAMONVoxelList}
                    % If resolution isn't set Set Default and warn.
                    if isempty(qObj.resolution)
                        if isempty(this.defaultResolution)
                            error('OCP:MissingDefaultResolution',...
                                'The provided query is missing the resolution property.  The default resolution has not been set in this OCP object.  Cannot Query Database.');
                        end
                        
                        qObj.setResolution(this.defaultResolution);
                        warning('OCP:QueryResolutionEmpty',...
                            'Resolution empty in query.  Default value of %d used. Turn off "OCP:QueryResolutionEmpty" to suppress',this.defaultResolution);
                    end
                    
                    % If annoToken hasn't been set stop
                    if isempty(this.annoToken)
                        ex = MException('OCP:MissingAnnoToken',...
                            'You must specify the annotation database to read from by setting the "annoToken" property. ');
                        throw(ex);
                    end
                    
                    % Verify query
                    [tf, msg] = qObj.validate(this.annoInfo);
                    if tf == 0
                        ex = MException('OCP:BadQuery',sprintf('Query Validation Failed: \n%s',msg));
                        throw(ex);
                    end
                    % Build URL
                    url = this.buildRAMONUrl(qObj);
                    this.lastUrl = url;
                    % Query DB and get HDF5 File
                    hdfFile = OCPHdf(this.net.read(url));
                    this.lastHdfFile = hdfFile.filename;
                    % Convert to RAMON Object based on what comes back
                    response = hdfFile.toRAMONObject(qObj);
                    % Set dataType (support batch interface)
                    if iscell(response) == 1
                        for ii = 1:length(response)
                            response{ii}.setDataType(this.annoChanInfo.DATATYPE);
                        end
                    else
                        response.setDataType(this.annoChanInfo.DATATYPE);
                    end
                    
                case eOCPQueryType.RAMONMetaOnly
                    % Verify query
                    [tf, msg] = qObj.validate(this.annoInfo);
                    if tf == 0
                        ex = MException('OCP:BadQuery',sprintf('Query Validation Failed: \n%s',msg));
                        throw(ex);
                    end
                    
                    % If annoToken hasn't been set stop
                    if isempty(this.annoToken)
                        ex = MException('OCP:MissingAnnoToken',...
                            'You must specify the annotation database to read from by setting the "annoToken" property. ');
                        throw(ex);
                    end
                    
                    % Build URL
                    url = this.buildRAMONUrl(qObj);
                    this.lastUrl = url;
                    % Query DB and get HDF5 File
                    hdfFile = OCPHdf(this.net.read(url));
                    this.lastHdfFile = hdfFile.filename;
                    % Convert to RAMON Object based on what comes back
                    response = hdfFile.toRAMONObject(qObj);
                    
                    
                case eOCPQueryType.RAMONBoundingBox
                    % If resolution isn't set Set Default and warn.
                    if isempty(qObj.resolution)
                        if isempty(this.defaultResolution)
                            error('OCP:MissingDefaultResolution',...
                                'The provided query is missing the resolution property.  The default resolution has not been set in this OCP object.  Cannot Query Database.');
                        end
                        
                        qObj.setResolution(this.defaultResolution);
                        warning('OCP:QueryResolutionEmpty',...
                            'Resolution empty in query.  Default value of %d used. Turn off "OCP:QueryResolutionEmpty" to suppress',this.defaultResolution);
                    end
                    
                    % If annoToken hasn't been set stop
                    if isempty(this.annoToken)
                        ex = MException('OCP:MissingAnnoToken',...
                            'You must specify the annotation database to read from by setting the "annoToken" property. ');
                        throw(ex);
                    end
                    
                    % Verify query
                    [tf, msg] = qObj.validate(this.annoInfo);
                    if tf == 0
                        ex = MException('OCP:BadQuery',sprintf('Query Validation Failed: \n%s',msg));
                        throw(ex);
                    end
                    
                    % Build URL
                    url = this.buildRAMONUrl(qObj);
                    this.lastUrl = url;
                    % Query DB and get HDF5 File
                    hdfFile = OCPHdf(this.net.read(url));
                    this.lastHdfFile = hdfFile.filename;
                    % Convert to RAMON Object based on what comes back
                    response = hdfFile.toRAMONObject(qObj);
                    
                    
                case eOCPQueryType.RAMONIdList
                    
                    % If doing a cutout and resolution isn't set Set Default and warn.
                    if ~isempty(qObj.xRange) && ~isempty(qObj.yRange) && ~isempty(qObj.zRange)
                        if isempty(qObj.resolution)                            
                            if isempty(this.defaultResolution)
                                error('OCP:MissingDefaultResolution',...
                                    'The provided query is missing the resolution property.  The default resolution has not been set in this OCP object.  Cannot Query Database.');
                            end

                            qObj.setResolution(this.defaultResolution);
                            warning('OCP:QueryResolutionEmpty',...
                                'Resolution empty in query.  Default value of %d used. Turn off "OCP:QueryResolutionEmpty" to suppress',this.defaultResolution);
                        end
                    end
                    
                    % If annoToken hasn't been set stop
                    if isempty(this.annoToken)
                        ex = MException('OCP:MissingAnnoToken',...
                            'You must specify the annotation database to read from by setting the "annoToken" property. ');
                        throw(ex);
                    end
                    
                    % Verify query
                    [tf, msg] = qObj.validate(this.annoInfo);
                    if tf == 0
                        ex = MException('OCP:BadQuery',sprintf('Query Validation Failed: \n%s',msg));
                        throw(ex);
                    end
                    % Build URL
                    url = this.buildRAMONIdUrl(qObj);
                    this.lastUrl = url;
                    
                    % Build HDF5 if needed
                    if isempty(qObj.xRange) && isempty(qObj.yRange) && isempty(qObj.zRange)
                        % no cutout restriction
                        % Query DB and get HDF5 File
                        hdfFile = OCPHdf(this.net.read(url));
                        this.lastHdfFile = hdfFile.filename;
                        
                    elseif ~isempty(qObj.xRange) && ~isempty(qObj.yRange)...
                            && ~isempty(qObj.zRange) && ~isempty(qObj.resolution)
                        % cutout Restriction
                        hdfCutoutFile = OCPHdf(qObj);
                        hdfCutoutFile.toCutoutHDF();
                        
                        % Query DB and get HDF5 File
                        hdfFile = OCPHdf(this.net.read(url,hdfCutoutFile.filename));
                        this.lastHdfFile = hdfFile.filename;
                        
                    else
                        ex = MException('OCP:MalformedQuery','Cannot build URL.  Either set or clear cutout args.');
                        throw(ex);
                    end
                    
                    % Convert to a vector
                    response = hdfFile.toMatrix();
                    
                case eOCPQueryType.voxelId
                    % If resolution isn't set Set Default and warn.
                    if isempty(qObj.resolution)
                        if isempty(this.defaultResolution)
                            error('OCP:MissingDefaultResolution',...
                                'The provided query is missing the resolution property.  The default resolution has not been set in this OCP object.  Cannot Query Database.');
                        end
                        
                        qObj.setResolution(this.defaultResolution);
                        warning('OCP:QueryResolutionEmpty',...
                            'Resolution empty in query.  Default value of %d used. Turn off "OCP:QueryResolutionEmpty" to suppress',this.defaultResolution);
                    end
                    
                    % Verify query
                    [tf, msg] = qObj.validate(this.annoInfo);
                    if tf == 0
                        ex = MException('OCP:BadQuery',sprintf('Query Validation Failed: \n%s',msg));
                        throw(ex);
                    end
                    
                    % If annoToken hasn't been set stop
                    if isempty(this.annoToken)
                        ex = MException('OCP:MissingAnnoToken',...
                            'You must specify the annotation database to read from by setting the "annoToken" property. ');
                        throw(ex);
                    end
                    
                    % Build URL
                    url = this.buildXyzVoxelIdUrl(qObj);
                    this.lastUrl = url;
                    
                    % Query
                    hdfResponse = OCPHdf(this.net.read(url));
                    response = str2double(hdfResponse.filename);
                    
                otherwise
                    ex = MException('OCP:InvalidQuery','Invalid Query Type');
                    throw(ex);
            end
            
            % Save query
            this.lastQuery = qObj;
        end
        
        %% Methods - Single slice
        function slice = nextSlice(this)
            % This method increments cIndex by 1 and returns an image
            % The last query MUST have been a slice query for this to work
            slice = [];
            qObj = this.lastQuery;
            
            if ~isempty(qObj)
                if qObj.type == eOCPQueryType.annoSlice || ...
                        qObj.type == eOCPQueryType.imageSlice || ...
                        qObj.type == eOCPQueryType.overlaySlice
                    % You are good to go
                    
                    % Verify query
                    qObj.setCIndex(qObj.cIndex + 1);
                    [tf, msg] = qObj.validate(this.annoInfo);
                    if tf == 0
                        ex = MException('OCP:BadQuery',sprintf('Query Validation Failed: \n%s',msg));
                        throw(ex);
                    end
                    % Build URL
                    url = this.buildSliceUrl(qObj);
                    this.lastUrl = url;
                    % Query DB and get png File back
                    slice = this.net.queryImage(url);
                else
                    warning('OCP:MissingInitQuery','You must run a full slice query before using next/previous methods.');
                end
            else
                warning('OCP:MissingInitQuery','You must run a full slice query before using next/previous methods.');
            end
        end
        
        
        function slice = previousSlice(this)
            % This method decrements cIndex by 1 and returns an image
            % The last query MUST have been a slice query for this to work
            slice = [];
            qObj = this.lastQuery;
            
            if ~isempty(qObj)
                if qObj.type == eOCPQueryType.annoSlice || ...
                        qObj.type == eOCPQueryType.imageSlice || ...
                        qObj.type == eOCPQueryType.overlaySlice
                    % You are good to go
                    
                    % Verify query
                    qObj.setCIndex(qObj.cIndex - 1);
                    [tf, msg] = qObj.validate(this.annoInfo);
                    if tf == 0
                        ex = MException('OCP:BadQuery',sprintf('Query Validation Failed: \n%s',msg));
                        throw(ex);
                    end
                    % Build URL
                    url = this.buildSliceUrl(qObj);
                    this.lastUrl = url;
                    % Query DB and get png File back
                    slice = this.net.queryImage(url);
                else
                    warning('OCP:MissingInitQuery','You must run a full slice query before using next/previous methods.');
                end
            else
                warning('OCP:MissingInitQuery','You must run a full slice query before using next/previous methods.');
            end
        end
        
        %% Methods - Image Data Upload
        function uploadImageData(this, ramonObj, conflictOption)
            % This method writes image data to the database
            % specified by imageToken.
            %
            % You can also optionally specify the conflict option
            % (overwrite OR preserve) by passing in your choice
            % via the eOCPConflictOption enum. If omitted default is overwrite.
            %
            % ex: oo.uploadImageData(myData,eOCPConflicOption.preserve);
            %
            
            % TODO: Service should be able to propagate image8 data.
%             if (this.getImagePropagateStatus() ~= eOCPPropagateStatus.inconsistent)
%                 ex = MException('OCP:DbLocked',...
%                     'Image DB is locked due to propagation. Must wait for db to be consistent, then make writable');
%                 throw(ex);
%             end
            
            % Set default conflict option default (overwrite) if needed
            if ~exist('conflictOption','var')
                conflictOption = eOCPConflictOption.overwrite;
            else
                if conflictOption == eOCPConflictOption.exception || ...
                    conflictOption == eOCPConflictOption.reduce
                    ex = MException('OCP:InvalidConflictOpt',...
                    'When uploading Image Data you must use overwrite or preserve');
                    throw(ex);
                end
            end
                      
            % If imageToken hasn't been set stop
            if isempty(this.imageToken)
                ex = MException('OCP:MissingImageToken',...
                    'You must specify the image database to write to by setting the "imageToken" property. ');
                throw(ex);
            end
            
            % If the imageChannel hasn't been set stop
            if isempty(this.imageChannel)
                ex = MException('OCP:MissingImageChannel',...
                    'You must specify the image database to write to by setting both the "imageToken" and "imageChannel" properties.');
                throw(ex);
            end
            
            % Make sure you are writing to a database that is properly
            % setup for image upload
            if this.imageChanInfo.EXCEPTIONS == 1
                warning('OCP:ProjectOpts','Exceptions are enabled for the image database. This is non-optimal and unnessary for image data databases');
            end
            
            % Make sure you are writing to an Image datatype
            imgDataType = this.imageChanInfo.DATATYPE{1};
            if eRAMONChannelDataType.(imgDataType) ~= eRAMONChannelDataType.uint8 && ...
                    eRAMONChannelDataType.(imgDataType) ~= eRAMONChannelDataType.uint16           
                ex = MException('OCP:ProjectOpts',...
                    'The current imageToken is for a non-grayscale datatype database.  Only grayscale 8 or 16bit is supported. Contact OCP support of uploading multichannel data');
                throw(ex);
            end
            
            % Make sure this is an image channel type.
            imgChannelType = this.imageChanInfo.TYPE{1};
            if eRAMONChannelType.(imgChannelType) ~= eRAMONChannelType.image
                ex = Exception('OCP:ProjectOpts',...
                    'The current imageToken is not for an image database!');
                throw(ex);
            end
            
            % Make sure you have a RAMON volume and not something else
            if strcmpi(class(ramonObj),'RAMONVolume') == false
                ex = MException('OCP:InvalidClassType',...
                'To upload image data, please provide a RAMONVolume object');
                throw(ex);
            end
                       
            % Check for chunking
            if ramonObj.voxelCount() > this.maxAnnoSize
                % Block style upload
                if ramonObj.voxelCount() > this.maxAnnoSize * 10
                    warning('OCP:LargeUpload','The RAMONVolume is very large and will be chunked.  Write may take a long time depending on internet speed.');
                end
                
                  % Set datatype to that of the database
                ramonObj.setDataType(eRAMONDataType(this.imageChanInfo.TYPE));
                
                % Compute chunked blocks by slice to make it easy for now.
                % TODO: make this smarter if needed to deal with massive
                % single slices
                dims = size(ramonObj);
                slices_per_upload = floor(this.maxAnnoSize/(dims(1)*dims(2)));
                slices_per_upload = max(slices_per_upload,1);
                
                % Create temp ramon volume for chunks
                temp_vol = RAMONVolume();
                temp_vol.setResolution(ramonObj.resolution);
                temp_vol.setDataType(ramonObj.dataType);
                
                zstart = 1;
                zend = zstart + slices_per_upload - 1;
                
                while zend <= dims(3)
                    % Set data
                    temp_vol.setCutout(ramonObj.data(:,:,zstart:zend));
                    
                    % Set xyz offset
                    temp_vol.setXyzOffset([ramonObj.xyzOffset(1),ramonObj.xyzOffset(2),...
                        ramonObj.xyzOffset(3) + zstart - 1]);
                    
                    % post                    
                    this.writeBlockImageData(ramonObj, conflictOption)
                    
                    zstart = zend + 1;
                    zend = zstart + slices_per_upload - 1;
                end
                
                % Check if you have "remainder" slices
                if zend ~= dims(3)
                    % Set data
                    temp_vol.setCutout(ramonObj.data(:,:,zstart:end));
                    
                    % Set xyz offset
                    temp_vol.setXyzOffset([ramonObj.xyzOffset(1),ramonObj.xyzOffset(2),...
                        ramonObj.xyzOffset(3) + zstart - 1]);
                    
                    % post                    
                    this.writeBlockImageData(ramonObj, conflictOption)                    
                end
            else     
                % Set datatype to that of the database
                imageDataType = this.imageChanInfo.DATATYPE{1};
                ramonObj.setDataType(eRAMONChannelDataType.(imageDataType));

                % Block style upload
                this.writeBlockImageData(ramonObj, conflictOption)        
            end             
        end
        
        %% Methods - RAMON - Create
        function id = createAnnotation(this, ramonObj, conflictOption)
            % This method adds a new RAMON annotation to the database
            % specified by annoToken.
            %
            % It supports the batch interface by passing in a cell array of
            % RAMON objects instead of a single RAMON Object.
            %
            % You can also optionally specify the conflict option
            % (overwrite, preserve, exception) by passing in your choice
            % via the eOCPConflictOption enum. If omitted default is overwrite.
            %
            % ex: id = createAnnotation(myObjects,eOCPConflicOption.overwrite);
            %
            
            % If annoToken hasn't been set stop
            if isempty(this.annoToken)
                ex = MException('OCP:MissingAnnoToken',...
                    'You must specify the annotation database token to write to by setting the "annoToken" property. ');
                throw(ex);
            end
            
            % If annoChannel hasn't been set stop (we need channel
            % information)
            if isempty(this.annoChannel)
                ex = MException('OCP:MissingAnnoChannel',...
                    'You must specify an annotation database channel to write to by setting the "annoChannel" property. ');
                throw(ex);
            end
            
            % Set the DataType and ChannelType for the ramonObj based on
            % the channel info (this.annoChanInfo)
            chanDataType = this.annoChanInfo.DATATYPE{1};
            ramonObj.setDataType(eRAMONChannelDataType.(chanDataType));
            
            chanType = this.annoChanInfo.TYPE{1};
            ramonObj.setChannelType(eRAMONChannelType.(chanType));
            
            
            % Make sure you can write to db
            % TODO: For now this is only for anno32 and anno64 type
            % databases
            if (ramonObj.channelType == eRAMONChannelType.annotation)
                if (this.getAnnoPropagateStatus() ~= eOCPPropagateStatus.inconsistent)
                    ex = MException('OCP:DbLocked',...
                        'Annotation DB is locked due to propagation. Must wait for db to be consistent, then make writable');
                    throw(ex);
                end
            end
            
            % Set default conflict option default (overwrite) if needed
            if ~exist('conflictOption','var')
                conflictOption = eOCPConflictOption.overwrite;
            end
                   
            
            % Build upload job based on input.  If a cell array of
            % RAMONObjects then you must build batches based on
            % this.batchSize.  If any annotation is larger than
            % this.maxAnnoSize then it must be broken up into pieces to
            % make http requests resonable in size and safe to pass through most
            % networks without trouble
            
            if isa(ramonObj,'cell')
                % Batch upload requested - build batch index while checking
                % for big annotations that need chunked
                
                if strcmpi(class(ramonObj),'RAMONVolume')
                    error('OCP:NotSupported','Batch uploading of block style uploads is not supported.');
                end
                
                [batchIndex, chunkIndex] = this.createAnnoBatches(ramonObj);
                                
                % Upload Batches
                batchIds = [];
                for ii = 1:size(batchIndex,1)
                    % Set datatype
                    ramonObj_batch = this.checkSetDataType(ramonObj(batchIndex{ii}));
                    
                    batchIds = cat(2,batchIds,...
                        this.writeRamonObject(ramonObj_batch,false,conflictOption));
                end
                
                % If required chunk annotations and upload
                chunkIds = [];
                if ~isempty(chunkIndex)
                    chunkCollections = this.createAnnoChunks(ramonObj(chunkIndex));
                    
                    % Set datatype
                    chunkCollections = this.checkSetDataType(chunkCollections);
                                        
                    chunkIds = this.writeRamonChunks(chunkCollections,false,conflictOption);                    
                end
                
                % Finalize output
                id = zeros(1,length(batchIds) + length(chunkIds));
                batchIndexCat = [];
                for ii = 1:size(batchIndex,1)
                    batchIndexCat = cat(2,batchIndexCat,batchIndex{ii});
                end
                id(batchIndexCat) = batchIds;
                id(chunkIndex) = chunkIds;                
            else
                % Check for chunking
                if ramonObj.voxelCount() > this.maxAnnoSize
                    if strcmpi(class(ramonObj),'RAMONVolume')
                        % Block style upload
                        if ramonObj.voxelCount() > this.maxAnnoSize * 10
                            warning('OCP:LargeUpload','The RAMONVolume is VERY large and will be chunked.  Write may take a long time.');
                        end
                        
                        % Set datatype
                        ramonObj = this.checkSetDataType(ramonObj);
                    
                        this.writeBlockData(ramonObj, conflictOption)
                        id = [];
                    else
                        % Chunk it up                    
                        chunkCollection = this.createAnnoChunks(ramonObj);
                        
                        % Set datatype
                        chunkCollection = this.checkSetDataType(chunkCollection);

                        % Upload the chunked annotation
                        id = this.writeRamonChunks(chunkCollection,false,conflictOption);
                    end
                else                    
                    % Single annotation to upload
                    if strcmpi(class(ramonObj),'RAMONVolume')
                        % Set datatype
                        ramonObj = this.checkSetDataType(ramonObj);
                        
                        % Block style upload
                        this.writeBlockData(ramonObj, conflictOption)
                        id = [];
                    else
                        % Set datatype
                        ramonObj = this.checkSetDataType(ramonObj);
                        
                        % Standard RAMON Object upload
                        id = this.writeRamonObject(ramonObj, false, conflictOption);  
                    end
                end
            end
        end
        
        %% Methods - RAMON - Update
        function id = updateAnnotation(this, ramonObj, conflictOption)            
            % This method updates a RAMON annotation to the database
            % specified by annoToken.
            %
            % It supports the batch interface by passing in a cell array of
            % RAMON objects instead of a single RAMON Object.
            %
            % You can also optionally specify the conflict option
            % (overwrite, preserve, exception) by passing in your choice
            % via the eOCPConflictOption enum. If omitted default is overwrite.
            %
            
            % Set default conflict option default (overwrite) if needed
            if ~exist('conflictOption','var')
                conflictOption = eOCPConflictOption.overwrite;
            end
                      
            % If annoToken hasn't been set stop
            if isempty(this.annoToken)
                ex = MException('OCP:MissingAnnoToken',...
                    'You must specify the annotation database to write to by setting the "annoToken" property. ');
                throw(ex);
            end            
            
            % Build upload job based on input.  If a cell array of
            % RAMONObjects then you must build batches based on
            % this.batchSize.  If any annotation is larger than
            % this.maxAnnoSize then it must be broken up into pieces to
            % make http requests resonable in size and safe to pass through most
            % networks without trouble
            
            if isa(ramonObj,'cell')
                % Batch upload requested - build batch index while checking
                % for big annotations that need chunked
                
                if strcmpi(class(ramonObj{1}),'RAMONVolume')
                    error('OCP:NotSupported','Updating of block style uploads is not supported. Create annotation with the appropriate conflict options');
                end
                
                [batchIndex, chunkIndex] = this.createAnnoBatches(ramonObj);
                                
                % Upload Batches
                batchIds = [];
                for ii = 1:size(batchIndex,1)
                    batchIds = cat(2,batchIds,...
                        this.writeRamonObject(ramonObj(batchIndex{ii}),true,conflictOption));
                end
                
                % If required chunk annotations and upload
                chunkIds = [];
                if ~isempty(chunkIndex)
                    chunkCollections = this.createAnnoChunks(ramonObj(chunkIndex));
                    
                    for ii = 1:size(chunkCollections)
                        chunkIds = cat(2, chunkIds,...
                            this.writeRamonChunks(chunkCollections,true,conflictOption));
                    end
                end
                
                % Finalize output
                id = cat(2,batchIds,chunkIds);
                
            else
                if strcmpi(class(ramonObj),'RAMONVolume')
                    error('OCP:NotSupported','Updating of block style uploads is not supported. Create annotation with the appropriate conflict options');
                end
                
                % Check for chunking
                if ramonObj.voxelCount() > this.maxAnnoSize
                    % Chunk it up                    
                    chunkCollection = this.createAnnoChunks(ramonObj);
                    
                    % Upload the chunked annotation
                    id = this.writeRamonChunks(chunkCollection,true,conflictOption);
                else                    
                    % Single annotation to upload
                    id = this.writeRamonObject(ramonObj, true, conflictOption);                    
                end
            end
        end
        
        %% Methods - RAMON - Delete
        function response = deleteAnnotation(this, id)
            % This method deletes an exisiting RAMON Annotation in the
            % database specified by annotationToken and id
            
            % If annoToken hasn't been set stop
            if isempty(this.annoToken)
                ex = MException('OCP:MissingAnnoToken',...
                    'You must specify the annotation database to write to by setting the "annoToken" property. ');
                throw(ex);
            end
            
            % If in batch mode build id string
            if length(id) > 1
                idStr = sprintf('%d,',id);
                idStr(end) = [];
            else
                idStr = sprintf('%d',id);
            end
            
            % Send DELETE request
            urlStr = sprintf('%s/ocp/ocpca/%s/%s/%s/',this.serverLocation,this.annoToken,this.annoChannel,idStr);
            this.lastUrl = urlStr;
            response = this.net.deleteRequest(urlStr);
        end
        
         %% Methods - RAMON - Merge
        function response = mergeAnnotation(this, parent, children)
            % This method merges an 1xn vector of exisiting RAMON
            % Annotations (children) into the parent annotation in the
            % database indicated by annoToken AT THE DEFAULT RESOLUTION
            
            % If annoToken hasn't been set stop
            if isempty(this.annoToken)
                ex = MException('OCP:MissingAnnoToken',...
                    'You must specify the annotation database to write to by setting the "annoToken" property. ');
                throw(ex);
            end
            
            % build id string
            merge_str = num2str(parent);
            merge_str = [merge_str sprintf(',%d',children)];          

            % Send request
            urlStr = sprintf('%s/ocp/ca/%s/merge/%s/global/%d/',this.serverLocation,this.annoToken,merge_str,this.defaultResolution);
            this.lastUrl = urlStr;
            response = this.net.read(urlStr);
        end
        
        %% Methods - RAMON - Get/Set
        function setField(this, id, field, value)
            % This method sets an individual field of an annotation based
            % on the provided annotation id and field name and value.  Use OCPFields
            % to get the proper translation from RAMON api names to server.
            % 
            % NOTE: Only single value fields are currently supported
            %
            % ex: f = OCPFields;
            %     val = oo.setField(2834,f.synapse.synapseType,eRAMONSynapseType.excitatory);
            %     val = oo.getField(2834,'author','my_username');
            
            % Build URL
            url = this.buildSetFieldURL(id,field,value);
            this.lastUrl = url;            
            
            % Call URL
            this.net.read(url);   
        end
        
        
        function value = getField(this, id, field)
            % This method gets an individual field from an annotation based
            % on the provided annotation id and field name.  Use OCPFields
            % to get the proper translation from RAMON api names to server
            % names.
            % ex: f = OCPFields;
            %     val = oo.getField(2834,f.synapse.synapseType);
            %     val = oo.getField(2834,'author');
            
            % Build URL
            url = sprintf('%s/ocp/ocpca/%s/%s/%d/getField/%s/',this.serverLocation,this.annoToken,this.annoChannel,id,field);
            this.lastUrl = url;            
            
            % Call URL
            response = this.net.read(url);
            
            % Parse response
            value = this.getFieldParser(response,field);
        end
        
        
        %% Methods - Database Info Query
        function info = queryDBInfo(this,token)
            % This method queries the "projinfo" service with a token and
            % returns information about that database.  The return
            % structure is:
            %
            % info.CHANNELS
            %   <<CHAN_NAME>>
            %       DATATYPE
            %       NAME
            %       PROPAGATE
            %       RESOLUTION
            %       TYPE
            %       WINDOWRANGE
            % info.PROJECT
            %   HOST
            %   NAME
            %   OCP_VERSION
            %   SCHEMA_VERSION
            % info.DATASET
            %   CUBE_DIMENSION
            %   IMAGE_SIZE
            %   NAME 
            %   OFFSET
            %   RESOLUTIONS
            %   TIMERANGE
            %   VOXELRES
            
            url = sprintf('%s/ocp/ocpca/%s/projinfo/',this.serverLocation,token);
            this.lastUrl = url;
            
            % Query DB for hdf5 file
            hdfFile = this.net.read(url);
            
            % Load into struct
            ocpH5 = OCPHdf(hdfFile);
            info = ocpH5.toStruct();
        end
        
        %% Methods - ID Reservation
        function ids = reserve_ids(this, num_ids)
            % This method requests a contiguous batch of IDs from the OCP
            % database for use during uploading. You must manually set your
            % RAMON object ids, but this helps speed up big batch writes
            
            % Check num_ids
            validateattributes(num_ids,{'numeric'},{'scalar','integer','finite','nonnegative','nonnan','real'});
            
            % Build URL
            url = sprintf('%s/ocp/ca/%s/reserve/%d/', ...
                            this.serverLocation,this.annoToken,num_ids);
            this.lastUrl = url; 
            
            % Query DB            
            response = this.net.read(url);
            
            % Parse and return
            response = eval(response);
            ids = response(1):response(1) + response(2) - 1;            
            
        end
        
        
        %% Methods - getAnnoPropagateStatus checks the status of the 
        % annotation database propagation
        function status = getAnnoPropagateStatus(this)
            % Check status
            if ~isempty(this.annoToken) && ~isempty(this.annoChannel)
                status = this.getPropagateStatus(this.annoToken, this.annoChannel);
            else
                status = [];
            end
        end
        
        %% Methods - getImagePropagateStatus checks the status of the 
        % image database propagation
        function status = getImagePropagateStatus(this)
            % Check status
            if ~isempty(this.annoToken)
                status = this.getPropagateStatus(this.imageToken);
            else
                status = [];
            end
        end
        
        
        %% Methods - makeAnnoWritable sets the status of the 
        % annotation database to inconsistant so you can write to it (only
        % needed if the database has been propagated and is currently
        % consistent.
        function makeAnnoWritable(this)
            if isempty(this.annoToken)
                ex = MException('OCP:MissingToken',...
                    'You must set the annoToken before you can change propagation state!');
                throw(ex);
            elseif isempty(this.annoChannel)
                ex = MException('OCP:MissingChannel',...
                    'You must set the annoChannel before you can change propagation state!');
                throw(ex);
            end
            
            if (this.getAnnoPropagateStatus() == eOCPPropagateStatus.propagating)
                ex = MException('OCP:DbLocked',...
                    'Annotation DB is locked due to propagation. Must wait for db to be consistent, before you can make it writable');
                throw(ex);
            end
            
            this.setPropagateStatus(this.annoToken, this.annoChannel, eOCPPropagateStatus.inconsistent);

        end
        
        %% Methods - makeImageWritable sets the status of the 
        % image database to inconsistant so you can write to it (only
        % needed if the database has been propagated and is currently
        % consistent.
        function makeImageWritable(this)
            if isempty(this.annoToken)
                ex = MException('OCP:MissingToken',...
                    'You must set the imageToken before you can change propagation state!');
                throw(ex);
            elseif isempty(this.imageChannel) 
                ex = MException('OCP:MissingChannel',...
                    'You must set the imageChannel before you can change the propagation state!');
                throw(ex);
            end
            
            if (this.getImagePropagateStatus() == eOCPPropagateStatus.propagating)
                ex = MException('OCP:DbLocked',...
                    'Image DB is locked due to propagation. Must wait for db to be consistent, before you can make it writable');
                throw(ex);
            end
            
            this.setPropagateStatus(this.imageToken, this.imageChannel, eOCPPropagateStatus.inconsistent);
            
        end
        
        %% Methods - propagateAnnoDB triggers propagation of the annoToken 
        % database.  Will lock the db until the propagation process has
        % completed
        function propagateAnnoDB(this)
            if isempty(this.annoToken)
                ex = MException('OCP:MissingToken',...
                    'You must set the annoToken before you can change propagation state!');
                throw(ex);
            elseif isempty(this.annoChannel)
                ex = MException('OCP:MissingChannel',...
                    'You must set the annoChannel before you can change propagation state!');
                throw(ex);
            end
            
            this.setPropagateStatus(this.annoToken, this.annoChannel, eOCPPropagateStatus.propagating);
        end
        
        %% Methods - propagateImageDB triggers propagation of the imageToken 
        % database.  Will lock the db until the propagation process has
        % completed
        function propagateImageDB(this)
            if isempty(this.annoToken)
                ex = MException('OCP:MissingToken',...
                    'You must set the imageToken before you can change propagation state!');
                throw(ex);
            elseif isempty(this.imageChannel) 
                ex = MException('OCP:MissingChannel',...
                    'You must set the imageChannel before you can change the propagation state!');
                throw(ex);
            end
            
            this.setPropagateStatus(this.imageToken, this.imageChannel, eOCPPropagateStatus.propagating);
            
        end
        
        
    end
    
    methods( Access = private )
        
        %% Private Method - calculate batches based on settings and annotation size
        function [batchIndex, chunkIndex] = createAnnoBatches(this, ramonObj)
            % This method creates an index that breaks the ramonObj cell
            % array into batches for upload based on both number of
            % annotation and voxel size of annotations
            
            objectIndex = 1:length(ramonObj);
            
            % Check for objects that require chunking
            count = cellfun(@(x) x.voxelCount,ramonObj);
            chunkIndex = find(count > this.maxAnnoSize);
            objectIndex(chunkIndex) = [];
            
            % Build batches
            numObj = length(objectIndex);
            numGroups = floor(numObj / this.batchSize);
            remainGroup = mod(numObj,this.batchSize);
            
            if remainGroup ~= 0
                batchIndex = cell(numGroups + 1, 1);
            else
                batchIndex = cell(numGroups, 1);
            end
            
            startInd = 1;
            for ii = 1:numGroups
                batchIndex(ii) = {objectIndex(startInd:startInd + this.batchSize - 1)};
                startInd = startInd + this.batchSize;
            end
            
            if remainGroup ~= 0
                batchIndex(numGroups + 1) = {objectIndex(startInd:numObj)};
            end                       
        end
        
        %% Private Method - inforce max annotation size with chunking
        function chunkCollections = createAnnoChunks(this, ramonObj)
            % This method enforces max annotation size by breaking the
            % annotation into chunks that can be uploaded
            
            if length(ramonObj) == 1
                ramonObj = {ramonObj};   
                chunkCollections = cell(1,1);
            else                
                chunkCollections = cell(1,length(ramonObj));
            end
            
            for ii = 1:length(ramonObj)
               clear chunkGroup
               
               % Convert to voxel list
               annoVoxelList = ramonObj{ii}.clone;
               annoVoxelList.toVoxelList();
               
               % Create update objects
               voxCount = annoVoxelList.voxelCount();
               numChunks = floor(voxCount / this.maxAnnoSize);
               remainChunk = mod(voxCount,this.maxAnnoSize);
               
               % Create empty initial annotation
               template = annoVoxelList.clone('novoxels');
               template.setVoxelList([]);
               if remainChunk ~= 0
                   chunkGroup = cell(1,numChunks + 2);
               else
                   chunkGroup = cell(1,numChunks + 1);
               end
               chunkGroup{1} = template;
               
               % Create chunks
               startInd = 1;
               if numChunks ~= 0
                   for jj = 2:numChunks+1
                       tempObj = template.clone('novoxels');
                       tempObj.setVoxelList(annoVoxelList.data(startInd:startInd+this.maxAnnoSize-1,:));
                       startInd = startInd+this.maxAnnoSize;
                       chunkGroup{jj} = tempObj;
                   end
               end
               
               if remainChunk ~= 0
                   tempObj = template.clone('novoxels');
                   tempObj.setVoxelList(annoVoxelList.data(startInd:voxCount,:));
                   chunkGroup{end} = tempObj;                   
               end    
               
               % Store group into collection
               chunkCollections{ii} = chunkGroup;
            end
        end
        
        %% Private Method - write annotation chunks to database
        function id = writeRamonChunks(this, chunkCollection, updateFlag, conflictOption)
            % This method writes a chunked ramon object by creating an
            % annotation without voxel data first and then updating it
            % repeatedly with the chunked voxel data in list form.
            %
            % updateFlag is an optional boolean indicating if you want to
            % upload the annotation as an update instead of a create.
            % It is false by default (create new annotation)
            
            if ~exist('updateFlag','var') 
                updateFlag = false;
            end
            
            id = [];
            for ii = 1:length(chunkCollection)
                chunkGroup = chunkCollection{ii};
                
                if updateFlag == false
                    % Write empty anno and get ID
                    id = cat(2,id,...
                        this.writeRamonObject(chunkGroup{1}, 0, conflictOption));    
                else
                    % You are doing a big update so first write is an
                    % update as well
                    id = cat(2,id,...
                        this.writeRamonObject(chunkGroup{1}, 1, conflictOption));   
                end
            
                % Set the ID and update with all voxel chunks
                for jj = 2:length(chunkGroup)
                    chunkGroup{jj}.setId(id(end));
                	this.writeRamonObject(chunkGroup{jj}, 1, conflictOption);
                end
            end
        end
        
        %% Private Method - write annotation to database
        function id = writeRamonObject(this, ramonObj, updateFlag, conflictOption)
            % This method writes a ramon object to the specified database
            % Also supports batch interface so ramonObj can be a cell array.
            %
            % updateFlag is an optional boolean indicating if you want to
            % upload the annotation as an update instead of a create.
            % If true all objects must have an ID already assigned
            
            % If updateFlag is true, enforce ID requirement
            if exist('updateFlag','var') 
                if updateFlag == true
                    if isa(ramonObj,'cell')
                        % Batch Upload
                        ind = cellfun(@(x) isprop(x,'id'),ramonObj);
                        ind1 = cellfun(@(x) isempty(x.id),ramonObj(ind));
                        ind2 = cellfun(@(x) x.id == 0,ramonObj(ind));

                        if sum(ind1) > 0 || sum(ind2) > 0                   
                            error('OCP:IdMissing',...
                                'If uploading annotations with the updateFlag = true you must set the ID field in each object first so the correct annotation can be updated!');
                        end                
                    else
                        % Single object
                        if isempty(ramonObj.id) || ramonObj.id == 0                            
                            error('OCP:IdMissing',...
                                'If uploading annotations with the updateFlag = true you must set the ID field in each object first so the correct annotation can be updated!');
                        end                
                    end  
                end
            else
                updateFlag = false;
            end

            
            % If resolution isn't set Set Default and warn.
            if isa(ramonObj,'cell')
                % Batch Upload
                
                ind = cellfun(@(x) isprop(x,'resolution'),ramonObj);
                ind = cellfun(@isempty,ramonObj(ind));
                
                if sum(ind) > 0                                               
                    if isempty(this.defaultResolution)
                        error('OCP:MissingDefaultResolution',...
                            'The provided RAMON Object''s resolution property is empty AND the default resolution in this OCP object is empty.  One of these is required to complete operation.');
                    end
                            
                    cellfun(@(x) x.setResolution(this.defaultResolution),ramonObj(ind))
                    warning('OCP:RAMONResolutionEmpty',...
                        'Resolution empty in RAMON Object.  Default value of %d used. Turn off "OCP:RAMONResolutionEmpty" to suppress',this.defaultResolution);
                end                
            else
                % Single object
                
                if isprop(ramonObj,'resolution')
                    if isempty(ramonObj.resolution)                           
                        if isempty(this.defaultResolution)
                            error('OCP:MissingDefaultResolution',...
                            'The provided RAMON Object''s resolution property is empty AND the default resolution in this OCP object is empty.  One of these is required to complete operation.');
                        end
                        ramonObj.setResolution(this.defaultResolution);
                        warning('OCP:RAMONResolutionEmpty',...
                            'Resolution empty in RAMON Object.  Default value of %d used. Turn off "OCP:RAMONResolutionEmpty" to suppress',this.defaultResolution);
                    end
                end                
            end        
                  
            % Create HDF5 file
            hdfFile = OCPHdf(ramonObj);
                    
            % Build URL
            if updateFlag == false
                % Create Annotation
                urlStr = sprintf('%s/ocp/ocpca/%s/%s/%s/',...
                    this.serverLocation,...
                    this.annoToken,...
                    this.annoChannel,...
                    char(conflictOption));
            else
                % Update Annotation                
                urlStr = sprintf('%s/ocp/ocpca/%s/%s/update/%s/',...
                    this.serverLocation,...
                    this.annoToken,...
                    this.annoChannel,...
                    char(conflictOption));            
            end 
            this.lastUrl = urlStr;
            
            % Post HDF file to database with retry on failure
            cnt = 1;
            while cnt <= 5
                try
                    id = this.net.write(urlStr,hdfFile.filename);
                    break;
                    
                catch ME
                    if cnt == 5
                        rethrow(ME);
                    end
                    warning('OCP:BatchWriteError','DB Write Op Failed. Attempting RETRY: %d\nError: %s',cnt,ME.message);
                    pause(5*cnt);
                    cnt = cnt + 1;
                end
            end
                    
            if isa(ramonObj,'cell')
                % Batch Upload                
                id = eval(['[' id ']']);                
            else
                % Single object                   
                id = str2double(id);
            end
        end
        
         %% Private Method - write block style annotation to database
        function writeBlockData(this, ramonVol, conflictOption)
            % This method writes a ramon RAMONVolume to the specified database
            %
            % Upload Type must be set in the RAMONVolume so the data can be
            % converted to the proper format.
            %
            % XYZOffset and Resolution must be set so the database can
            % locate the data in the volume properly!
            %
            % Note: Data must match the selected upload type or possible
            % loss of data may occur!
            % Note: Upload type must match database type or upload will
            % fail.           
            
            % If not a RAMONVolume fail              
            if ~strcmpi(class(ramonVol),'RAMONVolume')
                error('OCP:IncorrectObjectTyp',...
                    'You can only block style upload RAMONVolume objects.');
            end
            
            % if channel name isn't set fail
            if isempty(ramonVol.channel)
                error('OCP:NoUploadChannel',...
                    'Channel name not specified in RAMONVolume. Set using setChannel()');
            end
            
            % If resolution isn't set fail               
            if isempty(ramonVol.resolution) 
                error('OCP:ResolutionEmpty',...
                    'Resolution empty in RAMONVolume.  You must set this before uploading block style data!');
            end
            
            % If xyz offset isn't set fail             
            if isempty(ramonVol.xyzOffset) 
                error('OCP:XYZOffsetEmpty',...
                    'XYZ Offset empty in RAMONVolume.  You must set this before uploading block style data!');
            end
            
            % If upload datatype doesn't match database datatype fail
            annoDataType = this.annoChanInfo.DATATYPE{1};
            if eRAMONChannelDataType.(annoDataType) ~= ramonVol.dataType
                error('OCP:DataTypeMismatch',...
                    'The RAMONVolume data type does not match the database you are trying to upload to. Project: %s - Database: %s',...
                    this.annoChanInfo.DATATYPE,ramonVol.dataType);
            end

            % If upload type doesn't match database type fail     
            annoChanType = this.annoChanInfo.TYPE{1};
            if eRAMONChannelType.(annoChanType) ~= ramonVol.channelType
                error('OCP:DataTypeMismatch',...
                    'The RAMONVolume type does not match the database you are trying to upload to. Project: %s - Database: %s',...
                    this.annoChanInfo.TYPE,ramonVol.channelType);
            end

            % Create HDF5 file
            hdfFile = OCPHdf(ramonVol);
                        
                    
            % Build URL           
            urlStr = sprintf('%s/ocp/ca/%s/%s/hdf5/%d/%d,%d/%d,%d/%d,%d/%s/',...
                            this.serverLocation,...
                            this.annoToken,...
                            this.annoChannel,...
                            ramonVol.resolution,...
                            ramonVol.xyzOffset(1), ramonVol.xyzOffset(1) + ramonVol.size(2),...
                            ramonVol.xyzOffset(2),ramonVol.xyzOffset(2) + ramonVol.size(1),...
                            ramonVol.xyzOffset(3),ramonVol.xyzOffset(3) + ramonVol.size(3),...
                            char(conflictOption));
          
            this.lastUrl = urlStr;
            
            % Post HDF file to database with retry on failure
            cnt = 1;
            while cnt <= 5
                try
                    this.net.write(urlStr,hdfFile.filename);
                    break;
                    
                catch ME
                    if cnt == 5
                        rethrow(ME);
                    end
                    warning('OCP:BlockWriteError','DB Write Op Failed. Attempting RETRY: %d\nError: %s',cnt,ME.message);
                    pause(5*cnt);
                    cnt = cnt + 1;
                end
            end  
        end
        
        %% Private Method - write block style annotation to database
        function writeBlockImageData(this, ramonVol, conflictOption)
            % This method writes a ramon RAMONVolume to the specified database
            %
            % Upload Type must be set in the RAMONVolume so the data can be
            % converted to the proper format.
            %
            % XYZOffset and Resolution must be set so the database can
            % locate the data in the volume properly!
            %
            % Note: Data must match the selected upload type or possible
            % loss of data may occur!
            % Note: Upload type must match database type or upload will
            % fail.           
                        
            % If resolution isn't set fail               
            if isempty(ramonVol.resolution) 
                error('OCP:ResolutionEmpty',...
                    'Resolution empty in RAMONVolume.  You must set this before uploading block style data!');
            end
            
            % If xyz offset isn't set fail             
            if isempty(ramonVol.xyzOffset) 
                error('OCP:XYZOffsetEmpty',...
                    'XYZ Offset empty in RAMONVolume.  You must set this before uploading block style data!');
            end
            
            % If data type doesn't match database fail
            imgDataType = this.imageChanInfo.DATATYPE{1};
            if eRAMONChannelDataType.(imgDataType) ~= ramonVol.dataType
                error('OCP:DataTypeMismatch',...
                    'The RAMONVolume type does not match the database you are trying to upload to. Project: %s - Database: %s',...
                    this.imageChanInfo.DATATYPE,ramonVol.dataType);
            end
                  
            % Create HDF5 file
            hdfFile = OCPHdf(ramonVol);                        
                    
            % Build URL           
            urlStr = sprintf('%s/ocp/ca/%s/%s/hdf5/%d/%d,%d/%d,%d/%d,%d/%s/',...
                            this.serverLocation,...
                            this.imageToken,...
                            this.imageChannel,...
                            ramonVol.resolution,...
                            ramonVol.xyzOffset(1), ramonVol.xyzOffset(1) + ramonVol.size(2),...
                            ramonVol.xyzOffset(2),ramonVol.xyzOffset(2) + ramonVol.size(1),...
                            ramonVol.xyzOffset(3),ramonVol.xyzOffset(3) + ramonVol.size(3),...
                            char(conflictOption));
          
            this.lastUrl = urlStr;
            
            % Post HDF file to database with retry on failure
            cnt = 1;
            while cnt <= 5
                try
                    this.net.write(urlStr,hdfFile.filename);
                    break;
                    
                catch ME
                    if cnt == 5
                        rethrow(ME);
                    end
                    warning('OCP:BlockWriteError','DB Write Op Failed. Attempting RETRY: %d\nError: %s',cnt,ME.message);
                    pause(5*cnt);
                    cnt = cnt + 1;
                end
            end  
        end
        
        %% Private Method - Build URL - Cutout
        function url = buildCutoutUrl(this, qObj)
            % This method build the url for a cutout type query.  It
            % selects the correct service and token automatically.
%             isMulti = false;
            switch qObj.type
                case eOCPQueryType.imageDense
                    service = '/ocp/ca';
                    token = this.imageToken;
                    channel = this.imageChannel;
                    qObj.setFilterIds([]);
                    % AB TODO -- kill this, (I think)
%                     if (this.imageChanInfo.TYPE == eRAMONDataType.channels16) || ...
%                         (this.imageChanInfo.TYPE == eRAMONDataType.channels8)
%                         isMulti = true;
%                     end
                case eOCPQueryType.annoDense
                    service = '/ocp/ca';
                    token = this.annoToken;
                    channel = this.annoChannel;
                case eOCPQueryType.probDense
                    service = '/ocp/ca';
                    token = this.annoToken;
                    channel = this.annoChannel;
                    qObj.setFilterIds([]);
                otherwise
                    ex = MException('OCP:NotCutout','Query is not a cutout type.  Cannot build url.');
                    throw(ex);
            end
  
            
            % build url
            if isempty(channel)
                % Attempt a legacy cutout
                url = sprintf('%s%s/%s/hdf5/%d/%d,%d/%d,%d/%d,%d/',...
                    this.serverLocation,...
                    service,...
                    token,...
                    qObj.resolution,...
                    qObj.xRange(1),qObj.xRange(2),...
                    qObj.yRange(1),qObj.yRange(2),...
                    qObj.zRange(1),qObj.zRange(2));
            else
                url = sprintf('%s%s/%s/%s/hdf5/%d/%d,%d/%d,%d/%d,%d/',...
                    this.serverLocation,...
                    service,...
                    token,...
                    channel,...
                    qObj.resolution,...
                    qObj.xRange(1),qObj.xRange(2),...
                    qObj.yRange(1),qObj.yRange(2),...
                    qObj.zRange(1),qObj.zRange(2));
            end

%              AB Note: As of 1.8.0 we don't support multichannel cutouts.
%              Perform multiple single channel cutouts instead

%             if isMulti == true
%                 % Multichannel Database!
%                 % Build channel string
%                 new_channels = cell(length(qObj.channels),1);
%                 for ii = 1:length(qObj.channels)
%                     new_channels{ii} = strrep(qObj.channels{ii},'__','-');
%                 end
%                 channel_str = sprintf('%s,',new_channels{:});
% 
%                 % build url
%                 url = sprintf('%s%s/%s/hdf5/%s/%d/%d,%d/%d,%d/%d,%d/',...
%                     this.serverLocation,...
%                     service,...
%                     token,...
%                     channel_str(1:end-1),...
%                     qObj.resolution,...
%                     qObj.xRange(1),qObj.xRange(2),...
%                     qObj.yRange(1),qObj.yRange(2),...
%                     qObj.zRange(1),qObj.zRange(2));
% 
%             else
%                 % Don't use channels in normal cutout so clear channels to
%                 % support datatype kludge
%                 qObj.setChannels([]);
% 
%                 % normal 
%                 url = sprintf('%s%s/%s/hdf5/%d/%d,%d/%d,%d/%d,%d/',...
%                     this.serverLocation,...
%                     service,...
%                     token,...
%                     qObj.resolution,...
%                     qObj.xRange(1),qObj.xRange(2),...
%                     qObj.yRange(1),qObj.yRange(2),...
%                     qObj.zRange(1),qObj.zRange(2));
%             end
                       
            if ~isempty(qObj.filterIds)
                % add filter option
                ids2filter = sprintf('%d,',qObj.filterIds);
                ids2filter(end) = [];
                url = sprintf('%sfilter/%s/',...
                    url,...
                    ids2filter);
                
            end
        end
        
        %% Private Method - Build URL - Slice
        function url = buildSliceUrl(this, qObj)
            % This method build the url for a slice type query.  It
            % selects the correct service and token automatically.
%             isMulti = false;
            switch qObj.type
                case eOCPQueryType.imageSlice
                    service = '/ocp/ca';
                    token = this.imageToken;
                    channel = this.imageChannel;
                    qObj.setFilterIds([]);
                case eOCPQueryType.annoSlice
                    service = '/ocp/ca';
                    token = this.annoToken;
                    channel = this.annoChannel;
                otherwise
                    ex = MException('OCP:NotSlice','Query is not a slice type.  Cannot build url.');
                    throw(ex);
            end
            
            %AB TODO match the above (after testing) 
            
%             if isMulti == true
%                 % Multichannel Database!
%                 % Build channel string
%                 new_channels = cell(length(qObj.channels),1);
%                 for ii = 1:length(qObj.channels)
%                     new_channels{ii} = strrep(qObj.channels{ii},'__','-');
%                 end
%                 channel_str = sprintf('%s,',new_channels{:});
%                 
%                 % build url         
%                 switch qObj.slicePlane
%                     case eOCPSlicePlane.xy
%                         url = sprintf('%s%s/%s/mcfc/%s/%s/%d/%d,%d/%d,%d/%d/',...
%                             this.serverLocation,...
%                             service,...
%                             token,...
%                             char(qObj.slicePlane),...
%                             channel_str(1:end-1),...
%                             qObj.resolution,...
%                             qObj.aRange(1),qObj.aRange(2),...
%                             qObj.bRange(1),qObj.bRange(2),...
%                             qObj.cIndex(1));
%                         
%                     case eOCPSlicePlane.xz
%                         url = sprintf('%s%s/%s/mcfc/%s/%s/%d/%d,%d/%d/%d,%d/',...
%                             this.serverLocation,...
%                             service,...
%                             token,...
%                             char(qObj.slicePlane),...
%                             channel_str(1:end-1),...
%                             qObj.resolution,...
%                             qObj.aRange(1),qObj.aRange(2),...
%                             qObj.cIndex(1),...
%                             qObj.bRange(1),qObj.bRange(2));
%                         
%                     case eOCPSlicePlane.yz
%                         url = sprintf('%s%s/%s/mcfc/%s/%s/%d/%d/%d,%d/%d,%d/',...
%                             this.serverLocation,...
%                             service,...
%                             token,...
%                             char(qObj.slicePlane),...
%                             channel_str(1:end-1),...
%                             qObj.resolution,...
%                             qObj.cIndex(1),...
%                             qObj.aRange(1),qObj.aRange(2),...
%                             qObj.bRange(1),qObj.bRange(2));
%                 end            
%                 
%             else
                % Don't use channels in normal cutout so clear channels to
                % support datatype kludge
                qObj.setChannels([]);
                
                % normal
                switch qObj.slicePlane
                    case eOCPSlicePlane.xy
                        url = sprintf('%s%s/%s/%s/%s/%d/%d,%d/%d,%d/%d/',...
                            this.serverLocation,...
                            service,...
                            token,...
                            channel,...
                            char(qObj.slicePlane),...
                            qObj.resolution,...
                            qObj.aRange(1),qObj.aRange(2),...
                            qObj.bRange(1),qObj.bRange(2),...
                            qObj.cIndex(1));
                        
                    case eOCPSlicePlane.xz
                        url = sprintf('%s%s/%s/%s/%s/%d/%d,%d/%d/%d,%d/',...
                            this.serverLocation,...
                            service,...
                            token,...
                            channel,...
                            char(qObj.slicePlane),...
                            qObj.resolution,...
                            qObj.aRange(1),qObj.aRange(2),...
                            qObj.cIndex(1),...
                            qObj.bRange(1),qObj.bRange(2));
                        
                    case eOCPSlicePlane.yz
                        url = sprintf('%s%s/%s/%s/%s/%d/%d/%d,%d/%d,%d/',...
                            this.serverLocation,...
                            service,...
                            token,...
                            channel,...
                            char(qObj.slicePlane),...
                            qObj.resolution,...
                            qObj.cIndex(1),...
                            qObj.aRange(1),qObj.aRange(2),...
                            qObj.bRange(1),qObj.bRange(2));
                end            
%             end (end for multi channel, commented out above)
            
            if ~isempty(qObj.filterIds)
                % add filter option
                ids2filter = sprintf('%d,',qObj.filterIds);
                ids2filter(end) = [];
                url = sprintf('%sfilter/%s/',...
                    url,...
                    ids2filter);
                
            end
        end
        
        %% Private Method - Build URL - Overlay
        function url = buildOverlayUrl(this, qObj)
            % This method build the url for a overlay type query.
            % overlay service:
            % ocp/overlay/alpha/server1/token1/channel1/server2/token2/channel2/cutout
            service = 'ocp/overlay';
            server = this.serverLocation(8:end); % strip http:// off server location
            
            switch qObj.slicePlane
                case eOCPSlicePlane.xy
                    url = sprintf('%s/%s/%0.1f/%s/%s/%s/%s/%s/%s/%s/%d/%d,%d/%d,%d/%d/',...
                        this.serverLocation,...
                        service,...
                        qObj.overlayAlpha,...
                        server,...
                        this.annoToken,...
                        this.annoChannel,...
                        server,...
                        this.imageToken,...
                        this.imageChannel,...
                        char(qObj.slicePlane),...
                        qObj.resolution,...
                        qObj.aRange(1),qObj.aRange(2),...
                        qObj.bRange(1),qObj.bRange(2),...
                        qObj.cIndex(1));
                    
                case eOCPSlicePlane.xz
                    url = sprintf('%s/%s/%0.1f/%s/%s/%s/%s/%s/%s/%s/%d/%d,%d/%d/%d,%d/',...
                        this.serverLocation,...
                        service,...
                        qObj.overlayAlpha,...
                        server,...
                        this.annoToken,...
                        this.annoChannel,...
                        server,...
                        this.imageToken,...
                        this.imageChannel,...
                        char(qObj.slicePlane),...
                        qObj.resolution,...
                        qObj.aRange(1),qObj.aRange(2),...
                        qObj.cIndex(1),...
                        qObj.bRange(1),qObj.bRange(2));
                    
                case eOCPSlicePlane.yz
                    url = sprintf('%s/%s/%0.1f/%s/%s/%s/%s/%s/%s/%s/%d/%d/%d,%d/%d,%d/',...
                        this.serverLocation,...
                        service,...
                        qObj.overlayAlpha,...
                        server,...
                        this.annoToken,...
                        this.annoChannel,...
                        server,...
                        this.imageToken,...
                        this.imageChannel,...
                        char(qObj.slicePlane),...
                        qObj.resolution,...
                        qObj.cIndex(1),...
                        qObj.aRange(1),qObj.aRange(2),...
                        qObj.bRange(1),qObj.bRange(2));
            end
            
            if ~isempty(qObj.filterIds)
                % add filter option
                ids2filter = sprintf('%d,',qObj.filterIds);
                ids2filter(end) = [];
                url = sprintf('%sfilter/%s/',...
                    url,...
                    ids2filter);
                
            end
        end
        
        %% Private Method - Build URL - RAMON
        function url = buildRAMONUrl(this,qObj)
            % This method build the url for a RAMON object query.  It
            % selects the correct service and token automatically.
            switch qObj.type
                case eOCPQueryType.RAMONDense
                    option = 'cutout';
                    token = this.annoToken;
                    channel = this.annoChannel;
                case eOCPQueryType.RAMONVoxelList
                    option = 'voxels';
                    token = this.annoToken;
                    channel = this.annoChannel;
                case eOCPQueryType.RAMONMetaOnly
                    option = 'nodata';
                    token = this.annoToken;
                    channel = this.annoChannel;
                case eOCPQueryType.RAMONBoundingBox
                    option = 'boundingbox';
                    token = this.annoToken;
                    channel = this.annoChannel;
                otherwise
                    ex = MException('OCP:NotRAMON','Query is not a RAMON type.  Cannot build url.');
                    throw(ex);
            end
            
            % If batch mode you need to send csv list of ids in url
            if length(qObj.id) > 1
                idStr = sprintf('%d,',qObj.id);
                idStr(end) = [];
            else
                idStr = sprintf('%d',qObj.id);
            end
            
            % If just tacking on the resolution add to URL
            % If doing a cutout add all cutout args
            % Otherwise don't mess with url
            if ~isempty(qObj.resolution) && ...
                    isempty(qObj.xRange) && ...
                    isempty(qObj.yRange) && ...
                    isempty(qObj.zRange)
                % Add resolution
                url = sprintf('%s/ocp/ca/%s/%s/%s/%s/%d/',...
                    this.serverLocation,...
                    token,...
                    channel,...
                    idStr,...
                    option,...
                    qObj.resolution);
            elseif  ~isempty(qObj.resolution) && ...
                    ~isempty(qObj.xRange) && ...
                    ~isempty(qObj.yRange) && ...
                    ~isempty(qObj.zRange)
                % Add resolution
                url = sprintf('%s/ocp/ca/%s/%s/%s/%s/%d/%d,%d/%d,%d/%d,%d/',...
                    this.serverLocation,...
                    token,...
                    channel,...
                    idStr,...
                    option,...
                    qObj.resolution,...
                    qObj.xRange(1),qObj.xRange(2),...
                    qObj.yRange(1),qObj.yRange(2),...
                    qObj.zRange(1),qObj.zRange(2));
            else
                % Don't
                url = sprintf('%s/ocp/ca/%s/%s/%s/%s/',...
                    this.serverLocation,...
                    token,...
                    channel,...
                    idStr,...
                    option);
            end
        end
        
        %% Private Method - Build URL - RAMON Id List
        function url = buildRAMONIdUrl(this,qObj)
            % This method build the url for an RAMON object id predicate
            % query
            
            if ~isempty(qObj.idListPredicates)
                % Build predicate string
                predicateStr = '';
                keys = qObj.idListPredicates.keys;
                for ii = 1:qObj.idListPredicates.Count
                    switch keys{ii}
                        case char(eOCPPredicate.status)                            
                            predicateStr = sprintf('%s%s/%d/',predicateStr,...
                                keys{ii},uint32(qObj.idListPredicates(keys{ii})));

                        case char(eOCPPredicate.type)
                            predicateStr = sprintf('%s%s/%d/',predicateStr,...
                                keys{ii},uint32(qObj.idListPredicates(keys{ii})));
                            
                        case char(eOCPPredicate.confidence_gt)
                            predicateStr = sprintf('%s/confidence/gt/%f/',predicateStr,...
                                qObj.idListPredicates(keys{ii}));
                            
                        case char(eOCPPredicate.confidence_lt)
                            predicateStr = sprintf('%s/confidence/lt/%f/',predicateStr,...
                                qObj.idListPredicates(keys{ii}));
                            
                        otherwise
                            error('OCP:buildRAMONIdUrl','Unsupported predicate: %s',keys{ii});                            
                    end
                end
                
                % build url
                url = sprintf('%s/ocp/ca/%s/%s/query/%s',...
                    this.serverLocation,...
                    this.annoToken,...
                    this.annoChannel,...
                    predicateStr);
            else
                % no predicates listed so get ids of everything
                url = sprintf('%s/ocp/ca/%s/%s/query/',...
                    this.serverLocation,...
                    this.annoToken,...
                    this.annoChannel);
            end
            
            % if there is a list limit supplied append it to the URL
            if ~isempty(qObj.idListLimit)
                url = sprintf('%slimit/%d/',url,qObj.idListLimit);                
            end
            
        end
        
        %% Private Method - Build URL - XYZ Voxel ID
        function url = buildXyzVoxelIdUrl(this,qObj)
            % This method build the url for an xyz voxel id query
            
            % Set resolution to default if it isn't set
            if isempty(qObj.resolution)
                qObj.setResolution(this.defaultResolution);
            end
            
            url = sprintf('%s/ocp/ca/%s/%s/id/%d/%d/%d/%d/',...
                this.serverLocation,...
                this.getAnnoToken(),...
                this.annoChannel(),...
                qObj.resolution,...
                qObj.xyzCoord(1),...
                qObj.xyzCoord(2),...
                qObj.xyzCoord(3));
            
        end
        
        
        %% Private Method - Build setField URL
        
        function url = buildSetFieldURL(this, id, field, value)
            % This method builds a REST URL to set a field of an existing
            % annotation
            
            % Handle field value difference and convert to string
            switch field
                case 'author'
                    strVal = value;
                    
                case {'status','synapse_type','segmentclass','cubelocation',...
                        'organelleclass'}
                    strVal = num2str(uint32(value));
                    
                case {'confidence','weight','neuron','parentseed','source','parent'}
                    strVal = num2str(value);
                    
                case {'seeds','position','synapses','organelles','segments'}
                    strVal = sprintf('%d,',value);
                    strVal(end) = [];                    
                    
                otherwise
                    % Assume you're adding a custom KV pair
                    if ~ischar(field)
                        error('OCP:InvalidCustomKey','Custom Keys must be char strings');
                    end                        
                    warning('OCP:CustomKVPair','Adding a custom KV pair - Key: %s',field);
                    
                    % Convert value into a string that will eval to what it
                    % should be
                    if isnumeric(value)
                        % String-ify so it will eval() back to a numeric
                        strVal = mat2str(value);
                        strVal = strrep(strVal,' ',',');
                    elseif ischar(value)
                        value = strrep(value,' ','_');
                        strVal = value;
                    else                        
                        error('OCP:InvalidValueClass','Custom Values must be numeric or char strings.  Class: %s',class(value));
                    end
                       
            end
                 
            % Build URL
            url = sprintf('%s/ocp/ca/%s/%s/%d/setField/%s/%s/',...
                this.serverLocation,this.annoToken,this.annoChannel,id,field,strVal);
            
            
        end
        
        %% Private Method - getPropagate checks token propagate status
        function status = getPropagateStatus(this, token, channel)
            validateattributes(token,{'char'},{'nonempty'});
            validateattributes(channel,{'char'},{'nonempty'});
            
            % Build URL
            url = sprintf('%s/ocp/ca/%s/%s/getPropagate/',...
                this.serverLocation,token,channel);
           
            % Query DB and get HDF5 File
            resp = this.net.read(url);
            
            % Set result and return
            status = eOCPPropagateStatus(str2double(resp));
        end
        
         %% Private Method - setPropagate sets token propagate status
        function setPropagateStatus(this, token, channel, status)
            validateattributes(token,{'char'},{'nonempty'});
            validateattributes(channel,{'char'},{'nonempty'});
            validateattributes(status,{'numeric'},{'finite','nonnegative','integer','nonnan','real','scalar'});
            
            % Validate status and convert to int
            if ~isa(status, 'eOCPPropagateStatus')
                try
                    status = eOCPPropagateStatus(status);
                catch ME
                    rethrow(ME);
                end
            end
            
            status = int32(status);
            
            % Build URL
            url = sprintf('%s/ocp/ca/%s/%s/setPropagate/%d/',...
                this.serverLocation,token,channel,status);
            
            % Query DB and get HDF5 File
            this.net.read(url);
        end
        
        %% Private Method - getField interface response parser
        function value = getFieldParser(this, response, field)
            % parse the string response from the get interface and make the
            % appropriate type.
            switch field
                case {'author'}
                    value = response;
                    
                case 'status'
                    value = eRAMONAnnoStatus(str2double(response));
                                        
                case {'confidence','weight','neuron',...
                        'parentseed','source','parent'}
                    value = str2double(response);
                    
                case 'synapse_type'
                    value = eRAMONSynapseType(str2double(response));
                    
                case 'segmentclass'
                    value = eRAMONSegmentClass(str2double(response));
                
                case 'organelleclass'
                    value = eRAMONOrganelleClass(str2double(response));
                
                case 'cubelocation'
                    value = eRAMONCubeOrientation(str2double(response));
                
                case 'segments'
                    if ~isempty(strfind(response,'],['))
                        modStr = strrep(response,'],[','];[');
                        value = eval(['[' modStr ']']);
                    else
                        value = eval(['[' response ']']);
                    end
                
                case {'seeds','synapses','organelles','position'}
                    value = eval(['[' response ']']);
                    
                otherwise
                    % Assume custom KVPair
                    % Eval to make sure numerics go back to numerics
                    try
                        if all(ismember(response, '0123456789+-.'))               
                            value = eval(response);
                        else                                                
                            value = response;
                        end
                    catch ME %#ok<NASGU>
                        value = response;
                    end                       
                    
            end
            
        end
        
        %% Private Method - Build set dataType on annotation create
        
        function data_object = checkSetDataType(this, data_object)
            if iscell(data_object) == 1
                % Check all cell objects
                for ii = 1:length(data_object)
                    % Make sure you need to assign data type
                    classes = strfind(superclasses(data_object{ii}),'RAMONVolume');
                    if any([classes{:}]) == 0
                        %NOPE!
                        break
                    end
                    
                    if ~isempty(data_object{ii}.dataType)
                        % check that types match
                        if uint32(data_object{ii}.dataType) ~= this.annoChanInfo.TYPE
                            error('OCP:CheckSetDataType','Data type mismatch between project (%d) and object (%d)',...
                                this.annoChanInfo.TYPE,data_object{ii}.dataType)
                        end
                    else
                        % set data type to db value
                        data_object{ii}.setDataType(this.annoChanInfo.DATATYPE);
                    end 
                end

            else
                % Single object
                classes = strfind(superclasses(data_object),'RAMONVolume');
                if any([classes{:}]) == 1 
                    if ~isempty(data_object.dataType)
                        % check that types match
                        chanType = this.annoChanInfo.DATATYPE{1};
                        if data_object.dataType ~= eRAMONChannelDataType.(chanType)
                            error('OCP:CheckSetDataType','Data type mismatch between project (%s) and object (%s)',...
                                data_object.dataType,chanType)
                        end
                    else
                        % set data type to db value
                        data_object.setDataType(this.annoChanInfo.DATATYPE);
                    end
                end
            end
        end
                 
    end
end

