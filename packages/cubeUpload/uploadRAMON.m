function uploadRAMON (server, token, channel, RAMONObj, useSemaphore, idFile, varargin)
    % uploadRAMON function allows the user to post complete RAMON objects
    % (annotations and meta data), annotation metadata, or batch upload RAMON
    % prototypes.
    %
    % **Inputs**
    %
    %	:server: [string]   OCP server name serving as the target for annotations 
    %
    %	:token: [string]    OCP token name serving as the target for annotations
    %
    %   :channel: [string]  OCP channel name serving as the target for annotations
    %
    %	:RAMONObj: [RAMON object, cell array, string]  single RAMON object, cell array of RAMON objects, or path and filename of .mat file containing the RAMON object to be posted
    %
    %	:useSemaphore: [int][default=0]  throttles reading/writing client-side for large batch jobs.  Not needed in single cutout mode
    %
    %	:ids: [integer array]   optional ids if labels already exist or space has been reserved in the database
    %
    % **Outputs**
    %
    %	No explicit outputs.  Output file is optionally saved to disk rather
    %	than output as a variable to allow for downstream integration with
    %	LONI.
    %
    % **Notes**
    %
    %	When uploading metadata for a single or multiple complete RAMON
    %	objects, you should stack the RAMON objects in a cell array and pass
    %	that either directly or through a file.
    %   When uploading a prototype RAMON object to one or more ids, pass a
    %   single RAMON object either directly or through a file.
    %   If no id is provided, both of these methods perform the same. If there
    %   are mutliple ids and one RAMON object, then the RAMON proto option will
    %   be selected. If there are an uneven (but greater than one) number of
    %   RAMON objects and ids, then an error will be raised.

if nargin > 6
    outFile = varargin{1};
end

% Allow ids to be unset - left empty
ids = [];

if ~isempty(idFile)
    load(idFile)
    
    % Verify that if ids are set that
    if ~isempty(ids)
        assert(length(ids)==length(RAMONObj));     
    end
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
    ids = oo.createAnnotation(obj);
catch
    for i = 1:length(obj)
        ids(i) = oo.createAnnotation(obj{i});
    end
end

save('idFile', 'ids')
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