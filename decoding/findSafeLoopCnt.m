% coded since 16.6.4
% find loopCnt that is rightbefore logLikelihood starts oscilliating
% 
function [safeLoopCnt] = findSafeLoopCnt(logLike)

coeff = 5;
startTimePoint = 20;
safeLoopCnt = 0;

for i = startTimePoint:(length(logLike)-1)
    avgPastIncrease = mean(logLike((i-5):i) - logLike((i-6):(i-1)));
    newIncrease = logLike(i+1) - logLike(i);
    if newIncrease < (- coeff) * avgPastIncrease
        safeLoopCnt = i;
        break
    end
end

end

