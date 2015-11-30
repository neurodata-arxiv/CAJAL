function RAMONtoHDF5(inFile, outputFile)

% TODO:
%Build this into interfaces in a more standard way
% Save relevant "cutout" RAMONVolume fields to HDF5 file.
% data, dataFormat, xyzOffset, resolution, etc.
% To accomodate HDF5 packaging (OCP+server), we permute cube
% dimensions here

load(inFile) %must be saved as cube

data = cube.data;
data = permute(data,[2,1,3]);
cube.setCutout(data);
OCPHdf(cube,outputFile);