% Upload Image Data Example Script
% Tokens can be obtained from OCP personnel or created using the web
% interface

% W. Gray Roncal

imToken = XXX; %Your token goes here
server = XXX;  %Your server goes here

oo = OCP();
oo.setServerLocation(server);
oo.setImageToken(imToken);

imChunk = 16; %Controls how many slices to upload at a time - keep this fairly small
              %Ideally multiples of 16 (careful if your xy extent is large
zOffset = 0;  %Starting slice offset (set to 0, normally)

q = OCPQuery;

%Data Directory
f = dir('*.tif'); %Assumes tif files in your local directory

nChunk = ceil(length(f)/imChunk);

for jj = 1:nChunk
    clear im %do this
    jj
    s1 = imChunk * (jj-1) + 1;
    s2 = min(imChunk * (jj), length(f));
    
    c = 1;
    for ii = s1:s2
        
        im(:,:,c) = im2uint8(imread(f(ii).name));  %You may not need this conversion
        c = c + 1;
    end
     
    X = RAMONVolume; X.setCutout(im);
    X.setResolution(0);
    X.setXyzOffset([0,0,zOffset+s1-1]);
    
    % Put chunks
    oo.uploadImageData(X) 

end
