function contextSynDetect_object(prob, threshold, minSize2D, maxSize2D, minSize3D, doEdgeCrop, outFile)
%
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


%% Load Data
% Load data volume
if ischar('prob') %else, assume passing in a RAMONObject (testing)
load(prob) %should be saved as cube
prob = cube; 
end

%% Threshold probabilities
temp_prob = prob.data;

prob
whos temp_prob
% POST PROCESSING
% threshold prob
temp_prob(temp_prob >= threshold) = 1;
temp_prob(temp_prob < 1) = 0;

% Check 2D size limits first
cc = bwconncomp(temp_prob,4);

%Apply object size filter
for jj = 1:cc.NumObjects
    if length(cc.PixelIdxList{jj}) < minSize2D || length(cc.PixelIdxList{jj}) > maxSize2D
        temp_prob(cc.PixelIdxList{jj}) = 0;
    end
end

% get size of each region in 3D
cc = bwconncomp(temp_prob,6);

% check 3D size limits and edge hits
for ii = 1:cc.NumObjects
    %to be small
    if length(cc.PixelIdxList{ii}) < minSize3D
        temp_prob(cc.PixelIdxList{ii}) = 0;
    end
end

%Drop all that touch an edge
if doEdgeCrop
    % get inds of edges
    ind_block = zeros(size(prob));
    ind_block(:,:,1) = 1;
    ind_block(:,:,end) = 1;
    ind_block(1,:,:) = 1;
    ind_block(end,:,:) = 1;
    ind_block(:,1,:) = 1;
    ind_block(:,end,:) = 1;
    inds = find(ind_block == 1);
    
    for ii = 1:cc.NumObjects
        
        if any(ismember(cc.PixelIdxList{ii},inds))
            temp_prob(cc.PixelIdxList{ii}) = 0;
            %continue;
        end
    end
end

% re-run connected components
cc = bwconncomp(temp_prob,18);

fprintf('Number Synapses detected: %d\n',cc.NumObjects);

cube.setCutout(labelmatrix(cc));
outFile
save(outFile, 'cube')
