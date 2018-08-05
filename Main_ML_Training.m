function [weightVectors,miniweightVectors,tuftVectors] = ...
    Main_ML_Training(imageTune,noOfImages,weightVectors,miniweightVectors,tuftVectors)
%%
% Main ML Training func
WindAngle=imageTune.FlowAngle;
%%
for img=1:noOfImages %for each frame
    %% choose rand image then segment and tune it
    [bw,labeled,I] = segmentrandframe(imageTune);
    
    %% Create the training set
    % create tuft set
    [tuftSet,xcenter,ycenter,graindata]=create_tuft_set(labeled,bw,deg2rad(WindAngle));
    
    %% create the traing set
    global val;
    val=[];
    choose_tufts_for_ML(bw,xcenter,ycenter,graindata)
    uiwait (gcf)
    x_point=val.x;
    [x_point,ia,ic] = unique(x_point,'last');
    y_point=val.y(ia);
    labels=val.label(ia);
    tuft=val.tufts(ia);
    box=val.box(ia,:);
    val=[]; clear val;
    tuftLabel=[tuft;labels]';
    
%%    
    if ~exist('weightVector')
        noOfFeatures=10;
        miniweightVector=zeros(1,noOfFeatures);
        weightVector=zeros(1,noOfFeatures);%ones(1,noOfFeatures)/noOfFeatures;
    else
        if size(weightVectors,1)>1
            meanweightVector=mean(weightVectors);
            meanminiweightVector=mean(miniweightVectors);
            weightVector=meanweightVector;
            miniweightVector=meanminiweightVector;
        end
    end
    lh=LearningHandler;
    
    %% this func should sends to the stohastic perceptro 
    % and then does BP and get back the train matrix
    [weightVector,tuftMat,miniweightVector] =lh.process(tuftSet,...
        tuftLabel,weightVector,miniweightVector);

    if img==1 && noOfImages>1
        tuftVectors=tuftMat;
        tuftLabels=tuftLabel;
        weightVectors=weightVector;
        meanweightVector=weightVector;
        miniweightVectors=miniweightVector;
        meanminiweightVector=miniweightVectors;
        %Orientations=Orientation; %if we want to guess wind diraction
    else
        weightVectors=[weightVectors;weightVector];
        miniweightVectors=[miniweightVectors;miniweightVector];
        meanweightVector=mean(weightVectors);
        meanminiweightVector=mean(miniweightVectors);
        weightVector=meanweightVector;
        miniwesightVector=meanminiweightVector;
        tuftVectors=[tuftVectors;tuftMat];
    end
    %%
    
    %deletenPoints=[];
    graindata = regionprops(labeled,'basic');
    %     uiwait(gcf)
    
    %contourmap_drawer_ML(weightVector,tuftMat,imageTune.CroppedMask,I);
    %streamline_gui(tuftSet,imageTune.CroppedMask,I,bw,WindAngle,graindata)
    %streamline_drawer_ML(tuftSet,imageTune.CroppedMask,I,bw,WindAngle,2,1);
    %uiwait(gcf)
    
end

end