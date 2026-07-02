clc;
clear;
close all;

load v0TrainingResults_220_20240728185754;  
ImageSize = size;
clear size;  
SampleName = 1; 
imagedirection = dir(fullfile('New_images', int2str(SampleName), '*.tif'));
if isempty(imagedirection)
    error('no .tif images');
end

readingimage = fullfile('New_images', int2str(SampleName), imagedirection(1).name);
imageinf = imread(readingimage);
if size(imageinf, 3) == 3
    imageinf = imageinf(:, :, 1);
end
imageinf = im2double(imageinf);
for i=1:4
    for j=1:5
        crop = imageinf(ImageSize*(i-1)+1:ImageSize*i, ImageSize*(j-1)+1:ImageSize*j);
        inputImg = uint8(imresize(crop, [ImageSize, ImageSize]) * 255);
        R = double(activations(net, inputImg, 'classOutput', 'OutputAs', 'channels'));
        R = R(:);
        [~, I] = max(R);
        if I == SampleName
            borderColor = [0 1 0];
        else
            borderColor = [1 0 0];
        end
        
        crop_rgb = repmat(crop, [1 1 3]);
        lineWidth = 4;
        crop_rgb(1:lineWidth,:,1) = borderColor(1);
        crop_rgb(1:lineWidth,:,2) = borderColor(2);
        crop_rgb(1:lineWidth,:,3) = borderColor(3);
        crop_rgb(end-lineWidth+1:end,:,1) = borderColor(1);
        crop_rgb(end-lineWidth+1:end,:,2) = borderColor(2);
        crop_rgb(end-lineWidth+1:end,:,3) = borderColor(3);
        crop_rgb(:,1:lineWidth,1) = borderColor(1);
        crop_rgb(:,1:lineWidth,2) = borderColor(2);
        crop_rgb(:,1:lineWidth,3) = borderColor(3);
        crop_rgb(:,end-lineWidth+1:end,1) = borderColor(1);
        crop_rgb(:,end-lineWidth+1:end,2) = borderColor(2);
        crop_rgb(:,end-lineWidth+1:end,3) = borderColor(3);
        
        label = classify(net, inputImg);
        scoreMap = gradCAM(net, inputImg, label);
        scoreMap = mat2gray(scoreMap);
        CAMrgb = ind2rgb(im2uint8(scoreMap), jet(256));
        figure('Color','w');
        imshow(crop_rgb);
        hold on;
        h = imshow(CAMrgb);
        set(h, 'AlphaData', 0.30); 
        title(sprintf('True = %d, Pred = %d', SampleName, I), 'FontSize', 12);
        hold off;
        axis image;
        set(gca, 'Position', [0 0 1 1]);
        saveas(gcf, ['CAM-' num2str(i) '-' num2str(j) '.tif']);
    end 
end