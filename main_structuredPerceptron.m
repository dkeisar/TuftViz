OriginalVideo=VideoReader('christ.mov.MOV');
global featureVector
featureVector = featureVectorEntry(3, 2);
weightVector = zeros(featureVector.FullSize, 4);
name=OriginalVideo.Name;
numberOfFrames=500;%round((length(dir)-3)/2);
counter=1; tc=1; i=1;
existFrames = [];
testFrames = [];
while i<=numberOfFrames
        try
            load([name,'_frame_',num2str(i),'_tuftSet.mat']);
            load([name,'_frame_',num2str(i),'_tuftLabels.mat']);
            %
            if(mod(counter + tc ,4) ~= 0)
                existFrames(counter) = i;
                counter=counter+1;
            else
                testFrames(tc) = i;
                tc = tc + 1;
            end
        catch pr
            fprintf(pr.message + "\n");
        end
        i=i+1;
end
for t = 1:25
    for i=1:length(existFrames)
        try
            load([name,'_frame_',num2str(existFrames(i)),'_tuftSet.mat']);
            load([name,'_frame_',num2str(existFrames(i)),'_tuftLabels.mat']);
            weightVector = structuredPerceptron.structuredPerceptronAlg(tuftSet,tuftLabel,weightVector);
        catch pr
            fprintf(pr.message + "\n");
        end
    end
    fprintf('finish iteration %d\n',t)
end
fprintf('%d\n',weightVector)
save learned_weight_vector.mat weightVector
fprintf('testing:\n')
for i = 1:length(testFrames)
    load([name,'_frame_',num2str(testFrames(i)),'_tuftSet.mat']);
    load([name,'_frame_',num2str(testFrames(i)),'_tuftLabels.mat']);
    prediction = structuredPerceptron.predict(tuftSet, weightVector);
    res = comparePrediction(prediction, tuftLabel);
    fprintf('frame i result = %d\n',res)
end


