% by Taro Tezuka since 15.1.13
% runs spikernel using spiketrainlib

function [] = spikernel()

disp('$Id: testKernelFactory.m 92 2011-09-07 22:36:23Z memming $');

sts = cell(5, 1);
sts{1} = [];
sts{2} = [0];
sts{3} = [1];
sts{4} = [0 1];
sts{5} = [0 1 2];

T = 3;
tol = 10 * eps;

assertRange = @(x,y,msg) assert(abs(x-y) < tol, msg);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ks = kernelFactory('spikernel', T, 'Gaussian');
if ~isempty(ks) % spikernel is installed
    ksizeList = ks.autoParam(ks, sts)
    for cidx = 1:size(ksizeList,1)
	K = computeKernelMatrix(ks, sts, ksizeList{cidx})
    end
    assertRange(norm(K - K'), 1e-30, 'not symmetric!');
    EV = eig(K);
    assert(min(EV) >= 0, sprintf('not positive definite!! %f', min(EV)));
else
    fprintf('Spikernel is not installed. See spikernel.txt for details\n');
end


end

