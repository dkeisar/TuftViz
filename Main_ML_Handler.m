function Main_ML_Handler(mainHandle)
%% This is the function that control the operation of the ML of the weight
%vector that assume the probability of the tuft to be attached
%

%% this part is training the weight vector
numberOfFrames=min(5,mainHandle.OriginalVideo.NumberOfFrames/30);
for img = 1:numberOfFrames  %for each frame
    %% this part pic a rand frame, adjust it and segments it
    %devide into frames and read them
    I = read(mainHandle.OriginalVideo, round(rand(1)*numberOfFrames));
    %make the frame B&W, crop and mask
    I=rgb2gray(I);
    I(mainHandle.Mask)=256;
    I = imcrop(I, mainHandle.CropFrame);
    %tune the frame by the parameters difined by the user
    I(:,:,:)=I(:,:,:)*(50^log((mainHandle.BrightnessKnob.Value+0.5)));
    I= locallapfilt(I, mainHandle.SigmaKnob.Value, ...
        mainHandle.AlphaKnob.Value);
    I = imadjust(I,[mainHandle.LowInSlider.Value ...
        mainHandle.HighInSlider.Value],[],mainHandle.GammaKnob.Value);
    I=imsharpen(I,'Radius',mainHandle.RadiusSlider.Value,...
        'Amount',mainHandle.SharpnessstrengthKnob.Value,...
        'Threshold',mainHandle.ThresholdSlider.Value);
    %segment the frame
    [bw,labeled] = matlab_seg(I,app.CroppedMask);
    
    %% this part intracts with the user to get a label vector for the
    % bached tufts
    % tuftLabels - No of tuft in the segmentation and the user label
    % tuftVectors - mat containing feature vector
    [tuftVector,tuftLabel,Orientation]=create_training_set(labeled,bw)
    if counter=1
        tuftVectors=tuftVector;
        tuftLabels=tuftLabel;
        Orientations=Orientation;
    elseif
        tuftVectors=[tuftVectors,tuftVector];
        tuftLabels=[tuftLabels,tuftLabel];
        Orientations=[Orientations,Orientation];
    end
end
% this part addes the wind relation angle estimation

for i=1:length(tuftLabels)
    if tuftLabels(i,2)==1
        windangles(i)=Orientations(i).Orientation;
    end
end
windangle=mean(windangles);
for i=1:length(tuftLabels)
    tuftVectors(i).windRelatedAngle=cos(abs(windangle-...
        Orientations(i).Orientation));
end




end

