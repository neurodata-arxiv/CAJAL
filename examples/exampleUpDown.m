% W Gray Roncal - 02.12.2015
% Demonstrates downloading from the server and uploading from the server (best practices)

%% Download Data
% View data cuboid here (100 megavoxels)
% http://openconnecto.me/ocp/overlay/0.7/ac4/xy/1/4400,5424/5440,6464/1100/
% Careful to use an API version compatible with the server
% Uploads currently slow on DSP

% relabel_id is a dependency in this example.  It can be safely omitted, but regionprops will potentially allocate a lot of extra memory.  It is available here:
% https://github.com/openconnectome/i2g/blob/dev/packages/utilities/relabel_id.m

oo = OCP();
oo.setServerLocation('http://openconnecto.me');
oo.setImageToken('kasthuri11cc');
oo.setAnnoToken('ac4')

q = OCPQuery;
q.setType(eOCPQueryType.annoDense);
q.setCutoutArgs([4400,5424],[5440,6464],[1100,1200],1);
segCuboid = oo.query(q);


%% Upload Data - assumes OCP class has been setup, above

oo.setServerLocation('http://openconnecto.me');
oo.setImageToken('kasthuri11cc');
oo.setDefaultResolution(1);
oo.setAnnoToken('test_upload_ramon');
oo.setAnnoChannel('anno');
[zz, n] = relabel_id(segCuboid.data);
 
% Create empty RAMON Objects - faster than the naive way
seg = RAMONSegment();
seg.setAuthor('test upload');
seg_cell = cell(n,1);
for ii = 1:n
    s = seg.clone();
    seg_cell{ii} = s;
end

% Batch write RAMON Objects
clear t
tic
oo.setBatchSize(100);
ids = oo.createAnnotation(seg_cell);
fprintf('Batch Metadata Upload: ');
t(1) = toc

% relabel Paint
fprintf('Relabling: ');

tic
labelOut = zeros(size(zz));

rp = regionprops(zz,'PixelIdxList');
for ii = 1:length(rp)
    labelOut(rp(ii).PixelIdxList) = ids(ii);
end

clear zz
t(2) = toc

% Block write paint
tic
paint = RAMONVolume();
paint.setCutout(labelOut);
paint.setDataType(eRAMONChannelDataType.uint32);
paint.setChannelType(eRAMONChannelType.annotation);
paint.setChannel('anno');
paint.setResolution(1);
paint.setXyzOffset([4400,5440,1100]);
oo.createAnnotation(paint);
fprintf('Block Write Upload: ');
t(3) = toc

t(4) = sum(t)







tic
paint = RAMONVolume();
paint.setCutout(labelOut(:,:,1:96));
paint.setDataType(eRAMONChannelDataType.uint32);
paint.setChannelType(eRAMONChannelType.annotation);
paint.setChannel('anno');
paint.setResolution(1);
paint.setXyzOffset([128*20,128*25,16*10]);
oo.createAnnotation(paint);
fprintf('Block Write Upload: ');
t(5) = toc
t(6) = t(1)+t(5);
