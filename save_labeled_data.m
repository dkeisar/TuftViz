function save_labeled_data(imageTune,randnum,tuftSet,tuftLabel)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
name=imageTune.OriginalVideo.Name;
frameNumber=round(randnum*imageTune.OriginalVideo.NumberOfFrames);
save ([name,'_frame_',num2str(frameNumber),'_tuftSet.mat'],'tuftSet');
save ([name,'_frame_',num2str(frameNumber),'_tuftLabels.mat'],'tuftLabel');
end

