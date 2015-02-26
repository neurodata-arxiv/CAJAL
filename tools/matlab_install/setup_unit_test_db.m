%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2015 The Johns Hopkins University / Applied Physics Laboratory 
% All Rights Reserved. 
% Contact the JHU/APL Office of Technology Transfer for any additional rights.  
% www.jhuapl.edu/ott
%  
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%  
%     http://www.apache.org/licenses/LICENSE-2.0
%  
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    ****** Check with OCP team before running this script *******
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% TEST DB SETUP SCRIPT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IMPORTANT!!!! This only needs to run on a **NEW** server that has not been initalized
% before.  In almost ALL cases this does not need to be done by the average
% user.  
%
% ****** Check with OCP team before running this script *******
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% REQUIRED DATABASE TOKENS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% kasthuri11 - kasthuri11 image database
% apiUnitTestKasthuri - anno32 database, exceptions enabled, base res 1
% apiUnitTestKasthuriProb - prob32 database, base rest 1
% apiUnitTestImageUpload - image8 database, no excepctions, base res 1
% apiUnitTestPropagate - anno32 database, base res 1, should be a SMALL DB (500x500x20)
% Ex10R55 - Multichannel example image dataset
% mitra14N777 - RGBA example image dataset
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setup OCP
oo = OCP();
oo.setServerLocation('braingraph1.cs.jhu.edu');
oo.setImageToken('kasthuri11');

%% Check all Required tokens are created
oo.setAnnoToken('apiUnitTestKasthuri');
oo.makeAnnoWritable();
oo.setAnnoToken('apiUnitTestKasthuriProb');
oo.makeAnnoWritable();
oo.setImageToken('apiUnitTestImageUpload');
oo.setAnnoToken('apiUnitTestPropagate'); % This should be a SMALL DB (500x500x5)
oo.makeAnnoWritable();

%% API Unit Test DB
oo.setImageToken('kasthuri11');
oo.setAnnoToken('apiUnitTestKasthuri');

% Set default resolutino
oo.setDefaultResolution(1);

% load ids for predicate query so you can test limit.
d = zeros(100,80,30);
d(40:60,40:60,1:2) = 1;
d(50:55,60:70,2:3) = 1;
for ii = 1:25
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[1000 1000 100],1,eRAMONSynapseType.excitatory, 100,...
        [1,2;4,0],[2,34],[],.64, eRAMONAnnoStatus.unprocessed,{'tester',1212},'testuser');
    oo.createAnnotation(s1);
end

% setup anno cutout
d = zeros(100,80,30);
d(40:60,40:60,1:2) = 1;
d(50:55,60:70,2:3) = 1;
d(40:70,50:65,2:5) = 1;

s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[2200 2200 200],1,eRAMONSynapseType.excitatory, 100,...
    [1,2;4,0],34,[],.64, eRAMONAnnoStatus.processed,{'tester',1212;'test2',[];'test','sets'},'testuser');
oo.createAnnotation(s1);




%% Id Distributor Unit Test DB
oo.setAnnoToken('idDistributorUnitTestKasthuri');

% Set default resolutino
oo.setDefaultResolution(1);

% load ids for predicate query so you can test limit.
d = zeros(100,80,30);
d(40:60,40:60,1:2) = 1;
d(50:55,60:70,2:3) = 1;
for ii = 1:25
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[1000 1000 100],1,eRAMONSynapseType.excitatory, 100,...
        [1,2;4,0],[2,34],[],.64, eRAMONAnnoStatus.unprocessed,{'tester',1212},'testuser');
    oo.createAnnotation(s1);
end

% different status
for ii = 1:5
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[1000 1000 100],1,eRAMONSynapseType.excitatory, 100,...
        [1,2;4,0],[2,34],[],.64, eRAMONAnnoStatus.processed,{'tester',1212},'testuser');
    oo.createAnnotation(s1);
end

% high conf
for ii = 1:5
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[1000 1000 100],1,eRAMONSynapseType.excitatory, 100,...
        [1,2;4,0],[2,34],[],.9, eRAMONAnnoStatus.unprocessed,{'tester',1212},'testuser');
    oo.createAnnotation(s1);
end

% low conf
for ii = 1:5
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[1000 1000 100],1,eRAMONSynapseType.excitatory, 100,...
        [1,2;4,0],[2,34],[],.25, eRAMONAnnoStatus.unprocessed,{'tester',1212},'testuser');
    oo.createAnnotation(s1);
end

d = zeros(100,80,1);
d(50:60,20:60,1) = 1;
d(50:55,60:70,1) = 1;
    
% different type
for ii = 1:5
    s1 = RAMONSegment(d,eRAMONDataFormat.dense, [3000 3000 20+ii], 1, eRAMONSegmentClass.unknown,54,...
        [2 45 67], [234 67], 64, [], .256, eRAMONAnnoStatus.unprocessed,...
        {'tester',1212},'testuser');
    id = oo.createAnnotation(s1);
end


%% Setup image upload test database

oo.setImageToken('apiUnitTestImageUpload');

d = ones([250,250,5]);
v = RAMONVolume();
v.setCutout(d);
v.setXyzOffset([3000,4000,500]);
v.setResolution(1);

oo.uploadImageData(v);

