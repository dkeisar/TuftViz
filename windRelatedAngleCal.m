function [windangle,trainingSet] = ...
    windRelatedAngleCal(trainingSet,windangles)
% this func addes the angle estimation of each tuft to the
% avareged true labled wing diraction
for i=1:length(tuftLabels)
    if tuftLabels(i,2)==1
        windangles(i)=Orientations(i).Orientation;
    end
end
windangle=mean(windangles);
for i=1:length(tuftLabels)
    trainingSet(i).windRelatedAngle=cos(abs(windangle-...
        Orientations(i).Orientation));
end