classdef eRAMONDataType < int32
    %eRAMONDataType Enumeration of the types of data in OCP DB
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
        image8 (1)
        anno32 (2)
        channels16 (3)
        channels8 (4)
        prob32 (5)
        bitmask (6)
        anno64 (7) 
        image16 (8)  
        rgba32 (9)   
        rgba64 (10)         
    end
    
end

