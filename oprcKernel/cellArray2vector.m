% Coded by Taro Tezuka since 14.9.19
% 
function vector = cellArray2vector( cellArray )

sampleNum = size(cellArray,1);
vector = zeros(sampleNum,1);

for sampleID = 1:sampleNum
   vector(sampleID) = cellArray{sampleID};
end

end

