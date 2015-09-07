% There are several major ways to upload annotation data to OCP, including:
% uploading labeled volumes, adding RAMON metadata to existing labels, and
% uploading individual RAMON objects containing paint data. 
%Performance-wise, the first two options performed in succession are faster. 
% Here we demonstrate how to perform uploads in these ways.
%
% TODO:  Because of a CAJAL bug, using uploadLabels followed by uploadRAMON
% will result in a duplicate primary key error.  Please use
% cubeUploadDense, which does both of these operations in one file as an
% alternative.

% Ensure that idFile has been removed prior to running
%!rm demo_ids.mat
%% cubeUpload Dense
% Use when uploading RAMON objects in batch

%define your server, project, and channel
server = 'openconnecto.me';
channel = 'anno1';
token = 'test_cajal';

%define some region you wish to annotate
d = round(checkerboard(5)*10);
d = d + 1;

xstart = 6000;
ystart = 5000;
zstart = 400;

cube = RAMONVolume;
cube.setResolution(1);
cube.setCutout(d);
cube.setChannel(channel);
cube.setChannelType(eRAMONChannelType.annotation);
cube.setDataType(eRAMONChannelDataType.uint32);
cube.setXyzOffset([xstart, ystart, zstart]);
protoRAMON = 'RAMONSynapse()';
useSemaphore = 0;


cubeUploadDense(server, token, channel, cube, protoRAMON, useSemaphore)

%% Upload Labels
% Use this when uploading only labels, or probability maps

%create a RAMONVolume
obj = RAMONVolume;
obj.setChannelType(eRAMONChannelType.annotation); %define channel type
obj.setDataType(eRAMONChannelDataType.uint32); %define data type
obj.setChannel(channel); %pick a channel
obj.setResolution(1); %pick a resolution
obj.setCutout(d); %set the annotation data
obj.setXyzOffset([xstart ystart zstart]); %set the offset (i.e. where the data is placed)

%call the upload script.
semaphore = false;
probability = false;
idFile = 'demo_ids.mat';
uploadLabels(server, token, channel, obj, idFile, probability, semaphore);

%% Upload Annotation Metadata
% This mode is not recommended due to the documented bug, which may result
% in duplicate primary keys, limiting upload functionality.

% %get server id of object you wish to annotate
% id = load(idFile); id = id.ids;
% 
% %create, say, a RAMONSynapse
% synapse = RAMONSynapse();
% 
% % Set the objects properties as desired.
% synapse.setXyzOffset([xstart ystart zstart]);
% synapse.setResolution(1);
% 
% synapse.setSynapseType(eRAMONSynapseType.excitatory);
% synapse.setSeeds([2 4 6 3]);
% synapse.setConfidence(.8);
% 
% uploadRAMON(server, token, channel, synapse, semaphore, idFile);
% 

%% Upload Complete RAMONObjects
% Use if uploading single RAMON objects in series - may be slow!
%get server id of object you wish to annotate
id = load(idFile); id = id.ids;

%create, say, a RAMONSynapse

for i=1:3
    temp_apse = RAMONSynapse();
    temp_apse.setChannelType(eRAMONChannelType.annotation); %define channel type
    temp_apse.setDataType(eRAMONChannelDataType.uint32); %define data type
    temp_apse.setChannel(channel); %pick a channel
    temp_apse.setResolution(1); %pick a resolution
    temp_apse.setCutout(d); %set the annotation data
    temp_apse.setXyzOffset([xstart ystart zstart]); %set the offset (i.e. where the data is placed)
    % Set the objects properties as desired.
    temp_apse.setResolution(1);
    temp_apse.setSynapseType(eRAMONSynapseType.excitatory);
    temp_apse.setSeeds([2 4 6 3]);
    temp_apse.setConfidence(.8);
    
    synapses{i} = temp_apse;
    xstart  = xstart + 200;
    ystart  = ystart + 100;
    zstart  = zstart + 100;
    
end

uploadRAMON(server, token, channel, synapses, semaphore, []);

disp('Successful uploads!')