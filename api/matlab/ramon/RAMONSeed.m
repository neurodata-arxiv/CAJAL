classdef RAMONSeed < RAMONBase
    % RAMONSeed - data type to store information about a seed point.
    % Constructor available to initialize seed to state.  For any field not
    % desired to initialize use [].  If the field is omitted a default
    % value will be assigned
    %
    %
    % Example
    %   seed1 = RAMONSeed();  default seed
    %   seed1 = RAMONSeed(...);
    %   seed1 = RAMONSeed(position,cubeOrientation,parentSeed,sourceEntity,...
    %                       id,confidence,status, dynamicMetadata);
    %
    % Seed properties:
    % seed.position - x,y,z global coordinates [x,y,z] - type:integer
    % seed.cubeOrientation - Options are: +x,-x,+y,-y,+z,-z,c which specify where
    %   a cube would be created in relation to the seed - type:
    %   RAMONCubeOriencation
    % seed.parentSeed - Parent seed ID that derived this child seed (only
    %                   non-null if a child seed) - type: integer
    % seed.sourceEntity - ID of annotation entity that derived the parent
    %                   seed - type: integer
    % seed.id - unique identifier for the seed - type: integer
    % seed.confidence - Value 0-1 indicating confidence in annotation -
    %                       type: double
    % seed.status - Current state of the seed. 0 = new, 1 = processing,
    %                   2 = processed/complete - type: eRAMONAnnoStatus
    % seed.dynamicMetadata - Cell array of key-value pairs
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
        position = [0 0 0]; % x,y,z coordinates (global frame)
        cubeOrientation = eRAMONCubeOrientation.centered; % Where the seed is in relation to a cube it would generate. Options are: +x,-x,+y,-y,+z,-z,c
        parentSeed = []; % id of pervious generation seed
        sourceEntity = []; % ID of entity that derived this seed (first generation seeds only)
    end
    
    methods
        function this = RAMONSeed(varargin)
            % RAMONSeed();
            % RAMONSeed(...);
            % RAMONSeed(position,cubeOrientation,parentSeed,sourceEntity,id,...
            %            confidence,status,metadata,author);
            
            this.setPosition([0 0 0]);
            this.setCubeOrientation(eRAMONCubeOrientation.centered);
            this.setParentSeed([]);
            this.setSourceEntity([]);
            this.setId([]);
            this.setConfidence(1);
            this.setStatus(eRAMONAnnoStatus.unprocessed);
            this.clearDynamicMetadata();
            this.setAuthor('unspecified');
            
            % Assign fields based on input arguments
            if nargin > 0
                this.setPosition(varargin{1});
            end
            if nargin > 1
                this.setCubeOrientation(varargin{2});
            end
            if nargin > 2
                this.setParentSeed(varargin{3});
            end
            if nargin > 3
                this.setSourceEntity(varargin{4});
            end
            if nargin > 4
                this.setId(varargin{5});
            end
            if nargin > 5
                this.setConfidence(varargin{6});
            end
            if nargin > 6
                this.setStatus(varargin{7});
            end
            if nargin > 7
                [numKey, col] = size(varargin{8});
                if col ~= 2
                    ex = MException('RAMONPointAnnotation:MetadataFormatInvalid','The dynamic metadata format is invalid.  Check documentation.');
                    throw(ex);
                end
                data = varargin{8};
                for ii = 1:numKey
                    this = this.addDynamicMetadata(data{ii,1},data{ii,2});
                end
            end
            if nargin > 8
                this.setAuthor(varargin{9});
            end
            if nargin > 9
                ex = MException('RAMONSeed:TooManyArguments','Too many attributes, see documentation for use.');
                throw(ex);
            end
        end
        
        
        %% Set Functions to validate data
        
        function this = setPosition(this,position)
            % This member function sets the seed's position field.  If position is null
            % it will be set to default [0 0 0]
            
            if isempty(position)
                % If position is empty set to default
                position = [0 0 0];
            end
            
            validateattributes(position,{'numeric'},{'finite','integer','nonnan','real','size',[1,3]});
            this.position = position;
        end
        
        function this = setCubeOrientation(this,orientation)
            % This member function sets the seed's orientation field.
            % If orientation is null it will be set to default 'c' for center
            
            if isempty(orientation)
                % If orientation is empty set to default
                this.cubeOrientation = eRAMONCubeOrientation.centered;
            end
            
            if isa(orientation, 'eRAMONCubeOrientation')
                % Is of Type eRAMONCubeOrientation
                
            else
                % Is not of type AnnotationStatus
                validateattributes(orientation,{'numeric'},{'finite','nonnegative','integer','nonnan','real'});
                try
                    orientation = eRAMONCubeOrientation(orientation);
                catch ME
                    rethrow(ME);
                end
            end
            
            this.cubeOrientation = orientation;
        end
        
        function this = setParentSeed(this,parentSeed)
            % This member function sets the seed's parentSeed field.
            
            validateattributes(parentSeed,{'numeric'},{'finite','nonnegative','integer','nonnan','real'});
            this.parentSeed = parentSeed;
        end
        
        function this = setSourceEntity(this,sourceEntity)
            % This member function sets the seed's sourceEntity field.
            
            validateattributes(sourceEntity,{'numeric'},{'finite','positive','integer','nonnan','real'});
            this.sourceEntity = sourceEntity;
        end
        
        %% RAMON Converstion Methods
        function ramonObj = toGeneric(this)
            ramonObj = RAMONGeneric();
            ramonObj = this.setRAMONBaseProperties(ramonObj);
        end
        
        function handle = clone(this,~)
            % Perform a deep copy because these are handles and not objects
            % default using the = operator just copies the handle and not
            % the underlying object.
            
            % Instantiate new object of the same class.
            handle = feval(class(this));
            
            % Copy all properties.
            % Base
            handle = this.baseCloneHelper(handle);
            % Class
            handle.setPosition(this.position);
            handle.setCubeOrientation(this.cubeOrientation);
            handle.setParentSeed(this.parentSeed);
            handle.setSourceEntity(this.sourceEntity);
        end
        
    end
    
    
end

