classdef OCPHdf < handle
    %OCPHdf ************************************************
    % Provides advanced hdf file handling and transformation capability for
    % use with OCP framework
    %
    % Usage:
    %
    %  h = OCPHdf(); Creates object
    %
    % Constructor is "overloaded":
    %  h = OCPHdf(RAMONobject); Converts RAMON Object to HDF5 File
    %  h = OCPHdf({RAMONobjects}); Converts cell array of RAMON Objects
    %           to an HDF5 File
    %  h = OCPHdf(OCPQuery); Sets query object property
    %  h = OCPHdf('/path/to/hdf5.h5'); Sets filename property
    %  h = OCPHdf(RAMONVolume, '/path/to/hdf5.h5'); Convert volume to
    %                                                    HDF5 specified by filename
    %  h = OCPHdf(OCPQuery,'/path/to/hdf5.h5'); Creates object based
    %                                                on existing HDF5 file and OCPQuery object
    %
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
    
    properties
        filename = '';
        query = [];
    end
    
    properties(SetAccess = 'private', GetAccess = 'private')
        ramonType = [];
    end
    
    methods( Access = public )
        %% Methods - General
        function this = OCPHdf(varargin)
            % Constructor
            switch nargin
                case 0
                case 1
                    % Handle "Overloading"
                    if strcmpi(class(varargin{1}),'RAMONGeneric') ||...
                            strcmpi(class(varargin{1}),'RAMONSeed') ||...
                            strcmpi(class(varargin{1}),'RAMONSynapse') ||...
                            strcmpi(class(varargin{1}),'RAMONSegment') ||...
                            strcmpi(class(varargin{1}),'RAMONNeuron') ||...
                            strcmpi(class(varargin{1}),'RAMONOrganelle') ||...
                            strcmpi(class(varargin{1}),'RAMONVolume')  
                        % Ramon object passed in. Convert to HDF5 and set
                        % filename.
                        
                        this.setFilename(this.Ramon2Hdf(varargin{1}));
                        
                    elseif isa(varargin{1},'OCPQuery')
                        % Just passing in the path to a query object
                        this.setQuery(varargin{1});
                    elseif isa(varargin{1},'char')
                        % Just passing in the path to an existing hdf5 file
                        this.setFilename(char(varargin{1}));
                    elseif isa(varargin{1},'cell')
                        % Passing in a cell array of RAMON objects that
                        % need converted
                        this.setFilename(this.Ramon2Hdf(varargin{1}));
                    else
                        ex = MException('OCPHdf:ArgError','Unsupported argument in constructor');
                        throw(ex);
                    end
                case 2
                    if strcmpi(class(varargin{1}),'RAMONVolume')
                        % Passing in a RAMONVolume and a path to save the
                        % hdf5 file.
                        this.setFilename(this.Ramon2Hdf(varargin{1},varargin{2}));
                    else
                        % Just passing in the path to an existing hdf5 file
                        % along with it's associated OCPQuery object
                        this.setFilename(char(varargin{1}));
                        this.setQuery(varargin{2});
                    end
                otherwise
                    ex = MException('OCPHdf:ArgError','Invalid number of arguments in constructor');
                    throw(ex);
            end
        end
        
        function this = setFilename(this, file)
            this.filename = file;
        end
        function this = setQuery(this, q)
            this.query = q;
        end
        
        %% Methods - HDF5 to MATLAB Structure
        function h5Struct = toStruct(this)
            % Method to load an HDF5 file into a matlab structure
            %
            % ocph5 = OCPhdf('/path/to/file.h5')
            % data = ocph5.toStruct();
            %
            % Parameters
            % ----------
            %
            % file
            %     Name of the file to load data from
            % path : optional
            %     Path to the part of the HDF5 file to load
            
            
            loc = H5F.open(this.filename, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
            try
                h5Struct = this.loadH5Recursive(loc);
                H5F.close(loc);
            catch exc
                H5F.close(loc);
                rethrow(exc);
            end
            
        end
        
        %% Methods - HDF5 to RAMONVolume type
        function volumeObj = toRAMONVolume(this,groupName)
            % Method to take a cutout and put it into a RAMON volume
            % object. This is useful for viewing and compatibility between
            % programs.  Also it provides additional information about the
            % cutout compared to a simple MATLAB matrix.
            
            if nargin == 1
                groupName = '';
            end
            
            if isempty(this.filename)
                ex = MException('OCPHdf:FilenameMissing','HDF5 file required to create RAMONVolume');
                throw(ex);
            end
            
            if isempty(this.query)
                ex = MException('OCPHdf:QueryMissing','Query object required to create RAMONVolume');
                throw(ex);
            end
            
            if isempty(groupName)
                % Get data type
                data_type = h5read(this.filename,'/DATATYPE');     
            else 
                dtpath = sprintf('/%s/DATATYPE', groupName);
                data_type = h5read(this.filename, dtpath);
            end
            
%             if ~isa(data_type{1}, 'eRAMONChanelDataType')
%                 error('OCPHdf:toRAMONVolume','Unsupported datatype: %s',data_type{1});
%             end
            
            % Based on datatype grab the data

            % AB TODO -- this is a stupid and broken way to do this. do it
            % better. 
            switch eRAMONChannelDataType.(data_type{1})
                % image8,anno32,prob32,bitmask,anno64,image16
                % single channel data
                case {eRAMONChannelDataType.uint8,...
                        eRAMONChannelDataType.uint16,...
                        eRAMONChannelDataType.uint32,...
                        eRAMONChannelDataType.uint64,...
                        eRAMONChannelDataType.float32}
                    % Create object
                    volumeObj = RAMONVolume();

                    % Load data
                    if isempty(groupName)
                        ctpath = sprintf('/CUTOUT');
                    else
                        ctpath = sprintf('/%s/CUTOUT',groupName);
                    end
                    cube = h5read(this.filename,ctpath);
                    cube = permute(cube, [2 1 3]);
                    %n = 'Cutout';

                    % Populate object
                    volumeObj = volumeObj.setCutout(cube);
                    volumeObj = volumeObj.setXyzOffset([this.query.xRange(1) this.query.yRange(1) this.query.zRange(1)]);
                    volumeObj = volumeObj.setResolution(this.query.resolution);
                    volumeObj = volumeObj.setName(groupName);
                    
%                 case {3,4}
%                     % channels16,channels8
%                     % multichannel data
%                     volumeObj = cell(1,length(this.query.channels));
% 
%                     % create cell array of volume objects!
%                     for ii = 1:length(this.query.channels)                    
%                         v = RAMONVolume();
% 
%                         ch = strrep(this.query.channels{ii},'__','-');
%                         cube = h5read(this.filename,['/CUTOUT/' ch]);
%                         cube = permute(cube, [2 1 3]);
% 
%                         v = v.setCutout(cube);
%                         v = v.setXyzOffset([this.query.xRange(1) this.query.yRange(1) this.query.zRange(1)]);
%                         v = v.setResolution(this.query.resolution);
%                         v = v.setName(ch);
%                         volumeObj{ii} = v;
%                     end      
                    
                case {9,10}
                    % rgba32,rgba64
                    % Create object
                    volumeObj = RAMONVolume();

                    % Load data
                    if isempty(groupName)
                        ctpath = sprintf('/CUTOUT');
                    else
                        ctpath = sprintf('/%s/CUTOUT',groupName);
                    end
                    cube = h5read(this.filename,ctpath);

                    % handle RGBA data
                    cube = permute(cube, [2 1 3 4]);
                    n = 'RGBA32 Cutout';
       
                    % Populate object
                    volumeObj = volumeObj.setCutout(cube);
                    volumeObj = volumeObj.setXyzOffset([this.query.xRange(1) this.query.yRange(1) this.query.zRange(1)]);
                    volumeObj = volumeObj.setResolution(this.query.resolution);
                    volumeObj = volumeObj.setName(n);
                otherwise
                    error('OCPHdf:toRAMONVolume','Unsupported datatype: %s',data_type{1});
                    

            end
        end
        
        %% Methods - HDF5 to MATLAB matrix
        function data = toMatrix(this)
            % Method to take a cutout and put it into a MATLAB matrix.
            % Only database cutouts (imageCutout, annoCutout) support this
            
            if isempty(this.filename)
                ex = MException('OCPHdf:FilenameMissing','HDF5 file required to create a matrix');
                throw(ex);
            end
            
            % Get the thing to read
            info = h5info(this.filename);
            
            if length(info.Datasets) == 1
                dname = sprintf('/%s',info.Datasets.Name);
                data = h5read(this.filename,dname);
                data = permute(data, [2 1 3]);
            elseif length(info.Datasets) > 1
                for ii = 1:length(info.Datasets)
                    dname = sprintf('/%s',info.Datasets.Name);
                    tdata = h5read(this.filename,dname);
                    data{ii} = permute(tdata, [2 1 3]);
                end
            else
                data = [];
            end
        end
        
        %% Methods - HDF5 to RAMONObject
        function ramonObjOut = toRAMONObject(this,qObj)
            
            % If you pass in a eOCPQueryType instead of an actual query object
            % just build what you need.
            if ~(strcmpi(this.ramonType,'RAMONSeed') || strcmpi(this.ramonType,'RAMONNeuron') || ...
                    strcmpi(this.ramonType,'RAMONBase'))
                if exist('qObj','var')
                    if isa(qObj,'eOCPQueryType')
                        qObj = OCPQuery(qObj);
                    end
                else
                    ex = MException('OCPHdf:DataFormatMissing',...
                        'You must specify the format of the voxel data as an eOCPQueryType - ie. RAMONDense');
                    throw(ex);
                end
            end
            
            % Get Object Information
            info = h5info(this.filename);
            numObjects = length(info.Groups);
            if numObjects == 0
                ex = MException('OCPHdf:InvalidFormat','HDF5 File format error.  Cannot parse object.');
                throw(ex);
            end
            if numObjects == 1
                ramonObjOut = [];
            else
                ramonObjOut = cell(1,numObjects);
            end
            
            % Loop on objects in file
            for ii = 1:numObjects
                % Get ID
                rootGroup = info.Groups(ii).Name;
                
                % Get annotation type
                annotationType = h5read(this.filename,sprintf('%s/ANNOTATION_TYPE',rootGroup));
                
                switch annotationType
                    case uint32(eRAMONAnnoType.generic)
                        % Create Generic
                        ramonObj = RAMONGeneric();
                        
                        % Set ID
                        ramonObj.setId(str2double(rootGroup(2:end)));
                        
                        % Populate Confidence, Status, and kv pairs
                        ramonObj = OCPHdf.getCommonMetadata(this.filename,ramonObj,rootGroup);
                        
                        % Populate Voxel Data Fields
                        if qObj.type ~= eOCPQueryType.RAMONMetaOnly;
                            ramonObj = OCPHdf.getVoxelData(this.filename, ramonObj, rootGroup, qObj);
                        end
                        
                     case uint32(eRAMONAnnoType.volume)
                        % Create Generic
                        ramonObj = RAMONVolume();
                        
                        % Set ID
                        ramonObj.setId(str2double(rootGroup(2:end)));
                        
                        % Populate Confidence, Status, and kv pairs
                        ramonObj = OCPHdf.getCommonMetadata(this.filename,ramonObj,rootGroup);
                        
                        % Populate Voxel Data Fields
                        ramonObj = OCPHdf.getVoxelData(this.filename, ramonObj, rootGroup, qObj);
                        
                    case uint32(eRAMONAnnoType.seed)
                        % Create seed
                        ramonObj = RAMONSeed();
                        
                        % Set ID
                        ramonObj.setId(str2double(rootGroup(2:end)));
                        
                        % Populate Position Field
                        pos = h5read(this.filename,sprintf('%s/METADATA/POSITION',rootGroup));
                        ramonObj.setPosition(double(pos'));
                        
                        % Populate Cube Location Field
                        data = OCPHdf.getOptionalField(this.filename, sprintf('%s/METADATA/CUBE_LOCATION',rootGroup), eRAMONCubeOrientation.centered);
                        ramonObj.setCubeOrientation(double(data));
                        
                        % Populate Parent Seed Field
                        data = OCPHdf.getOptionalField(this.filename, sprintf('%s/METADATA/PARENT',rootGroup), []);
                        ramonObj.setParentSeed(double(data));
                        
                        % Populate Source Entity Field
                        data = OCPHdf.getOptionalField(this.filename, sprintf('%s/METADATA/SOURCE',rootGroup), []);
                        ramonObj.setSourceEntity(double(data));
                        
                        % Populate ID, Confidence, Status, and kv pairs
                        ramonObj = OCPHdf.getCommonMetadata(this.filename,ramonObj,rootGroup);
                        
                    case uint32(eRAMONAnnoType.synapse)
                        % Create synapse
                        ramonObj = RAMONSynapse();
                        
                        % Set ID
                        ramonObj.setId(str2double(rootGroup(2:end)));
                        
                        % Populate Confidence, Status, and kv pairs
                        ramonObj = OCPHdf.getCommonMetadata(this.filename,ramonObj,rootGroup);
                        
                        % Populate Voxel Data Fields
                        if qObj.type ~= eOCPQueryType.RAMONMetaOnly;
                            ramonObj = OCPHdf.getVoxelData(this.filename, ramonObj, rootGroup, qObj);
                        end
                        
                        % Populate Synapse Type Field
                        type = h5read(this.filename,sprintf('%s/METADATA/SYNAPSE_TYPE',rootGroup));
                        ramonObj.setSynapseType(double(type));
                        
                        % Populate Seeds Field
                        data = OCPHdf.getOptionalField(this.filename, sprintf('%s/METADATA/SEEDS',rootGroup), []);
                        ramonObj.setSeeds(double(data'));
                        
                        % Populate Segments Field
                        data = OCPHdf.getOptionalField(this.filename, sprintf('%s/METADATA/SEGMENTS',rootGroup), []);
                        data = data';
                        for gg = 1:size(data,1)
                            ramonObj.addSegment(data(gg,1),data(gg,2));
                        end
                        
                        % Populate Weight Field
                        data = OCPHdf.getOptionalField(this.filename, sprintf('%s/METADATA/WEIGHT',rootGroup), []);
                        ramonObj.setWeight(double(data));
                        
                    case uint32(eRAMONAnnoType.segment)
                        % Create synapse
                        ramonObj = RAMONSegment();
                        
                        % Set ID
                        ramonObj.setId(str2double(rootGroup(2:end)));
                        
                        % Populate Confidence, Status, kv pairs, and author
                        ramonObj = OCPHdf.getCommonMetadata(this.filename,ramonObj,rootGroup);
                        
                        % Populate Voxel Data Fields
                        if qObj.type ~= eOCPQueryType.RAMONMetaOnly;
                            ramonObj = OCPHdf.getVoxelData(this.filename, ramonObj, rootGroup, qObj);
                        end
                        
                        % Populate Synapse Type Field
                        type = h5read(this.filename,sprintf('%s/METADATA/SEGMENTCLASS',rootGroup));
                        ramonObj.setClass(double(type));
                        
                        % Populate Seeds Field
                        data = OCPHdf.getOptionalField(this.filename, sprintf('%s/METADATA/SYNAPSES',rootGroup), []);
                        ramonObj.setSynapses(double(data'));
                        
                        % Populate Segments Field
                        data = OCPHdf.getOptionalField(this.filename, sprintf('%s/METADATA/ORGANELLES',rootGroup), []);
                        ramonObj.setOrganelles(double(data'));
                        
                        % Populate Neuron Field
                        data = OCPHdf.getOptionalField(this.filename, sprintf('%s/METADATA/NEURON',rootGroup), []);
                        ramonObj.setNeuron(double(data));
                        
                        % Populate Weight Field
                        data = OCPHdf.getOptionalField(this.filename, sprintf('%s/METADATA/PARENTSEED',rootGroup), []);
                        ramonObj.setParentSeed(double(data));
                    case uint32(eRAMONAnnoType.neuron)
                        % Create neuron
                        ramonObj = RAMONNeuron();
                        
                        % Set ID
                        ramonObj.setId(str2double(rootGroup(2:end)));
                        
                        % Populate Segment Field (Optional)
                        seg = OCPHdf.getOptionalField(this.filename, sprintf('%s/METADATA/SEGMENTS',rootGroup), []);
                        ramonObj.setSegments(double(seg'));
                        
                        % Populate ID, Confidence, Status, and kv pairs
                        ramonObj = OCPHdf.getCommonMetadata(this.filename,ramonObj,rootGroup);
                        
                    case uint32(eRAMONAnnoType.organelle)
                        % Create synapse
                        ramonObj = RAMONOrganelle();
                        
                        % Set ID
                        ramonObj.setId(str2double(rootGroup(2:end)));
                        
                        % Populate Confidence, Status, and kv pairs
                        ramonObj = OCPHdf.getCommonMetadata(this.filename,ramonObj,rootGroup);
                        
                        % Populate Voxel Data Fields
                        if qObj.type ~= eOCPQueryType.RAMONMetaOnly;
                            ramonObj = OCPHdf.getVoxelData(this.filename, ramonObj, rootGroup, qObj);
                        end
                        
                        % Populate Organelle Class Field
                        type = h5read(this.filename,sprintf('%s/METADATA/ORGANELLECLASS',rootGroup));
                        ramonObj.setClass(double(type));
                        
                        % Populate Seeds Field
                        data = OCPHdf.getOptionalField(this.filename, sprintf('%s/METADATA/SEEDS',rootGroup), []);
                        ramonObj.setSeeds(double(data'));                        
                        
                        % Populate Parent Seed Field
                        data = OCPHdf.getOptionalField(this.filename, sprintf('%s/METADATA/PARENTSEED',rootGroup), []);
                        ramonObj.setParentSeed(double(data));
                        
                        
                    otherwise
                        % Not a supported RAMON type.
                        ex = MException('OCPHdf:UnsupportedType','Attempting to convert an unsupported RAMON annotation type: %d',annotationType);
                        throw(ex);
                        
                end
                
                if numObjects == 1
                    ramonObjOut = ramonObj;
                else
                    ramonObjOut{ii} = ramonObj; %#ok<*AGROW>
                end
            end
        end
        
        %% Methods - Query to Cutout HDF file
        function h5file = toCutoutHDF(this)
            
            % Create HDF5 file
            tempLocation = getenv('PIPELINE_TEMP_DIR');
            if isempty(tempLocation)
                [path, name, ~] = fileparts(tempname); 
                h5file = fullfile(path,sprintf('OCPHdf_Cutout_%s.h5',name));
            else
                [~, name, ~] = fileparts(tempname); 
                h5file = fullfile(tempLocation,sprintf('OCPHdf_Cutout_%s.h5',name));
            end               
                
            h5Handle =  H5F.create(h5file, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
            
            % Write Resolution
            space = H5S.create_simple(1,1,1);
            dset = H5D.create(h5Handle, '/RESOLUTION', 'H5T_STD_U32LE', space, 'H5P_DEFAULT');
            H5D.write (dset, 'H5T_NATIVE_INT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', uint32(this.query.resolution));
            H5D.close (dset);
            H5S.close (space);
            
            % Write xyzOffset
            xyzOffset = [this.query.xRange(1) this.query.yRange(1) this.query.zRange(1)];
            dims = size(xyzOffset);
            rankVal = 1;
            dims = dims(2);
            space = H5S.create_simple(rankVal,fliplr(dims),fliplr(dims));
            dset = H5D.create(h5Handle, '/XYZOFFSET', 'H5T_STD_U32LE', space, 'H5P_DEFAULT');
            H5D.write (dset, 'H5T_NATIVE_INT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', uint32(xyzOffset)');
            H5D.close (dset);
            H5S.close (space);
            
            % Write CUTOUTSIZE
            cutoutSize = [this.query.xRange(2) - this.query.xRange(1),...
                this.query.yRange(2) - this.query.yRange(1),...
                this.query.zRange(2) - this.query.zRange(1)];
            space = H5S.create_simple(rankVal,fliplr(dims),fliplr(dims));
            dset = H5D.create(h5Handle, '/CUTOUTSIZE', 'H5T_STD_U32LE', space, 'H5P_DEFAULT');
            H5D.write (dset, 'H5T_NATIVE_INT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', uint32(cutoutSize)');
            H5D.close (dset);
            H5S.close (space);
            
            H5F.close(h5Handle);
            
            % If done set filename in class
            this.setFilename(h5file);
            
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%% Private Methods %%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    methods( Access = private )
        
        %% Private Methods - Ramon2Hdf
        function hdfFile = Ramon2Hdf(this,ramonObjIn,outputFilename)
            %Ramon2Hdf Function to convert RAMON objects to HDF5 files
            % RAMON objects that support conversion to hdf5 objects have toHDF
            % methods that invoke this function
            %
            % Currently supports converting:
            %   RAMONGeneric
            %   RAMONSeed
            %   RAMONSynapse
            %   RAMONSegment
            %   RAMONNeuron
            %   RAMONVolume
            %%%%%
            
            % if outputFilename is not specified, create temp filename
            if exist('outputFilename','var')
                hdfFile = outputFilename;
            else                
                tempLocation = getenv('PIPELINE_TEMP_DIR');
                if isempty(tempLocation)
                    [path, name, ~] = fileparts(tempname); 
                    hdfFile = fullfile(path,sprintf('OCPHdf_RAMON_%s.h5',name));
                else
                    [~, name, ~] = fileparts(tempname); 
                    hdfFile = fullfile(tempLocation,sprintf('OCPHdf_RAMON_%s.h5',name));
                end  
            end
            
            if isa(ramonObjIn,'cell')
                % Batch Upload!
                this.ramonType = 'batch';
            else
                % Set type
                ramonObj = ramonObjIn;
                this.ramonType = class(ramonObj);
            end
            
            for ii = 1:length(ramonObjIn)
                if isa(ramonObjIn,'cell')
                    % Batch Upload!
                    % Check to see if IDs are set or if OCP should assign
                    empty_ids = cellfun(@(x) isempty(x.id),ramonObjIn);
                    if sum(empty_ids) > 0 && sum(empty_ids) ~= length(empty_ids)
                        % There a MIX of assigned and non-assigned IDs.
                        % Current we don't support this in a single batch.
                        error('OCPHdf:MixedIDBatch',...
                        'You currently cannot mix a batch upload with pre-assigned and empty ids');
                    end
                    
                    if sum(empty_ids) == 0
                        % Pre-assigned IDs
                        ramonId = ramonObjIn{ii}.id;
                    else
                        % Empty ids!
                        % make id decimal so batch interface kicks in
                        ramonId = str2double(sprintf('1.%04d',ii));
                    end
                    ramonObj = ramonObjIn{ii};
                else
                    % Single annotation
                    if isempty(ramonObj.id)
                        ramonObj.setId(0);
                    end
                    ramonId = ramonObj.id;
                end
                
                % Switch off object type and build hdf5 file
                switch class(ramonObj)
                    case 'RAMONGeneric'
                        % Init file - write ID and Annotation Type
                       
                        if ii == 1
                            h5Handle = OCPHdf.initH5Obj(hdfFile, ramonId, eRAMONAnnoType.generic);
                        else
                            OCPHdf.addDataset(h5Handle, ramonId, eRAMONAnnoType.generic);
                        end

                        % Add Voxel Data
                        OCPHdf.addVoxelData(h5Handle, ramonObj,ramonId)

                        % Write Confidence, Status, KVPairs, author
                        OCPHdf.writeCommonMetadata(h5Handle,ramonObj,ramonId)
                    case 'RAMONVolume'
                        % This is a block style upload of DB data.
                        % Currently Probabilty Maps and 32bit Annotations
                        % are supported
                        
                        % No batch interface for block style uploads!
                        if isa(ramonObjIn,'cell')
                            error('OCPHdf:BatchNotSupported','Batch uploads are not supported with block style uploading');
                        end            
 
                        % Add Voxel Data 
                        if isempty(ramonObj.data)
                            error('OCPHdf:NoData','RAMONVolume is empty.  No data to upload.');
                        end
                     
                        if isempty(ramonObj.dataType)
                            % trying to simply save a RAMONVolume object
                            h5Handle = OCPHdf.initH5Obj(hdfFile, ramonId, eRAMONAnnoType.volume);
                            
                            % Add Voxel Data
                            OCPHdf.addVoxelData(h5Handle, ramonObj,ramonId)

                            % Write Confidence, Status, KVPairs, author
                            OCPHdf.writeCommonMetadata(h5Handle,ramonObj,ramonId)                            
                        else
                            % Trying to block style upload  
                            switch ramonObj.dataType
                                case eRAMONChannelDataType.uint32
                                    switch ramonObj.dbType 
                                        case eRAMONChannelType.probmap 
                                            % Create HDF5 file
                                            h5Handle =  H5F.create(hdfFile, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');            
                                            % Probability Map                                    
                                            OCPHdf.addBlockData(h5Handle, ramonObj.channel, single(ramonObj.data), 'H5T_IEEE_F32LE','H5T_IEEE_F32LE');
                                        case eRAMONChannelType.annotation
                                            % Create HDF5 file
                                            h5Handle =  H5F.create(hdfFile, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
                                            % add group 
                                            gid = H5G.create(h5Handle,ramonObj.channel,'H5P_DEFAULT','H5P_DEFAULT','H5P_DEFAULT');
                                            % 32Bit annotations
                                            OCPHdf.addBlockData(h5Handle, ramonObj.channel, uint32(ramonObj.data), 'H5T_STD_U32LE','H5T_NATIVE_INT');  
                                    end   
                                    
                                case eRAMONDataType.uint16
                                    % Create HDF5 file
                                    h5Handle =  H5F.create(hdfFile, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');     
                                    % 32Bit annotations                                
                                    OCPHdf.addBlockData(h5Handle, ramonObj.channel, uint16(ramonObj.data), 'H5T_STD_U16LE','H5T_STD_U16LE');
                                    
                                    
                                case eRAMONDataType.uint8
                                    % Create HDF5 file
                                    h5Handle =  H5F.create(hdfFile, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');     
                                    % 32Bit annotations                                
                                    OCPHdf.addBlockData(h5Handle, ramonObj.channel, uint8(ramonObj.data), 'H5T_STD_U8LE','H5T_STD_U8LE');
                                    
                                
%                                 case eRAMONDataType.image8
%                                     % Trying to save 8bit image data
%                                     %OCPHdf.addBlockData(h5Handle, uint8(ramonObj.data), 'H5T_STD_U8LE','H5T_STD_U8LE'); 
%                                     
%                                     % trying to simply save a RAMONVolume object
%                                     h5Handle = OCPHdf.initH5Obj(hdfFile, ramonId, eRAMONAnnoType.volume);
% 
%                                     % Add Voxel Data
%                                     OCPHdf.addVoxelData(h5Handle, ramonObj,ramonId)
% 
%                                     % Write Confidence, Status, KVPairs, author
%                                     OCPHdf.writeCommonMetadata(h5Handle,ramonObj,ramonId)                  

                                otherwise
                                    error('OCPHdf:UnsupportedUploadType','Unsupported type for block style uploads');
                            end
                        end

                    case 'RAMONSeed'
                        % Init file - write ID and Annotation Type

                        if ii == 1
                            h5Handle = OCPHdf.initH5Obj(hdfFile, ramonId, eRAMONAnnoType.seed);
                        else
                            OCPHdf.addDataset(h5Handle, ramonId, eRAMONAnnoType.seed);
                        end

                        % Write Confidence, Status, KVPairs, author
                        OCPHdf.writeCommonMetadata(h5Handle,ramonObj,ramonId);

                        % Write Position Metadata
                        OCPHdf.addMetadata(h5Handle, ramonId, 'POSITION', uint32(ramonObj.position),2);

                        % Write Cube Location Metadata
                        OCPHdf.addMetadata(h5Handle, ramonId, 'CUBE_LOCATION', uint32(ramonObj.cubeOrientation));

                        % Write Parent Seed Metadata
                        OCPHdf.addMetadata(h5Handle, ramonId, 'PARENT', uint32(ramonObj.parentSeed));

                        % Write Source Entity Metadata
                        OCPHdf.addMetadata(h5Handle, ramonId, 'SOURCE', uint32(ramonObj.sourceEntity));


                    case 'RAMONSynapse'
                        % Init file - write ID and Annotation Type  
                        if ii == 1
                            h5Handle = OCPHdf.initH5Obj(hdfFile, ramonId, eRAMONAnnoType.synapse);
                        else
                            OCPHdf.addDataset(h5Handle, ramonId, eRAMONAnnoType.synapse);
                        end

                        % Add Voxel Data
                        OCPHdf.addVoxelData(h5Handle, ramonObj,ramonId)

                        % Write Confidence, Status, KVPairs, author
                        OCPHdf.writeCommonMetadata(h5Handle,ramonObj,ramonId)

                        % Write Seed Metadata
                        OCPHdf.addMetadata(h5Handle, ramonId, 'SEEDS', uint32(ramonObj.seeds),2);

                        % Write Cube Location Metadata
                        segMat = [];
                        keys = ramonObj.segments.keys;
                        values = ramonObj.segments.values;
                        for gg = 1:ramonObj.segments.Count
                            segMat = cat(1,segMat,[keys{gg} values{gg}]);
                        end
                        %if gg ~= 1
                        %    segMat = segMat';
                        %end
                        OCPHdf.addMetadata(h5Handle, ramonId, 'SEGMENTS', uint32(segMat));

                        % Write Parent Synapse Type Metadata
                        OCPHdf.addMetadata(h5Handle, ramonId, 'SYNAPSE_TYPE', uint32(ramonObj.synapseType));

                        % Write Synape Weight Metadata
                        OCPHdf.addMetadata(h5Handle, ramonId, 'WEIGHT', double(ramonObj.weight));


                    case 'RAMONSegment'
                        % Init file - write ID and Annotation Type
                       
 
                        if ii == 1
                            h5Handle = OCPHdf.initH5Obj(hdfFile, ramonId, eRAMONAnnoType.segment);
                        else
                            OCPHdf.addDataset(h5Handle, ramonId, eRAMONAnnoType.segment);
                        end

                        % Add Voxel Data
                        OCPHdf.addVoxelData(h5Handle, ramonObj,ramonId)

                        % Write Confidence, Status, KVPairs, author
                        OCPHdf.writeCommonMetadata(h5Handle,ramonObj,ramonId)

                        % Write the class of Segemnt Metadata
                        OCPHdf.addMetadata(h5Handle, ramonId, 'SEGMENTCLASS', uint32(ramonObj.class));

                        % Write Synapse ID Metadata
                        OCPHdf.addMetadata(h5Handle, ramonId, 'SYNAPSES', uint32(ramonObj.synapses),2);

                        % Write Organelle ID Metadata
                        OCPHdf.addMetadata(h5Handle, ramonId, 'ORGANELLES', uint32(ramonObj.organelles),2);

                        % Write the Neuron Metadata
                        OCPHdf.addMetadata(h5Handle, ramonId, 'NEURON', uint32(ramonObj.neuron));

                        % Write the Parent Seed Metadata
                        OCPHdf.addMetadata(h5Handle, ramonId, 'PARENTSEED', uint32(ramonObj.parentSeed));


                    case 'RAMONNeuron'
                        % Init file - write ID and Annotation Type
                        

                        if ii == 1
                            h5Handle = OCPHdf.initH5Obj(hdfFile, ramonId, eRAMONAnnoType.neuron);
                        else
                            OCPHdf.addDataset(h5Handle, ramonId, eRAMONAnnoType.neuron);
                        end

                        % Write Confidence, Status, KVPairs, author
                        OCPHdf.writeCommonMetadata(h5Handle,ramonObj,ramonId)

                        % Write Segment Metadata
                        OCPHdf.addMetadata(h5Handle, ramonId, 'SEGMENTS', uint32(ramonObj.segments),2);
                        
                    case 'RAMONOrganelle'
                        % Init file - write ID and Annotation Type  
                        if ii == 1
                            h5Handle = OCPHdf.initH5Obj(hdfFile, ramonId, eRAMONAnnoType.organelle);
                        else
                            OCPHdf.addDataset(h5Handle, ramonId, eRAMONAnnoType.synapse);
                        end

                        % Add Voxel Data
                        OCPHdf.addVoxelData(h5Handle, ramonObj,ramonId)

                        % Write Confidence, Status, KVPairs, author
                        OCPHdf.writeCommonMetadata(h5Handle,ramonObj,ramonId)
                        
                         % Write Parent Organelle Class Metadata
                        OCPHdf.addMetadata(h5Handle, ramonId, 'ORGANELLECLASS', uint32(ramonObj.class));
                        
                        % Write the Parent Seed Metadata
                        OCPHdf.addMetadata(h5Handle, ramonId, 'PARENTSEED', uint32(ramonObj.parentSeed));
                        
                        % Write Seed Metadata
                        OCPHdf.addMetadata(h5Handle, ramonId, 'SEEDS', uint32(ramonObj.seeds),2);

                    otherwise
                        % Not a supported RAMON type.
                        ex = MException('OCPHdf:InvalidInputType','Attempting to convert an unsupported object type.  Check input to be of a supported RAMON type.');
                        throw(ex);

                end
            end
            
            % Close file handle
            H5F.close(h5Handle);
            
        end
    end
    
    
    methods(Static, Access = private )
        %% Private Methods - Ramon2Hdf Helpers
        % Method to initialize HDF5 and add base fields
        function h5Handle = initH5Obj(filename, id, type)
            % Create HDF5 file            
            h5Handle =  H5F.create(filename, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
            
            % Create dataspace.
            space = H5S.create_simple(1,1,1);
            
            % Create Group for ID
            groupM = H5G.create (h5Handle, sprintf('/%d',id), 'H5P_DEFAULT', 'H5P_DEFAULT', 'H5P_DEFAULT');
            H5G.close(groupM);
            
            % Write Annotation Type
            dset = H5D.create(h5Handle, sprintf('/%d/ANNOTATION_TYPE',id), 'H5T_STD_U32LE', space, 'H5P_DEFAULT');
            H5D.write (dset, 'H5T_NATIVE_INT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', uint32(type));
            
            
            H5D.close (dset);
            H5S.close (space);
        end
        
        function addDataset(h5Handle, id, type)
            % Create dataspace.
            space = H5S.create_simple(1,1,1);
            
            % Create Group for ID
            groupM = H5G.create(h5Handle, sprintf('/%d',id), 'H5P_DEFAULT', 'H5P_DEFAULT', 'H5P_DEFAULT');
            H5G.close(groupM);            
            
            % Write Annotation Type
            dset = H5D.create(h5Handle, sprintf('/%d/ANNOTATION_TYPE',id), 'H5T_STD_U32LE', space, 'H5P_DEFAULT');
            H5D.write (dset, 'H5T_NATIVE_INT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', uint32(type));            
            
            H5D.close (dset);
            H5S.close (space);
        end
        
        % Method to write all "common" metadata including creating the group
        function writeCommonMetadata(h5Handle,ramonObj,ramonId)
            
            groupM = H5G.create (h5Handle, sprintf('/%d/METADATA',ramonId), 'H5P_DEFAULT', 'H5P_DEFAULT', 'H5P_DEFAULT');
            H5G.close(groupM);
            
            % Write Author Metadata
            OCPHdf.addMetadata(h5Handle, ramonId, 'AUTHOR', ramonObj.author);
            
            % Write Confidence Metadata
            OCPHdf.addMetadata(h5Handle, ramonId, 'CONFIDENCE', ramonObj.confidence);
            
            % Write Status Metadata
            OCPHdf.addMetadata(h5Handle, ramonId, 'STATUS', uint32(ramonObj.status));
            
            % Write KVPairs Metadata
            keys = ramonObj.getMetadataKeys();
            kvPairs = '';
            for ii = 1:size(keys,2)
                value = ramonObj.getMetadataValue(keys{ii});
                if ~ischar(value)
                    value = num2str(value);
                end
                kvPairs = sprintf('%s%s,%s\r\n',kvPairs,keys{ii},value);
            end
            if ~isempty(kvPairs)
                kvPairs = strtrim(kvPairs);
            end
            OCPHdf.addMetadata(h5Handle, ramonId, 'KVPAIRS', kvPairs);
        end
        
        % Method for adding voxel data
        function addVoxelData(h5Handle, ramonObj,ramonId)
            if isempty(ramonObj.data)
                % if no value don't add field
                return;
            end
            
            % TODO check to see if channel is set (if not warn) 
                     
            switch ramonObj.dataFormat
                case eRAMONDataFormat.dense
                    % Write xyzOffset
                    dims = size(ramonObj.xyzOffset);
                    rankVal = 1;
                    dims = dims(2);
                    
                    space = H5S.create_simple(rankVal,fliplr(dims),fliplr(dims));
                    
                    dset = H5D.create(h5Handle,  sprintf('/%d/XYZOFFSET',ramonId), 'H5T_STD_U32LE', space, 'H5P_DEFAULT');
                    H5D.write (dset, 'H5T_NATIVE_INT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', uint32(ramonObj.xyzOffset)');
                    H5D.close (dset);
                    H5S.close (space);
                    
                    
                    % Write Voxel Data                    
                    data = permute(ramonObj.data,[2 1 3]);
                    rankVal = ndims(data);
                    dims = size(data);
                    
                    %TODO: Figure out if this is the right solution.  Temporarily
                    %force 3D
                    if rankVal ~= 3
                        rankVal = 3;
                        dims(3) = 1;
                    end
                    
                    space = H5S.create_simple(rankVal,fliplr(dims),[]);
                    
                    % Set Chunk sizes                   
                    for ii = [256,128,64,32,16,8,4,1]
                        if (dims(1) >= ii)
                            x_chunk = ii;
                            break;
                        end
                    end               
                    for ii = [256,128,64,32,16,8,4,1]
                        if (dims(2) >= ii)
                            y_chunk = ii;
                            break;
                        end
                    end               
                    for ii = [16,8,4,1]
                        if (dims(3) >= ii)
                            z_chunk = ii;
                            break;
                        end
                    end
                                        
                    % Set Compression (if available)
                    zipped = false;
                    avail = H5Z.filter_avail('H5Z_FILTER_DEFLATE');
                    if ~avail
                        error ('gzip filter not available.');
                    else

                        % Check that it can be used.
                        H5Z_FILTER_CONFIG_ENCODE_ENABLED = H5ML.get_constant_value('H5Z_FILTER_CONFIG_ENCODE_ENABLED');
                        H5Z_FILTER_CONFIG_DECODE_ENABLED = H5ML.get_constant_value('H5Z_FILTER_CONFIG_DECODE_ENABLED');
                        filter_info = H5Z.get_filter_info('H5Z_FILTER_DEFLATE');
                        if ( ~bitand(filter_info,H5Z_FILTER_CONFIG_ENCODE_ENABLED) || ...
                                ~bitand(filter_info,H5Z_FILTER_CONFIG_DECODE_ENABLED) )
                            error ('gzip filter not available for encoding and decoding.');
                        else
                            % Good to go! Compress GZIP 
                            dcpl = H5P.create('H5P_DATASET_CREATE');
                            H5P.set_deflate(dcpl, 9);
                            H5P.set_chunk (dcpl, fliplr([x_chunk,y_chunk,z_chunk]));
                            zipped = true;
                        end
                    end
                    
                    
                    % Write unsigned int labeled voxel data
                    % AB TODO -- do we want the name CUTOUT or the channel
                    % name here? 
                    dset = H5D.create(h5Handle, sprintf('/%d/%s',ramonId,ramonObj.channel), 'H5T_STD_U32LE', space, dcpl);
                    H5D.write (dset, 'H5T_NATIVE_INT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', uint32(data));
                    H5D.close (dset);
                    H5S.close (space);
                    if zipped == true;
                        H5P.close(dcpl);
                    end
                    
                    
                    % Write Resolution
                    rankVal = 1;
                    dims = 1;
                    
                    space = H5S.create_simple(rankVal,fliplr(dims),fliplr(dims));
                    
                    dset = H5D.create(h5Handle, sprintf('/%d/RESOLUTION',ramonId), 'H5T_STD_U32LE', space, 'H5P_DEFAULT');
                    H5D.write (dset, 'H5T_NATIVE_INT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', uint32(ramonObj.resolution)');
                    H5D.close (dset);
                    H5S.close (space);
                    
                case eRAMONDataFormat.voxelList
                    % Set voxel list
                    % Write Voxel List
                    dims = size(ramonObj.data);
                    rankVal = ndims(ramonObj.data);
                    
                    space = H5S.create_simple(rankVal,dims,[]);
                    
                    % Write unsigned int labeled voxel data
                    dset = H5D.create(h5Handle, sprintf('/%d/VOXELS',ramonId), 'H5T_STD_U32LE', space, 'H5P_DEFAULT');
                    H5D.write (dset, 'H5T_NATIVE_INT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', uint32(ramonObj.data'));
                    H5D.close (dset);
                    H5S.close (space);
                    
                    
                    % Write Resolution
                    rankVal = 1;
                    dims = 1;
                    
                    space = H5S.create_simple(rankVal,fliplr(dims),fliplr(dims));
                    
                    dset = H5D.create(h5Handle, sprintf('/%d/RESOLUTION',ramonId), 'H5T_STD_U32LE', space, 'H5P_DEFAULT');
                    H5D.write (dset, 'H5T_NATIVE_INT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', uint32(ramonObj.resolution'));
                    H5D.close (dset);
                    H5S.close (space);
                    
                otherwise
                    % Not a supported voxel method
                    ex = MException('OCPHdf:UnsupportedDataFormat','Unsupported data format when creating HDF5 files: %s',char(qObj.type));
                    throw(ex);
            end
        end
        
        
        % Method for adding voxel data
        function addBlockData(h5Handle, channel, data, createType,writeType)

            % Write Voxel Data                    
            data = permute(data,[2 1 3]);
            rankVal = ndims(data);
            dims = size(data);

            %TODO: Figure out if this is the right solution.  Temporarily
            %force 3D
            if rankVal ~= 3
                rankVal = 3;
                dims(3) = 1;
            end

            space = H5S.create_simple(rankVal,fliplr(dims),[]);

            % Set Chunk sizes                   
            for ii = [256,128,64,32,16,8,4,1]
                if (dims(1) >= ii)
                    x_chunk = ii;
                    break;
                end
            end               
            for ii = [256,128,64,32,16,8,4,1]
                if (dims(2) >= ii)
                    y_chunk = ii;
                    break;
                end
            end               
            for ii = [16,8,4,1]
                if (dims(3) >= ii)
                    z_chunk = ii;
                    break;
                end
            end

            % Set Compression (if available)
            zipped = false;
            avail = H5Z.filter_avail('H5Z_FILTER_DEFLATE');
            if ~avail
                error ('gzip filter not available.');
            else

                % Check that it can be used.
                H5Z_FILTER_CONFIG_ENCODE_ENABLED = H5ML.get_constant_value('H5Z_FILTER_CONFIG_ENCODE_ENABLED');
                H5Z_FILTER_CONFIG_DECODE_ENABLED = H5ML.get_constant_value('H5Z_FILTER_CONFIG_DECODE_ENABLED');
                filter_info = H5Z.get_filter_info('H5Z_FILTER_DEFLATE');
                if ( ~bitand(filter_info,H5Z_FILTER_CONFIG_ENCODE_ENABLED) || ...
                        ~bitand(filter_info,H5Z_FILTER_CONFIG_DECODE_ENABLED) )
                    error('gzip filter not available for encoding and decoding.');
                else
                    % Good to go! Compress GZIP 
                    dcpl = H5P.create('H5P_DATASET_CREATE');
                    H5P.set_deflate(dcpl, 9);
                    H5P.set_chunk (dcpl, fliplr([x_chunk,y_chunk,z_chunk]));
                    zipped = true;
                end
            end


            % Write unsigned int labeled voxel data
            dsetName = sprintf('/%s/CUTOUT', channel); 
            dset = H5D.create(h5Handle, dsetName, createType, space, dcpl);
            H5D.write(dset, writeType, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', data);
            H5D.close(dset);
            H5S.close(space);
            if zipped == true
                H5P.close(dcpl);
            end         
        end
        
        
        
        % Method to write metadata fields
        function addMetadata(h5Handle, id, fieldName, data, forceSingleDim)
            
            if ~exist('forceSingleDim','var')
                forceSingleDim = 0;
            end
            
            switch class(data)
                case 'double'
                    if isempty(data)
                        % if no value don't add field
                        return;
                    end
                    
                    % Create dataspace based on dimensions of data
                    dims = size(data);
                    if isscalar(data)
                        rankVal = 1;
                        dims = 1;
                        forceSingleDim = 0; % it's scalar so forced already
                    else
                        rankVal = ndims(data);
                    end
                    
                    % Special 1-D case
                    if forceSingleDim == 1
                        rankVal = 1;
                        dims = dims(1);
                    end
                    if forceSingleDim == 2
                        rankVal = 1;
                        dims = dims(2);
                    end
                    
                    space = H5S.create_simple(rankVal,dims,dims);
                    
                    % Write 64-bit float metadata
                    dataSetName = sprintf('/%d/METADATA/%s',id,fieldName);
                    dset = H5D.create(h5Handle, dataSetName, 'H5T_IEEE_F64LE', space, 'H5P_DEFAULT');
                    H5D.write (dset, 'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', data');
                    
                    H5D.close (dset);
                    H5S.close (space);
                    
                case 'char'
                    if isempty(data)
                        % if no value don't add field
                        return;
                    end
                    
                    dims = size(data);
                    dataSetName = sprintf('/%d/METADATA/%s',id,fieldName);
                    
                    % Create file and memory datatypes. MATLAB strings do not have \0's.
                    filetype = H5T.copy ('H5T_FORTRAN_S1');
                    H5T.set_size(filetype, dims(2));
                    memtype = H5T.copy('H5T_C_S1');
                    H5T.set_size(memtype, dims(2));
                    
                    % Create dataspace.  Setting maximum size to [] sets the maximum
                    % size to be the current size.
                    space = H5S.create_simple(1,1, []);
                    
                    % Create the dataset and write the string data to it.
                    dset = H5D.create (h5Handle, dataSetName, filetype, space, 'H5P_DEFAULT');
                    % Transpose the data to match the layout in the H5 file to match C
                    % generated H5 file.
                    H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', data');
                    
                    % Close and release resources.
                    H5D.close (dset);
                    H5S.close (space);
                    H5T.close (filetype);
                    H5T.close (memtype);
                    
                case 'uint32'
                    % Create dataspace based on dimensions of data
                    if isempty(data)
                        % if no value don't add field
                        return;
                    end
                    dims = size(data);
                    if isscalar(data)
                        rankVal = 1;
                        dims = 1;
                        forceSingleDim = 0; % it's scalar so forced already
                    else
                        rankVal = ndims(data);
                    end
                    
                    % Special 1-D case
                    if forceSingleDim == 1
                        rankVal = 1;
                        dims = dims(1);
                    end
                    if forceSingleDim == 2
                        rankVal = 1;
                        dims = dims(2);
                    end
                    
                    space = H5S.create_simple(rankVal,dims,dims);
                    
                    % Write unsigned int metadata
                    dataSetName = sprintf('/%d/METADATA/%s',id,fieldName);
                    dset = H5D.create(h5Handle, dataSetName, 'H5T_STD_U32LE', space, 'H5P_DEFAULT');
                    H5D.write (dset, 'H5T_NATIVE_INT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', data');
                    
                    
                    H5D.close (dset);
                    H5S.close (space);
                    
                otherwise
                    ex = MException('OCPHdf:UnsupportedMetadataType','Attempting to write an unsupported metadata type: %s',class(data));
                    throw(ex);
            end
        end
        
        %% Private Methods - toStruct helpers
        function data = loadH5Recursive(loc)
            % Original Source Author: Pauli Virtanen <pav@iki.fi>
            %   Script was in the Public Domain with No warranty.
            % Heavily Modified by Dean Kleissas
            
            % Output Structure
            data = struct();
            
            % Get number of objects in file
            numObjs = H5G.get_num_objs(loc);
            
            % Load groups and datasets recursively
            for ii=0:numObjs-1,
                objtype = H5G.get_objtype_by_idx(loc, ii);
                objname = H5G.get_objname_by_idx(loc, ii);
                
                % objtype index factory according to matlab version
                v = ver('MATLAB');
                if datenum(v.Date)>datenum('04-Aug-2008')
                    objtype = objtype+1;
                end
                
                if objtype == 1
                    % Group
                    name = regexprep(objname, '.*/', '');
                    
                    group_loc = H5G.open(loc, name);
                    try
                        subData = OCPHdf.loadH5Recursive(group_loc);
                        H5G.close(group_loc);
                    catch exc
                        H5G.close(group_loc);
                        rethrow(exc);
                    end
                    
                    % Put whatever was returned into struct
                    data.(name) = subData;
                    
                elseif objtype == 2
                    % Dataset
                    name = regexprep(objname, '.*/', '');
                    
                    if ii == 0 && sum(isstrprop(name,'digit')) == length(name)
                        % You are getting a group full of numbered
                        % values.  Use a map!
                        data = containers.Map('KeyType', 'double','ValueType', 'any');
                    end
                    
                    dataset_loc = H5D.open(loc, name);
                    try
                        subData = H5D.read(dataset_loc, ...
                            'H5ML_DEFAULT', 'H5S_ALL','H5S_ALL','H5P_DEFAULT');
                        
                        H5D.close(dataset_loc);
                    catch exc
                        H5D.close(dataset_loc);
                        rethrow(exc);
                    end
                    
                    subData = OCPHdf.fixData(subData);
                    
                    if sum(isstrprop(name,'digit')) == length(name)
                        subData = double(subData);
                        data(str2double(name)) = subData;
                    else
                        % if name has a hyphen in it we need to replace so
                        % you can store it as a field in a struct. Warn
                        % when you are doing this.
                        if ~isempty(strfind(name,'-'))
                            % Fix hyphen
                            name=strrep(name,'-','__');
                            warning('OCPHdf:BadFieldChar',...
                                'There is a hyphen in an HDF5 field (most likely a channel name).  The hyphen (-) has been replaced with two underscores (__).  This will automatically be handled by the API during interfacing with OCP, but be aware the channel name listed by OCP.getChannelList will not match the server. Disable OCPHdf:BadFieldChar to suppress this warning');
                        end
                        data.(name) = subData;
                    end
                end
            end
        end
        
        function data = fixData(data)
            % Original Source Author: Pauli Virtanen <pav@iki.fi>
            %   Script was in the Public Domain with No warranty.
            
            % Fix some common types of data to more friendly form.
            if isstruct(data)
                fields = fieldnames(data);
                if length(fields) == 2 && strcmp(fields{1}, 'r') && strcmp(fields{2}, 'i')
                    if isnumeric(data.r) && isnumeric(data.i)
                        data = data.r + 1j*data.i;
                    end
                end
            end
            
            %     for i=1:length(fields)
            %         f = data.(fields{i});
            %         if ischar(f)
            %             f = permute(f, fliplr(1:ndims(f)));
            %             data.(fields{i})= f;
            %         end
            %     end
            
            if isnumeric(data) && ndims(data) > 1
                % permute dimensions
                data = permute(data, fliplr(1:ndims(data)));
            end
        end
        
        %% Private Methods - Hdf2Ramon Helpers
        % method to get voxel data fields and add to ramon object
        function ramonObj = getVoxelData(HDF5File, ramonObj, rootGroup, qObj)
            
            switch qObj.type
                case eOCPQueryType.RAMONDense
                    try
                        % If this works all cutout args were present
                        data = h5read(HDF5File,sprintf('%s/CUTOUT',rootGroup));
                        ramonObj.setCutout(double(permute(data,[2 1 3])));
                        res = h5read(HDF5File,sprintf('%s/RESOLUTION',rootGroup));
                        ramonObj.setResolution(double(res));
                        off = h5read(HDF5File,sprintf('%s/XYZOFFSET',rootGroup));
                        ramonObj.setXyzOffset(double(off'));
                    catch ME %#ok<NASGU>
                        warning('OCPHdf:NoVoxelData', 'No voxel data was returned from the server.')
                        ramonObj.setCutout([]);
                        ramonObj.setResolution([]);
                    end
                    
                case eOCPQueryType.RAMONVoxelList
                    % Set voxel list
                    try
                        data = h5read(HDF5File,sprintf('%s/VOXELS',rootGroup));
                        ramonObj.setVoxelList(data');
                        res = h5read(HDF5File,sprintf('%s/RESOLUTION',rootGroup));
                        ramonObj.setResolution(double(res));
                    catch ME %#ok<NASGU>
                        warning('OCPHdf:NoVoxelData', 'No voxel data was returned from the server.')
                        ramonObj.setVoxelList([]);
                        ramonObj.setResolution([]);
                    end
                    
                    
                case eOCPQueryType.RAMONBoundingBox
                    % Set boudning box
                    try
                        data = h5read(HDF5File,sprintf('%s/XYZDIMENSION',rootGroup));
                        ramonObj.setBoundingBoxSpan(data');
                        off = h5read(HDF5File,sprintf('%s/XYZOFFSET',rootGroup));
                        ramonObj.setXyzOffset(double(off'));                    
                        res = h5read(HDF5File,sprintf('%s/RESOLUTION',rootGroup));
                        ramonObj.setResolution(double(res));
                    catch ME %#ok<NASGU>
                        warning('OCPHdf:NoBoundingBox', 'No bounding box data was returned from the server.')
                        ramonObj.setBoundingBoxSpan([]);
                        ramonObj.setResolution([]);
                    end
                    
                otherwise
                    % Not a supported voxel method
                    ex = MException('OCPHdf:UnsupportedDataFormat','Unsupported data format: %s',char(qObj.type));
                    throw(ex);
            end
        end
        
        % Method to get common metadata and set ramon object
        function ramonObj = getCommonMetadata(HDF5File, ramonObj, rootGroup)
            
            % Populate Author Field
            author = h5read(HDF5File,sprintf('%s/METADATA/AUTHOR',rootGroup));
            ramonObj.setAuthor(author{:});
            
            % Populate Status Field
            status = h5read(HDF5File,sprintf('%s/METADATA/STATUS',rootGroup));
            ramonObj.setStatus(double(status));
            
            % Populate Confidence Field
            data = OCPHdf.getOptionalField(HDF5File, sprintf('%s/METADATA/CONFIDENCE',rootGroup), []);
            ramonObj.setConfidence(double(data));
            
            % Populate KVPair Field
            
            % get data and split into cell array
            data = OCPHdf.getOptionalField(HDF5File,sprintf('%s/METADATA/KVPAIRS',rootGroup), []);
            if ~isempty(data)
                data = data{:};
            end
            if ~isempty(data)
                remain = data;
                cnt = 1;
                while ~isempty(remain)
                    [temp, remain] = strtok(remain,char(13)); %#ok<AGROW,STTOK>
                    remain = strtrim(remain);
                    [kvPairs{cnt,1}, temp] = strtok(temp,','); %#ok<STTOK,AGROW>
                    kvPairs{cnt,2} = temp(2:end); %#ok<AGROW>
                    cnt = cnt + 1;
                end
                
                % Trim leading and trailing whitespace
                kvPairs = cellfun(@strtrim,kvPairs,'UniformOutput', false);
                
                indToNull = find(cellfun(@isempty,kvPairs) == 1);
                if ~isempty(indToNull)
                    kvPairs{indToNull} = [];
                end
                
                % Group into pairs, if a numerical value is stored as a value it is
                % converted to a double.
                for ii = 1:size(kvPairs,1)
                    value = kvPairs{ii,2};
                    if (sum(isstrprop(value, 'digit')) == length(value)) && ~isempty(value)
                        value = str2double(value);
                    end
                    kvPairs{ii,2} = value;
                end
                
                % Add to object
                for ii = 1:size(kvPairs,1)
                    ramonObj.addDynamicMetadata(kvPairs{ii,1},kvPairs{ii,2});
                end
            else
                ramonObj.clearDynamicMetadata();
            end
        end
        
        
        % method to get and optional field's data
        function data = getOptionalField(HDF5File, dataset, defaultVal)
            try
                data = h5read(HDF5File,dataset);
            catch ME
                if strcmpi(ME.identifier,'MATLAB:imagesci:h5read:datasetDoesNotExist') || ...
                        strcmpi(ME.identifier,'MATLAB:imagesci:h5read:libraryError')
                    % second catch condition is for R2013 support
                    % Optional field not populated
                    data = defaultVal;
                else
                    rethrow(ME);
                end
            end
        end
        
        
    end
end

