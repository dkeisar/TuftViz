
function [bw,labeled] = matlab_seg(I,ImageTune,whatToShow)
% This function sements the tuned image that was sent to it (I) and also
% gets the mask of the image to sent the other functions


% adjust the image using background Surface approximation - not assures
% good segmentation - for now better not to use
% background = imopen(I,strel('disk',15));
% I2 = I - background;
% I3 = imadjust(I2);
% bw = imbinarize(I3); %binerize the image

%%%%% add a button to determine if the tufts are dark or bright%%%%
bw = imbinarize(I,'adaptive','ForegroundPolarity',...
    ImageTune.TuftcolorButtonGroup.SelectedObject.Text,...
    'Sensitivity',ImageTune.SensitivitySpinner.Value);
try
    if ImageTune.TuftcolorButtonGroup.SelectedObject.Text=="Dark"
        bw=~bw;
    end
end

% Binerize the image and remove items not within [min max] pixels
%bw = imbinarize(I);
bw = bwareafilt(bw, [ImageTune.MinSpinner.Value ImageTune.MaxSpinner.Value]);

% Lable all the components that are connected with 8 pixels around them
cc = bwconncomp(bw, 8);
labeled = labelmatrix(cc);
% Extract the information about the labeled data - Basic + Orientation
graindata = regionprops(labeled,'basic');
graindata_Orientation=regionprops(labeled,'Orientation');

if ImageTune.stdd.Value~= inf
    for i=1:length(graindata)
        graindata_size(i)=graindata(i).Area;
    end
    stdd=std(graindata_size); meann=mean(graindata_size);

    bw = bwareafilt(bw, [meann-stdd*ImageTune.stdd.Value meann+stdd*ImageTune.stdd.Value]);

    % Lable all the components that are connected with 8 pixels around them
    cc = bwconncomp(bw, 8);
    labeled = labelmatrix(cc);
    % Extract the information about the labeled data - Basic + Orientation
    graindata = regionprops(labeled,'basic');
    graindata_Orientation=regionprops(labeled,'Orientation');
end

% send to make streamline drawing or/and contor map drawing
try
    if whatToShow=="streamlines"
        streamlinedrawer(graindata,graindata_Orientation,...
            ImageTune.CroppedMask,ImageTune.CropFrame,ImageTune.Mask,ImageTune.FlowAngle, I,0)
    elseif whatToShow=="contour map"
        contourmap_drawer(graindata,graindata_Orientation,...
            ImageTune.CroppedMask,ImageTune.FlowAngle,I)
    end
end
%contourmap_drawer(graindata,graindata_Orientation,imageTune.CroppedMask,I)
%   streamlinedrawer(graindata,graindata_Orientation,imageTune.CroppedMask,I)
end