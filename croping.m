function [Mask] = croping(I)
%This function lets you crop the image by hand and returns the croped image
%as well as the crop details
imshow(I);
h = impoly
Mask = ~h.createMask();
%I(Mask) = 256;
%imshow(I);
end