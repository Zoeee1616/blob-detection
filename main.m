%% Spring 2014 CS 543
%% Project
%%
%% Evan Bowling
%% Yi Zou

% path to the folder and subfolder
root_path = 'images/';
save_path = 'output/';
image_names=cell(2,1);
%image_names{1}='05AUG23185648-M3XS-000000232762_01_P001';
%image_names{1}='pan_split0';
image_names{1}='pan_small1'
save_flag=1; % 1 - save, 0 - don't save
inverted=0;

num_images=size(image_names,2);

%% process images
for i=1:num_images
    image_path = sprintf('%s%s.tif', root_path, image_names{i});
    fprintf('Processing: %s\n',image_path);
    
    %% process image in color
    %raw_colorimage = imread(image_path);
    %raw_colorimage(:,:,4)=[];
    %colorimage = im2double(raw_colorimage);
    %%rescale from [x,max] => [0,1]
    %min_i=min(min(min(colorimage)));
    %max_i=max(max(max(colorimage)));
    %colorimage = colorimage / max_i;
    %imshow(colorimage);
    
    % process image in grayscale
    raw_image = imread(image_path);
    %raw_image(:,:,1)=raw_image(:,:,4);
    %raw_image2 = rgb2gray(raw_image);
    image = im2double(raw_image2);
    %rescale from [x,max] => [0,1]
    min_i=min(min(image));
    max_i=max(max(image));
    diff_i=max_i-min_i;
    image = (image - min_i) / diff_i;
    
    imshow(image);
    if inverted
        invert_image = imcomplement(image);
        %imshow(inverted);
        image = invert_image;
    end

    if save_flag
        imwrite(image,sprintf('%s%s-grayscale.png',save_path,image_names{i}),'png','Mode','lossless','BitDepth',16);
    end
    
    % run blob_detector
    blob_method='1';
    num_scales=5;
    starting_sigma=2;
    k=1.3;
    threshold=0.1;
    blob_save_flag=0;
    test_flag=0;
    [circle_r,circle_c,circle_rad] = blob_detectfeatures(image, image_names{i},save_path,blob_method,num_scales,starting_sigma,k,threshold,blob_save_flag,test_flag);
    [binary_image] = blob_binarization(image,circle_r,circle_c,circle_rad);
    imshow(binary_image);
    show_all_circles(image,circle_c,circle_r,circle_rad);
    if save_flag
        imwrite(binary_image,sprintf('%s%s-binary.png',save_path,image_names{i}),'png','Mode','lossless','BitDepth',16);
        print('-dpng',sprintf('%s%s-circles.png',save_path,image_names{i}));
    end    
    
    
    %extract subset
    %image = image(1:200,1:200);
    %subplot(3,2,1);
    %imshow(image);
    %binary_image = binary_image(1:200,1:200);
    %subplot(3,2,2);
    %imshow(binary_image);
    
    
    %generate sure forground
    tic;
    se = strel('disk',3);
    sure_foreground = imerode(binary_image,se);
    if save_flag
        imwrite(sure_foreground,sprintf('%s%s-foreground.png',save_path,image_names{i}),'png','Mode','lossless','BitDepth',16);
    end    
    
    
    toc;
    
    
    
    
    %generate sure background
    sure_background = imdilate(binary_image,se);
    if save_flag
        imwrite(sure_background,sprintf('%s%s-background.png',save_path,image_names{i}),'png','Mode','lossless','BitDepth',16);
    end    
    
    toc;
    
    %watershed algorithm
    D = bwdist(sure_foreground);
    imshow(D);
    if save_flag
        imwrite(D,sprintf('%s%s-bwdist.png',save_path,image_names{i}),'png','Mode','lossless','BitDepth',16);
    end    
    
    DL = watershed(D);
    if save_flag
        imwrite(DL,sprintf('%s%s-watershed.png',save_path,image_names{i}),'png','Mode','lossless','BitDepth',16);
    end    
    
end




