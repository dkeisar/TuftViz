OriginalVideo=VideoReader('christ.mov.MOV');
weightVector=[0,0,1,1,1,1];
name=OriginalVideo.Name;
numberOfFrames=round((length(dir)-3)/2);
counter=1; i=1;
while i<=OriginalVideo.NumberOfFrames
    try
        load([name,'_frame_',num2str(i),'_tuftSet.mat']);
        load([name,'_frame_',num2str(i),'_tuftLabels.mat']);
        weightVector=structuredPerceptron(tuftSet,tuftLabels,weightVector);
        counter=counter+1;
        if counter*3/2>numberOfFrames
            break
        end
    end
    i=i+1;
end
fprintf('%d\n',weightVector)

