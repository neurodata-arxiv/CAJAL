function uploadRAMON (server, token, channel, RAMONObj, useSemaphore, ids, varargin)
%uploadRAMON
% if people want to use voxel list they use this not upload labels

% Function to upload objects in a RAMON volume as a denseVolume

% Requires that all objects begin from a common prototype, and that
% RAMONVolume has appropriate fields (in particular resolution and XYZ
% offset)
% This only supports anno32 data for now and the preserve anno option

if nargin > 6
    outFile = varargin{1};
end

if nargin > 5
    assert(length(ids)==length(RAMONObj))
else
    ids = [];
end

if useSemaphore
    oo = OCP('semaphore');
else
    oo = OCP;
end

if ischar(RAMONObj)
    load(RAMONObj) %should be saved as cube
    assert(exist('obj', 'var'))
else
    obj = RAMONObj;
end

oo.setServerLocation(server);
oo.setAnnoToken(token);
oo.setAnnoChannel(channel);


if iscell(obj)
    obj = normalProcess(obj, ids);
else
    obj = batchProcess(obj, ids);
end

try
    oo.createAnnotation(obj);
catch
    for i = 1:length(obj)
        oo.createAnnotation(obj{i});
    end
end

if exist('outFile')
    save(outFile,'obj')
end

    function object = batchProcess(obj, ids)
        object{1} = obj; %sets the first in case no ids are present
        for ii = 1:length(ids)
            object{ii} = obj;
            object{ii}.setId(ids(ii));
        end
    end

    function object = normalProcess(obj, ids)
        object = obj;
        for ii = 1:length(ids)
            object{ii}.setId(ids(ii))
        end
    end

end