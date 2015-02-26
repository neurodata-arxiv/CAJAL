classdef eOCPQueryType < uint32
    %eRequests Enumeration of server request types
    % imageDense - Dense Image DB Cutout
    % imageSlice - Single Slice of Image DB
    % annoDense - Dense Annotation DB Cutout
    % annoSlice - Single Slice of Annotation DB
    % overlaySlice - Single Slice of Overlay of image and annotation DBs
    % RAMONDense - RAMON object query with voxel data in Dense Format
    % RAMONVoxelList - RAMON object query with voxel data in Voxel List Format
    % RAMONMetaOnly - RAMON object query with NO voxel data returned
    % RAMONBoundingBox - Returns a cuboid aligned bounding box around RAMON Object
    % RAMONIdList - Query to search annotation database by setting
    %               RAMON object metadata predicates.  Can be restricted to
    %               a cutout by setting Cutout Args.  By default searches
    %               whole DB if X, Y, and Z ranges are empty.
    % voxelId - Query the ID of a voxel based on it's x,y, and z
    %           coordinates.  This is useful if you want to see what ID that 
    %           database has assigned to an annotation after you have created it.
    % probDense - dense cutout of a probability database.  returns
    %             RAMONVolume with data of type single
    % 
    % Terminology:
    %   - Dense: 3D volumetric cutout where 0 is unlabled voxels and
    %   non-zero are labled voxels (uint32)
    %   - VoxelList: Nx3 array of the x,y,z coordinates of the labeled
    %   voxels in database coordinates at the resolution you are working!
    %   (only works when operating on a single RAMON object)
    %   - MetaOnly: Query retrieves no voxel data, but only RAMON object
    %   metadata
    %
    % NOTE:
    % - Slice service does NOT return raw data, but depending on the selected
    % resolution, a scaled image for visualization purposes encoded as a png.
    % If you want a single slice of raw data use the Dense Cutout Service
    % with your z dimension span = 1
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
        imageDense (0)
        imageSlice (1)
        annoDense (2)
        annoSlice (3)
        overlaySlice (4)
        RAMONDense (5)
        RAMONVoxelList (6)
        RAMONMetaOnly (7)
        RAMONBoundingBox (8)
        RAMONIdList (9)
        voxelId (10)
        probDense (11)
    end
    
end

