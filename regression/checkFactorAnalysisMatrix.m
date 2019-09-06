% coded on 160107
% checks if factor analysis matrix AA^T + D is positive semidefinite.

trialNum = 100;
sampleNum = 2;
rank = 2;

U = [1, 1; -1, 1] / sqrt(2);
S = diag([5, 2]);
D = [1, 0;  0, 1];

% for trialID = 1:trialNum

    % A = randn(sampleNum, rank);    
    % D = diag(rand(sampleNum,1));
    % K = A * A' + D;
    K = U * S * U' + D;

    [U,L] = eig(K);
    
    LV = diag(L);
    negIndices = zeros(sampleNum,1);   
    negIndices(LV < 0) = 1;
    
    numNegIndices = sum(negIndices);
    
    if numNegIndices > 0
        ids = 1:sampleNum;
        disp(['neg indices = ' num2str(ids(negIndices == 1))]);
        disp(['neg values = ' num2str(LV(negIndices == 1)')]);
    end
    
% end