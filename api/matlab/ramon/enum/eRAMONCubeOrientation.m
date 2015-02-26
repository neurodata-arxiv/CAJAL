classdef eRAMONCubeOrientation < int32
    %RAMONCubeOrientation Enumeration of possible cube orientations
    % This is used in the RAMONSeed class.  It indicatates how a cube
    % should be generated around a seed.
    %     pos_x - place the seed in the center of the +x face
    %     neg_x - place the seed in the center of the -x face 
    %     pos_y - place the seed in the center of the +y face 
    %     neg_y - place the seed in the center of the -y face 
    %     pos_z - place the seed in the center of the +z face 
    %     neg_z - place the seed in the center of the -z face 
    %     centered - center the cube around the seed
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
        pos_x (0)
        neg_x (1)
        pos_y (2)
        neg_y (3)
        pos_z (4)
        neg_z (5)
        centered (6)
    end
    
end

