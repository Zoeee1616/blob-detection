function [ result ] = blob_calcmatrixpderivative( matrix, direction )
%CALC_MATRIX_PDERIVATIVE
%   calculates the partial derivative of the matrix in the 
%   provided direction ('x' or 'y')

if nargin < 2
    direction = 'x'; % use x direction by default
end

x_partial = [ 0 0 0; -1 0 1; 0 0 0];
y_partial = [ 0 -1 0; 0 0 0; 0 1 0]; % defined with assumption that upper-left corner of image is [0,0];

if(strcmp(direction,'x') == 1)
	result = conv2(matrix,x_partial, 'same');
elseif(strcmp(direction,'y') == 1)
	result = conv2(matrix,y_partial, 'same');
end

end
