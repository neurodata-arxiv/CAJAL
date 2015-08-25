classdef RAMONBase < handle
    % RAMONBase is the basic class for RAMON types. All RAMON types inherit
    % this class.
    %
    % **Properties**
    %
    %	:id: [int32]    Unique 32bit ID value assigned by OCP database
    %
    %	:channel: [string]  Name of the channel corresponding to this object (for creating HDF5 files)
    %
    %	:confidence: [float]    Value 0-1 indicating confidence in annotation
    %
    %	:dynamicMetadata: [string array] A flexible, unspecified collection key-value pairs
    %
    %	:status: [flag] Status of annotation in database
    %
    %   :author: [string]   username of the person who created the annotation
    %
    % **Methods**
    %
    %
    %


    properties(SetAccess = 'private', GetAccess = 'public')
        id                  % Unique 32bit ID value assigned by OCP database
        channel             % Name of the channel corresponding to this object (for creating HDF5 files)
        confidence          % Value 0-1 indicating confidence in annotation
        dynamicMetadata     % A flexible, unspecified collection key-value pairs
        status              % Status of annotation in database
        author              % username of the person who created the annotation   
        
        % All posted HDF5 files must have a ChannelType and DataType. These
        % fields are included in all RAMON objects now for simplicity. 
        dataType = [] % eRAMONChannelDataType
        channelType = [] % eRAMONChannelType 
    end
    
    methods
        function this = RAMONBase(varargin)
            % Assign fields based on input arguments
            this.setId([]);
            this.setConfidence(1);
            this.setStatus(eRAMONAnnoStatus.unprocessed);
            this.clearDynamicMetadata();
            this.setAuthor('unspecified');
                    
            if nargin > 0
                this.setId(varargin{1});
            end
            if nargin > 1
                this.setConfidence(varargin{2});
            end
            if nargin > 2
                this.setStatus(varargin{3});
            end
            if nargin > 3
                if ~isempty(varargin{4})
                    [numKey, col] = size(varargin{4});
                    if col ~= 2
                        ex = MException('RAMONBase:DMDFormatInvalid','The dynamic metadata format is invalid.  Check documentation.');
                        throw(ex);
                    end
                    data = varargin{4};
                    this.clearDynamicMetadata();
                    for ii = 1:numKey
                        this = this.addDynamicMetadata(data{ii,1},data{ii,2});
                    end
                end
            end
            if nargin > 4
                this.setAuthor(varargin{5});  
            end
            if nargin > 5
                ex = MException('RAMONBase:TooManyArguments','Too many arguments in constructor for initialization, see documentation for use.');
                throw(ex);
            end
            
        end
        
        %% Setter Functions for input validation
        
        function this = setId(this,value)
            % This member function sets the id field (32 bit positive
            % non-zero integer)
                        
            try
                validateattributes(value,{'numeric'},{'finite','nonnegative','integer','nonnan','real'});
            catch %#ok<*CTCH>
                ME = lasterror; %#ok<*LERR>
                ME.message = sprintf('Error setting id property: %s',ME.message);
                rethrow(ME);
            end
            
            this.id = value;
        end
        
        function this = setConfidence(this,value)
            % This member function sets the confidence field. (0-1)
            
            if isempty(value)
                % Default confidence is 1.  All annotations must have a
                % confidence value.  It is assumed that unless a confidence
                % has been calculated the confidence is 1.
                value = 1;
                warning('RAMONBase:DefaultConfidence','Attemped to set confidence to null value.  Default value of 1 used instead');
            end
            
            try
                validateattributes(value,{'numeric'},{'scalar','<=',1,'>=',0,'finite','nonnegative','nonnan','real'});
            catch 
                ME = lasterror; 
                ME.message = sprintf('Error setting confidence property: %s',ME.message);
                rethrow(ME)
            end
            
            this.confidence = value;
        end
                        
        function this = setAuthor(this,value)
            % This member function sets the author field.
            
            if ~isempty(value) && ~isa(value,'char');
                ex = MException('RAMONBase:InvalidAuthor','Author must be of type char');
                throw(ex);
            end
            
            this.author = value;
        end
                 
        function this = setChannel(this,name)
            % Sets the channel name (str) 
            if isa(name, 'char')
                this.channel = name;
            else
                ex = MException('RAMONVolume:ChannelNameTypeError','Channel name field must be a character string.');
                throw(ex);
            end
        end
        
        function this = setStatus(this,value)
            % This member function sets the status field.
            % The value of this field must either be of the enumeration
            % eRAMONAnnoStatus or a uint32 that corresponds to a supported
            % enumeration in eRAMONAnnoStatus
            
            if isa(value, 'eRAMONAnnoStatus')
                % Is of Type AnnotationStatus
                
            else
                % Is not of type AnnotationStatus
                try
                    validateattributes(value,{'numeric'},{'finite','nonnegative','integer','nonnan','real'});
                catch 
                    ME = lasterror; 
                    ME.message = sprintf('Error setting status property: %s',ME.message);
                    rethrow(ME)
                end
            
                try
                    value = eRAMONAnnoStatus(value);
                catch ME
                    rethrow(ME);
                end
            end
            
            this.status = value;
        end
        
        function this = setDynamicMetadata(this,map)
            % This member function directly sets the dynamic metadata and
            % is useful when copying a whole set of metadata from one
            % object to another
            
            if ~isa(map,'containers.Map');
                ex = MException('RAMONBase:InvalidDMType','Error setting dynamic metadata: Dynamic Metadata must be represented as a container.Map');
                throw(ex);
            end
            
            this.dynamicMetadata = map;      
        end
        
        function this = addDynamicMetadata(this,key,value)
            % This member function adds a key value pair to the 
            % dynamic metadata field.  They key must not already
            % exist.
            
            if ~isa(key,'char');
                ex = MException('RAMONBase:InvalidKey','Error adding dynamic metadata: Key must be of type char');
                throw(ex);
            end
            
            % add key
            if this.dynamicMetadata.Count == 0
                % first key
                this.dynamicMetadata(key) = value;
            else
                % not the first key
                
                % check if key exists already
                if ~isempty(find(ismember(this.dynamicMetadata.keys, key)==1, 1))
                    ex = MException('RAMONBase:DuplicateKey',sprintf('Error adding dynamic metadata: Key "%s" already exists.  Cannot Add.  Try update.',key));
                    throw(ex);
                end
                
                % If you are here the key doesn't exist
                this.dynamicMetadata(key) = value;                
            end
        end
        
        function this = removeDynamicMetadata(this,key)
            % This member function removes a key value pair from the 
            % dynamic metadata field. 
            
            if ~isa(key,'char');
                ex = MException('RAMONBase:InvalidKey','Error adding dynamic metadata: Key must be of type char');
                throw(ex);
            end
            
            % check if key exists already
            if isempty(find(ismember(this.dynamicMetadata.keys, key)==1, 1))
                warning('RAMONBase:KeyNotFound', 'Key not found. Nothing was removed.')
            else
                this.dynamicMetadata.remove(key);
            end
        end
        
        function this = updateDynamicMetadata(this,key,value)
            % This member function updates a key value pair to the point
            % annotation dynamic metadata field.  If they key doesn't
            % already exist it is simply created.
            
            if ~isa(key,'char');
                ex = MException('RAMONBase:InvalidKey','Error adding dynamic metadata: Key must be of type char');
                throw(ex);
            end
            
            % Update/Add key
            this.dynamicMetadata(key) = value;  
        end
        
        function this = clearDynamicMetadata(this)
            % This member function clears the point annotation dynamic
            % metadata field.
            this.dynamicMetadata = containers.Map();
        end
        
        function keys = getMetadataKeys(this)
            keys = this.dynamicMetadata.keys();
        end
        
        function value = getMetadataValue(this, key)
            if ~isa(key,'char');
                ex = MException('RAMONBase:InvalidKey','Key must be of type char');
                throw(ex);
            end
            
            % check if key exists already
            if isempty(find(ismember(this.dynamicMetadata.keys, key)==1, 1))
                ex = MException('RAMONBase:KeyDoesNotExist',sprintf('Key "%s" does not exist.  Cannot Get Value.',key));
                throw(ex);
            end

            value = this.dynamicMetadata(key);
        end
        
        
        function this = setDataType(this,type)        
            % This member function sets the volume object datatype field.
            % The datatype field corresponds to the representation of data
            % in the DB. Examples include uint8, uint16, uint32, float32,
            % etc. See eRAMONChannelDataType for all. 
            % 
            % The data will be converted to this type on upload! If there
            % is a mismatch between your data and the selected type
            % information could be lost. If there is a mismatch between the
            % database data type (specified by the token) and the upload
            % type the upload will fail.
            
            % ignore for non-volume objects
            if (strcmpi(class(this),'RAMONVolume'))
                
                if isempty(type)
                    ex = MException('RAMONBase:EmptyDataType',sprintf('Supplied data type is empty!'));
                    throw(ex);
                end

                if isa(type, 'eRAMONChannelDataType')
                    % Is of Type eRAMONChannelDataType

                else
                    % Is not of type eRAMONDataType
                    %validateattributes(type,{'numeric'},{'finite','nonnegative','integer','nonnan','real'});
                    try
                        if ischar(type)
                            type = eRAMONChannelDataType.(type);
                        else
                            type = eRAMONChannelDataType.(char(type));
                        end
                    catch ME
                        rethrow(ME);
                    end
                end

                this.dataType = type;
            end
        end

        function this = setChannelType(this,type)        
            % This member function sets the volume object database type field.
            % This specifies types like annotation, probmap, etc. See
            % eRAMONChannelType.
            if (strcmpi(class(this),'RAMONVolume'))
                if isempty(type)
                    ex = MException('RAMONBase:EmptyChannelType',sprintf('Supplied channel type is empty!'));
                    throw(ex);
                end                        
                if isa(type, 'eRAMONChannelType')
                    % Is of Type eRAMONChannelType
                    this.channelType = type;
                else
                    try
                        if ischar(type)
                            type = eRAMONChannelType.(type);
                        else
                            type = eRAMONChannelType.(char(type));
                        end
                    catch ME
                        rethrow(ME);
                    end
                end
                this.channelType = type;
            end
        end

        
        function handle = clone(this, ~)
           % Perform a deep copy because these are handles and not objects
           % default using the = operator just copies the handle and not
           % the underlying object.
           
            % Instantiate new object of the same class.
            handle = feval(class(this));
 
            % Copy all properties.
            % Base
            handle = this.baseCloneHelper(handle);
        end
                       
       %% RAMON to HDF METHOD - Static

        function filename = toHDF(this)
            filename = OCPHdf(this);
        end
        
        
        
    end
    
    methods(Static)
        %% Pass through voxel count method (since no voxels)        
        function count = voxelCount()
            % Returns the number of voxels stored in the RAMON objects that
            % don't have RAMONVolume as a super class
            count = 0;
        end     
    end
        
    
    %% Methods - Utility Functions
    methods( Access = protected)
        function ramonObj = setRAMONBaseProperties(this,ramonObj)
            % RAMONBase
            ramonObj.setId(this.id);
            ramonObj.setConfidence(this.confidence);
            ramonObj.setDynamicMetadata(this.dynamicMetadata);
            ramonObj.setStatus(this.status);
            ramonObj.setAuthor(this.author);
            ramonObj.setDataType(this.dataType);
            ramonObj.setChannelType(this.channelType);
        end 
       
        function metadataConstructHelper(this,var)
            
            [numkey, col] = size(var);
            if numkey ~= 0
                if col ~= 2
                    ex = MException('RAMONBase:MetadataFormatInvalid','The init dynamic metadata format is invalid.  Should be Nx2 cell array.');
                    throw(ex);
                end
                data = var;
                for ii = 1:numkey
                    this = this.addDynamicMetadata(data{ii,1},data{ii,2});
                end
            else
                this.clearDynamicMetadata();
            end
        end
        
        function handle = baseCloneHelper(this, handle)
            % Copy all properties.
            % Base
            handle.setId(this.id);
            handle.setConfidence(this.confidence);
            handle.setDynamicMetadata(this.dynamicMetadata);
            handle.setStatus(this.status);
            handle.setAuthor(this.author); 
            handle.setDataType(this.dataType);
            handle.setChannelType(this.channelType);
        end
    end
    
end

