classdef eRAMONUploadDataType < int32
    %eRAMONUploadDataType Enumeration of the types of
    %
    % 8bit Image Data (0)
    % 32bit Annotation Data (1)
    % 16bit Multichannel data (2)
    % 8bit Multichannel data
    % 32bit Probability Map (4)
    % Bitmask (5)
    % 64bit Annotation Data (6)
    % RGBA 32 bit image data (6)
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
    
    enumeration
        image8 (0)
        anno32 (1)
        channels16 (2)
        channels8 (3)
        prob32 (4)
        bitmask (5)
        anno64 (6)   
        rgba32 (7)         
    end
    
end

