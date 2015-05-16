classdef RAMONVolume < RAMONBase
    % RAMONVolume - class to store voxel data
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
        xyzOffset = [];
        resolution = [];  % Level in the Database Resolution Hierarchy
        
        name = 'Volume1';       % Descriptive display name to give the cube
        sliceDisplayIndex = 1;     % Contains Z index for slice to display
               
        dataFormat = []; % Property indicating the format of the data property
        % eRAMONDataFormat.dense - dense NxMxKx.. voxel cutout
        % eRAMONDataFormat.voxelList - Nx3 XYZ coordinates
        % of labled voxels
        % eRAMONDataFormat.boundingBox - 1x3 X,Y,Z span (from xyzOffset start point)
        data = [];	% Property containing voxel data
        
        % This indicates what datatype this RAMONVolume represents.  Since
        % developers often just make everything doubles in MATLAB
        % autodetecting this is unreliable.
        % DEPRICATED.  WILL BE REMOVED IN FUTURE VERSIONS
        uploadType = []
        % DEPRICATED.  WILL BE REMOVED IN FUTURE VERSIONS 

        % This indicates what datatype this RAMONVolume represents.  Since
        % developers often just make everything doubles in MATLAB
        % autodetecting this is unreliable.  This is automatically synced automatically with
        % the database project type when possible.
        dataType = [] % eRAMONChannelDataType
        dbType = [] % eRAMONDataType 
    end
    
    methods
        
        function this = RAMONVolume(varargin)
            % this = RAMONVolume()
            % this = RAMONVolume(data, dataFormat)
            % this = RAMONVolume(data, dataFormat, [ref coords])
            % this = RAMONVolume(data, dataFormat, [ref coords], resolution)

            this.setCutout([]);
            this.setXyzOffset([]);
            this.setResolution([]);
            
            if nargin == 1
                ex = MException('RAMONVolume:MissingDataFormat',...
                    'When instantiating a RAMONVolume object you must include the "dataFormat" argument indicating the voxel data representation.');
                throw(ex);
            end
            if nargin > 1
                this = this.setDataFormat(varargin{2});
                this = this.initVoxelData(varargin{1}, this.dataFormat);
            end
            if nargin > 2
                this = this.setXyzOffset(varargin{3});
            end
            if nargin > 3
                this = this.setResolution(varargin{4});
            end
            if nargin > 4
                ex = MException('RAMONVolume:TooManyArguments','Too many properties for initialization, see documentation for use.');
                throw(ex);
            end
        end
        
        %% Setter Functions for property validation
        
        function this = setCutout(this,cube)
            % this = setCutout(this,cube)
            %
            % This member function sets the data field in cutout format.
            % A volume object can be 1x1 to NxNxN, representing a single
            % point to a 3D volume.
            % If an annotation, a  value of 0 represents unlabled space.
            % Any other nonnegative integer value represents a labeled region
            % If non-integer data is probabilities or image data.
            
            validateattributes(cube,{'numeric','logical'},{'finite','nonnegative','nonnan','real'});
                        
            this.data = cube;
            this.dataFormat = eRAMONDataFormat.dense;
        end
        
        function this = setVoxelList(this,voxels)
            % this = setVoxelList(this,cube)
            %
            % This member function sets the data field in voxel list format
            % A volume object can be 1x1 to NxNxN, representing a single
            % point to a 3D volume.
            % A voxel value of 0 represents unlabled space.  Any other
            % nonnegative integer value represents a labeled region
            
            if ~isempty(voxels)
                validateattributes(voxels,{'numeric'},{'finite','nonnegative','integer','nonnan','real'});
                
                if ndims(voxels) ~= 2
                    ex = MException('RAMONVolume:InvalidVoxelList','Voxel list should be an Nx3 matrix.');
                    throw(ex);
                end
                
                if size(voxels,2) ~= 3
                    ex = MException('RAMONVolume:InvalidVoxelList','Voxel list should be an Nx3 matrix.');
                    throw(ex);
                end
            end
            
            this.data = voxels;
            this.dataFormat = eRAMONDataFormat.voxelList;
        end
        
        function this = setBoundingBoxSpan(this,bboxSpan)
            % this = this.setBoundingBoxSpan([X Y Z])
            %
            % This member function sets the data field in bounding box
            % span format (1x3 - X,Y,Z).  The span is related to the property
            % xyzOffset which represents the starting corner of the the bounding box
            % that contains the annotation.
            %
            % If the query IS NOT restricted to a cutout the entire object
            % will be contained by the bounding box.
            % If the query IS restricted to a cutout the object may or may
            % not be contained entirely in the bounding box.
            
            if ~isempty(bboxSpan)
                validateattributes(bboxSpan,{'numeric'},{'finite','nonnegative','integer','nonnan','real','size', [1,3]});
            end
            
            this.data = bboxSpan;
            this.dataFormat = eRAMONDataFormat.boundingBox;
        end
        
        function this = setXyzOffset(this,coord)
            % this = setXyzOffset(this,[x y z])
            %
            % This member function sets the volume object xyzOffset field.
            if ~isempty(coord)
                validateattributes(coord,{'numeric'},{'finite','nonnegative','integer','nonnan','real','size', [1 3]});
            end
            this.xyzOffset = coord;
        end
        
        function this = setResolution(this,res)
            % this = setResolution(this,resolution)
            %
            % This member function sets the volume object resolution field.
            
            if ~isempty(res)
                validateattributes(res,{'numeric'},{'finite','nonnegative','integer','nonnan','real','scalar'});
            end
            this.resolution = res;
        end
        
        function this = setName(this,name)
            % this = setName(this,'string name')
            %
            % This member function sets the volume object name field.
            
            if isa(name, 'char')
                this.name = name;
            else
                ex = MException('RAMONVolume:NameTypeError','Name field must be a character string');
                throw(ex);
            end
        end
        
        function this = setUploadType(this,type)        
            % This member function sets the volume object upload type field.
            % The data will be converted to this type on upload! If there
            % is a mismatch between your data and the selected type
            % information could be lost. If there is a mismatch between the
            % database data type (specified by the token) and the upload
            % type the upload will fail.

            error('RAMONVolume:MethodDepricated', 'setUploadType has been depricated.  Use setDataType and eRAMONDataType instead. Note, this property now is automatically set by the OCP class in most cases.')
                        
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
                        
            if isa(type, 'eRAMONChannelDataType')
                % Is of Type eRAMONChannelDataType
                
            else
                % Is not of type eRAMONDataType
                validateattributes(type,{'numeric'},{'finite','nonnegative','integer','nonnan','real'});
                try
                    type = eRAMONChannelDataType(type);
                catch ME
                    rethrow(ME);
                end
            end
            
            this.dataType = type;
        end

        function this = setDBType(this,type)        
            % This member function sets the volume object database type field.
            % This specifies types like annotation, probmap, etc. See
            % eRAMONChannelType.
                        
            if isa(type, 'eRAMONChannelType')
                % Is of Type eRAMONChannelType
                
            else
                % Is not of type eRAMONDataType
                validateattributes(type,{'numeric'},{'finite','nonnegative','integer','nonnan','real'});
                try
                    type = eRAMONChannelType(type);
                catch ME
                    rethrow(ME);
                end
            end
            
            this.dbType = type;
        end

        function handle = clone(this,option)
            % Perform a deep copy because these are handles and not objects
            % default using the = operator just copies the handle and not
            % the underlying object.
            %
            % Optionally pass in 'novoxels' to perform copy without voxel
            % data
            %
            % ex: new_obj = my_obj.clone('novoxels');
            
            if ~exist('option','var');
                option = [];
            end
            
            % Instantiate new object of the same class.
            handle = feval(class(this));
            
            % Copy all properties.
            % Base
            handle = this.baseCloneHelper(handle);
            % Volume
            handle = this.volumeCloneHelper(handle,option);
            
        end
        
        
        %% Coordinate Transform Methods
        % Remember Matlab is 1 indexed!
        
        function globalCoord = local2Global(this,localCoord)
            % This method returns a given local coordinate (coordinate
            % system of the cutout) in global coordinates (coordinate
            % system of the database at the current resolution)
            
            if this.dataFormat ~= eRAMONDataFormat.dense
                error('RAMONVolume:DataFormatNotSupported',...
                    'Local2Global coordinate transform only applies to dense cutouts');
            end
            
            gx = localCoord(:,1) + this.xyzOffset(1) - 1;
            gy = localCoord(:,2) + this.xyzOffset(2) - 1;
            gz = localCoord(:,3) + this.xyzOffset(3) - 1;
            
            globalCoord = [gx gy gz];
        end
        
        function localCoord = global2Local(this,globalCoord)
            % This method returns a given global coordinates (coordinate
            % system of the database at the current resolution) in local
            % coordinates (coordinate system of the cutout)
            
            if this.dataFormat ~= eRAMONDataFormat.dense
                error('RAMONVolume:DataFormatNotSupported',...
                    'Global2Local coordinate transform only applies to dense cutouts');
            end
            
            lx = globalCoord(:,1) - this.xyzOffset(1) + 1;
            ly = globalCoord(:,2) - this.xyzOffset(2) + 1;
            lz = globalCoord(:,3) - this.xyzOffset(3) + 1;
            
            if sum(lx < 1) || sum(lx > size(this.data,2)) ||...
                    sum(ly < 1) || sum(ly > size(this.data,1)) ||...
                    sum(lz < 1) || sum(lz > size(this.data,3))
                
                warning('RAMONVolume:GCOutsideVolume',...
                    'At least 1 of the provided global coordinates are outside the local volume.');
            end
            
            localCoord = [lx ly lz];
        end
        
        %% Resolution Transform Methods
        %TODO
        
        %% VoxelList-Cutout Transform Methods
        function this = toVoxelList(this)
            % Convert the data to voxel list representation
            switch this.dataFormat
                case eRAMONDataFormat.dense
                    if unique(this.data) > 2
                        error('RAMONVolume:TooManyObjects',...
                            'You can only represent a single RAMON object as a voxel list.  Failed to convert annotation database cutout to voxel list');
                    end
                    
                    [y, x, z] = ind2sub(size(this.data), find(this.data ~= 0));
                    voxels = cat(2,x,y,z) + repmat(this.xyzOffset-1,length(x),1);
                    
                    this.setVoxelList(voxels);
                    this.setXyzOffset([]);
                    
                case eRAMONDataFormat.voxelList
                    % already in voxel list format
                    
                case eRAMONDataFormat.boundingBox
                    error('RAMONVolume:NotApplicable',...
                        'There is no voxel data stored with the bounding box data type.  Cannot convert to Voxel List.');
                    
                otherwise
                    error('Unsupported data format');
            end
        end
        
        function this = toCutout(this)
            % Convert the data to voxel list representation
            switch this.dataFormat
                case eRAMONDataFormat.dense
                    % already in cutout form
                    
                case eRAMONDataFormat.voxelList
                    this.setXyzOffset(min(this.data,[],1));
                    
                    this.data = this.data - repmat(this.xyzOffset - 1,size(this.data,1),1);
                    
                    maxVal = max(this.data,[],1);
                    
                    cutout = zeros(maxVal(2),maxVal(1),maxVal(3));
                    
                    inds = sub2ind(size(cutout),...
                        this.data(:,2),...
                        this.data(:,1),...
                        this.data(:,3));
                    if isempty(this.id)
                        cutout(inds) = 1;
                    else
                        cutout(inds) = this.id;
                    end
                    
                    this.setCutout(cutout);
                    
                case eRAMONDataFormat.boundingBox
                    error('RAMONVolume:NotApplicable',...
                        'There is no voxel data stored with the bounding box data type.  Cannot convert to cutout');
                    
                otherwise
                    error('Unsupported data format');
            end
        end
        
        function this = toBoundingBox(this)
            ex = MException('RAMONVolume:NotSupported','This method is not yet supported');
            throw(ex);
        end
        
        %% Create image query based on volume object.
        function queryObj = toImageDenseQuery(this)
            % If the volume object is holding a cutout, give a query that
            % would retrieve an image volume
            if this.dataFormat == eRAMONDataFormat.dense
                queryObj = OCPQuery(eOCPQueryType.imageDense);
                [y, x, z] = size(this.data);
                queryObj.setCutoutArgs([this.xyzOffset(1) this.xyzOffset(1) + x],...
                    [this.xyzOffset(2) this.xyzOffset(2) + y],...
                    [this.xyzOffset(3) this.xyzOffset(3) + z],...
                    this.resolution);
            else
                queryObj = [];
            end
        end
        
        function queryObj = toAnnoDenseQuery(this)
            % If the volume object is holding a cutout, give a query that
            % would retrieve an annotation volume
            if this.dataFormat == eRAMONDataFormat.dense
                queryObj = OCPQuery(eOCPQueryType.annoDense);
                [y, x, z] = size(this.data);
                queryObj.setCutoutArgs([this.xyzOffset(1) this.xyzOffset(1) + x],...
                    [this.xyzOffset(2) this.xyzOffset(2) + y],...
                    [this.xyzOffset(3) this.xyzOffset(3) + z],...
                    this.resolution);
            else
                queryObj = [];
            end
        end
        
        %% Volume Support Methods
        function dims = size(this, dim)
            % dims = SIZE(obj)
            % dims = SIZE(obj, dim)
            %
            % Returns the dimension of the RAMONVolume
            % See SIZE for more information on usage
            %
            
            if exist('dim','var')
                dims = size(this.data,dim);
            else
                dims = size(this.data);
            end
                
        end
        
        function count = voxelCount(this)
            % Returns the number of voxels stored in the RAMONVolume object
            if isempty(this.dataFormat)
                count = 0;
            else
                switch this.dataFormat
                    case eRAMONDataFormat.dense
                        [x,y,z] = size(this.data);
                        count = x*y*z;
                        
                    case eRAMONDataFormat.voxelList
                        count = size(this.data, 1);
                        
                    case eRAMONDataFormat.boundingBox
                        error('RAMONVolume:NotApplicable',...
                            'There is no voxel data stored with the bounding box data type.  Cannot compute voxel count.');
                        
                    otherwise
                        error('Unsupported data format');
                end
            end
        end
        
        
        function h = image(this, slice, pos)
            if nargin < 2,
                slice = [];
            end
            
            if nargin < 3,
                pos = [];
            end
            
            if isempty(pos),
                pos = [100,100];
            end
            
            if isempty(slice),
                slice = this.sliceDisplayIndex;
            else
                this.sliceDisplayIndex = slice;
            end
            
            if slice > this.size(3) || slice < 1
                warning('RAMONVolume:SliceInvalid',...
                    'Slice number %d out of range.  %d slices available\n',...
                    slice,this.size(3));
                slice = 1;
            end
            
            h = VolumeImageBox(this.data, this.xyzOffset, slice, pos, this.name, this.dataType);
        end
        
        
        function notify_dataupdate_(this)
            % This function is called when the data within the object is updated.
            % It is up to the user to override this function for additional
            % functionality.
            %
            
        end
        
        function notify_dimensionupdate_(this)
            % This function is called the the data dimensions are updated by a
            % class member function. It is up to the user to override this
            % function for additional functionality.
            
        end
    end
    
    %% Methods - Utility Functions
    methods(Access = protected)
        function this = initVoxelData(this, data, format)
            % This method is used by the constructor to properly set the data and format
            
            switch format
                case eRAMONDataFormat.dense
                    this.setCutout(data);
                    
                case eRAMONDataFormat.voxelList
                    this.setVoxelList(data);
                    
                case eRAMONDataFormat.boundingBox
                    this.setBoundingBoxSpan(data);
                    
                otherwise
                    ex = MException('RAMONVolume:UnsupportedFormat','The specified data format is unsupported: %s', char(format));
                    throw(ex);
            end
        end
        
        function handle = volumeCloneHelper(this, handle, option)
            % Copy all properties.
            handle.setResolution(this.resolution);
            if ~exist('option','var')
                % Normal copy
                switch this.dataFormat
                    case eRAMONDataFormat.boundingBox
                        handle.setBoundingBoxSpan(this.data);
                        
                    case eRAMONDataFormat.dense
                        handle.setCutout(this.data);
                        
                    case eRAMONDataFormat.voxelList
                        handle.setVoxelList(this.data);
                end
                
                handle.setXyzOffset(this.xyzOffset);
                handle.setDataType(this.dataType);
            else
                % copy with option
                
                if isempty(option)
                    % you passed in [] for the option which means do normal
                    % copy
                    % Normal copy
                    switch this.dataFormat
                        case eRAMONDataFormat.boundingBox
                            handle.setBoundingBoxSpan(this.data);
                            
                        case eRAMONDataFormat.dense
                            handle.setCutout(this.data);
                            
                        case eRAMONDataFormat.voxelList
                            handle.setVoxelList(this.data);
                    end
                    
                    handle.setXyzOffset(this.xyzOffset);
                    handle.setDataType(this.dataType);
                elseif strcmpi(option,'novoxels') == 0
                    error('RAMONVolume:InvalidCloneOption',...
                        'Currently "novoxels" is the only supported option');
                end
            end
            
        end
        
        function ramonObj = setRAMONVolumeProperties(this,ramonObj)
            % RAMONVolume
            switch this.dataFormat
                case eRAMONDataFormat.dense
                    ramonObj.setCutout(this.data);
                    
                case eRAMONDataFormat.voxelList
                    ramonObj.setVoxelList(this.data);
                    
                case eRAMONDataFormat.boundingBox
                    ramonObj.setBoundingBoxSpan(this.data);
                    
                otherwise
                    ex = MException('RAMONVolume:UnsupportedFormat','The specified data format is unsupported: %s', char(format));
                    throw(ex);
            end
            
            ramonObj.setXyzOffset(this.xyzOffset);
            ramonObj.setResolution(this.resolution);
            ramonObj.setDataFormat(this.dataFormat);
        end
        
        function this = setDataFormat(this,format)
            % this = setDataFormat(this,true)
            %
            % This member function sets the volume object dataFormat field.
            if isempty(format)
                ex = MException('RAMONVolume:FormatMissing','No data format specified.');
                throw(ex);
            end
            
            if isa(format, 'eRAMONDataFormat')
                % Is of Type eRAMONDataFormat
                
            else
                % Is not of type eRAMONSegmentClass
                validateattributes(format,{'numeric'},{'finite','nonnegative','integer','nonnan','real'});
                try
                    format = eRAMONDataFormat(uint32(format));
                catch ME
                    rethrow(ME);
                end
            end
            
            this.dataFormat = format;
        end
    end
    
end

