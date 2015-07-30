function TIFFtoRaw(tiffIn, fileOut)
% Convert tiff stack to raw
% ask jordan (github j6k4m8) when this breaks


for ii = 1:size(im.data,3)
    data(:,:,ii) = imread(tiffIn, ii);
end

save(fileOut, 'data');

end