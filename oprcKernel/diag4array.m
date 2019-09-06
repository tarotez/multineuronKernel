% coded 1601081515
% http://jp.mathworks.com/matlabcentral/newsreader/view_thread/309655
% INPUT:
%   A: 3rd order tensor (array)
% OUTPUT:
%  d: diagonal elements

function [d] = diag4array(A)

[m,n,p] = size(A);
idx = find(speye(m,n));

reshapedA = reshape(A,m*n,p);
d = reshapedA(idx,:);
d = reshape(d,min(m,n),p); 

end

