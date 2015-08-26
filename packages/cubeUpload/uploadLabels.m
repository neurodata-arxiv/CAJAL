function uploadLabels(server, token, channel, volume, idFile, probability, useSemaphore, varargin)

% Function to upload objects in a RAMON volume as a denseVolume

% Requires that all objects begin from a common prototype, and that
% RAMONVolume has appropriate fields (in particular resolution and XYZ
% offset)
% This only supports anno32 data for now and the preserve anno option

if nargin > 8
    outFile = varargin{1};
end

if useSemaphore
    oo = OCP('semaphore');
else
    oo = OCP;
end

oo.setServerLocation(server);
oo.setAnnoToken(token);
oo.setAnnoChannel(channel);
oo.setChannel(channel);


% Load data volume
if ischar(volume)
    load(volume) %should be saved as cube
    assert(exist('cube', 'var'))
else
    cube = volume;
end

%% Upload to OCP
tic
% relabel Paint
fprintf('Relabling: ');
if ~probability
    labels = uint32(cube.data); %TODO - loss of precision if nid > 2^32
else
    labels = double(cube.data);
end
[zz, n] = relabel_id(labels);

labelOut = zeros(size(zz));
ids = oo.reserve_ids(n);

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

if probability
    cube.setDataType(eRAMONChannelDataType.float32); %just in case
else
    cube.setDataType(eRAMONChannelDataType.uint32); %just in case
end

oo.createAnnotation(cube);
fprintf('Block Write Upload: ');
toc

if exist('outFile')
    save(outFile,'cube')
end
save(idFile, ids);

end
