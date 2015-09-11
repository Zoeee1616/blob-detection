function [circle_r,circle_c,circle_rad ] =blob_detectfeatures(image,image_name,output,method,num_scales,starting_sigma,k,threshold,save_flag,test_flag)
%% BLOB_DETECTFEATURES 
%    run the Laplacian of Guassian blob filter detector
%
%  image - image matrix
%  image_name - name of image
%  output - output directory
%  method - '1' or '2'
%  num_scales - int number of scales to detect features at
%  starting_sigma - [int] starting sigma values
%  k - [double]
%
circle_r=[];
circle_c=[];
circle_rad=[];

    %% method 1
    if(method=='1')
        %% generate gaussian filter
        gfilter = fspecial('gaussian',3,10);

        %% filter image
        filter_image = imfilter(image,gfilter,'replicate', 'conv','full');

        scale_space = zeros(size(filter_image,1),size(filter_image,2),num_scales);
        
        %% build scale space
        for scale_index=1:num_scales 
        
            if(scale_index==1)
            	sigma=starting_sigma;
            else
            	sigma=sigma*k;
            end

            %% create log filter
            mask_width=64;
            if(sigma>7)
                mask_width=256;
            end
            if(sigma>50)
                mask_width=1024;
            end
            
        	log_filter = blob_createlogfilter(mask_width,sigma);
        	norm_filter = norm_matrix(log_filter);
            if(test_flag==1)
                imshow(norm_filter);
                print('-dpng',sprintf('%sm1-filter-%d.png',output,sigma));
                %imwrite(norm_filter,sprintf('%sm1-filter-%d.gif',output,sigma),'gif');
            end

        	%% convolve image with filter
        	result = conv2(filter_image,log_filter,'same');
        	result_sqrd = bsxfun(@times,result, result);
        	norm_response = norm_matrix(result_sqrd);
            if(test_flag==1)
                imshow(norm_response);
                print('-dpng',sprintf('%sm1-%s-%d.png',output,image_name,sigma));
            end  
    
            %% store laplacian squared response
            scale_space(:,:,scale_index) = result_sqrd;
            	
        end
        %% analyze log result across scale space
        for scale_index=1:num_scales
            [r,c,v] = find(scale_space(:,:,scale_index)>threshold);
            %disp(sprintf('analyzing scale [%d]',size(r,1)));
            if(scale_index==1)
            	sigma=starting_sigma;
            else
            	sigma=sigma*k;
            end
            for t_index=1:size(r,1)
                if(numel(r)==0)
                    break;
                end
                row = r(t_index);
                col = c(t_index);
                val = scale_space(row,col,scale_index);
                width = size(scale_space,2);
                height = size(scale_space,1);
                if(row>2 && col>2 && row<(height-2) && col<(width-2))
                    maxval=1;
                    scale_min=scale_index-1;
                    scale_max=scale_index+1;
                    if(scale_index==1)
                        scale_min=1;
                    end
                    if(scale_index==num_scales)
                        scale_max=scale_index;
                    end
                    for s=scale_min:scale_max
                        if(val < scale_space((row-1),(col-1),s))
                            maxval=0;
                        end
                        if(val < scale_space((row-1),col,s))
                            maxval=0;
                        end
                        if(val < scale_space((row-1),(col+1),s))
                            maxval=0;
                        end
                        if(val < scale_space(row,(col-1),s))
                            maxval=0;
                        end
                        if(val < scale_space(row,(col+1),s))
                            maxval=0;
                        end
                        if(s~=scale_index && val < scale_space(row,col,s))
                            maxval=0;
                        end
                        if(val < scale_space((row+1),(col-1),s))
                            maxval=0;
                        end
                        if(val < scale_space((row+1),col,s))
                            maxval=0;
                        end
                        if(val < scale_space((row+1),(col+1),s))
                            maxval=0;
                        end
                    end
		    if(maxval==1)
                circle_r=[circle_r;row];
                circle_c=[circle_c;col];
                circle_rad=[circle_rad;sigma*sqrt(2)];
		    end

                end
            end
        end
        %show_all_circles(image, circle_c, circle_r, circle_rad);
        if(save_flag==1)
            print('-dpng',sprintf('%sm1-%s-%d.png',output,image_name,threshold));
        end
    elseif(method=='2')


	%% create single laplacian of gaussian filter
        log_filter = blob_createlogfilter(64,starting_sigma);
        norm_filter = norm_matrix(log_filter);
        if(test_flag==1)
            imshow(norm_filter);
            print('-dpng',sprintf('%sm2-filter-%d.png',output,starting_sigma));
        end

        %% downsample images
        scale_space = cell(num_scales,1);
	for scale_index=1:num_scales
		if(scale_index==1)
			scale_space{1}=image;
		else
			prev=scale_index-1;
			scale_space{scale_index}=imresize(scale_space{prev},(1/k));
		end
	end

	final_scale_space = zeros(size(image,1),size(image,2),num_scales);
	curr_k=k;
	for scale_index=1:num_scales
	    %% apply filtering
            gfilter = fspecial('gaussian',3,10);
            filter_image = imfilter(scale_space{scale_index},gfilter,'replicate', 'conv','full');
	    scale_space{scale_index} = filter_image;

		
    	    %% convolve image with filter
    	    result = conv2(filter_image,log_filter,'same');
    	    result_sqrd = bsxfun(@times,result, result);
            scale_space{scale_index} = result_sqrd;
    	    norm_response = norm_matrix(result_sqrd);
	    if(test_flag==1)
	        imshow(norm_response);
	        print('-dpng',sprintf('%sm2-%s-%d.png',output,image_name,scale_index));
	    end

	   %% upsample squared result
	   if(scale_index==1)
		final_scale_space(:,:,scale_index)=result_sqrd(1:size(final_scale_space,1),1:size(final_scale_space,2));
       else
           %
		   temp=imresize(result_sqrd,curr_k);
		   final_scale_space(:,:,scale_index)=temp(1:size(final_scale_space,1),1:size(final_scale_space,2));
           curr_k = curr_k * k;
	   end
	   %imshow(final_scale_space(:,:,scale_index));
	end

        %% analyze log result across scale space
        for scale_index=1:num_scales
            [r,c,v] = find(final_scale_space(:,:,scale_index)>threshold);
            %disp(sprintf('analyzing scale [%d]',size(r,1)));
            if(scale_index==1)
            	sigma=starting_sigma;
            else
            	sigma=sigma*k;
            end
            for t_index=1:size(r,1)
                if(numel(r)==0)
                    break;
                end
                row = r(t_index);
                col = c(t_index);
                val = final_scale_space(row,col,scale_index);
                width = size(final_scale_space,2);
                height = size(final_scale_space,1);
                if(row>2 && col>2 && row<(height-2) && col<(width-2))
                    maxval=1;
                    scale_min=scale_index-1;
                    scale_max=scale_index+1;
                    if(scale_index==1)
                        scale_min=1;
                    end
                    if(scale_index==num_scales)
                        scale_max=scale_index;
                    end
                    for s=scale_min:scale_max
                        if(val < final_scale_space((row-1),(col-1),s))
                            maxval=0;
                        end
                        if(val < final_scale_space((row-1),col,s))
                            maxval=0;
                        end
                        if(val < final_scale_space((row-1),(col+1),s))
                            maxval=0;
                        end
                        if(val < final_scale_space(row,(col-1),s))
                            maxval=0;
                        end
                        if(val < final_scale_space(row,(col+1),s))
                            maxval=0;
                        end
                        if(s~=scale_index && val < final_scale_space(row,col,s))
                            maxval=0;
                        end
                        if(val < final_scale_space((row+1),(col-1),s))
                            maxval=0;
                        end
                        if(val < final_scale_space((row+1),col,s))
                            maxval=0;
                        end
                        if(val < final_scale_space((row+1),(col+1),s))
                            maxval=0;
                        end
                    end
		    if(maxval==1)
                circle_r=[circle_r;row];
                circle_c=[circle_c;col];
                circle_rad=[circle_rad;sigma*sqrt(2)];
		    end

                end
            end
        end
        %show_all_circles(image, circle_c, circle_r, circle_rad);
        if(save_flag==1)
            print('-dpng',sprintf('%sm2-%s-%d.png',output,image_name,threshold));
        end

    end

% end function
end
