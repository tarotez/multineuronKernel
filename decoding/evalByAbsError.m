% coded by Taro Tezuka since 14.10.19

function [meanAbsError] = evalByAbsError(estimated, correct)

meanAbsError = mean(abs(estimated - correct));

end

