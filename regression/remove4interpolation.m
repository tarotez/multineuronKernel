% coded by Taro Tezuka since 14.10.24
% removes from training data samples regarding certain labels, in order to check interpolation capability of kernel regression
%
function trainIndices = remove4interpolation(train_yIDs, remove_yIDs)

trainIndices = (ismember(train_yIDs, remove_yIDs) == 0);

end

