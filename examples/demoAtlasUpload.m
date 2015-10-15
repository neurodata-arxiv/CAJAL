%% Atlas upload script

% This script provides an example for how to upload atlases to OCP (large
% spatial label extent, without relabeling Ids)
%
% Prior to running, please make a new channel.  This code can only be run
% once as is for a given channel, because you are managing the IDs
% manually, versus letting the server do primary key management
%
% W. Gray Roncal 
% October 2015
% v1.0



%% ~2GB synthetic atlas - this code block is for simulation purposes only
% parameter choices are largely arbitrary
atlas = reshape(randperm(156),[12,13]);
atlas = imresize(atlas,300,'nearest');
atlas = uint32(repmat(atlas,[1,1,40]));
atlas = atlas*10; %doing this to validate that ids are being assigned non-sequentially
cube = RAMONVolume;
cube.setResolution(2);
cube.setCutout(atlas);
save('atlastest1','cube','-v7.3')

%% Setup 

tic

% Parameters
server = 'openconnecto.me';
token = 'test_atlas1';
channel = 't2';
inputData = 'atlastest1';
protoRAMON = 'RAMONSegment';
useSemaphore = 0;
cubeOffset = [1000,1200,3200]; % assume this is known

load('atlastest1') % optional, in case not in workspace

% Setup OCP interface
oo = OCP;
oo.setServerLocation(server);
oo.setAnnoToken(token);
oo.setAnnoChannel(channel);

cube.setXyzOffset(cubeOffset);

uid = unique(cube.data);
uid(uid == 0) = [];

%% Uploading RAMON Objects
sprintf('Now uploading RAMON Objects...\n');

% loop through each unique ID.  Don't relabel because it's an atlas
for i = 1:length(uid)
   s = RAMONSegment();
   s.setId(uid(i));
   s.setResolution(2);
   oo.createAnnotation(s);
end
%% Upload Annodata  

% In testing, uploading 2GB atlases worked great; these compress quite
% well.

tic
sprintf('Now uploading paint labels...\n');

cube.setDataType(eRAMONChannelDataType.uint32); %just in case
cube.setChannelType(eRAMONChannelType.annotation);
cube.setChannel(channel);
oo.createAnnotation(cube);

toc

% oo.propagateAnnoDB