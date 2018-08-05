clc
clear all
close all
a=VideoReader('Moving stall cell.mp4');
for img = 1:a.NumberOfFrames;
    filename=strcat('frame',num2str(img),'.jpg');
    I = read(a, img);
    I = rgb2gray(I);
    if img==1
        Mask = croping(I);
        I(Mask) = 256;
        bw = matlab_seg(I);
        v = VideoWriter('myFile','Archival');
        open(v);
        writeVideo(v,bw);
    else
        I(Mask) = 256;
        bw = matlab_seg(I);
        writeVideo(v,bw)
    end
end

close(v)
