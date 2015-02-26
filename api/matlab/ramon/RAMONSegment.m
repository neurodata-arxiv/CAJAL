classdef RAMONSegment < RAMONVolume
    % RAMONSegment - data type to store a segment of a neuron
    % Constructor available to initialize segment.  For any field not
    % desired to initialize use [].  If the field is omitted a default
    % value will be assigned
    %
    
    % SEGMENT- Annotation representing a segment of the membrane
    % boundary of a neuron
    % ID: Database assigned unique value
    % Neuron:  Neuron ID connected to this segment
    % Synapses: Synapse IDs connected to this segment
    % Parent Seed: Seed that resulted in the creation of this segment
    % Organelles: Associated organelle IDs
    % Class: axon, dendrite, soma, unknown
    % Voxel Set: Voxels representing this segment
    % Status: integer field that can be used to set status information
    % Confidence: value 0-1 representing confidence in accuracy of annotation
    % Dynamic Metadata: Key-value pairs
    
    % Example
    %   seg1 = RAMONSegment(volumeData, xyzOffset, resolution, class,...
    %               synapses, organelles, parentSeed, id, confidence, status,...
    %               dynamicMetadata, author);
    %
    % Required Fields: status, class
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
        
        class = []; %eRAMONSegmentClass
        neuron = []; % neuron.id 
        synapses = [];   %array (synapse.id)
        organelles = []; %array (organelle.id)
        parentSeed = [];  %seed.id
    end
    
    methods
        function this = RAMONSegment(varargin)
            % RAMONSegment();
            % RAMONSegment(...);
            % RAMONSegment(volumeData, dataFormat, xyzOffset, resolution, class,...
            %               neuron, synapses, organelles, parentSeed, id, confidence, status,...
            %               dynamicMetadata, author);
            
            this.setCutout([]);
            this.setXyzOffset([]);
            this.setResolution([]);
            this.setClass(eRAMONSegmentClass.unknown);
            this.setNeuron([]);
            this.setSynapses([]);
            this.setOrganelles([]);
            this.setParentSeed([]);
            this.setId([]);
            this.setConfidence(1);
            this.setStatus(eRAMONAnnoStatus.unprocessed);
            this.clearDynamicMetadata();
            this.setAuthor('unspecified');
            
            % Assign fields based on input arguments
            if nargin == 1
                ex = MException('RAMONSegment:MissingDataFormat',...
                    'When instantiating a RAMONSegment object you must include the "dataFormat" argument indicating the voxel data representation.');
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
                this.setClass(varargin{5});
            end
            if nargin > 5
                this.setNeuron(varargin{6});
            end
            if nargin > 6
                this.setSynapses(varargin{7});
            end
            if nargin > 7
                this.setOrganelles(varargin{8});
            end
            if nargin > 8
                this.setParentSeed(varargin{9});
            end
            if nargin > 9
                this.setId(varargin{10});
            end
            if nargin > 10
                this.setConfidence(varargin{11});
            end
            if nargin > 11
                this.setStatus(varargin{12});
            end
            if nargin > 12
                this.metadataConstructHelper(varargin{13})
            end
            if nargin > 13
               this.setAuthor(varargin{14});
            end
            if nargin > 14
                ex = MException('RAMONSegment:TooManyArguments','Too many attributes, see documentation for use.');
                    throw(ex);
            end
        end
        
        %% Set Functions to validate data
        
        %% Segment class
        function this = setClass(this,type)
            % This member function sets the segment class field.
            
            if isempty(type)
                % If type is empty set to default
                this.class = eRAMONSegmentClass.unknown;
            end
            
            if isa(type, 'eRAMONSegmentClass')
                % Is of Type eRAMONSegmentClass
                
            else
                % Is not of type eRAMONSegmentClass
                validateattributes(type,{'numeric'},{'finite','nonnegative','integer','nonnan','real'});
                try
                    type = eRAMONSegmentClass(uint32(type));
                catch ME
                    rethrow(ME);
                end
            end
            
            this.class = type;
        end
        
        %% SET NEURON FIELD
        function this = setNeuron(this,neu)
            % This member function sets the segment's linked neuron field.
            if ~isempty(neu)
                validateattributes(neu,{'numeric'},{'scalar','finite','nonnegative','nonnan','real'});
            end
            this.neuron = neu;
        end
        
        %% SET SYNAPSE FIELD
        function this = setSynapses(this,syn)
            % This member function sets the segment's linked synapses field.
            if ~isempty(syn)
                validateattributes(syn,{'numeric'},{'finite','nonnegative','nonnan','real'});
            end
            
            if size(syn,1) > 1
                ex = MException('RAMONSegment:InvalidFormat','Synapses should be a 1xN array');
                throw(ex);
            end
            
            this.synapses = syn;
        end
        
        function this = removeSynapses(this, synapseID)
            
            validateattributes(synapseID,{'numeric'},{'finite','nonnegative','integer','nonnan','real','scalar'});
            
            for ii = 1:length(synapseID)
                % check if key exists already
                if isempty(find(ismember(this.synapse, synapseID(ii))==1, 1))
                    warning('RAMONSegment:IDNotFound', 'ID not found in synapse. Nothing was removed.')
                else
                    ind = find(ismember(this.synapses, synapseID(ii))==1, 1);
                    this.synapses(ind) = [];
                end
            end
        end
        
        %% SET ORGANELLE FIELD
        
        function this = setOrganelles(this,org)
            % This member function sets the segment's linked organelle field.
            if ~isempty(org)
                validateattributes(org,{'numeric'},{'finite','nonnegative','nonnan','real'});
            end
            if size(org,1) > 1
                ex = MException('RAMONSegment:InvalidFormat','Organelles should be a 1xN array');
                throw(ex);
            end
            
            this.organelles = org;
        end
        
        function this = removeOrganelles(this, organelleID)
            
            validateattributes(organelleID,{'numeric'},{'finite','nonnegative','integer','nonnan','real'});
            
            % check if key exists already
            for ii = 1:length(organelleID)
                if isempty(find(ismember(this.organelles, organelleID(ii))==1, 1))
                    warning('RAMONSegment:IDNotFound', 'ID not found in organelles. Nothing was removed.')
                else
                    ind = find(ismember(this.organelles, organelleID(ii))==1, 1);
                    this.organelles(ind) = [];
                end
            end
        end
        
        %% SET PARENT SEED FIELD
        
        function this = setParentSeed(this,ps)
            % This member function sets the segment's linked parent seed field.
            
            if ~isempty(ps)
                validateattributes(ps,{'numeric'},{'scalar','finite','nonnegative','nonnan','real'});
            end
            this.parentSeed = ps;
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
            handle = RAMONSegment();
            
            % Copy all properties.
            % Base
            handle = this.baseCloneHelper(handle);
            % Volume
            handle = this.volumeCloneHelper(handle, option);
            % Class
            handle.setClass(this.class);
            handle.setNeuron(this.neuron);
            handle.setSynapses(this.synapses);
            handle.setOrganelles(this.organelles);
            handle.setParentSeed(this.parentSeed);
        end
    end
end