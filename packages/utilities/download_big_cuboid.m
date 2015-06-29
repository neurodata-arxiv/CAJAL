function VOL = download_big_cuboid(ocp, query)

zStart = query.zRange(1);
zStop = query.zRange(2);

for i = zStart:zStop-1
    i
    query.setZRange([i-1,i]);
    zz = ocp.query(query);
    vol(:,:,i-zStart+1) = zz.data;
    if i == zStart
        VOL = zz;
    end
end

VOL.setCutout(vol);

query.setZRange([zStart, zStop]); %reset because of shared memory
