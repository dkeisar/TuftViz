function [bw,labeled,I] = segmentrandframe(imageTune)
%% tune the image and segment it
    %devide into frames and read them
    I = read(imageTune.OriginalVideo, ...
        round(rand(1)*imageTune.OriginalVideo.NumberOfFrames));%read random frame
    %make the frame B&W, crop and mask
    I=rgb2gray(I);
    I(imageTune.Mask)=256;
    I = imcrop(I, imageTune.CropFrame);
    %tune the frame by the parameters difined by the user
    I(:,:,:)=I(:,:,:)*(50^log((imageTune.BrightnessKnob.Value+0.5)));
    try
        I= locallapfilt(I, imageTune.SigmaKnob.Value, imageTune.AlphaKnob.Value);
    end
    I = imadjust(I,[imageTune.LowInSlider.Value imageTune.HighInSlider.Value],[],...
        imageTune.GammaKnob.Value);
    I=imsharpen(I,'Radius',imageTune.RadiusSlider.Value,...
        'Amount',imageTune.SharpnessstrengthKnob.Value,...
        'Threshold',imageTune.ThresholdSlider.Value);
    %segment the frame
    [bw,labeled] = matlab_seg(I,imageTune);
end

