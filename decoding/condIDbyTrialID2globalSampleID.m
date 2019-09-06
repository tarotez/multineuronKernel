% Coded by Taro Tezuka since 2014.9.17
% converts a cell array of paramID -> sampleID to one with global sampleID.
%
function [samples, condIDvec] = condIDbyTrialID2globalSampleID(origData)

condNum = size(origData);

sampleCnt = 0;
for condID = 1:condNum
    trials = origData{condID};    
    trialNum = length(trials);
    for trialID = 1:trialNum      
        sampleCnt = sampleCnt + 1; 
    end    
end
% disp(['sample count = ' num2str(sampleCnt)])

samples = cell(sampleCnt,1);
condIDvec = zeros(sampleCnt,1);
sampleID = 1;
for condID = 1:condNum
    trials = origData{condID};
    trialNum = length(trials);
    for trialID = 1:trialNum      
        samples{sampleID} = trials{trialID};
        condIDvec(sampleID) = condID;
        sampleID = sampleID + 1;        
    end    
end

end

