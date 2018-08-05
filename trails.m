clc
clear all
close all
a=VideoReader('Moving stall cell.mp4');

I = read(a, 1);
%I = rgb2gray(I);
h_im = imshow(I);
Mask = impoly(gca);


BW = createMask(Mask,h_im);
% 4a) (For color images only) Augment the mask to three channels:
BW(:,:,2) = BW;
BW(:,:,3) = BW(:,:,1);
% 5) Use logical indexing to set area outside of ROI to zero:   
ROI = I;
ROI(BW == 0) = 0;
% 6) Display extracted portion:
figure, imshow(ROI);
% I(Mask) = 256;

