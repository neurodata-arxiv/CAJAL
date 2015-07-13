function cubeUploadProbabilities(server, token, RAMONVol, useSemaphore, varargin)

% W. Gray Roncal

% Function to upload objects in a RAMON volume as a probability cube
% This only supports anno32 data for now and the preserve anno option
% This assumes all values are in [0,1].

if nargin > 5
    outFile = varargin{1};
end

if useSemaphore
    oo = OCP('semaphore');
else
    oo = OCP;
end

oo.setServerLocation(server);
oo.setAnnoToken(token);

% Load data volume
if ischar(RAMONVol)
    load(RAMONVol) %should be saved as cube
else
    cube = RAMONVol;
end

%% Upload to OCP
tic

% Reuse object
cube.setDataType(eRAMONDataType.prob32);
oo.createAnnotation(cube);
fprintf('Block Write Upload: ');
toc

if exist('outFile')
save(outFile,'cube')
end