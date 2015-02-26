classdef eRAMONAnnoStatus < int32
    %eRAMONAnnoStatus Enumeration of status field values for RAMON annotations
    % 0 = Unprocessed
    % 1 = Locked
    % 2 = Processing
    % 3 = Ignored
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
        unprocessed (0)
        locked (1)
        processed (2)
        ignored (3)
    end
    
end

