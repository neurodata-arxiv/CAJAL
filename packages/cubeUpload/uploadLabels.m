function uploadLabels(server, token, channel, volume, idFile, probability, doRelabel, useSemaphore, varargin)
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
%   :probability: [float][default=0]   flag indicating whether annotation is a probaility map
%
%	:useSemaphore: [int][default=0]  throttles reading/writing client-side for large batch jobs.  Not needed in single cutout mode
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
    %assert(exist('cube', 'var')) %TODO
else
    cube = volume;
end

if sum(cube.data(:)) <= 0 %all zero cube
    disp('no detections to upload')
    return
end

%% Upload to OCP
tic
% relabel Paint

if probability == 1
    labels = double(cube.data);
    ids = [];
    % Reuse object
    cube.setCutout(labels);
    cube.setChannel(channel);
    cube.setDataType(eRAMONChannelDataType.float32); %just in case
    cube.setChannelType(eRAMONChannelType.image)
    tic
    oo.createAnnotation(cube);
    fprintf('Block Write Upload: ');
    toc
    
    save(idFile, 'ids');
    
else %annodata
    
    labels = uint32(cube.data); %TODO - loss of precision if nid > 2^32
    
    if doRelabel
    fprintf('Relabling: ');
        [zz, n] = relabel_id(labels);
    

        labelOut = zeros(size(zz));
        
        if exist(idFile);
            load(idFile)
        else
            ids = oo.reserve_ids(n);
        end
        
        rp = regionprops(zz,'PixelIdxList');
        for ii = 1:length(rp)
            labelOut(rp(ii).PixelIdxList) = ids(ii);
        end
        
        clear zz
        cube.setCutout(labelOut);

        toc
    end 
        % Block write paint
        tic
        
        % Reuse object
        cube.setChannel(channel);
        
        cube.setDataType(eRAMONChannelDataType.uint32); %just in case
        cube.setChannelType(eRAMONChannelType.annotation)
        oo.createAnnotation(cube);
        fprintf('Block Write Upload: ');
        toc
    end
    
    if exist('outFile')
        save(outFile,'cube')
    end
    
    save(idFile, 'ids');