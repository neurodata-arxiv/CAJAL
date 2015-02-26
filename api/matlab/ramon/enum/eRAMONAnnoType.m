classdef eRAMONAnnoType < int32
    %eRAMONAnnoType Enumeration of the types of RAMON annotations
    %that can be stored in the OCP annotation database
    %
    
    % Generic = 1
    % SYNAPSE = 2
    % SEED = 3
    % SEGMENT = 4
    % NEURON = 5
    % ORGANELLE = 6
    % ATTRIBUTEDREGION = 7
    % VOLUME = 8
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
    
    enumeration
        generic(1)
        synapse (2)
        seed (3)
        segment (4)
        neuron (5)
        organelle (6) % not supported yet
        attributedRegion (7) % not support yet
        volume(8)
    end
    
end

