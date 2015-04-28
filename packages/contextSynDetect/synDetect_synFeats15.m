function xt = synDetect_synFeats15(em, idxToTest, vesicles)
%FINAL

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


[xs, ys, zs] = size(em);
emVal = reshape(em,[xs*ys*zs,1]);

% Now with Integral Images
nFeats = 10;
nVox = length(idxToTest);

if nVox == 0
    xt = [];
else
    xt = single(zeros(nVox,nFeats));
    
    % Kernels
    B0 = ones(5,5,1)/(5*5*1);
    B1 = ones(15,15,3)/(15*15*3);
    B2 = ones(25,25,5)/(25*25*5);
    
    %% Intensity Feats
    
    I0 = convn(em,B0,'same');
    I2 = convn(em,B1,'same');
    
    xt(:,1) = reshape(I0(idxToTest),[nVox,1]);
    xt(:,2) = reshape(I2(idxToTest),[nVox,1]);
    
    clear I0 I2 I3 emVal
    disp('part 1 complete')
    %% Texture Feats
    
    IMGRAD = zeros(size(em));
    LBP = zeros(size(em));
    for i = 1:size(em,3)
        LBP(:,:,i) = efficientLBP(em(:,:,i), [5,5]);
        IMGRAD(:,:,i) = imgradient(em(:,:,i));
    end
    xt(:,3) = reshape(LBP(idxToTest),[nVox,1]);
    
    
    IMGRAD2 = convn(IMGRAD,B1,'same');
    xt(:,4) = reshape(IMGRAD2(idxToTest),[nVox,1]);
    
    clear IMGRAD2 LBP
    
    IMGRAD3 = convn(IMGRAD,B2,'same');
    
    xt(:,5) = reshape(IMGRAD3(idxToTest),[nVox,1]);
    
    clear IMGRAD IMGRAD3
    
    disp('part 2 complete')
    
    temp = bwdist(vesicles.data);
    xt(:,6) = reshape(temp(idxToTest),[nVox,1]);
    
    temp = convn(vesicles.data,B2,'same');
    
    xt(:,7) = reshape(temp(idxToTest), [nVox,1]);
    
    disp('part 3 complete')
    
    IIM = cumsum(cumsum(double(vesicles.data)),2); %Integral Image
    
    % VC2 & VC3
    sR = [50,50]; %MUST ALL BE EVEN!!! %101, 101, 5
    sRC = sR/2;
    [R, C, Z] = size(IIM);
    
    imOut = zeros(R,C,Z);
    
    for k = 1:Z
        
        imOut(1:R-sRC(1),1:C-sRC(2),k) = imOut(1:R-sRC(1),1:C-sRC(2),k) + IIM(1+sRC(1):R,1+sRC(2):C,k);
        imOut(1+sRC(1):R,1+sRC(2):C,k) = imOut(1+sRC(1):R,1+sRC(2):C,k) + IIM(1:R-sRC(1),1:C-sRC(2),k);
        imOut(1:R-sRC(1),1+sRC(2):C,k) = imOut(1:R-sRC(1),1+sRC(2):C,k) - IIM(1+sRC(1):R,1:C-sRC(2),k);
        imOut(1+sRC(1):R,1:C-sRC(2),k) = imOut(1+sRC(1):R,1:C-sRC(2),k) - IIM(1:R-sRC(1),1+sRC(2):C,k);
    end
    imOut(1:sRC(1),:,:) = 0;
    imOut(:,1:sRC(2),:) = 0;
    imOut(R:-1:R-sRC(1)+1,:,:) = 0;
    imOut(:,C:-1:C-sRC(2)+1,:) = 0;
    
    xt(:,8) = reshape(imOut(idxToTest),[nVox,1]);
    
    disp('part 4 complete')
    clear imOut vesicles
    %%
    ST1 = zeros(size(em));
    for i = 1:size(em,3)
        [~, ~, ST1(:,:,i)] = structureTensorImage2(em(:,:,i),1, 1);
    end
    
    temp = convn(ST1, B1, 'same');
    xt(:,9) = reshape(temp(idxToTest),[nVox,1]);
    
    temp = convn(ST1, B2, 'same');
    xt(:,10) = reshape(temp(idxToTest),[nVox,1]);
    
    clear ST1 temp
    
    disp('part 5 complete')
    % if training, output yt
end