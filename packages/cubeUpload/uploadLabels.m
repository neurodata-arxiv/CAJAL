function uploadLabels(server, token, channel, volume, idFile, probability, useSemaphore, varargin)
    % uploadLabels function allows the user to post raw annotation data (i.e.
    % no meta data) in the form of either annotation labels or probabilities to
    % OCP.
    %
    % **Inputs**
    %
    %	:server: [string]   OCP server name serving as the target for annotations 
    %
    %	:token: [string]    OCP token name serving as the target for annotations
    %
    %   :channel: [string]  OCP channel name serving as the target for annotations
    %
    %	:volume: [RAMONVolume, string]  RAMONVolume or path and filename of .mat file containing the RAMONVolume to be posted
    %
    %	:idFile: [string]   path and filename which will store the posted id
    %
    %   :probability: [number][default=0]   flag indicating whether annotation is a probaility map
    %
    %	:useSemaphore: [number][default=0]  throttles reading/writing client-side for large batch jobs.  Not needed in single cutout mode
    %
    % **Outputs**
    %
    %	No explicit outputs.  Output file is optionally saved to disk rather
    %	than output as a variable to allow for downstream integration with
    %	LONI.
    %
    % **Notes**
    %
    %	Probabilities are uploaded as float32 data, and normal annotations are
    %	uploaded as uint32.

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
save(idFile, 'ids');

end
