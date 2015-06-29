function cropVolume(volFileIn, volFileOut, cropX, cropY, cropZ)

%% load volFileIn

load(volFileIn) %assume stored as cube

dd = cube.data; 

off = cube.xyzOffset;

dd(cropX+1:end-cropX, cropY+1:end-cropY, cropZ+1,end-cropZ);

cube.setXyzOffset([off(1)+cropX,off(2)+cropY,off(3)+cropZ]);

cube.setCutout(dd)

save(volFileOut,'cube')
