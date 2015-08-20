%test_query
xstart = 5472; 
xstop = xstart + 512;
ystart = 8712;
ystop = ystart + 512;
zstart = 1020;
zstop = zstart + 16;

resolution = 1;

query = OCPQuery;
query.setType(eOCPQueryType.imageDense);
query.setCutoutArgs([xstart, xstop],[ystart,ystop],[zstart,zstop],resolution);

server = 'openconnecto.me';
token = 'kasthuri11cc';
