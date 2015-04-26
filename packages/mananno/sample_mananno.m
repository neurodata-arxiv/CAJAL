% Mananno Example File

%% test_query
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

%% Servers and tokens - alter appropriately
server = 'openconnecto.me';
token = 'kasthuri11cc';

serverUp = 'braingraph1dev.cs.jhu.edu'
tokenUp = 'temp2';

%% Run Mananno

mananno_getImage(server,token,'queryFileTest','testitk.nii',0)
mananno_putAnno(serverUp,tokenUp,'queryFileTest','exampleAnno.nii.gz',RAMONOrganelle, 1,0)