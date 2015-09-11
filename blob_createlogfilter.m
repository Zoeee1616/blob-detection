function [ result ] = blob_createlogfilter( width, sigma )
%CREATE_LOG_FILTER
%   calculates the laplacian of guassian filter of the given size 
%   using the sigma values provided
%
% Reference: http://fourier.eng.hmc.edu/e161/lectures/gradient/node9.html

if nargin < 1
	width = 3;
end
if nargin < 2
	sigma = 0.5;
end


%% use built-in guassian function
gaussian = fspecial('gaussian',width,sigma);

%% calculate second order x partial derivative
gaussian_x1 = blob_calcmatrixpderivative(gaussian,'x');
gaussian_x2 = blob_calcmatrixpderivative(gaussian_x1,'x');
%% calculate second order y partial derivative
gaussian_y1 = blob_calcmatrixpderivative(gaussian,'y');
gaussian_y2 = blob_calcmatrixpderivative(gaussian_y1,'y');

%% create laplacian of guassian kernel
result = gaussian_x2 + gaussian_y2;

%% normalize filter by multiplying by sigma^2
result2 = bsxfun(@times,result,(sigma * sigma));
result = result2;

end
