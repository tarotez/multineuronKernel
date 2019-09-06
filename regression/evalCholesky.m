

testNum = 5;
regCoeff = 0.01;
sampleNum = 2000;
attrNum = 2000;

for testID = 1:testNum

    X = rand(sampleNum,attrNum);
    kernelMat = X * X';
    y = rand(sampleNum,1);
    
    disp(' ')
    disp('cholesky:');
    tic    
    [alphaChol] = kernelRegression(kernelMat, y, regCoeff);
    toc
    disp(['alphaChol(1:10) = ' num2str(alphaChol(1:10)')])

    disp(' ')
    disp('no cholesky')
    tic
    [alphaNoChol] = kernelRegressionNoCholesky(kernelMat, y, regCoeff);    
    toc
    disp(['alphaNoChol(1:10) = ' num2str(alphaNoChol(1:10)')])
    
    sqDiff = sum((alphaChol - alphaNoChol).^2);
    disp(' ')
    disp(['square difference is ' num2str(sqDiff)])
    
end