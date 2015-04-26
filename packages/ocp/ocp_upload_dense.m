function ocp_upload_dense(server, token, RAMONVol, protoRAMON, useSemaphore, varargin)

% W. Gray Roncal

% Function to upload objects in a RAMON volume as a denseVolume

% Requires that all objects begin from a common prototype, and that
% RAMONVolume has appropriate fields (in particular resolution and XYZ
% offset)
% This only supports anno32 data for now and the preserve anno option

if nargin > 6
    outFile = varargin{1};
end

if useSemaphore
    oo = OCP('semaphore');
else
    oo = OCP;
end

oo.setServerLocation(server);
oo.setAnnoToken(token);

% Load data volume
if ischar(RAMONVol)
    load(RAMONVol) %should be saved as cube
else
    cube = RAMONVol;
end


%% Upload to OCP

% relabel Paint
fprintf('Relabling: ');
labels = uint32(cube.data); %TODO - loss of precision if nid > 2^32
[zz, n] = relabel_id(labels);

% Create empty RAMON Objects

obj_cell = cell(n,1);
for ii = 1:n
    obj_cell{ii} = protoRAMON.clone;
end

% Batch write RAMON Objects
tic
oo.setBatchSize(100);
ids = oo.createAnnotation(obj_cell);
fprintf('Batch Metadata Upload: ');
toc

labelOut = zeros(size(zz));

rp = regionprops(zz,'PixelIdxList');
for ii = 1:length(rp)
    labelOut(rp(ii).PixelIdxList) = ids(ii);
end

clear zz
toc

% Block write paint
tic

% Reuse object
cube.setCutout(labelOut);
cube.setDataType(eRAMONDataType.anno32); %just in case
oo.createAnnotation(cube);
fprintf('Block Write Upload: ');
toc

if exist('outFile')
save(outFile,'cube')
end