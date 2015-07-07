function segOut = cleanup_speckle(segIn)
% Function to iteratively dilate labeled regions to remove backround
% regions
% Function terminates when none left
% TODO: max loops just in case
% TODO: clean up appropriately

%Usage suggestion: 
% rp = regionprops(segIn,'PixelIdxList','Area');
% areaAll = [rp.Area];
% toRemove = find(areaAll < thresh); %perhaps 500 pixels
% for i = 1:length(toRemove)
%   segIn(rp(toRemove(i)).PixelIdxList) = 0;
%end
%


% W Gray Roncal 01152015

segOut = zeros(size(segIn));

for i = 1:size(segIn,3)
    i
    L = segIn(:,:,i);
    L2 = L;
while sum(L2(:) == 0) > 0
    L2 = imdilate(L,strel('disk',3));
    L2(L>0) = L(L>0);
    sum(L2(:) == 0);
    L = L2;
end
segOut(:,:,i) = L;
end