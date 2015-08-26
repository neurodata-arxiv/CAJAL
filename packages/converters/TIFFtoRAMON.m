function TIFFtoRAMON(tiffIn, fileOut, queryFile, padX, padY, padZ)
% Save tiff stack as ramon
% ask jordan (github j6k4m8) when this breaks

load(queryFile);

xSize = xRange(2) - xRange(1);
ySize = yRange(2) - yRange(1);
zSize = zRange(2) - zRange(1);

data = zeros(xSize, ySize, zSize);

for ii = 1:size(im.data,3)
    data(:,:,ii) = imread(tiffIn, ii);
end

cube = RAMONVolume;
cube.setCutout(data);
cube.setResolution(query.resolution);
cube.setXyzOffset([query.xRange(1)+padX,query.yRange(1)+padY,query.zRange(1)+padZ]);
save(fileOut, 'cube')

end