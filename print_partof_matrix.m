% Purpose: print part of a matrix for debugging purposes
% Author: Evan Bowling

function print_partof_matrix( matrix, num_rows, num_cols )
%PRINT_PART Summary of this function goes here
%   Detailed explanation goes here

% throw exception
%if( size(matrix,1) < num_rows
%size(matrix,2) < num_cols


for rIndex = 1:num_rows
    colString = ' ';
    for cIndex = 1:num_cols
        val = sprintf('%d ', matrix(rIndex,cIndex));
        colString = [colString val];
    end
    disp(colString);
end
end
