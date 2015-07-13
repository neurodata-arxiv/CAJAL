function [eData, mData, sData, vData] = get_ac4_data(zStart, zEnd)
% Simple helper function to get AC4 data from server for synapse detection
oo = OCP();
oo.setServerLocation('http://braingraph1dev.cs.jhu.edu/');
oo.setImageToken('kasthuri11cc');

xTestExt = [4400, 5424];
yTestExt = [5440, 6464];
zTestExt = [zStart,zEnd];

q = OCPQuery();
q.setResolution(1);
q.setType(eOCPQueryType.imageDense);
q.setXRange(xTestExt);
q.setYRange(yTestExt);
q.setZRange(zTestExt);

try
eData = oo.query(q);

catch
  eData = download_big_cuboid(oo,q);
end
    disp('done with edata')

%% Synapse Data
oo.setServerLocation('http://openconnecto.me/');
oo.setAnnoToken('ac4_synTruth_v3');
q.setType(eOCPQueryType.annoDense);

try
    sData = oo.query(q);   
catch
    sData = download_big_cuboid(oo,q);
end
%% Membranes
oo.setServerLocation('http://dsp061.pha.jhu.edu/');
oo.setAnnoToken('kasthuri11_final_membranes');

q.setType(eOCPQueryType.probDense);

try
    mData = oo.query(q);
    
catch
    mData = download_big_cuboid(oo,q);
end
%% Vesicles
oo.setServerLocation('http://dsp061.pha.jhu.edu/');
oo.setAnnoToken('kasthuri11_inscribed_vesicles');
q.setType(eOCPQueryType.annoDense);

try
    vData = oo.query(q);
catch
    vData = download_big_cuboid(oo,q);
end

