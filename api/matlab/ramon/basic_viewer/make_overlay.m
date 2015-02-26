function overlayOut = make_overlay(imgVol, annoVol)

% This is a helper function to make an overlay volume suitable for use with
% the viewer (e.g., image(RAMONVolume).  It has limited functionality and
% requires that images are the same size and are coregistered.

% Inputs:  RAMONVolume with images, RAMONVolume with annotations
% Output:  MxNxPx4 array containing overlaid images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2015 The Johns Hopkins University / Applied Physics Laboratory 
% All Rights Reserved. 
% Contact the JHU/APL Office of Technology Transfer for any additional rights.  
% www.jhuapl.edu/ott
%  
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%  
%     http://www.apache.org/licenses/LICENSE-2.0
%  
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nColors = 16;

img = imgVol.data;
anno = annoVol.data;

% Rescale image:
mmin = min(img(:));
mmax = max(img(:));

if (mmax-mmin) == 0,
    mmin = 0;
end

img = uint8(double(img - mmin) / double(mmax-mmin)*255.0);

overlayColors = round(255*jet(nColors));% Array containing color info (id,r,g,b)
overlayColors(end+1,:) = [0,0,0]; %for BG
%annoOut = uint8(zeros(size(anno,1),size(anno,2),3,size(anno,3)));
for i = 1:size(anno,3)
    if mod(i,20) == 0
        sprintf('Now processing slice %d of %d...\n',i,size(anno,3));
    end
    annoSlice = anno(:,:,i);
    imgSlice = img(:,:,i);
    
    if size(imgSlice,3) == 1,
        imgSlice = cat(3, imgSlice,imgSlice,imgSlice);
    end
    
    colorIdx = mod(annoSlice,nColors - 1) + 1;
    colorIdx(annoSlice == 0) = size(overlayColors,1);
    annoOut(:,:,1)  = reshape(overlayColors(colorIdx,1),size(annoSlice,1),size(annoSlice,2));
    
    annoOut(:,:,2)  = reshape(overlayColors(colorIdx,2),size(annoSlice,1),size(annoSlice,2));
    annoOut(:,:,3)  = reshape(overlayColors(colorIdx,3),size(annoSlice,1),size(annoSlice,2));
    
    overlayImgLayer = uint8(annoOut);
    overlayAlphaLayer = uint8(sum(overlayImgLayer,3));
    overlayAlphaLayer(overlayAlphaLayer > 0) = 100;
    
    % Merge Images
    overlayAlphaLayer = repmat(overlayAlphaLayer,[1 1 3]);
    
    overlayAlphaLayer = double(overlayAlphaLayer);
    imgSlice = double(imgSlice);
    overlayImgLayer = double(overlayImgLayer);
    overlaySlice = (imgSlice .* (255 - overlayAlphaLayer)./255) + (overlayImgLayer .* (overlayAlphaLayer./255));
    
    overlayOut(:,:,:,i) = uint8(overlaySlice);
end

