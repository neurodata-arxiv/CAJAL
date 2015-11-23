% Upload Image Data Example Script
% Tokens can be obtained from OCP personnel or created using the web
% interface

% W. Gray Roncal

%% Get Data to push

oo = OCP();
oo.setServerLocation('http://openconnecto.me');
oo.setImageToken('kasthuri11cc');
oo.setImageChannel('image');
q = OCPQuery;
q.setType(eOCPQueryType.imageDense);
q.setCutoutArgs([4400,5424],[5440,6464],[1100,1200],1);
imData = oo.query(q);

mkdir('temp')
for i = 1:size(imData.data,3)
    istr = zeropad_number(i,4);
    slice = imData.data(:,:,i);
    
    imwrite(slice,sprintf('temp/sampledata_slice_%s.tif',istr))
end

%% Upload Image Data

% setup ocp server, token, channels
server = 'openconnecto.me';
imToken = 'testupload';
imChannel = 'test1';
resolution = 1;

% number of slices to write
zChunk = 16;

% specify offset of first slice
blockOffset = [4400, 5440, 1100];

% load data into a directory and add directory into a path
addpath('temp')
f = dir('temp/*.tif');

oo = OCP();
oo.setServerLocation(server);
oo.setImageToken(imToken);
oo.setImageChannel(imChannel);
oo.setDefaultResolution(resolution);

dataOffset = oo.imageInfo.DATASET.OFFSET(resolution);
zOffset = dataOffset(3);

% align block - may be less than zChunk!
nFilesStart = zChunk-mod(blockOffset(3)-zOffset+1, zChunk);


nChunk = ceil(length(f)/zChunk);
c = 1; %file index pointer - don't change

tic
for jj = 1:nChunk
    clear imVol
    
    % upload initial partial block
    if jj == 1
        zstart = blockOffset(3);
        zstop = blockOffset(3) + nFilesStart;
        
    % upload final partial block
    elseif jj == nChunk
        zstart = zstop+1;
        zstop = blockOffset(3)+length(f);
        
    % upload all other blocks
    else
        zstart = zstop + 1;
        zstop = zstart + zChunk;
    end
    
    nSlice = zstop - zstart;
    
    for kk = 1:nSlice
        imVol(:,:,kk) = imread(f(c).name); % this loop is inefficient but fast
        c = c + 1;
    end
    
    X = RAMONVolume; X.setCutout(imVol);
    X.setResolution(resolution);
    X.setXyzOffset([blockOffset(1), blockOffset(2), zstart]);
    X.setChannel(imChannel);
    X.setDataType(eRAMONChannelDataType.uint8); %DATA TYPE HARDCODED TODO
    X.setChannelType(eRAMONChannelType.image);
    
    % Put data chunks
    oo.uploadImageData(X)
    
end

t = toc
