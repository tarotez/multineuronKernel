% Coded by Taro Tezuka since 14.9.19
% 
function [xs, xsVec] = generateRandomCellArray( sampleNum )

xs = cell(sampleNum, 1);
xsVec = randn(sampleNum,1);

for sampleID = 1:sampleNum
   xs{sampleID} = xsVec(sampleID);
end

end

