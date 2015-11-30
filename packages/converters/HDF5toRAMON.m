function HDF5toRAMON(inFile, outputFile,varargin)

% TODO:
%Build this into interfaces in a more standard way
% Save relevant "cutout" RAMONVolume fields to HDF5 file.
% data, dataFormat, xyzOffset, resolution, etc.
% To accomodate HDF5 packaging (OCP+server), we permute cube
% dimensions here

if nargin == 4
    load(queryFile) % not supported
    dataset = varargin{1};
elseif nargin == 3
    dataset = varargin{1};
else
    dataset = 'CUTOUT';
end

data = h5read(inFile,dataset);

cube = RAMONVolume;
cube.setCutout(data); %no compensation as in cube cutout, because assumed local
save(outputFile,'cube')