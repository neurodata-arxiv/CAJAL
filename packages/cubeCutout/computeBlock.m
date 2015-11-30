function computeBlock(serverLocation, token, channel, resolution, xStart, xStop, yStart, yStop, zStart, zStop, xSpan, ySpan, zSpan, padX, padY, padZ, alignXY, alignZ, computeOptions, shuffleFilesFlag, cubeListFile, cubeOutputDir, mergeListFile, mergeOutputDir, print_flag)
% computeBlock function allows the user to create a query and pull data
% from NeuroData easily while computing subvolumes from a larger volume of
% interest.
%
% **Inputs**
%
% server: (string)
%   - OCP server name serving as the source for data
%
% token: (string)
%   - OCP token name serving as the source for data
%
% channel: (string)
%   - OCP channel name serving as the source for data
%
% resolution: (int)
%   - Resolution of data you wish to download
%
% xStart, yStart, zStart: (int)
%   - Lower bounds of cube to download
%
% xStop, yStop, zStop: (int)
%   - Upper bounds of cube to download
%
% xSpan, ySpan, zSpan: (int)
%   - Data range in each dimension
%
% padX, padY, padZ: (int)
%   - How much you wish to pad the data in each dimension
%
% alignXY, alignZ: (int)
%   - Flag for aligning cutout volumes with cubes
%
% computeOptions: (string)
%   - Additional processing options
%
% shuffleFilesFlag: (int)
%   - Flag for shuffling file ordering of cutouts
%
% cubeListFile: (string)
%   - Basename of output cubeList file
%
% cubeOutputDir: (string)
%   - Directory to which downloaded cubes are saved
%
% mergeListFile: (int)
%   - Flag for merging listfiles across instances
%
% mergeOutputDir: (int)
%   - Flag for merging output directories across instances
%
% print_flag: (int)
%   - Flag for verbose output or not
%
% **Outputs**
%
%	No explicit outputs.  Output cubes are saved to disk rather
%	than output as a variable to allow for downstream integration with
%	LONI.
%
% **Notes**
%
% Function definition must be one line for documentation to work (known bug in sphinx)
%

oo = OCP();
oo.setServerLocation(serverLocation);
% Get Dataset info
oo.setImageToken(token);
oo.setImageChannel(channel);
oo.imageChanInfo.TYPE
%  PROJECT.TYPE
if strcmpi(oo.imageChanInfo.TYPE,'image')
    query_type = eOCPQueryType.imageDense;
    oo.setImageChannel(channel);
elseif strcmpi(oo.imageChanInfo.TYPE, 'annotation')
    query_type = eOCPQueryType.annoDense;
    oo.setAnnoChannel(channel);
elseif strcmpi(oo.imageChanInfo.TYPE, 'timeseries')
    error('not yet implemented')
else
    error('cubeCutoutPreprocess:UnsupportedDataSetType','Unsupported database data type: %d\n',...
        oo.imageChanInfo.TYPE);
end

if isempty(cubeOutputDir)
    cubeOutputDir = tempdir;
end

if isempty(mergeOutputDir)
    mergeOutputDir = tempdir;
end

%TODO: WRGR
%     switch oo.imageInfo.PROJECT.TYPE
%         case {1,3,4,8,9,10}
%             query_type = eOCPQueryType.imageDense;
%             oo.setImageChannel(channel);
%         case {2,6,7}
%             query_type = eOCPQueryType.annoDense;
%             oo.setAnnoChannel(channel);
%         case 5
%             query_type = eOCPQueryType.probDense;
%         otherwise
%            error('cubeCutoutPreprocess:UnsupportedDataSetType','Unsupported database data type: %d\n',...
%                oo.imageInfo.PROJECT.TYPE);
%     end


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
validateattributes(padX,{'numeric'},{'finite','nonnegative','integer','nonnan','real','scalar'});
validateattributes(padY,{'numeric'},{'finite','nonnegative','integer','nonnan','real','scalar'});
validateattributes(padZ,{'numeric'},{'finite','nonnegative','integer','nonnan','real','scalar'});
validateattributes(computeOptions,{'numeric'},{'integer','nonnan','real','scalar','>',-1,'<',3});
validateattributes(alignZ,{'numeric'},{'integer','nonnan','real','scalar','>',-1,'<',2});
validateattributes(cubeListFile,{'char'},{'row'});
validateattributes(cubeOutputDir,{'char'},{'row'});
validateattributes(mergeListFile,{'char'},{'row'});
validateattributes(mergeOutputDir,{'char'},{'row'});


%% Check and recompute inputs to align with cuboids
% wrgr TODO (check)
cuboid = double(oo.imageInfo.DATASET.CUBE_DIMENSION(resolution));
dsize = double(oo.imageInfo.DATASET.IMAGE_SIZE(resolution));
xy_size = dsize(1:2);
offset = oo.imageInfo.DATASET.OFFSET(resolution);
z_size = (offset(3)+0,offset(3)+dsize(3)-1);

debugLog(sprintf('Cutout Parameters:\n\n'),print_flag);
debugLog(sprintf('X: (%d,%d)\n',xStart,xStop),print_flag);
debugLog(sprintf('Y: (%d,%d)\n',yStart,yStop),print_flag);
debugLog(sprintf('Z: (%d,%d)\n',zStart,zStop),print_flag);
debugLog(sprintf('X Span: %d\n',xSpan),print_flag);
debugLog(sprintf('Y Span: %d\n',ySpan),print_flag);
debugLog(sprintf('Z Span: %d\n\n\n',zSpan),print_flag);

% fix start
if (alignXY == 1)
    xStart = (floor(xStart/cuboid(1)) * cuboid(1));
    yStart = (floor(yStart/cuboid(2)) * cuboid(2));
end

if (alignZ == 1)
    if (floor(zStart/cuboid(3))) > 0
        zStart = z_size(1) + (floor((zStart-z_size(1))/cuboid(3)) * cuboid(3));
    else
        zStart = z_size(1);
    end
end

% fix stop
if (alignXY == 1)

    xStop = (ceil(xStop/cuboid(1)) * cuboid(1));
    if (xStop > xy_size(1))
        xStop = xy_size(1);
    end
    yStop = (ceil(yStop/cuboid(2)) * cuboid(2));
    if (yStop > xy_size(2))
        yStop = xy_size(2);
    end
end

if (alignZ == 1)
    if (floor(zStop/cuboid(3))) > 0
        zStop = z_size(1) + (ceil((zStop-z_size(1)+1)/cuboid(3)) * cuboid(3));
        if (zStop > z_size(2))
            zStop = z_size(2);
        end
    else
        zStop = z_size(1) + cuboid(3);
    end
end

% fix span
if (alignXY == 1)

    if xSpan < cuboid(1)
        xSpan = cuboid(1);
    else
        xSpan = floor(xSpan/cuboid(1)) * cuboid(1);
    end
    if ySpan < cuboid(2)
        ySpan = cuboid(2);
    else
        ySpan = floor(ySpan/cuboid(2)) * cuboid(2);
    end
end

if (alignZ == 1)
    if zSpan < cuboid(3)
        zSpan = cuboid(3);
    else
        zSpan = floor(zSpan/cuboid(3)) * cuboid(3);
    end
end

debugLog(sprintf('Auto-Alignment to Cuboids in %s Results:\n\n',token),print_flag);
debugLog(sprintf('X: (%d,%d)\n',xStart,xStop),print_flag);
debugLog(sprintf('Y: (%d,%d)\n',yStart,yStop),print_flag);
debugLog(sprintf('Z: (%d,%d)\n',zStart,zStop),print_flag);
debugLog(sprintf('X Span: %d\n',xSpan),print_flag);
debugLog(sprintf('Y Span: %d\n',ySpan),print_flag);
debugLog(sprintf('Z Span: %d\n',zSpan),print_flag);


%% Check inputs to be valid
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
xExtent= xStop - xStart;
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
switch computeOptions
    case 0
        (~, ~, ext) = fileparts(cubeListFile);
        if ~strcmpi(ext,'.list')
            error('cubeCutoutPreprocess:BADLISTFILE','Cube list file must have a .list extension!\nListfile: %s',...
                cubeListFile);
        end
    case 1
        (~, ~, ext) = fileparts(mergeListFile);
        if ~strcmpi(ext,'.list')
            error('cubeCutoutPreprocess:BADLISTFILE','Merge list file must have a .list extension!\nListfile: %s',...
                mergeListFile);
        end
    case 2
        (~, ~, ext) = fileparts(cubeListFile);
        if ~strcmpi(ext,'.list')
            error('cubeCutoutPreprocess:BADLISTFILE','Cube list file must have a .list extension!\nListfile: %s',...
                cubeListFile);
        end
        (~, ~, ext) = fileparts(mergeListFile);
        if ~strcmpi(ext,'.list')
            error('cubeCutoutPreprocess:BADLISTFILE','Merge list file must have a .list extension!\nListfile: %s',...
                cubeListFile);
        end
end


% create output directory since the pipeline can't know what is being
% created
if ~exist('cubeOutputDir','var')
    cubeOutputDir = tempdir;
end
if ~exist('mergeOutputDir','var')
    mergeOutputDir = tempdir;
end
validateattributes(cubeOutputDir,{'char'},{'row'});
validateattributes(mergeOutputDir,{'char'},{'row'});

import java.util.UUID;
cubeOutputDir = fullfile(cubeOutputDir,(datestr(now,30) '_' char(UUID.randomUUID())));
mkdir(cubeOutputDir);
mergeOutputDir = fullfile(mergeOutputDir,(datestr(now,30) '_' char(UUID.randomUUID())));
mkdir(mergeOutputDir);


%% Calc Num Type I Blocks
numXblocks = floor(xExtent/xSpan);
numYblocks = floor(yExtent/ySpan);
numZblocks = floor(zExtent/zSpan);

remXSpan = rem(xExtent,xSpan);
remYSpan = rem(yExtent,ySpan);
remZSpan = rem(zExtent,zSpan);

xEdges = ();
yEdges = ();
zEdges = ();
%% Generate Query Objects - TYPE I (full cubes)
if computeOptions == 0 || computeOptions == 2
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
                (xMin,xMax,yMin,yMax,zMin,zMax) = checkCoordBoundaries(xCoord,padX,...
                    yCoord,padY,zCoord,padZ,xSpan,ySpan,zSpan,xy_size,z_size);

                % Log edges for merge regions later
                xEdges = cat(1,xEdges,xMin);
                yEdges = cat(1,yEdges,yMin);
                zEdges = cat(1,zEdges,zMin);

                qq.setCutoutArgs((xMin  xMax),...
                    (yMin  yMax),...
                    (zMin  zMax),...
                    resolution);

                % Save query
                tFilename = fullfile(cubeOutputDir,sprintf('ccQuery_token_%s_channel_%s_r%d_x%d-%d_y%d-%d_z%d-%d.mat',...
                    token,...
                    channel,...
                    resolution,...
                    xMin, xMax,...
                    yMin, yMax,...
                    zMin, zMax));
                qq.save(tFilename);

                % Add to list of filenames
                listFileStr = sprintf('%s%s\n',listFileStr,tFilename);

                % Add to informational printing
                debugLog(sprintf('Resolution:%2d - xRange: (%6d %6d) - yRange: (%6d %6d) - zRange: (%6d %6d)\n',...
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
                (xMin,xMax,yMin,yMax,zMin,zMax) = checkCoordBoundaries(xCoord,padX,...
                    yCoord,padY,zCoord,padZ,xSpan,remYSpan,zSpan,xy_size,z_size);

                % Log edges for merge regions later
                xEdges = cat(1,xEdges,xMin);
                yEdges = cat(1,yEdges,yMin);
                zEdges = cat(1,zEdges,zMin);

                qq.setCutoutArgs((xMin  xMax),...
                    (yMin  yMax),...
                    (zMin  zMax),...
                    resolution);

                % Save query
                tFilename = fullfile(cubeOutputDir,sprintf('ccQuery_token_%s_channel_%s_r%d_x%d-%d_y%d-%d_z%d-%d.mat',...
                    token,...
                    channel,...
                    resolution,...
                    xMin, xMax,...
                    yMin, yMax,...
                    zMin, zMax));
                qq.save(tFilename);

                % Add to list of filenames
                listFileStr = sprintf('%s%s\n',listFileStr,tFilename);

                % Add to informational printing
                debugLog(sprintf('Resolution:%2d - xRange: (%6d %6d) - yRange: (%6d %6d) - zRange: (%6d %6d)\n',...
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
                (xMin,xMax,yMin,yMax,zMin,zMax) = checkCoordBoundaries(xCoord,padX,...
                    yCoord,padY,zCoord,padZ,remXSpan,ySpan,zSpan,xy_size,z_size);

                % Log edges for merge regions later
                xEdges = cat(1,xEdges,xMin);
                yEdges = cat(1,yEdges,yMin);
                zEdges = cat(1,zEdges,zMin);

                qq.setCutoutArgs((xMin  xMax),...
                    (yMin  yMax),...
                    (zMin  zMax),...
                    resolution);

                % Save query
                tFilename = fullfile(cubeOutputDir,sprintf('ccQuery_token_%s_channel_%s_r%d_x%d-%d_y%d-%d_z%d-%d.mat',...
                    token,...
                    channel,...
                    resolution,...
                    xMin, xMax,...
                    yMin, yMax,...
                    zMin, zMax));
                qq.save(tFilename);

                % Add to list of filenames
                listFileStr = sprintf('%s%s\n',listFileStr,tFilename);

                % Add to informational printing
                debugLog(sprintf('Resolution:%2d - xRange: (%6d %6d) - yRange: (%6d %6d) - zRange: (%6d %6d)\n',...
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
            (xMin,xMax,yMin,yMax,zMin,zMax) = checkCoordBoundaries(xCoord,padX,...
                yCoord,padY,zCoord,padZ,remXSpan,remYSpan,zSpan,xy_size,z_size);

            % Log edges for merge regions later
            xEdges = cat(1,xEdges,xMin);
            yEdges = cat(1,yEdges,yMin);
            zEdges = cat(1,zEdges,zMin);

            qq.setCutoutArgs((xMin  xMax),...
                (yMin  yMax),...
                (zMin  zMax),...
                resolution);

            % Save query
            tFilename = fullfile(cubeOutputDir,sprintf('ccQuery_token_%s_channel_%s_r%d_x%d-%d_y%d-%d_z%d-%d.mat',...
                token,...
                channel,...
                resolution,...
                xMin, xMax,...
                yMin, yMax,...
                zMin, zMax));
            qq.save(tFilename);

            % Add to list of filenames
            listFileStr = sprintf('%s%s\n',listFileStr,tFilename);

            % Add to informational printing
            debugLog(sprintf('Resolution:%2d - xRange: (%6d %6d) - yRange: (%6d %6d) - zRange: (%6d %6d)\n',...
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
                (xMin,xMax,yMin,yMax,zMin,zMax) = checkCoordBoundaries(xCoord,padX,...
                    yCoord,padY,zCoord,padZ,xSpan,ySpan,remZSpan,xy_size,z_size);

                % Log edges for merge regions later
                xEdges = cat(1,xEdges,xMin);
                yEdges = cat(1,yEdges,yMin);
                zEdges = cat(1,zEdges,zMin);

                qq.setCutoutArgs((xMin  xMax),...
                    (yMin  yMax),...
                    (zMin  zMax),...
                    resolution);

                % Save query
                tFilename = fullfile(cubeOutputDir,sprintf('ccQuery_token_%s_channel_%s_r%d_x%d-%d_y%d-%d_z%d-%d.mat',...
                    token,...
                    channel,...
                    resolution,...
                    xMin, xMax,...
                    yMin, yMax,...
                    zMin, zMax));
                qq.save(tFilename);

                % Add to list of filenames
                listFileStr = sprintf('%s%s\n',listFileStr,tFilename);

                % Add to informational printing
                debugLog(sprintf('Resolution:%2d - xRange: (%6d %6d) - yRange: (%6d %6d) - zRange: (%6d %6d)\n',...
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
            (xMin,xMax,yMin,yMax,zMin,zMax) = checkCoordBoundaries(xCoord,padX,...
                yCoord,padY,zCoord,padZ,xSpan,remYSpan,remZSpan,xy_size,z_size);

            % Log edges for merge regions later
            xEdges = cat(1,xEdges,xMin);
            yEdges = cat(1,yEdges,yMin);
            zEdges = cat(1,zEdges,zMin);

            qq.setCutoutArgs((xMin  xMax),...
                (yMin  yMax),...
                (zMin  zMax),...
                resolution);

            % Save query
            tFilename = fullfile(cubeOutputDir,sprintf('ccQuery_token_%s_channel_%s_r%d_x%d-%d_y%d-%d_z%d-%d.mat',...
                token,...
                channel,...
                resolution,...
                xMin, xMax,...
                yMin, yMax,...
                zMin, zMax));
            qq.save(tFilename);

            % Add to list of filenames
            listFileStr = sprintf('%s%s\n',listFileStr,tFilename);

            % Add to informational printing
            debugLog(sprintf('Resolution:%2d - xRange: (%6d %6d) - yRange: (%6d %6d) - zRange: (%6d %6d)\n',...
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
            (xMin,xMax,yMin,yMax,zMin,zMax) = checkCoordBoundaries(xCoord,padX,...
                yCoord,padY,zCoord,padZ,remXSpan,ySpan,remZSpan,xy_size,z_size);

            % Log edges for merge regions later
            xEdges = cat(1,xEdges,xMin);
            yEdges = cat(1,yEdges,yMin);
            zEdges = cat(1,zEdges,zMin);

            qq.setCutoutArgs((xMin  xMax),...
                (yMin  yMax),...
                (zMin  zMax),...
                resolution);

            % Save query
            tFilename = fullfile(cubeOutputDir,sprintf('ccQuery_token_%s_channel_%s_r%d_x%d-%d_y%d-%d_z%d-%d.mat',...
                token,...
                channel,...
                resolution,...
                xMin, xMax,...
                yMin, yMax,...
                zMin, zMax));
            qq.save(tFilename);

            % Add to list of filenames
            listFileStr = sprintf('%s%s\n',listFileStr,tFilename);

            % Add to informational printing
            debugLog(sprintf('Resolution:%2d - xRange: (%6d %6d) - yRange: (%6d %6d) - zRange: (%6d %6d)\n',...
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
        (xMin,xMax,yMin,yMax,zMin,zMax) = checkCoordBoundaries(xCoord,padX,...
            yCoord,padY,zCoord,padZ,remXSpan,remYSpan,remZSpan,xy_size,z_size);

        % Log edges for merge regions later
        xEdges = cat(1,xEdges,xMin);
        yEdges = cat(1,yEdges,yMin);
        zEdges = cat(1,zEdges,zMin);


        qq.setCutoutArgs((xMin  xMax),...
            (yMin  yMax),...
            (zMin  zMax),...
            resolution);

        % Save query
        tFilename = fullfile(cubeOutputDir,sprintf('ccQuery_token_%s_channel_%s_s_r%d_x%d-%d_y%d-%d_z%d-%d.mat',...
            token,...
            channel,...
            resolution,...
            xMin, xMax,...
            yMin, yMax,...
            zMin, zMax));
        qq.save(tFilename);

        % Add to list of filenames
        listFileStr = sprintf('%s%s\n',listFileStr,tFilename);

        % Add to informational printing
        debugLog(sprintf('Resolution:%2d - xRange: (%6d %6d) - yRange: (%6d %6d) - zRange: (%6d %6d)\n',...
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

    if shuffleFilesFlag == 1
        % Shuffle Files
        fid = fopen(cubeListFile,'rt');
        C = textscan(fid, '%s');
        fclose(fid);
        C = C{:};
        orig_inds = 1:size(C,1);
        rand_inds = randperm(size(C,1));

        C(orig_inds) = C(rand_inds);

        %fid = fopen(fullfile(pwd,'test.txt'),'wt');
        fid = fopen(cubeListFile,'wt');
        fprintf(fid,'%s\n',C{:});
        fclose(fid);
    end
end

%% Compute merge blocks
if computeOptions == 1 || computeOptions == 2
    if (padX ~= 0) || (padY ~= 0)  || (padZ ~= 0)
        error('cubeCutoutPreprocess:MergeRegionNoPad','Currently computing merge regions is not supported with padding enabled.');
    end

    % Remove Duplicates
    xEdges = unique(xEdges);
    yEdges = unique(yEdges);
    zEdges = unique(zEdges);

    % Remove Edges
    if xEdges(1) == 0
        xEdges(1) = ();
    end
    if yEdges(1) == 0
        yEdges(1) = ();
    end
    if xEdges(end) == xy_size(1)
        xEdges(end) = ();
    end
    if yEdges(end) == xy_size(2)
        yEdges(end) = ();
    end
    if zEdges(1) == z_size(1)
        zEdges(1) = ();
    end
    if zEdges(end) == z_size(2)
        zEdges(end) = ();
    end

    % Compute x plane cutouts
    xSpan = 2560;
    ySpan = 2560;
    zSpan = 2560;
    padX = 0;
    padY = 0;
    padZ = 0;

    numXblocks = floor(xExtent/xSpan);
    numYblocks = floor(yExtent/ySpan);
    numZblocks = floor(zExtent/zSpan);

    remXSpan = rem(xExtent,xSpan);
    remYSpan = rem(yExtent,ySpan);
    remZSpan = rem(zExtent,zSpan);

    listFileStr = '';
    xCoord = xStart;
    yCoord = yStart;
    zCoord = zStart;
    cnt = 0;

    %% X Plane
    debugLog(sprintf('Computing Z Plane Merge Blocks\n'),print_flag);
    for ee = 1:length(zEdges)
        % Full Blocks
        for yy = 1:numYblocks
            for xx = 1:numXblocks

                % Create Query
                qq = OCPQuery(query_type);

                % Check edge conditions
                (xMin,xMax,yMin,yMax,~,~) = checkCoordBoundaries(xCoord,padX,...
                    yCoord,padY,zCoord,padZ,xSpan,ySpan,zSpan,xy_size,z_size);

                qq.setCutoutArgs((xMin  xMax),...
                    (yMin  yMax),...
                    (zEdges(ee)-1  zEdges(ee)+1),...
                    resolution);

                % Save query
                tFilename = fullfile(mergeOutputDir,sprintf('mergeQuery_token_%s_channel_%s_r%d_x%d-%d_y%d-%d_z%d-%d.mat',...
                    token,...
                    channel,...
                    resolution,...
                    xMin, xMax,...
                    yMin, yMax,...
                    zEdges(ee)-1, zEdges(ee)+1));
                qq.save(tFilename);

                % Add to list of filenames
                listFileStr = sprintf('%s%s\n',listFileStr,tFilename);

                % Add to informational printing
                debugLog(sprintf('Resolution:%2d - xRange: (%6d %6d) - yRange: (%6d %6d) - zRange: (%6d %6d)\n',...
                    resolution,...
                    xMin, xMax,...
                    yMin, yMax,...
                    zEdges(ee)-1, zEdges(ee)+1),print_flag);
                cnt = cnt + 1;

                % Remainder Blocks in Y direction created as you move
                % through X
                if remYSpan ~= 0
                    % Create Query
                    qq = OCPQuery(query_type);

                    % Check edge conditions
                    (xMin,xMax,yMin,yMax,~,~) = checkCoordBoundaries(xCoord,padX,...
                        yStart + (numYblocks*ySpan),padY,zCoord,padZ,xSpan,remXSpan,zSpan,xy_size,z_size);

                    qq.setCutoutArgs((xMin  xMax),...
                        (yMin  yMax),...
                        (zEdges(ee)-1  zEdges(ee)+1),...
                        resolution);

                    % Save query
                    tFilename = fullfile(mergeOutputDir,sprintf('mergeQuery_token_%s_channel_%s_r%d_x%d-%d_y%d-%d_z%d-%d.mat',...
                        token,...
                        channel,...
                        resolution,...
                        xMin, xMax,...
                        yMin, yMax,...
                        zEdges(ee)-1, zEdges(ee)+1));
                    qq.save(tFilename);

                    % Add to list of filenames
                    listFileStr = sprintf('%s%s\n',listFileStr,tFilename);

                    % Add to informational printing
                    debugLog(sprintf('Resolution:%2d - xRange: (%6d %6d) - yRange: (%6d %6d) - zRange: (%6d %6d)\n',...
                        resolution,...
                        xMin, xMax,...
                        yMin, yMax,...
                        zEdges(ee)-1, zEdges(ee)+1),print_flag);

                    cnt = cnt + 1;
                end

                % Step X
                xCoord = xCoord + xSpan;
            end

            % Remainder Blocks in X direction created as you step Y
            if remXSpan ~= 0
                % Create Query
                qq = OCPQuery(query_type);

                % Check edge conditions
                (xMin,xMax,yMin,yMax,~,~) = checkCoordBoundaries(xStart + (numXblocks*xSpan),padX,...
                    yCoord,padY,zCoord,padZ,remXSpan,ySpan,zSpan,xy_size,z_size);

                qq.setCutoutArgs((xMin  xMax),...
                    (yMin  yMax),...
                    (zEdges(ee)-1  zEdges(ee)+1),...
                    resolution);

                % Save query
                tFilename = fullfile(mergeOutputDir,sprintf('mergeQuery_token_%s_channel_%s_r%d_x%d-%d_y%d-%d_z%d-%d.mat',...
                    token,...
                    channel,...
                    resolution,...
                    xMin, xMax,...
                    yMin, yMax,...
                    zEdges(ee)-1, zEdges(ee)+1));
                qq.save(tFilename);

                % Add to list of filenames
                listFileStr = sprintf('%s%s\n',listFileStr,tFilename);

                % Add to informational printing
                debugLog(sprintf('Resolution:%2d - xRange: (%6d %6d) - yRange: (%6d %6d) - zRange: (%6d %6d)\n',...
                    resolution,...
                    xMin, xMax,...
                    yMin, yMax,...
                    zEdges(ee)-1, zEdges(ee)+1),print_flag);

                cnt = cnt + 1;
            end

            xCoord = xStart;
            yCoord = yCoord + ySpan;
        end

        % Double Remainder Block created at the end
        if remXSpan ~= 0 && remYSpan ~= 0
            % Create Query
            qq = OCPQuery(query_type);

            % Check edge conditions
            (xMin,xMax,yMin,yMax,~,~) = checkCoordBoundaries(xStart + (numXblocks*xSpan),padX,...
                yStart + (numYblocks*ySpan),padY,zCoord,padZ,remXSpan,remYSpan,zSpan,xy_size,z_size);

            qq.setCutoutArgs((xMin  xMax),...
                (yMin  yMax),...
                (zEdges(ee)-1  zEdges(ee)+1),...
                resolution);

            % Save query
            tFilename = fullfile(mergeOutputDir,sprintf('mergeQuery_token_%s_channel_%s_r%d_x%d-%d_y%d-%d_z%d-%d.mat',...
                token,...
                channel,...
                resolution,...
                xMin, xMax,...
                yMin, yMax,...
                zEdges(ee)-1, zEdges(ee)+1));
            qq.save(tFilename);

            % Add to list of filenames
            listFileStr = sprintf('%s%s\n',listFileStr,tFilename);

            % Add to informational printing
            debugLog(sprintf('Resolution:%2d - xRange: (%6d %6d) - yRange: (%6d %6d) - zRange: (%6d %6d)\n',...
                resolution,...
                xMin, xMax,...
                yMin, yMax,...
                zEdges(ee)-1, zEdges(ee)+1),print_flag);

            cnt = cnt + 1;
        end

        % Reset for next edge
        xCoord = xStart;
        yCoord = yStart;
    end

    %% Compute y plane cutouts
    debugLog(sprintf('Computing X Plane Merge Blocks\n'),print_flag);
    xCoord = xStart;
    yCoord = yStart;
    zCoord = zStart;

    for ee = 1:length(xEdges)
        % Full Blocks
        for yy = 1:numYblocks
            for xx = 1:numZblocks

                % Create Query
                qq = OCPQuery(query_type);

                % Check edge conditions
                (~,~,yMin,yMax,zMin,zMax) = checkCoordBoundaries(xCoord,padX,...
                    yCoord,padY,zCoord,padZ,xSpan,ySpan,zSpan,xy_size,z_size);

                qq.setCutoutArgs((xEdges(ee)-1  xEdges(ee)+1),...
                    (yMin  yMax),...
                    (zMin  zMax),...
                    resolution);

                % Save query
                tFilename = fullfile(mergeOutputDir,sprintf('mergeQuery_token_%s_channel_%s_r%d_x%d-%d_y%d-%d_z%d-%d.mat',...
                    token,...
                    channel,...
                    resolution,...
                    xEdges(ee)-1, xEdges(ee)+1,...
                    yMin, yMax,...
                    zMin, zMax));
                qq.save(tFilename);

                % Add to list of filenames
                listFileStr = sprintf('%s%s\n',listFileStr,tFilename);

                % Add to informational printing
                debugLog(sprintf('Resolution:%2d - xRange: (%6d %6d) - yRange: (%6d %6d) - zRange: (%6d %6d)\n',...
                    resolution,...
                    xEdges(ee)-1, xEdges(ee)+1,...
                    yMin, yMax,...
                    zMin, zMax),print_flag);
                cnt = cnt + 1;

                % Remainder Blocks in Y direction created as you move
                % through Z
                if remYSpan ~= 0
                    % Create Query
                    qq = OCPQuery(query_type);

                    % Check edge conditions
                    (~,~,yMin,yMax,zMin,zMax) = checkCoordBoundaries(xCoord,padX,...
                        yStart + (numYblocks*ySpan),padY,zCoord,padZ,xSpan,remYSpan,zSpan,xy_size,z_size);

                    qq.setCutoutArgs((xEdges(ee)-1  xEdges(ee)+1),...
                        (yMin  yMax),...
                        (zMin  zMax),...
                        resolution);

                    % Save query
                    tFilename = fullfile(mergeOutputDir,sprintf('mergeQuery_token_%s_channel_%s_r%d_x%d-%d_y%d-%d_z%d-%d.mat',...
                        token,...
                        channel,...
                        resolution,...
                        xEdges(ee)-1, xEdges(ee)+1,...
                        yMin, yMax,...
                        zMin, zMax));
                    qq.save(tFilename);

                    % Add to list of filenames
                    listFileStr = sprintf('%s%s\n',listFileStr,tFilename);

                    % Add to informational printing
                    debugLog(sprintf('Resolution:%2d - xRange: (%6d %6d) - yRange: (%6d %6d) - zRange: (%6d %6d)\n',...
                        resolution,...
                        xEdges(ee)-1, xEdges(ee)+1,...
                        yMin, yMax,...
                        zMin, zMax),print_flag);

                    cnt = cnt + 1;
                end

                % Step Z
                zCoord = zCoord + zSpan;
            end

            % Remainder Blocks in Z direction created as you step Y
            if remZSpan ~= 0
                % Create Query
                qq = OCPQuery(query_type);

                % Check edge conditions
                (~,~,yMin,yMax,zMin,zMax) = checkCoordBoundaries(xCoord,padX,...
                    yCoord,padY,zStart + (numZblocks*zSpan),padZ,xSpan,ySpan,remZSpan,xy_size,z_size);

                qq.setCutoutArgs((xEdges(ee)-1  xEdges(ee)+1),...
                    (yMin  yMax),...
                    (zMin  zMax),...
                    resolution);

                % Save query
                tFilename = fullfile(mergeOutputDir,sprintf('mergeQuery_token_%s_channel_%s_r%d_x%d-%d_y%d-%d_z%d-%d.mat',...
                    token,...
                    channel,...
                    resolution,...
                    xEdges(ee)-1, xEdges(ee)+1,...
                    yMin, yMax,...
                    zMin, zMax));
                qq.save(tFilename);

                % Add to list of filenames
                listFileStr = sprintf('%s%s\n',listFileStr,tFilename);

                % Add to informational printing
                debugLog(sprintf('Resolution:%2d - xRange: (%6d %6d) - yRange: (%6d %6d) - zRange: (%6d %6d)\n',...
                    resolution,...
                    xEdges(ee)-1, xEdges(ee)+1,...
                    yMin, yMax,...
                    zMin, zMax),print_flag);

                cnt = cnt + 1;
            end

            zCoord = zStart;
            yCoord = yCoord + ySpan;
        end

        % Double Remainder Block created at the end
        if remZSpan ~= 0 && remYSpan ~= 0
            % Create Query
            qq = OCPQuery(query_type);

            % Check edge conditions
            (~,~,yMin,yMax,zMin,zMax) = checkCoordBoundaries(xCoord,padX,...
                yStart + (numYblocks*ySpan),padY,zStart + (numZblocks*zSpan),padZ,xSpan,remYSpan,remZSpan,xy_size,z_size);

            qq.setCutoutArgs((xEdges(ee)-1  xEdges(ee)+1),...
                (yMin  yMax),...
                (zMin  zMax),...
                resolution);

            % Save query
            tFilename = fullfile(mergeOutputDir,sprintf('mergeQuery_token_%s_channel_%s_r%d_x%d-%d_y%d-%d_z%d-%d.mat',...
                token,...
                channel,...
                resolution,...
                xEdges(ee)-1, xEdges(ee)+1,...
                yMin, yMax,...
                zMin, zMax));
            qq.save(tFilename);

            % Add to list of filenames
            listFileStr = sprintf('%s%s\n',listFileStr,tFilename);

            % Add to informational printing
            debugLog(sprintf('Resolution:%2d - xRange: (%6d %6d) - yRange: (%6d %6d) - zRange: (%6d %6d)\n',...
                resolution,...
                xEdges(ee)-1, xEdges(ee)+1,...
                yMin, yMax,...
                zMin, zMax),print_flag);

            cnt = cnt + 1;
        end

        % Reset for next edge
        zCoord = zStart;
        yCoord = yStart;
    end

    %% Compute Y plane cutouts
    debugLog(sprintf('Computing Y Plane Merge Blocks\n'),print_flag);
    xCoord = xStart;
    yCoord = yStart;
    zCoord = zStart;

    for ee = 1:length(yEdges)
        % Full Blocks
        for xx = 1:numXblocks
            for zz = 1:numZblocks

                % Create Query
                qq = OCPQuery(query_type);

                % Check edge conditions
                (xMin,xMax,~,~,zMin,zMax) = checkCoordBoundaries(xCoord,padX,...
                    yCoord,padY,zCoord,padZ,xSpan,ySpan,zSpan,xy_size,z_size);

                qq.setCutoutArgs((xMin, xMax),...
                    (yEdges(ee)-1, yEdges(ee)+1),...
                    (zMin, zMax),...
                    resolution);

                % Save query
                tFilename = fullfile(mergeOutputDir,sprintf('mergeQuery_token_%s_channel_%s_r%d_x%d-%d_y%d-%d_z%d-%d.mat',...
                    token,...
                    channel,...
                    resolution,...
                    xMin, xMax,...
                    yEdges(ee)-1, yEdges(ee)+1,...
                    zMin, zMax));
                qq.save(tFilename);

                % Add to list of filenames
                listFileStr = sprintf('%s%s\n',listFileStr,tFilename);

                % Add to informational printing
                debugLog(sprintf('Resolution:%2d - xRange: (%6d %6d) - yRange: (%6d %6d) - zRange: (%6d %6d)\n',...
                    resolution,...
                    xMin, xMax,...
                    yEdges(ee)-1, yEdges(ee)+1,...
                    zMin, zMax),print_flag);
                cnt = cnt + 1;

                % Remainder Blocks in X direction created as you move
                % through Z
                if remXSpan ~= 0
                    % Create Query
                    qq = OCPQuery(query_type);

                    % Check edge conditions
                    (xMin,xMax,~,~,zMin,zMax) = checkCoordBoundaries(xStart + (numXblocks*xSpan),padX,...
                        yCoord,padY,zCoord,padZ,remXSpan,ySpan,zSpan,xy_size,z_size);

                    qq.setCutoutArgs((xMin, xMax),...
                        (yEdges(ee)-1, yEdges(ee)+1),...
                        (zMin, zMax),...
                        resolution);

                    % Save query
                    tFilename = fullfile(mergeOutputDir,sprintf('mergeQuery_token_%s_channel_%s_r%d_x%d-%d_y%d-%d_z%d-%d.mat',...
                        token,...
                        channel,...
                        resolution,...
                        xMin, xMax,...
                        yEdges(ee)-1, yEdges(ee)+1,...
                        zMin, zMax));
                    qq.save(tFilename);

                    % Add to list of filenames
                    listFileStr = sprintf('%s%s\n',listFileStr,tFilename);

                    % Add to informational printing
                    debugLog(sprintf('Resolution:%2d - xRange: (%6d %6d) - yRange: (%6d %6d) - zRange: (%6d %6d)\n',...
                        resolution,...
                        xMin, xMax,...
                        yEdges(ee)-1, yEdges(ee)+1,...
                        zMin, zMax),print_flag);

                    cnt = cnt + 1;
                end

                % Step Z
                zCoord = zCoord + zSpan;
            end

            % Remainder Blocks in Z direction created as you step Y
            if remZSpan ~= 0
                % Create Query
                qq = OCPQuery(query_type);

                % Check edge conditions
                (xMin,xMax,~,~,zMin,zMax) = checkCoordBoundaries(xCoord,padX,...
                    yCoord,padY,zStart + (numZblocks*zSpan),padZ,xSpan,ySpan,remZSpan,xy_size,z_size);

                qq.setCutoutArgs((xMin, xMax),...
                    (yEdges(ee)-1, yEdges(ee)+1),...
                    (zMin, zMax),...
                    resolution);

                % Save query
                tFilename = fullfile(mergeOutputDir,sprintf('mergeQuery_token_%s_channel_%s_r%d_x%d-%d_y%d-%d_z%d-%d.mat',...
                    token,...
                    channel,...
                    resolution,...
                    xMin, xMax,...
                    yEdges(ee)-1, yEdges(ee)+1,...
                    zMin, zMax));
                qq.save(tFilename);

                % Add to list of filenames
                listFileStr = sprintf('%s%s\n',listFileStr,tFilename);

                % Add to informational printing
                debugLog(sprintf('Resolution:%2d - xRange: (%6d %6d) - yRange: (%6d %6d) - zRange: (%6d %6d)\n',...
                    resolution,...
                    xMin, xMax,...
                    yEdges(ee)-1, yEdges(ee)+1,...
                    zMin, zMax),print_flag);

                cnt = cnt + 1;
            end

            zCoord = zStart;
            xCoord = xCoord + xSpan;
        end

        % Double Remainder Block created at the end
        if remZSpan ~= 0 && remXSpan ~= 0
            % Create Query
            qq = OCPQuery(query_type);

            % Check edge conditions
            (xMin,xMax,~,~,zMin,zMax) = checkCoordBoundaries(xStart + (numXblocks*xSpan),padX,...
                yCoord,padY,zStart + (numZblocks*zSpan),padZ,remXSpan,ySpan,remZSpan,xy_size,z_size);

            qq.setCutoutArgs((xMin, xMax),...
                (yEdges(ee)-1, yEdges(ee)+1),...
                (zMin, zMax),...
                resolution);

            % Save query
            tFilename = fullfile(mergeOutputDir,sprintf('mergeQuery_token_%s_channel_%s_r%d_x%d-%d_y%d-%d_z%d-%d.mat',...
                token,...
                channel,...
                resolution,...
                xMin, xMax,...
                yEdges(ee)-1, yEdges(ee)+1,...
                zMin, zMax));
            qq.save(tFilename);

            % Add to list of filenames
            listFileStr = sprintf('%s%s\n',listFileStr,tFilename);

            % Add to informational printing
            debugLog(sprintf('Resolution:%2d - xRange: (%6d %6d) - yRange: (%6d %6d) - zRange: (%6d %6d)\n',...
                resolution,...
                xMin, xMax,...
                yEdges(ee)-1, yEdges(ee)+1,...
                zMin, zMax),print_flag);

            cnt = cnt + 1;
        end

        % Reset for next edge
        zCoord = zStart;
        xCoord = xStart;
    end


    %% Print results for logging
    debugLog(sprintf('Generated %d merge queries.\n\n',cnt),print_flag);


    %% write cube cutout list file
    fid = fopen(mergeListFile,'wt');

    if ispc
        %need to fix \
        listFileStr = strrep(listFileStr,'\','\\');
    end

    fprintf(fid,listFileStr);
    fclose(fid);

    if shuffleFilesFlag == 1
        % Shuffle Files
        fid = fopen(mergeListFile,'rt');
        C = textscan(fid, '%s');
        fclose(fid);
        C = C{:};
        orig_inds = 1:size(C,1);
        rand_inds = randperm(size(C,1));

        C(orig_inds) = C(rand_inds);

        fid = fopen(mergeListFile,'wt');
        fprintf(fid,'%s\n',C{:});
        fclose(fid);
    end

end
end

function (xMin,xMax,yMin,yMax,zMin,zMax) = checkCoordBoundaries(xCoord,padX,...
    yCoord,padY,zCoord,padZ,xSpan,ySpan,zSpan,xy_size,z_size)

% Check start edge conditions
if xCoord - padX < 0
    xMin = 0;
else
    xMin = xCoord - padX;
end

if yCoord - padY < 0
    yMin = 0;
else
    yMin = yCoord - padY;
end

if zCoord - padZ < z_size(1)
    zMin = z_size(1);
else
    zMin = zCoord - padZ;
end

% Check end edge conditions
if xCoord + xSpan + padX > xy_size(1)
    xMax = xy_size(1);
else
    xMax = xCoord + xSpan + padX;
end

if yCoord + ySpan + padY > xy_size(2)
    yMax = xy_size(2);
else
    yMax = yCoord + ySpan + padY;
end

if zCoord + zSpan + padZ > z_size(2)
    zMax = z_size(2);
else
    zMax = zCoord + zSpan + padZ;
end
end

function debugLog(string, print_flag)
if print_flag == 1
    fprintf(string);
end
end
