function [sp] = copy2subsamplingParams(op, allParamVecH, allParamVecV, timeLength)

sp.offDiagElemH = allParamVecH(1);
sp.offDiagElemV = allParamVecV(1);
sp.kernelParamsH = allParamVecH(2:end-1);
sp.kernelParamsV = allParamVecV(2:end-1);
sp.regCoeffH = allParamVecH(end);
sp.regCoeffV = allParamVecV(end);
%----
sp.evalTargets = op.evalTargets;
sp.ks = op.ks;
sp.condNum = op.condNum;
sp.rankNum = op.rankNum;
sp.period = op.period;
sp.visualize = op.visualize;
sp.timeLength = timeLength;

end

