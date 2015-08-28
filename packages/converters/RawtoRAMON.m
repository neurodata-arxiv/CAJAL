function RawtoRAMON(RAMONVolInFile, RAMONVolOutFile, queryFile, padX, padY, padZ)

%Should be called cube
load(RAMONVolInFile)
load(queryFile)

data = cube;

cube = RAMONVolume;
cube.setCutout(data);
cube.setResolution(query.resolution);
cube.setXyzOffset([query.xRange(1)+padX,query.yRange(1)+padY,query.zRange(1)+padZ]); %TODO
save(RAMONVolOutFile, 'cube') %-v7.3 TODO