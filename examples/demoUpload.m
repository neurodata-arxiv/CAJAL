% There are several major ways to upload annotation data to OCP, including:
% uploading just labels, adding just RAMON information to labels, and
% uploading RAMON information and labels simultaneously. Performance-wise,
% the first two options performed in succession are faster. Here we
% demonstrate how to perform uploads in these ways.
%

%define your server, project, and channel
server = 'openconnecto.me';
channel = 'testanno';
token = 'gk1';

%define some region you wish to annotate
d = zeros(200,200,5);
d(30:170,30:170,:) = 1;

xstart = 3000;
ystart = 5000;
zstart = 400;

%% Upload Labels

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

%get server id of object you wish to annotate
id = load(idFile); id = id.ids;

%create, say, a RAMONSynapse
synapse = RAMONSynapse();

% Set the objects properties as desired.
synapse.setXyzOffset([xstart ystart zstart]);
synapse.setResolution(1);

synapse.setSynapseType(eRAMONSynapseType.excitatory);
synapse.setSeeds([2 4 6 3]);
synapse.setConfidence(.8);

uploadRAMON(server, token, channel, synapse, semaphore, id);


%% Upload Complete RAMONObjects

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

uploadRAMON(server, token, channel, synapses, semaphore);

