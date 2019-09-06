% Coded by Taro Tezuka since 14.9.18
% evaluate alpha obtained from kernel regression by repeatedly testing on 
% 
function [meanSquaredError] = evalAlpha( kernelVec, alpha, test_y )

test_y_num = size(test_y,1);
squaredError = zeros(test_y_num, 1);

for test_y_ID = 1:test_y_num
    
    newY = predictByAlpha(kernelVec, alpha);
    
    % disp(['size(newY) = ' num2str(size(newY))]);
    % disp(['size(test_y) = ' num2str(size(test_y(test_y_ID)))]);
    
    squaredError(test_y_ID) = (newY - test_y(test_y_ID))^2;

end

meanSquaredError = mean(squaredError);


end

