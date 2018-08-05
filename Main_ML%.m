classdef (Sealed) Main_ML < handle
    properties (Access = private)
        app
    end
    methods
        function Main_ML_func(~,Main_ML.app)
            
            [windangle,tuftVectors]=Learn_Weight_Vector(~,Main_ML.app)
            
            
        end
    end
    methods
        function [tuftVectors,tuftLabel,Orientation]=...
                create_training_set(~,labeled,bw)
            
            graindata = regionprops(labeled,'basic');
            
            len=length(graindata);
            x=zeros(len,1);y=zeros(len,1);     %initialize
            for i=1:len
                %extract center and orientation
                Center=graindata(i).Centroid;
                
                %classify to the x and y location
                x(i)=Center(1); y(i)=Center(2);
            end
            [h,l]=size(bw);
            
            imshow(bw)
            hold on
            title('Choose segments representing attached flow','FontSize',16,'Color',[0,0,0]);
            hold off
            [x_point,y_point] = getpts;
            close
            Min_Dis=Inf;
            attached_tufts=zeros(length(x_point),1);
            attached_tufts(:,2)=1;
            for i=1:length(x_point)
                for j=1:length(x)
                    Dis=pdist2([x_point(i) y_point(i)],[x(j) y(j)]);
                    if Dis<Min_Dis
                        Min_Dis=Dis;
                        attached_tufts(:,1)=j;
                    end
                end
                Min_Dis=Inf;
            end
            
            imshow(bw)
            hold on
            title('Choose segments representing UN-attached flow','FontSize',16,'Color',[0,0,0]);
            hold off
            [x_point,y_point] = getpts;
            close
            Min_Dis=Inf;
            unattached_tufts=zeros(length(x_point),2);
            unattached_tufts(:,2)=0;
            for i=1:length(x_point)
                for j=1:length(x)
                    Dis=pdist2([x_point(i) y_point(i)],[x(j) y(j)]);
                    if Dis<Min_Dis
                        Min_Dis=Dis;
                        unattached_tufts(:,1)=j;
                    end
                end
                Min_Dis=Inf;
            end
            
            MinorAxisLength=regionprops(labeled,'MinorAxisLength');
            MajorAxisLength=regionprops(labeled,'MajorAxisLength');
            %Orientations=regionprops(labeled,'Orientation');
            %windangle=0;
            for i=1:length(x)
                tuftVectors(i).pixelX=x(i)/l; tuftVectors(i).pixelY=y(i)/h;
                
                tuftVectors(i).straightness=(1-MinorAxisLength(i).MinorAxisLength...
                    /MajorAxisLength(i).MajorAxisLength);
            end
            tuftLabel=[attached_tufts,unattached_tufts];
            
            Min_Dis_1=Inf;Min_Dis_2=Inf;Min_Dis_3=Inf;Min_Dis_4=Inf;
            for i=1:length(x)
                for j=1:length(x)
                    if i~=j
                        Dis=pdist2([x(i) y(i)],[x(j) y(j)]);
                        if Dis<Min_Dis_1
                            Min_Dis_1=Dis;
                            tuftVectors(i).neighbor_1=j;
                        elseif Dis<Min_Dis_2
                            Min_Dis_2=Dis;
                            tuftVectors(i).neighbor_2=j;
                        elseif Dis<Min_Dis_3
                            Min_Dis_3=Dis;
                            tuftVectors(i).neighbor_3=j;
                        elseif Dis<Min_Dis_4
                            Min_Dis_4=Dis;
                            tuftVectors(i).neighbor_4=j;
                        end
                    end
                end
                Min_Dis_1=Inf;Min_Dis_2=Inf;Min_Dis_3=Inf;Min_Dis_4=Inf;
            end
            
            
        end
    end
    
    methods
        function [windangle,tuftVectors]=Learn_Weight_Vector(~,Main_ML.app)
            % This is the function that control the operation of the ML of the weight
            %vector that assume the probability of the tuft to be attached
            %
            
            % this part is training the weight vector
            numberOfFrames=min(5,Main_ML.app.OriginalVideo.NumberOfFrames/30);
            for img = 1:numberOfFrames  %for each frame
                %% this part pic a rand frame, adjust it and segments it
                %devide into frames and read them
                I = read(Main_ML.app.OriginalVideo, round(rand(1)*numberOfFrames));
                %make the frame B&W, crop and mask
                I=rgb2gray(I);
                I(Main_ML.app.Mask)=256;
                I = imcrop(I, Main_ML.app.CropFrame);
                %tune the frame by the parameters difined by the user
                I(:,:,:)=I(:,:,:)*(50^log((Main_ML.app.BrightnessKnob.Value+0.5)));
                I= locallapfilt(I, Main_ML.app.SigmaKnob.Value, ...
                    Main_ML.app.AlphaKnob.Value);
                I = imadjust(I,[Main_ML.app.LowInSlider.Value ...
                    Main_ML.app.HighInSlider.Value],[],Main_ML.app.GammaKnob.Value);
                I=imsharpen(I,'Radius',Main_ML.app.RadiusSlider.Value,...
                    'Amount',Main_ML.app.SharpnessstrengthKnob.Value,...
                    'Threshold',Main_ML.app.ThresholdSlider.Value);
                %segment the frame
                [bw,labeled] = matlab_seg(I,Main_ML.app.CroppedMask);
                
                %% this part intracts with the user to get a label vector for the
                % bached tufts
                % tuftLabels - No of tuft in the segmentation and the user label
                % tuftVectors - mat containing feature vector
                [tuftVector,tuftLabel,Orientation]=create_training_set(labeled,bw);
                if counter==1
                    tuftVectors=tuftVector;
                    tuftLabels=tuftLabel;
                    Orientations=Orientation;
                else
                    tuftVectors=[tuftVectors,tuftVector];
                    tuftLabels=[tuftLabels,tuftLabel];
                    Orientations=[Orientations,Orientation];
                end
            end
            [windangle,tuftVectors] = ...
                windRelatedAngleCal(~,tuftVectors,windangles)
        end
    end
    
    methods
        function [windangle,tuftVectors] = ...
                windRelatedAngleCal(~,tuftVectors,windangles)
            % this func addes the angle estimation of each tuft to the
            % avareged true labled wing diraction
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
    end
    
    events (ListenAccess = protected)
        StateChanged
    end
end
