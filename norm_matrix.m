function [ result ] = norm_matrix( matrix )
%NORM_MATRIX Summary of this function goes here
%   convert matrix range to [0,1]


result = zeros(size(matrix,1),size(matrix,2));

minval = min(min(matrix));
maxval = max(max(matrix));

%convert range to start at 0
result = bsxfun(@plus,matrix,-minval);
maxval = maxval -minval;
minval = 0;


%convert range to end at 1
result2 = bsxfun(@rdivide,result,maxval);

result = result2;
minval = min(min(result));
maxval = max(max(result));


end
