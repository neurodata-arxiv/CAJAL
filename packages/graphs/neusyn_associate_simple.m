function edgeList = neusyn_associate_simple(nMtxCube, sMtxCube)

synDil = 5;

sMtx = imdilate(sMtxCube.data,strel('disk',synDil));
uid = unique(sMtxCube.data);
uid(uid == 0) = [];

rp = regionprops(sMtx,'PixelIdxList','Area');
edgeList = [];
for i = 1:length(uid)
    if rp(uid(i)).Area > 0
        sId = nMtxCube.data(rp(uid(i)).PixelIdxList);
        sId(sId == 0) = [];
        sp1 = mode(sId);
        sId(sId == sp1) = [];
        sp2 = mode(sId);
        
        % Skipping direction
        direction = 0;
        synDatabaseId = double(uid(i));
        
       % if sp1 > 0 & sp2 > 0 % TODO - possibly errorful
            
            edgeList(end+1,:) =  [sp1, sp2, synDatabaseId, 0];
       % end
    end
end
