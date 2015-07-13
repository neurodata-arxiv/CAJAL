function cubeUploadVoxelList(server, token, RAMONVolume, protoRAMON, useSemaphore, outFile)

% W. Gray Roncal

% Function to upload objects in a RAMON volume as a voxelList

% Requires that all objects begin from a common prototype, and that
% RAMONVolume has appropriate fields (in particular resolution and XYZ
% offset)
% This only supports anno32 data for now and the preserve anno option

if useSemaphore
    oo = OCP('semaphore');
else
    oo = OCP;
end

oo.setServerLocation(server);
oo.setAnnoToken(token);

% Load data volume
if ischar(RAMONVolume)
    load(RAMONVolume) %should be saved as cube
else
    cube = RAMONVolume.clone;
end

zz = relabel_id(cube.data);

rp = regionprops(zz,'PixelIdxList');

%% Upload RAMON objects as voxel lists with preserve write option
fprintf('Creating RAMON Objects...');
objects = cell(length(rp),1);

for ii = 1:length(rp)
    
    s = eval(protoRAMON);
    s.clearDynamicMetadata; %TODO Clone issue
    s.setDataType([]); %TODO Clone issue
    
    s.setDataType(eRAMONDataType.anno32);
    s.setXyzOffset(cube.xyzOffset);
    s.setResolution(cube.resolution);
    
    [r,c,z] = ind2sub(size(cube.data),rp(ii).PixelIdxList);
    voxel_list = cat(2,c,r,z);
    
    s.setVoxelList(cube.local2Global(voxel_list));
    
    % Approximate absolute centroid
    approxCentroid = cube.local2Global(round(mean(voxel_list,1)));
    
    %metadata - for convenience
    s.addDynamicMetadata('approxCentroid', approxCentroid);
    
    
    objects{ii} = s;
    clear s
end

if length(rp) ~= 0
    fprintf('Uploading %d objects\n\n',length(objects));
    ids = oo.createAnnotation(objects,eOCPConflictOption.preserve);
    
    for ii = 1:length(ids)
        fprintf('Uploaded object id: %d\n',ids(ii));
    end
    
else
    fprintf('No Objects Detected\n');
end