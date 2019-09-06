% Coded by Taro Tezuka since 2014.9.18
% reduce the data size by random sampling
%
function [xs, y] = reduceSampleNum(orig_xs, orig_y, reducedNum)

origSampleNum = size(orig_xs,1);

if reducedNum < origSampleNum

    % samplingIdx = round(linspace(1, origSampleNum, reducedNum));
    
    % disp(['size(samplingIdx) = ' num2str(size(samplingIdx))]);
    
    samplingIdxLong = randperm(origSampleNum);
    
    samplingIdx = samplingIdxLong(1:reducedNum);
    
    xs = orig_xs(samplingIdx,1);
    y = orig_y(samplingIdx);
    
else    
    disp(['origSampleNum = ' num2str(origSampleNum) ' and reduceSampleNum = ' num2str(reducedNum) '. Can not be reduced further.']);    
    
    xs = orig_xs;
    y = orig_y;
    
end

end

