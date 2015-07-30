function RAMONtoTIFF(fileIn, fileOut)
% Save RAMON volume data to a tiff-stack file

load(fileIn)
im = cube;

for ii = 1:size(im.data,3)
    imwrite(im.data(:,:,ii), fileOut, 'writemode', 'append');
end

end