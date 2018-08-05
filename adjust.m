clc
clear all
close all
a=VideoReader('Moving stall cell.mp4');
img=1;
I = read(a, img);
I = rgb2gray(I);
figure(1)
imshow(I)

IA=imadjust(I);
figure(2)
imshow(IA)
B=imsharpen(IA);
imcontrast(gca);

%sigma = 0.4;
%alpha = 0.5;
%B= locallapfilt(IA, sigma, alpha, 'ColorMode', 'separate');
%t_speed = timeit(@() locallapfilt(IA ,sigma, alpha, 'NumIntensityLevels', 100))
%B_speed = locallapfilt(IA, sigma, alpha, 'NumIntensityLevels', 100);
figure (3)
imshowpair(IA, B, 'montage')


% ID=imsharpen(IA);
% ID=imcontrast(ID);
% 
% figure(3)
% imshow(ID)
