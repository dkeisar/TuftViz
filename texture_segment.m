clc
clear all
close all
I = imread('try1_for_seg.jpg');
I = rgb2gray(I);
function [outputArg1,outputArg2] = (inputArg1,inputArg2)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
outputArg1 = inputArg1;
outputArg2 = inputArg2;
end
%Use entropyfilt to create a texture image. The function entropyfilt
%returns an array where each output pixel contains the entropy value of 
%the 9-by-9 neighborhood around the corresponding pixel in the input 
%image I. Entropy is a statistical measure of randomness.
E = entropyfilt(I);
%rescale the texture image E so that its values are in the
%default range for a double image.
Eim = rescale(E);
%Threshold the rescaled image Eim to segment the textures
BW1 = imbinarize(Eim, .81);%check the treshhold
% extract a texture 
BWao = bwareaopen(BW1,300);%change the No
%smooth the edges and to close any open holes in the object in BWao.
%A 9-by-9 neighborhood is selected
nhood = true(9);
closeBWao = imclose(BWao,nhood);
%fill holes in the object in closeBWao
roughMask = imfill(closeBWao,'holes');
figure (2)
imshow(roughMask);
I2 = I;
I2(roughMask) = 0;
figure (3)
imshow(I2)