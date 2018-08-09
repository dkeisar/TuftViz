function [weightVectors,miniweightVectors,tuftVectors] = ...
    Main_ML_develop(imageTune,weightVectors,miniweightVectors,tuftVectors)
%%
% Main ML Training func
WindAngle=imageTune.FlowAngle;

%% choose rand image then segment and tune it
    [bw,labeled,I] = segmentrandframe(imageTune);
%% create tuft set
[trainingSet]=create_tuft_set(labeled,bw,WindAngle);

%%
meanweightVector=mean(weightVectors);
meanminiweightVector=mean(miniweightVectors);
weightVector=meanweightVector;
miniweightVector=meanminiweightVector;

lh=LearningHandler;
[trainingmat,windangles] = lh.buildTrainingSet(trainingSet);
firstPrediction = zeros(1,length(trainingmat));

for i=1:length(firstPrediction)
    firstPrediction(i) = dot(trainingmat(i,:), miniweightVector);
end


trainingmat = lh.calculateBeliefPropagation(trainingmat, firstPrediction,windangles);

[tuftSet,Orientation]=create_develop(labeled,bw,...
    WindAngle,trainingmat,weightVector,imageTune.CropFrame,I);
global val;
val=[];
try
x_point=val.x;
[x_point,ia,ic] = unique(x_point,'last');
y_point=val.y(ia);
labels=val.label(ia);
tuft=val.tufts(ia);
box=val.box(ia,:);
val=[]; clear val;
tuftLabel=[tuft;labels]';
catch
   fprintf('Nothing hasnt change') ;
end
%
% %calculate the angle
% for i=1:length(Orientation)
%     tuftSet(i).windRelatedAngle=deg2rad((WindAngle-...
%         Orientation(i).Orientation));
% end
for i=1:length(Orientation)
    tuftSet(i).windRelatedAngle=deg2rad((WindAngle-...
        Orientation(i).Orientation));
end
% this func should start BP and get back the train matrix
if exist('tuftLabel')
    [weightVector,~,miniweightVector] =lh.process(tuftSet,tuftLabel,weightVector,miniweightVector);
end
%Orientations=Orientation; %if we want to guess wind diraction
global MLhandel
if isfield(MLhandel,'selectedFeatures')
    changeVector=[MLhandel.selectedFeatures,0,0,0]
    for i=1:length(MLhandel.selectedFeatures)
       if changeVector(i)==0
           weightVector(i)=0;
       end
    end
    weightVectors=[(length(weightVectors)+1)*weightVector];
else
    weightVectors=[weightVectors;weightVector];
    meanweightVector=mean(weightVectors);
    meanminiweightVector=mean(miniweightVectors);
    weightVector=meanweightVector;
    
end
miniweightVectors=[miniweightVectors;miniweightVector];
miniweightVector=meanminiweightVector;
if exist('tuftMat')
    tuftVectors=[tuftVectors,tuftMat];
end
%contourmap_drawer_ML(weightVector,tuftMat,imageTune.CroppedMask,I)
end