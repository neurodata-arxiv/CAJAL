function cubeCutout(token, channel, queryFile, outputFile, useSemaphore, objectType, serviceLocation)
% cubeCutout function allows the user to retrieve raw cutout volumes (i.e. no meta data) of image or annotation volumes from NeuroData.
%
% **Inputs**
%
% token: (string)
%   - OCP token name serving as the source for data
%
% channel: (string)
%   - OCP channel name for source data
%
% queryFile: (string)
%   - Fully formed OCP query saved to a .mat file
%
% outFile (string)
%   - Location of output file, saved as a matfile containing a RAMONVolume named 'cube'.  Contains result of applying classifier to input data.
%
% useSemaphore: (int)(default=0)
%   - throttles reading/writing client-side for large batch jobs.  Not needed in single cutout mode.
%
% objectType: (int)
%   - Flag indicating data download type. 0=RAMONVolume saved to .mat; 1=HDF5 saved to .h5
%
% serviceLocation: (string)
%   - Location of OCP server hosting the data, typically openconnecto.me
%
% **Outputs**
%
%	No explicit outputs.  Output file is saved to disk rather than
%	output as a variable to allow for downstream integration with LONI.

if ~exist('useSemaphore','var')
    useSemaphore = false;
end

if ~exist('objectType','var')
    objectType = 0;
end

if ~exist('serviceLocation','var')
    serviceLocation = 'http://openconnecto.me/';
end

validateattributes(token,{'char'},{'row'});
validateattributes(queryFile,{'char'},{'row'});

if useSemaphore == 1
    oo = OCP('semaphore');
else
    oo = OCP();
end

oo.setServerLocation(serviceLocation);
oo.setImageToken(token);
oo.setImageChannel(channel);

%% Load Query
queryObj = OCPQuery.open(queryFile);

%% Get Data and save file

cube = oo.query(queryObj);

switch objectType
    case 0
        save(outputFile,'cube');
    case 1
        % TODO:  Build this into interfaces in a more standard way
        % Save relevant "cutout" RAMONVolume fields to HDF5 file.
        % data, dataFormat, xyzOffset, resolution, etc.
        % To accomodate HDF5 packaging (OCP+server), we permute cube
        % dimensions here
        data = cube.data;
        data = permute(data,[2,1,3]);
        cube.setCutout(data);
        OCPHdf(cube,outputFile);
    otherwise
        error('cubeCutout:DATAFORMATERROR','Invalid output type:%d',objectType);
end
