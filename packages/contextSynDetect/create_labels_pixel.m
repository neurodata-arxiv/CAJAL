function Y = create_labels_pixel(sData, pixIdx, pad)

Y = -1*ones(length(pixIdx),1);
sDistance = bwdistsc(sData>0,[1,1,5]);
padRegion = uint8(ones(size(sData)));
padRegion(pad(1)+1:end-pad(1), pad(2)+1:end-pad(2), pad(3)+1:end-pad(3)) = 0;
for i = 1:length(pixIdx)
    yScore = sData(pixIdx(i));
    padScore = padRegion(pixIdx(i));
    yDist = sDistance(pixIdx(i));
    
    if padScore == 0
        if yScore > 0.5
            Y(i,1) = 1;
        elseif yScore == 0 && yDist >= 10
            Y(i,1) = 0;
        else
            Y(i,1) = -1; % these are ambiguous, and bad for training!
        end
    else
        Y(i,1) = -1; % these are ambiguous, and bad for training!
    end
end