% objectDetection Driver
% W. Gray Roncal

% In this standalone (non-LONI) paradigm, many defaults have to be defined.
%  We use a helper function, get_ac3_data

% Note that results here won't exactly equal the LONI version because of
% cropping effects. (TODO)

%% BLOCK COMPUTE AND CUBE CUTOUT STANDALONE REPLACEMENT

zSlice = [1220,1236]; 
padX = 50; padY = 50; padZ = 2;
%Get data
[eData, mData, sData, vData] = get_ac3_data(zSlice(1),zSlice(2));

% Save Data in an appropriate format

cube = eData.clone;
save('eData.mat','cube');

cube = mData.clone;
save('mData.mat','cube');

cube = sData.clone;
save('sData.mat','cube');

cube.setCutout(cube.data(1+padX:end-padX, 1+padY:end-padY, 1+padZ:end-padZ));
save('sDataPR.mat','cube');

cube = vData.clone;
save('vData.mat','cube');

%% PIXEL CLASSIFICATION

contextSynDetect_probs('edata', 'vData', 'mData', 'kasthuri11cc_csd_classifier_v3', padX, padY, padZ, 'classProbTest.mat')
%% OBJECT PROCESSING
contextSynDetect_object('classProbTest.mat', 0.90, 0, 5000, 2000, 0, 'testObjVol.mat')
%% UPLOAD

cubeUploadDense('braingraph1dev.cs.jhu.edu','temp2', 'testObjVol', 'RAMONSynapse',0);

%% PR COMPUTATION
pr_eval_metrics('testObjVol','sDataPR','metricsTest')
load metricsTest
metrics
