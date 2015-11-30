function [neuGraph, nId, synGraph, synId] = graph_matrix(edgeList, varargin)

% Input:  Nx4/5 matrix, with Node 1, Node2, Synapse, Direction, SynapseMap]
% Output:  same, with

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) [2014] The Johns Hopkins University / Applied Physics Laboratory All Rights Reserved. Contact the JHU/APL Office of Technology Transfer for any additional rights.  www.jhuapl.edu/ott
% 
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
% 
%    http://www.apache.org/licenses/LICENSE-2.0
% 
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(varargin)
    edgeList2 = varargin{1};
else
    edgeList2 = [];
end

if size(edgeList,2) == 5 && sum(edgeList(:,5)) ~= 0
    eField = 5;
else
    eField = 3;
end

eField

if ~isempty(edgeList2)
    
    if size(edgeList2,2) == 5 && sum(edgeList2(:,5)) ~= 0 %TODO 
        eField2 = 5;
    else
        eField2 = 3;
    end
    synId2 = edgeList2(:,eField2);
    
    synId = unique([double(edgeList(:,eField)); double(synId2)]);
    
else
    synId = unique(edgeList(:,eField));
end

%Edge list 2 is used for correspondence
%Use true synapses if available.

%eField2 

synId(synId == 0) = []; %TODO

synGraph = zeros(length(synId));

neuConn = edgeList(:,1:2);
nId = unique(neuConn);
for i = 1:length(nId)
    
    [dataR, ~] = find(neuConn == nId(i));
    
    sIdMatch = unique(edgeList(dataR,eField));
    
    combo = combnk(sIdMatch,2);
    combo = sort(combo,2);
    for j = 1:size(combo,1)
        s1 = find(synId == combo(j,1));
        s2 = find(synId == combo(j,2));
        synGraph(s1,s2) = synGraph(s1,s2)+1;
    end
end

%figure, imagesc(synGraph), colormap(bone)


%All neurons not represented have degree 0
% syn-neuron: Any neuron
neuGraph = zeros(length(nId));
for i = 1:size(neuConn,1)
    n1 = neuConn(i,1);
    n2 = neuConn(i,2);
    
    n1 = find(n1 == nId);
    n2 = find(n2 == nId);
    neuGraph(min(n1,n2),max(n1,n2)) = neuGraph(min(n1,n2),max(n1,n2)) + 1;
end


