classdef RAMONOrganelle < RAMONVolume
    %RAMONOrganelle ************************************************
    % Annotation for neuron organelles. eRAMONOrganelleClass enumeration
    % contains the currently supported organelles and can be extended.  If
    % you wish to add to the baseline so it is standard amoung all users
    % contact OCP developers.
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
        class = []; %eRAMONOrganelleClass
        seeds = []; %list of seed IDs related to organelle
        parentSeed = [];  %id of seed that resulted in organelle creation
    end
    
    methods
        function this = RAMONOrganelle(varargin)
            % RAMONOrganelle();
            % RAMONOrganelle(...);
            % RAMONOrganelle(volumeData, dataFormat, xyzOffset, resolution, class,...
            %               seeds, parentSeed, id, confidence, status,...
            %               dynamicMetadata, author);
            
            this.setCutout([]);
            this.setXyzOffset([]);
            this.setResolution([]);
            this.setClass(eRAMONOrganelleClass.unknown);
            this.setSeeds([]);
            this.setParentSeed([]);
            this.setId([]);
            this.setConfidence(1);
            this.setStatus(eRAMONAnnoStatus.unprocessed);
            this.clearDynamicMetadata();
            this.setAuthor('unspecified');
            
            if nargin == 1
                ex = MException('RAMONOrganelle:MissingDataFormat',...
                    'When instantiating a RAMONOrganelle object with voxel data you must include the "dataFormat" argument indicating the voxel data representation.');
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
                this.setSeeds(varargin{6});
            end
            if nargin > 6
                this.setParentSeed(varargin{7});
            end
            if nargin > 7
                this.setId(varargin{8});
            end
            if nargin > 8
                this.setConfidence(varargin{9});
            end
            if nargin > 9
                this.setStatus(varargin{10});
            end
            if nargin > 10
                this.metadataConstructHelper(varargin{11})
            end
            if nargin > 11
                this.setAuthor(varargin{12});
            end
            if nargin > 12
                ex = MException('RAMONOrganelle:TooManyArguments','Too many attributes, see documentation for use.');
                throw(ex);
            end
        end
        
        
        
        %% Set Functions to validate data
        
        function this = setClass(this,type)
            % This member function sets the organelle class field.
            
            if isempty(type)
                % If type is empty set to default
                this.class = eRAMONOrganelleClass.unknown;
            end
            
            if isa(type, 'eRAMONOrganelleClass')
                % Is of Type eRAMONOrganelleClass
                
            else
                % Is not of type eRAMONOrganelleClass
                validateattributes(type,{'numeric'},{'finite','nonnegative','integer','nonnan','real'});
                try
                    type = eRAMONOrganelleClass(uint32(type));
                catch ME
                    rethrow(ME);
                end
            end
            
            this.class = type;
        end
        
        function this = setSeeds(this,seeds)
            % This member function sets the organelles associated seeds field.
            if ~isempty(seeds)
                validateattributes(seeds,{'numeric'},{'finite','nonnegative','nonnan','real'});
            end
            
            if size(seeds,1) > 1
                ex = MException('RAMONOrganelle:InvalidFormat','Seed list should be a 1xN array');
                throw(ex);
            end
            
            this.seeds = seeds;
        end
        
        function this = setParentSeed(this,ps)
            % This member function sets the organelle's associated parent seed field.
            
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
        
        function handle = clone(this, option)
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
            handle = feval('RAMONOrganelle');
            
            % Copy all properties.
            % Base
            handle = this.baseCloneHelper(handle);
            % Volume
            handle = this.volumeCloneHelper(handle, option);
            % Class
            handle.setClass(this.class);
            handle.setParentSeed(this.parentSeed);
            handle.setSeeds(this.seeds);
        end
    end
end

