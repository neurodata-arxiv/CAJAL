function [labelOut, nLabel] = relabel_id(labelIn,varargin)
%This function has two modes of operation:
%2d mode, which makes sure each slice has a unique ID and relabels
%3d mode, which simply reindexes 1:N

if nargin == 1
    mode = 3;
else
    mode = varargin{1};
end


if mode == 3
    id = regionprops(labelIn, 'PixelIdxList','Area');
    
    labelOut = uint32(zeros(size(labelIn)));
    count = 1;
    for i = 1:length(id)
        if id(i).Area > 0
            labelOut(id(i).PixelIdxList) = count;
            count = count + 1;
        end
    end
    
elseif mode == 2
    labelOut = uint32(zeros(size(labelIn)));
    count = 1;
    
    for i = 1:size(labelIn,3)
        slice = labelIn(:,:,i);
        sliceOut = zeros(size(slice));
        id = regionprops(slice, 'PixelIdxList','Area');
        
        for j = 1:length(id)
            if id(j).Area > 0
                sliceOut(id(j).PixelIdxList) = count;
                count = count + 1;
            end
        end
    labelOut(:,:,i) = sliceOut;    
    end
    
else
    error('merge mode not supported.')
end


nLabel = count-1;

% save memory
if nLabel <= intmax('uint8')
    labelOut = uint8(labelOut);
elseif nLabel <= intmax('uint16')
    labelOut = uint16(labelOut);
else
    labelOut = uint32(labelOut);
end
