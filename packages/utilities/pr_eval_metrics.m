function pr_eval_metrics(detectFile, truthFile ,metricsFile)
% W. Gray Roncal - 02.12.2015
% Feedback welcome and encouraged.  Let's make this better!
% Other options (size filters, morphological priors, etc. can be added.
%

% Load Objects
load(detectFile)
detectVol = cube.data > 0;

load(truthFile)
truthVol = cube.data;

tic

%% params
count = 1;
overlap = 1; % pixels required to overlap to count

% Currently assumes sparsity - that distinct objects don't touch
truthObj = bwconncomp(truthVol,18);
detectcc = bwconncomp(detectVol,18);
detectMtx = labelmatrix(detectcc);


% POST PROCESSING
stats2 = regionprops(detectcc,'PixelList','Area','Centroid','PixelIdxList');

fprintf('Number Synapses detected: %d\n',length(stats2));

% 3D metrics

TP = 0; FP = 0; FN = 0; TP2 = 0;

for j = 1:truthObj.NumObjects
    temp = detectMtx(truthObj.PixelIdxList{j});
    
    if sum(temp > 0) >= overlap
        TP = TP + 1;
        
        % TODO something fancier
        % any detected objects can only be used
        % once, so remove them here.
        % This does not penalize (or reward) fragmented
        % detections
        
        detectIdxUsed = unique(temp);
        detectIdxUsed(detectIdxUsed == 0) = [];
        
        for jjj = 1:length(detectIdxUsed)
            detectMtx(detectcc.PixelIdxList{detectIdxUsed(jjj)}) = 0;
        end
    else
        FN = FN + 1;
    end
end

for j = 1:detectcc.NumObjects
    temp =  truthVol(detectcc.PixelIdxList{j});
    %sum(temp>0)
    if sum(temp > 0) >= overlap
        %TP = TP + 1;  %don't do this again, because already
        % considered above
        TP2 = TP2 + 1;
    else
        FP = FP + 1;
    end
end

metrics.precision(count) = TP./(TP+FP);
metrics.recall(count) = TP./(TP+FN);
metrics.TP = TP;
metrics.FP = FP;
metrics.FN = FN;

metrics
save(metricsFile,'metrics')

