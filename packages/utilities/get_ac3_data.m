function [eData, mData, sData, vData] = get_ac3_data(zSlice, zSliceEnd)
oo = OCP();
oo.setServerLocation('openconnecto.me');
oo.setImageToken('kasthuri11cc');

%AC3
xTrainExt = [5472, 6496];
yTrainExt = [8712, 9736];
zTrainExt = [zSlice,zSliceEnd]; %1256

q = OCPQuery();
q.setResolution(1);
q.setType(eOCPQueryType.imageDense);
q.setXRange(xTrainExt);
q.setYRange(yTrainExt);
q.setZRange(zTrainExt);

try
    eData = oo.query(q);
    
catch
    eData = download_big_cuboid(oo,q);
end
%% Synapse Data

oo.setServerLocation('http://openconnecto.me/');
oo.setAnnoToken('kasthuri11_ac3_synapseTruth');
q.setType(eOCPQueryType.annoDense);

try
    sData = oo.query(q);
catch
    sData = download_big_cuboid(oo,q);
end

%% Membranes
oo.setServerLocation('openconnecto.me');
oo.setAnnoToken('kasthuri11_ac3_membranes');

q.setType(eOCPQueryType.probDense);

try
    mData = oo.query(q);
catch
    mData = download_big_cuboid(oo,q);
end
%% Vesicles

oo.setServerLocation('openconnecto.me');
oo.setAnnoToken('kasthuri11cc_ac3_vesicles');
q.setType(eOCPQueryType.annoDense);

try
    vData = oo.query(q);
catch    
    vData = download_big_cuboid(oo,q);
end
