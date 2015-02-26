classdef eOCPPropagateStatus < uint32
    %eOCPPropagateStatus Enumeration of options for database propagation
    %status
    %
    % inconsistent (0) - Read/Write mode. Database has been editied since last propagation
    %                    or has never been propagated. Annotations at
    %                    different resolutions may be inconsistent, but you
    %                    can edit the database.
    % propagating (1) - Read-only mode.  The database is currently
    %                   propagating all annotations in the background. You
    %                   must wait for this process to complete before the
    %                   database will become writable again.
    % consistent (2) - Read-only mode.  The database has been propagated
    %                  and is now consistent across all resolutions.  To
    %                  write again to the database you must unlock it by
    %                  invoking the "makeAnnoWritable" or
    %                  "makeAnnoWritable" methods in the OCP class.
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
        inconsistent (0)
        propagating (1)
        consistent (2)
    end
end

