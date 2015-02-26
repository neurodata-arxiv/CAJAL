classdef RAMONSynapse < RAMONVolume
    % RAMONSynapse - data type to store information about a synapse
    % Constructor available to initialize synapse.  For any field not
    % desired to initialize use [].  If the field is omitted a default
    % value will be assigned
    %
    % Example
    %   s1 = RAMONSynapse(volumeData, refCoordinates, synapseType,weight,...
    %                       segments,id,confidence,status,dynamicMetadata);
    %
    % Required Fields: status, synapseType
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
    
    properties(SetAccess = 'private', GetAccess = 'public')
        synapseType = eRAMONSynapseType.unknown;   % eRAMONSynapseType
        weight = [];        % double
        segments = containers.Map('KeyType', 'uint32','ValueType','uint32'); % Map [segmentID, RAMONSegementType]
        seeds = [];         % array 1xN (seedID)
    end
    
    methods
        function this = RAMONSynapse(varargin)
            % RAMONSynapse();
            % RAMONSynapse(...);
            % RAMONSynapse(volumeData, isCutout, xyzOffset, resolution, synapseType,...
            %               weight, segments, seeds, id, confidence,status,...
            %               dynamicMetadata, author);
            
            % "overloaded" constructor.  You can include any number of args
            % to init the object during constructor.  Any field you want to
            % skip over use "[]"
            
            % Default props
            this.setCutout([]);
            this.setXyzOffset([]);
            this.setResolution([]);
            this.setSynapseType(eRAMONSynapseType.unknown);
            this.setWeight([]);
            this.clearSegments();
            this.setSeeds([]);
            this.setId([]);
            this.setConfidence(1);
            this.setStatus(eRAMONAnnoStatus.unprocessed);
            this.clearDynamicMetadata();
            
            if nargin == 1
                ex = MException('RAMONSynapse:MissingDataFormat',...
                    'When instantiating a RAMONSynapse object you must include the "dataFormat" argument indicating the voxel data representation.');
                throw(ex);
            end
            if nargin > 1
                this = this.setDataFormat(varargin{2});
                this = this.initVoxelData(varargin{1}, this.dataFormat);
            end
            if nargin > 2
                this.setXyzOffset(varargin{3});
            end
            if nargin > 3
                this.setResolution(varargin{4});
            end
            if nargin > 4
                this.setSynapseType(varargin{5});
            end
            if nargin > 5
                this.setWeight(varargin{6});
            end
            if nargin > 6
                this.segmentConstructHelper(varargin{7})
            end
            if nargin > 7
                this.setSeeds(varargin{8});
            end
            if nargin > 8
                this.setId(varargin{9});
            end
            if nargin > 9
                this.setConfidence(varargin{10});
            end
            if nargin > 10
                this.setStatus(varargin{11});
            end
            if nargin > 11
                this.metadataConstructHelper(varargin{12})
            end
            if nargin > 12
                this.setAuthor(varargin{13});
            end
            if nargin > 13
                ex = MException('RAMONSynapse:TooManyArguments','Too many attributes, see documentation for use.');
                throw(ex);
            end
        end
        
        
        %% Set Functions to validate data
        
        function this = setSynapseType(this,type)
            % This member function sets the seed's synapse type field.
            
            if isempty(type)
                % If type is empty set to default
                this.synapseType = eRAMONSynapseType.unknown;
            end
            
            if isa(type, 'eRAMONSynapseType')
                % Is of Type eRAMONSynapseType
                
            else
                % Is not of type eRAMONSynapseType
                validateattributes(type,{'numeric'},{'finite','nonnegative','integer','nonnan','real'});
                try
                    type = eRAMONSynapseType(type);
                catch ME
                    rethrow(ME);
                end
            end
            
            this.synapseType = type;
        end
        
        function this = setWeight(this,weight)
            % This member function sets the synapse's wieght field.
            
            validateattributes(weight,{'numeric'},{'finite','nonnegative','nonnan','real'});
            this.weight = weight;
        end
        
        function this = setSegments(this,segmentMap)
            % This member function sets the seed's segments field with
            % an existing containers.Map file
            
            if ~isempty(segmentMap)
                % Check argument
                if ~isa(segmentMap,'containers.Map')
                    ex = MException('RAMONSynapse:InvalidType','"segments" must be of type containers.Map');
                    throw(ex);
                end
                
                if ~strcmpi(segmentMap.KeyType,'uint32')
                    ex = MException('RAMONSynapse:KeyType','"segments" container.Map keys must be uint32');
                    throw(ex);
                end
                if ~strcmpi(segmentMap.ValueType,'uint32')
                    ex = MException('RAMONSynapse:ValueType','"segments" container.Map values must be uint32');
                    throw(ex);
                end
            end
            
            this.segments = segmentMap;
        end
        
        function this = addSegment(this,segmentID, segmentFlowDir)
            
            validateattributes(segmentID,{'numeric'},{'finite','nonnegative','integer','nonnan','real','scalar'});
            
            if ~isa(segmentFlowDir, 'eRAMONFlowDirection')
                try
                    eRAMONFlowDirection(segmentFlowDir);
                catch ME
                    rethrow(ME);
                end
            else
                segmentFlowDir = int32(segmentFlowDir);
            end
            
            % add key
            % check if id exists already
            errFlag = 0;
            try
                this.segments(segmentID);
                errFlag = 1;
            catch %#ok<CTCH>
                % it doesn't so create it
                this.segments(segmentID) = int32(segmentFlowDir);
            end
            if errFlag == 1
                ex = MException('RAMONSynapse:IDExists',sprintf('Segment ID "%d" already exists in synapse.  Cannot Add to synapse',segmentID));
                throw(ex);
            end
        end
        
        function this = updateSegment(this,segmentID, segmentFlowDir)
            
            validateattributes(segmentID,{'numeric'},{'finite','nonnegative','integer','nonnan','real','scalar'});
            
            if ~isa(segmentFlowDir, 'eRAMONFlowDirection')
                try
                    eRAMONFlowDirection(segmentFlowDir);
                catch ME
                    rethrow(ME);
                end
            else
                segmentFlowDir = int32(segmentFlowDir);
            end
            
            % update key
            this.segments(segmentID) = int32(segmentFlowDir);
        end
        
        
        function this = removeSegment(this, segmentId)
            
            validateattributes(segmentId,{'numeric'},{'finite','nonnegative','integer','nonnan','real','scalar'});
            
            this.segments.remove(segmentId);
        end
        
        function this = clearSegments(this)
            % remove all segement data
            this.segments = containers.Map('KeyType', 'uint32','ValueType','uint32');
        end
        
        function this = setSeeds(this,seeds)
            % This member function sets the synapses seeds field.
            
            validateattributes(seeds,{'numeric'},{'finite','nonnegative','nonnan','real','integer'});
            this.seeds = seeds;
        end
        
        
        %% RAMON Converstion Methods
        function ramonObj = toGeneric(this)
            ramonObj = RAMONGeneric();
            ramonObj = this.setRAMONBaseProperties(ramonObj);
            ramonObj = this.setRAMONVolumeProperties(ramonObj);
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
            % Class
            handle.setSynapseType(this.synapseType);
            handle.setWeight(this.weight);
            handle.setSegments(this.segments);
            handle.setSeeds(this.seeds);
        end
    end
    
    %% Private helper to clean up code
    methods(Access = private)
        function segmentConstructHelper(this,segmentMat)
            
            if isempty(segmentMat)
                this.clearSegments();
            else
                if size(segmentMat,2) ~= 2
                    ex = MException('RAMONSynapse:SegmentsFormatInvalid','Segment init format is invalid.  Should be Nx2 uint32 array');
                    throw(ex);
                end
                for ii = 1:size(segmentMat,1)
                    this.addSegment(segmentMat(ii,1),segmentMat(ii,2));
                end
            end
        end
        
        function metadataconstructhelper(this,var)
            
            [numkey, col] = size(var);
            if numkey ~= 0
                if col ~= 2
                    ex = MException('RAMONSynapse:MetadataFormatInvalid','The init dynamic metadata format is invalid.  Should be Nx2 cell array.');
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
    end
    
end

