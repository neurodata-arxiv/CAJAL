function cubeCutoutPreprocessBasic(serverLocation, token, resolution, ...
                                    xStart, xStop, yStart, yStop, zStart, zStop,...
                                    xSpan, ySpan, zSpan, ... 
                                    cubeListFile, cubeOutputDir, print_flag)
                                
    % cubeCutoutPreprocessBasic This method calcs subvolume queries from a larger volume
    %
    % This method is used to create OCPQuery objects specifing subvolumes
    % of a larger volume that you want to query from the database.
    %
    % The region you are cutting out from is specified by the start and
    % stop arguments.  It is start point inclusive, stop point exclusive
    % (python convention)
    %
    % The specified span will be used to size the subcubes.  As many cubes
    % of the desired size as possible will be created and the remaining
    % volume will be diced up into smaller subcubes.
    %   
    % The result is OCPQuery objects called "query" saved in mat-files. One
    % mat-file is created per subvolume for easy pipelining and saved to 'cubeOutputDir'. 
    % The path to each file is stored in the .list file "cubeListFile".
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
    
             
    
    %% param validation  
    if ~exist('print_flag','var')
        print_flag = 1;
    end
    
    % valid type
    validateattributes(resolution,{'numeric'},{'finite','nonnegative','integer','nonnan','real','scalar'});
    validateattributes(xStart,{'numeric'},{'finite','nonnegative','integer','nonnan','real','scalar'});
    validateattributes(yStart,{'numeric'},{'finite','nonnegative','integer','nonnan','real','scalar'});
    validateattributes(zStart,{'numeric'},{'finite','nonnegative','integer','nonnan','real','scalar'});
    validateattributes(xStop,{'numeric'},{'finite','nonnegative','integer','nonnan','real','scalar'});
    validateattributes(yStop,{'numeric'},{'finite','nonnegative','integer','nonnan','real','scalar'});
    validateattributes(zStop,{'numeric'},{'finite','nonnegative','integer','nonnan','real','scalar'});
    validateattributes(xSpan,{'numeric'},{'finite','nonnegative','integer','nonnan','real','scalar'});
    validateattributes(ySpan,{'numeric'},{'finite','nonnegative','integer','nonnan','real','scalar'});
    validateattributes(zSpan,{'numeric'},{'finite','nonnegative','integer','nonnan','real','scalar'});
    validateattributes(serverLocation,{'char'},{'row'});
    validateattributes(token,{'char'},{'row'});  
    validateattributes(cubeListFile,{'char'},{'row'});
    validateattributes(cubeOutputDir,{'char'},{'row'});
    validateattributes(print_flag,{'numeric'},{'finite','nonnegative','integer','nonnan','real','scalar','>=',0,'<=',1});
    
    debugLog(sprintf('Cutout Parametiers:\n\n'),print_flag);
    debugLog(sprintf('X: [%d,%d]\n',xStart,xStop),print_flag);
    debugLog(sprintf('Y: [%d,%d]\n',yStart,yStop),print_flag);
    debugLog(sprintf('Z: [%d,%d]\n',zStart,zStop),print_flag);
    debugLog(sprintf('X Span: %d\n',xSpan),print_flag);
    debugLog(sprintf('Y Span: %d\n',ySpan),print_flag);
    debugLog(sprintf('Z Span: %d\n\n\n',zSpan),print_flag);
    
     %% Get Dataset info
    oo = OCP();
    oo.setServerLocation(serverLocation);
    oo.setImageToken(token);
    switch oo.imageInfo.PROJECT.TYPE
        case eRAMONDataType.image8
            query_type = eOCPQueryType.imageDense;
        case eRAMONDataType.image16
            query_type = eOCPQueryType.imageDense;
        case eRAMONDataType.anno32
            query_type = eOCPQueryType.annoDense;
        case eRAMONDataType.anno64
            query_type = eOCPQueryType.annoDense;
        case eRAMONDataType.prob32
            query_type = eOCPQueryType.probDense;
        case eRAMONDataType.rgba32
            query_type = eOCPQueryType.imageDense;
        case eRAMONDataType.rgba64
            query_type = eOCPQueryType.imageDense;
        case eRAMONDataType.channels16
            query_type = eOCPQueryType.imageDense;
        case eRAMONDataType.channels8
            query_type = eOCPQueryType.imageDense;
        otherwise
            error('cubeCutoutPreprocess:UnsupportedDataSetType','Unsupported database data type %d\n',...
                oo.imageInfo.PROJECT.TYPE);
    end
        
    %% Check inputs to be valid
    xy_size = double(oo.imageInfo.DATASET.IMAGE_SIZE(resolution));
    z_size = double(oo.imageInfo.DATASET.SLICERANGE);
    
    % start < stop
    if xStart >= xStop
        error('cubeCutoutPreprocess:PARAMERROR','X Starting Coordinate must be smaller than X Stopping Coordinate!\nStart: %d\nStop: %d',...
            xStart,xStop);
    end
    if yStart >= yStop
        error('cubeCutoutPreprocess:PARAMERROR','Y Starting Coordinate must be smaller than Y Stopping Coordinate!\nStart: %d\nStop: %d',...
            yStart,yStop);
    end
    if zStart >= zStop
        error('cubeCutoutPreprocess:PARAMERROR','Z Starting Coordinate must be smaller than Z Stopping Coordinate!\nStart: %d\nStop: %d',...
            zStart,zStop);
    end
    
    % max < extent
    xExtent = xStop - xStart;
    yExtent = yStop - yStart;
    zExtent = zStop - zStart;
    
    if xExtent < xSpan
        error('cubeCutoutPreprocess:NOSOLUTION','X span must be smaller than X Extent!\nSpan: %d\nExtent: %d',...
            xSpan,xExtent);
    end
    if yExtent < ySpan
        error('cubeCutoutPreprocess:NOSOLUTION','Y span must be smaller than Y Extent!\nSpan: %d\nExtent: %d',...
            ySpan,yExtent);
    end
    if zExtent < zSpan
        error('cubeCutoutPreprocess:NOSOLUTION','Z span must be smaller than Z Extent!\nSpan: %d\nExtent: %d',...
            zSpan,zExtent);
    end
    
    % max < dataset size    
    if xStop > xy_size(1)
        error('cubeCutoutPreprocess:PARAMERROR','X Ending Coordinate must be smaller than X Max Dimension!\nStop: %d\nMax: %d',...
            xStop,xy_size(1));
    end
    if yStop > xy_size(2)
        error('cubeCutoutPreprocess:PARAMERROR','Y Ending Coordinate must be smaller than Y Max Dimension!\nStop: %d\nMax: %d',...
            yStop,xy_size(2));
    end
    
    if zStart < z_size(1)
        error('cubeCutoutPreprocess:PARAMERROR','Z Starting Coordinate must be greater than or equal to Z Min Dimension!\nStart: %d\nMin: %d',...
            zStop,z_size(1));
    end
    if zStop > z_size(2) + 1
        error('cubeCutoutPreprocess:PARAMERROR','Z Ending Coordinate must be less than or equal to Z Max Dimension!\nStart: %d\nMax: %d',...
            zStop,z_size(2)+1);
    end
        
    
    % Make sure list file has a .list extension (othewise LONI won't parse
    % jobs properly)
    [~, ~, ext] = fileparts(cubeListFile);
    if ~strcmpi(ext,'.list')
        error('cubeCutoutPreprocess:BADLISTFILE','Cube list file must have a .list extension!\nListfile: %s',...
            cubeListFile);
    end   
      
    % create output directory since the pipeline can't know what is being
    % created
    if ~exist('cubeOutputDir','var')
        cubeOutputDir = tempdir;
    end
    
    validateattributes(cubeOutputDir,{'char'},{'row'});
    
    import java.util.UUID;
    cubeOutputDir = fullfile(cubeOutputDir,[datestr(now,30) '_' char(UUID.randomUUID())]);
    mkdir(cubeOutputDir);    
    
    
    %% Calc Num Type I Blocks
    numXblocks = floor(xExtent/xSpan);
    numYblocks = floor(yExtent/ySpan);
    numZblocks = floor(zExtent/zSpan);
    
    remXSpan = rem(xExtent,xSpan);
    remYSpan = rem(yExtent,ySpan);   
    remZSpan = rem(zExtent,zSpan);
    
 
    %% Generate Query Objects - TYPE I (full cubes)
    listFileStr = '';
    xCoord = xStart;
    yCoord = yStart;
    zCoord = zStart;
    cnt = 0;

  
    debugLog(sprintf('Computing Type I Blocks\n'),print_flag);
    for zz = 1:numZblocks
        for yy = 1:numYblocks
            for xx = 1:numXblocks

                % Create Query
                qq = OCPQuery(query_type);

                % Check edge conditions
                [xMin,xMax,yMin,yMax,zMin,zMax] = checkCoordBoundaries(xCoord,...
                    yCoord,zCoord,xSpan,ySpan,zSpan,xy_size,z_size);             


                qq.setCutoutArgs([xMin  xMax],...
                    [yMin  yMax],...
                    [zMin  zMax],...
                    resolution);

                % Save query
                tFilename = fullfile(cubeOutputDir,sprintf('ccQuery_%s_r%d_x%d-%d_y%d-%d_z%d-%d.mat',...
                    token,...
                    resolution,...
                    xMin, xMax,...
                    yMin, yMax,...
                    zMin, zMax));
                qq.save(tFilename);

                % Add to list of filenames
                listFileStr = sprintf('%s%s\n',listFileStr,tFilename);

                % Add to informational printing
                debugLog(sprintf('Resolution:%2d - xRange: [%6d %6d] - yRange: [%6d %6d] - zRange: [%6d %6d]\n',...
                    resolution,...
                    xMin, xMax,...
                    yMin, yMax,...
                    zMin, zMax),print_flag);

                xCoord = xCoord + xSpan;
                cnt = cnt + 1;
            end
            xCoord = xStart;
            yCoord = yCoord + ySpan;
        end
        yCoord = yStart;
        zCoord = zCoord + zSpan;
    end

    %% Generate Query Objects - TYPE IIa
    if remYSpan ~= 0
        debugLog(sprintf('Computing Type IIa Blocks\n'),print_flag);
        xCoord = xStart;
        yCoord = yStart + (numYblocks*ySpan);
        zCoord = zStart;

        for zz = 1:numZblocks
            for xx = 1:numXblocks

                % Create Query
                qq = OCPQuery(query_type);

                % Check edge conditions
                [xMin,xMax,yMin,yMax,zMin,zMax] = checkCoordBoundaries(xCoord,...
                    yCoord,zCoord,xSpan,remYSpan,zSpan,xy_size,z_size);  
                
                qq.setCutoutArgs([xMin  xMax],...
                    [yMin  yMax],...
                    [zMin  zMax],...
                    resolution);

                % Save query
                tFilename = fullfile(cubeOutputDir,sprintf('ccQuery_%s_r%d_x%d-%d_y%d-%d_z%d-%d.mat',...
                    token,...
                    resolution,...
                    xMin, xMax,...
                    yMin, yMax,...
                    zMin, zMax));
                qq.save(tFilename);

                % Add to list of filenames
                listFileStr = sprintf('%s%s\n',listFileStr,tFilename);

                % Add to informational printing
                debugLog(sprintf('Resolution:%2d - xRange: [%6d %6d] - yRange: [%6d %6d] - zRange: [%6d %6d]\n',...
                    resolution,...
                    xMin, xMax,...
                    yMin, yMax,...
                    zMin, zMax),print_flag);

                xCoord = xCoord + xSpan;
                cnt = cnt + 1;
            end
            xCoord = xStart;
            zCoord = zCoord + zSpan;
        end
    end

    %% Generate Query Objects - TYPE IIb
    if remXSpan ~= 0
        debugLog(sprintf('Computing Type IIb Blocks\n'),print_flag);
        xCoord = xStart + (numXblocks*xSpan);
        yCoord = yStart;
        zCoord = zStart;

        for zz = 1:numZblocks
            for yy = 1:numYblocks

                % Create Query
                qq = OCPQuery(query_type);

                % Check edge conditions
                [xMin,xMax,yMin,yMax,zMin,zMax] = checkCoordBoundaries(xCoord,...
                    yCoord,zCoord,remXSpan,ySpan,zSpan,xy_size,z_size);                 

                qq.setCutoutArgs([xMin  xMax],...
                    [yMin  yMax],...
                    [zMin  zMax],...
                    resolution);

                % Save query
                tFilename = fullfile(cubeOutputDir,sprintf('ccQuery_%s_r%d_x%d-%d_y%d-%d_z%d-%d.mat',...
                    token,...
                    resolution,...
                    xMin, xMax,...
                    yMin, yMax,...
                    zMin, zMax));
                qq.save(tFilename);

                % Add to list of filenames
                listFileStr = sprintf('%s%s\n',listFileStr,tFilename);

                % Add to informational printing
                debugLog(sprintf('Resolution:%2d - xRange: [%6d %6d] - yRange: [%6d %6d] - zRange: [%6d %6d]\n',...
                    resolution,...
                    xMin, xMax,...
                    yMin, yMax,...
                    zMin, zMax),print_flag);

                yCoord = yCoord + ySpan;
                cnt = cnt + 1;
            end
            yCoord = yStart;
            zCoord = zCoord + zSpan;
        end
    end

    %% Generate Query Objects - TYPE III
    if (remXSpan ~= 0 && remYSpan ~= 0)
        debugLog(sprintf('Computing Type III Blocks\n'),print_flag);
        xCoord = xStart + (numXblocks*xSpan);
        yCoord = yStart + (numYblocks*ySpan);
        zCoord = zStart;

        for zz = 1:numZblocks
            % Create Query
            qq = OCPQuery(query_type);

            % Check edge conditions
            [xMin,xMax,yMin,yMax,zMin,zMax] = checkCoordBoundaries(xCoord,...
                 yCoord,zCoord,remXSpan,remYSpan,zSpan,xy_size,z_size);

            qq.setCutoutArgs([xMin  xMax],...
                    [yMin  yMax],...
                    [zMin  zMax],...
                    resolution);

            % Save query
                tFilename = fullfile(cubeOutputDir,sprintf('ccQuery_%s_r%d_x%d-%d_y%d-%d_z%d-%d.mat',...
                    token,...
                    resolution,...
                    xMin, xMax,...
                    yMin, yMax,...
                    zMin, zMax));
                qq.save(tFilename);

                % Add to list of filenames
                listFileStr = sprintf('%s%s\n',listFileStr,tFilename);

                % Add to informational printing
                debugLog(sprintf('Resolution:%2d - xRange: [%6d %6d] - yRange: [%6d %6d] - zRange: [%6d %6d]\n',...
                    resolution,...
                    xMin, xMax,...
                    yMin, yMax,...
                    zMin, zMax),print_flag);

            zCoord = zCoord + zSpan;
            cnt = cnt + 1;
        end

    end


    %% Generate Query Objects - TYPE IV
    if (remZSpan ~= 0)
        debugLog(sprintf('Computing Type IV Blocks\n'),print_flag);
        xCoord = xStart;
        yCoord = yStart;
        zCoord = zStart + (numZblocks*zSpan);

        for yy = 1:numYblocks
            for xx = 1:numXblocks

                % Create Query
                qq = OCPQuery(query_type);

                % Check edge conditions
                [xMin,xMax,yMin,yMax,zMin,zMax] = checkCoordBoundaries(xCoord,...
                    yCoord,zCoord,xSpan,ySpan,remZSpan,xy_size,z_size); 

                qq.setCutoutArgs([xMin  xMax],...
                    [yMin  yMax],...
                    [zMin  zMax],...
                    resolution);

                % Save query
                tFilename = fullfile(cubeOutputDir,sprintf('ccQuery_%s_r%d_x%d-%d_y%d-%d_z%d-%d.mat',...
                    token,...
                    resolution,...
                    xMin, xMax,...
                    yMin, yMax,...
                    zMin, zMax));
                qq.save(tFilename);

                % Add to list of filenames
                listFileStr = sprintf('%s%s\n',listFileStr,tFilename);

                % Add to informational printing
                debugLog(sprintf('Resolution:%2d - xRange: [%6d %6d] - yRange: [%6d %6d] - zRange: [%6d %6d]\n',...
                    resolution,...
                    xMin, xMax,...
                    yMin, yMax,...
                    zMin, zMax),print_flag);

                xCoord = xCoord + xSpan;
                cnt = cnt + 1;
            end
            xCoord = xStart;
            yCoord = yCoord + ySpan;
        end
    end

    %% Generate Query Objects - TYPE Va
    if (remZSpan ~= 0 && remYSpan ~= 0)
        debugLog(sprintf('Computing Type Va Blocks\n'),print_flag);
        xCoord = xStart;
        yCoord = yStart + (numYblocks*ySpan);
        zCoord = zStart + (numZblocks*zSpan);

        for xx = 1:numXblocks

            % Create Query
            qq = OCPQuery(query_type);

            % Check edge conditions
            [xMin,xMax,yMin,yMax,zMin,zMax] = checkCoordBoundaries(xCoord,...
                yCoord,zCoord,xSpan,remYSpan,remZSpan,xy_size,z_size); 

            qq.setCutoutArgs([xMin  xMax],...
                    [yMin  yMax],...
                    [zMin  zMax],...
                    resolution);

            % Save query
            tFilename = fullfile(cubeOutputDir,sprintf('ccQuery_%s_r%d_x%d-%d_y%d-%d_z%d-%d.mat',...
                token,...
                resolution,...
                xMin, xMax,...
                yMin, yMax,...
                zMin, zMax));
            qq.save(tFilename);

            % Add to list of filenames
            listFileStr = sprintf('%s%s\n',listFileStr,tFilename);

            % Add to informational printing
            debugLog(sprintf('Resolution:%2d - xRange: [%6d %6d] - yRange: [%6d %6d] - zRange: [%6d %6d]\n',...
                resolution,...
                xMin, xMax,...
                yMin, yMax,...
                zMin, zMax),print_flag);

            xCoord = xCoord + xSpan;
            cnt = cnt + 1;
        end
    end

    %% Generate Query Objects - TYPE Vb
    if (remZSpan ~= 0 && remXSpan ~= 0)
        debugLog(sprintf('Computing Type Vb Blocks\n'),print_flag);
        xCoord = xStart + (numXblocks*xSpan);
        yCoord = yStart;
        zCoord = zStart + (numZblocks*zSpan);

        for yy = 1:numYblocks

            % Create Query
            qq = OCPQuery(query_type);

            % Check edge conditions
            [xMin,xMax,yMin,yMax,zMin,zMax] = checkCoordBoundaries(xCoord,...
                yCoord,zCoord,remXSpan,ySpan,remZSpan,xy_size,z_size); 

            qq.setCutoutArgs([xMin  xMax],...
                    [yMin  yMax],...
                    [zMin  zMax],...
                    resolution);

            % Save query
            tFilename = fullfile(cubeOutputDir,sprintf('ccQuery_%s_r%d_x%d-%d_y%d-%d_z%d-%d.mat',...
                token,...
                resolution,...
                xMin, xMax,...
                yMin, yMax,...
                zMin, zMax));
            qq.save(tFilename);

            % Add to list of filenames
            listFileStr = sprintf('%s%s\n',listFileStr,tFilename);

            % Add to informational printing
            debugLog(sprintf('Resolution:%2d - xRange: [%6d %6d] - yRange: [%6d %6d] - zRange: [%6d %6d]\n',...
                resolution,...
                xMin, xMax,...
                yMin, yMax,...
                zMin, zMax),print_flag);

            yCoord = yCoord + ySpan;
            cnt = cnt + 1;
        end
    end

    %% Generate Query Objects - TYPE VI
    if (remZSpan ~= 0 && remXSpan ~= 0 && remYSpan ~= 0)
        debugLog(sprintf('Computing Type VI Blocks\n'),print_flag);
        xCoord = xStart + (numXblocks*xSpan);
        yCoord = yStart + (numYblocks*ySpan);
        zCoord = zStart + (numZblocks*zSpan);


        % Create Query
        qq = OCPQuery(query_type);

        % Check edge conditions
        [xMin,xMax,yMin,yMax,zMin,zMax] = checkCoordBoundaries(xCoord,...
            yCoord,zCoord,remXSpan,remYSpan,remZSpan,xy_size,z_size);  
        
        qq.setCutoutArgs([xMin  xMax],...
            [yMin  yMax],...
            [zMin  zMax],...
            resolution);

        % Save query
        tFilename = fullfile(cubeOutputDir,sprintf('ccQuery_%s_r%d_x%d-%d_y%d-%d_z%d-%d.mat',...
            token,...
            resolution,...
            xMin, xMax,...
            yMin, yMax,...
            zMin, zMax));
        qq.save(tFilename);

        % Add to list of filenames
        listFileStr = sprintf('%s%s\n',listFileStr,tFilename);

        % Add to informational printing
        debugLog(sprintf('Resolution:%2d - xRange: [%6d %6d] - yRange: [%6d %6d] - zRange: [%6d %6d]\n',...
            resolution,...
            xMin, xMax,...
            yMin, yMax,...
            zMin, zMax),print_flag);

        cnt = cnt + 1;
    end


    %% Print results for logging
    debugLog(sprintf('Generated %d queries.\n\n',cnt),print_flag);

    %% write cube cutout list file
    fid = fopen(cubeListFile,'wt');

    if ispc
        %need to fix \
        listFileStr = strrep(listFileStr,'\','\\');
    end

    fprintf(fid,listFileStr);
    fclose(fid);
end

%% Helper functions
function [xMin,xMax,yMin,yMax,zMin,zMax] = checkCoordBoundaries(xCoord,...
                    yCoord,zCoord,xSpan,ySpan,zSpan,xy_size,z_size)
                
    % Check start edge conditions
    if xCoord < 0
        xMin = 0;
    else
        xMin = xCoord;
    end

    if yCoord < 0
        yMin = 0;
    else
        yMin = yCoord;
    end

    if zCoord < z_size(1)
        zMin = z_size(1);
    else
        zMin = zCoord;
    end

    % Check end edge conditions
    if xCoord + xSpan > xy_size(1)
        xMax = xy_size(1);
    else
        xMax = xCoord + xSpan;
    end

    if yCoord + ySpan > xy_size(2)
        yMax = xy_size(2);
    else
        yMax = yCoord + ySpan;
    end
    
    if zCoord + zSpan > z_size(2)
        zMax = z_size(2);
    else
        zMax = zCoord + zSpan;
    end
end

function debugLog(string, print_flag)
    if print_flag == 1
        fprintf(string);
    end
end
