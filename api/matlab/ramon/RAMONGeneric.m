classdef RAMONGeneric <  RAMONVolume
    %RAMONGeneric ************************************************
    % Generic Annotation Class used to capture basic annotations before they
    % have been attributed to a RAMON type, or to accomodate data that does
    % not have a RAMON type.  You should try to fit into the RAMON
    % data model and use this object as an intermediate product
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
        
    end
    
    methods
        function this = RAMONGeneric()
            % Constructor
            
        end
        
        function handle = clone(this, option)
            % Perform a deep copy because these are handles and not
            % objects.
            % Default using the = operator just copies the handle and not
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
        
        
        
        %% RAMON Converstion Methods
        function ramonObj = toSynapse(this)
            ramonObj = RAMONSynapse();
            ramonObj = this.setRAMONBaseProperties(ramonObj);
            ramonObj = this.setRAMONVolumeProperties(ramonObj);
        end
        
        function ramonObj = toSeed(this)
            ramonObj = RAMONSeed();
            ramonObj = this.setRAMONBaseProperties(ramonObj);
        end
        
        function ramonObj = toSegment(this)
            ramonObj = RAMONSegment();
            ramonObj = this.setRAMONBaseProperties(ramonObj);
            ramonObj = this.setRAMONVolumeProperties(ramonObj);
        end
        
        function ramonObj = toNeuron(this)
            ramonObj = RAMONNeuron();
            ramonObj = this.setRAMONBaseProperties(ramonObj);
        end
        
        
    end
end

