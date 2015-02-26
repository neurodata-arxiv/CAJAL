classdef RAMONNeuron < RAMONBase
    % RAMONNeuron - data type to store information about a neuron.
    % Constructor available to initialize neuron state.  For any field not
    % desired to initialize use [].  If the field is omitted a default
    % value will be assigned
    %
    % Example
    %   neuron1 = RAMONNeuron();  default seed
    %   neuron1 = RAMONNeuron(segments, id, confidence, status, dynamicMetadata);
    %
    % Neuron data structure:
    % neuron.segments - segment ids that are part of neuron
    % neuron.id - unique identifier for the neuron - type: integer
    % neuron.confidence - Value 0-1 indicating confidence in annotation -
    %                       type: double
    % neuron.status - Current state of the neuron. RAMONAnnotationStatus
    % neuron.dynamicMetadata - Cell array of key-value pairs
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
        segments = [];
    end
    
    methods
        function this = RAMONNeuron(varargin)
            % RAMONNeuron();
            % RAMONNeuron(...);
            % RAMONNeuron(segments, id, confidence, status, dynamicMetadata, author);

            this.setSegments([]);
            this.setId([]);
            this.setConfidence(1);
            this.setStatus(eRAMONAnnoStatus.unprocessed);
            this.clearDynamicMetadata();
            this.setAuthor('unspecified');
            
            
            if nargin > 0
                this.setSegments(varargin{1});
            end
            if nargin > 1
                this.setId(varargin{2});
            end
            if nargin > 2
                this.setConfidence(varargin{3});
            end
            if nargin > 3
                this.setStatus(varargin{4});
            end
            if nargin > 4
                if ~isempty(varargin{5})
                    [numKey, col] = size(varargin{5});
                    if col ~= 2
                        ex = MException('RAMONBase:DMDFormatInvalid','The dynamic metadata format is invalid.  Check documentation.');
                        throw(ex);
                    end
                    data = varargin{5};
                    this.clearDynamicMetadata();
                    for ii = 1:numKey
                        this = this.addDynamicMetadata(data{ii,1},data{ii,2});
                    end
                end
            end
            if nargin > 5
                this.setAuthor(varargin{6});  
            end
            if nargin > 6
                ex = MException('RAMONNeuron:TooManyArguments','Too many arguments in constructor for initialization, see documentation for use.');
                throw(ex);
            end  
        end
        
        
        %% Set Functions to validate data
        
                %SET SEGMENTS FIELD
        function this = setSegments(this,seg)
            % This member function sets the segment's linked synapses field.
            
            validateattributes(seg,{'numeric'},{'integer','nonnegative','nonnan','real'});
            this.segments = seg;
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
            handle.setSegments(this.segments);
        end
        
        %% RAMON Converstion Methods
        function ramonObj = toGeneric(this)
            ramonObj = RAMONGeneric();
            ramonObj = this.setRAMONBaseProperties(ramonObj);
        end
           
    end
     
end

