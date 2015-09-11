function [r,c] = test_mstats( matrix )
%TEST_MSTATS Summary of this function goes here
%   generates stats of matrix

disp('------------');
disp('matrix stats');
rows = size(matrix,1);
cols = size(matrix,2);
disp(sprintf('%drow x %dcol matrix',rows,cols));
min_arr=min(min(matrix));
max_arr=max(max(matrix));
mean_arr=mean(mean(matrix));
std_arr=std(std(matrix));
disp(sprintf('min: %d  max:%d mean:%d std:%d ',min_arr,max_arr,mean_arr,std_arr));



% end function
end
