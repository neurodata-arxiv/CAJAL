function RAMONtoRaw(RAMONVolInFile, RAMONVolOutFile)

%Should be called cube
load(RAMONVolInFile)

cube = cube.data;

save(RAMONVolOutFile, 'cube') %-v7.3 TODO