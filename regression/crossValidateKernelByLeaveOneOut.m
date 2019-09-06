% Coded by Taro Tezuka since 16.1.2
% cross validation for kernel regression
% use leave one out analysis
% 
function [likelihood] = crossValidateKernelByLeaveOneOut(totalKernelMat, depVar, regLambda, period)

sampleNum = size(totalKernelMat,1);

if period == 0
    %%% without regularization
    %%% totalAlpha = totalKernelMat \ depVar;
    totalAlpha = (totalKernelMat + (eye(sampleNum) * regLambda)) \ depVar;
    %%% implement below later.
    %{
    for paramID = 1:paramNum
        Z(paramID) = totalKernelMat \ dKdtheta(paramID);
    end
    %}
else
    [depVar_h, depVar_v] = angle2cartesian(depVar, period);
    %%% without regularization
    %%% totalAlpha_h = totalKernelMat \ depVar_h;
    %%% totalAlpha_v = totalKernelMat \ depVar_v;    
    totalAlpha_h = (totalKernelMat + (eye(sampleNum) * regLambda)) \ depVar_h;
    totalAlpha_v = (totalKernelMat + (eye(sampleNum) * regLambda)) \ depVar_v;
end
totalInverseMat = inv(totalKernelMat);
mu = zeros(sampleNum,1);
sigmaSq = zeros(sampleNum,1);
logpyi = zeros(sampleNum,1);

for sampleID = 1:sampleNum

    %%% disp(' ');
    %%% disp(['now on foldID = ' num2str(foldID) ' / ' num2str(foldNum)]);
    
    if period == 0
        test_depVar = depVar(sampleID);    
        mu(sampleID) = test_depVar - (totalAlpha(sampleID) / totalInverseMat(sampleID,sampleID));            
    else
        test_depVar_h = depVar_h(sampleID);
        test_depVar_v = depVar_v(sampleID);
        mu_h = test_depVar_h - (totalAlpha_h(sampleID) / totalInverseMat(sampleID,sampleID));    
        mu_v = test_depVar_v - (totalAlpha_v(sampleID) / totalInverseMat(sampleID,sampleID));
        mu(sampleID) = cartesian2angle(mu_h, mu_v, period);
    end
    sigmaSq(sampleID) = 1 / totalInverseMat(sampleID,sampleID);
    
    logpyi(sampleID) = - (log(sigmaSq(sampleID))/2) - ((depVar(sampleID) - mu(sampleID))^2)/(2 + sigmaSq(sampleID)) - (log(2 + pi) / 2);
            
end

likelihood = sum(logpyi);

disp(['Likelihood_{LOO} = ' num2str(likelihood)]);

end

