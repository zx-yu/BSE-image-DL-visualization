clc
clear
close all

ImageSize=220;

for SampleName=1:4
mkdir(['TrainingImage_' int2str(ImageSize) '/' int2str(SampleName)])
imagedirection = dir(['New_images\' int2str(SampleName) '\*.tif']); % image locations
nimages=size(imagedirection,1); 
count=1;

for ni = 1:nimages
    readingimage=['New_images\' int2str(SampleName) '\', imagedirection(ni).name];
    imageinf=imread(readingimage);
    imageinf=im2double(imageinf);
    Image_Ori=imageinf(1:884,:,1);

    for rot=0:90:359 %image rotation degree
        Image_Crop= imrotate(Image_Ori,rot);
        crop_num=floor(size(Image_Crop)./ImageSize);
        Image_Crop=reshape(Image_Crop(1:ImageSize*crop_num(1),1:ImageSize*crop_num(2),1), [ImageSize crop_num(1) ImageSize crop_num(2)]);
        Image_Crop =permute(Image_Crop,[1 3 2 4]);
        Image_Crop =reshape(Image_Crop,[ImageSize, ImageSize ,crop_num(1)*crop_num(2)]);
        
        for i = 1:crop_num(1)*crop_num(2)
            crop=Image_Crop(:,:,i);            
            fname=['Rot', int2str(rot),'_', int2str(SampleName),'_', int2str(ni), '_',int2str(count),'.png']; % save file names
            fname=fullfile(['TrainingImage_' int2str(ImageSize) '\' int2str(SampleName)],fname); % save file location
            imwrite(crop,fname)
            count=count+1;            
        end
    end
end
end

