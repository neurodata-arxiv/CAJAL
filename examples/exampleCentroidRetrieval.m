fileout = 'test.csv';
annoToken = 'test_ramonify_public';
annoChannel = 'synapse'
step = 100; %number of annotations to process at a time
oo = OCP;
oo.setAnnoToken(annoToken);
oo.setAnnoChannel(annoChannel);

q = OCPQuery;
q.setType(eOCPQueryType.RAMONIdList);
q.validate
id = oo.query(q);
q.setType(eOCPQueryType.RAMONMetaOnly);

cen = [];
for i = 1:step:length(id)
    i
    endId = min(i + step-1, length(id));
    q.setId(id(i:1:endId));
    c = oo.query(q);
    for j = 1:length(c)
        cen(end+1,:) = [c{j}.id,str2num(c{j}.dynamicMetadata('centroid'))];
    end
end

% IDs are returned in non-sorted order from OCP
[~,idx] = sort(cen(:,1),'ascend');
cen = cen(idx,:);

csvwrite(fileout,cen)