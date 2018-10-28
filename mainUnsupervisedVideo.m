function mainUnsupervisedVideo(imageTune,useHybryd)
%UNTITLED3 Summary of this function goes


%% choose rand image then segment and tune it
plot=0; %dont plot information
for frameNum=1:imageTune.OriginalVideo.NumberOfFrames
    [bw,labeled,I] = segmentspecificframe(imageTune,frameNum)
    [tuftSet,labeledTufts,algLabeledTufts] = clusterStepOne(bw,labeled,I,imageTune,useHybryd,plot);
end



end