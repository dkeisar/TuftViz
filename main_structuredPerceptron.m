OriginalVideo=VideoReader('christ.mov.MOV');
global featureVector
featureVector = featureVectorEntry(3, 2);
name=OriginalVideo.Name;
numberOfFrames=500;%round((length(dir)-3)/2);
T = 25;
useAverage = false;
identifier = 12;
for cv = 1:4
    counter=1; tc=1; i=1;
    trainFrames = [];
    testFrames = [];
    swv = zeros(featureVector.FullSize, 4);
    swvC = 1;
    weightVector = zeros(featureVector.FullSize, 4);
while i<=numberOfFrames
        try
            str = strcat(name,'_frame_',num2str(i),'_tuftSet.mat');
            if(exist(str, 'file') == 2)
                %load([name,'_frame_',num2str(i),'_tuftSet.mat']);
                %load([name,'_frame_',num2str(i),'_tuftLabels.mat']);
                if(mod(counter + tc ,4) ~= 4-cv)
                    trainFrames(counter) = i;
                    counter=counter+1;
                else
                    testFrames(tc) = i;
                    tc = tc + 1;
                end
            end
        catch pr
            fprintf(pr.message + "\n");
        end
        i=i+1;
end
fprintf('found %d frames in folder- learning amount: %d, testing amount: %d\n', counter + tc, counter, tc);
for t = 1:T
    for i=1:length(trainFrames)
        try
            load([name,'_frame_',num2str(trainFrames(i)),'_tuftSet.mat']);
            load([name,'_frame_',num2str(trainFrames(i)),'_tuftLabels.mat']);
            weightVector = structuredPerceptron.structuredPerceptronAlg(tuftSet,tuftLabel,weightVector);
            if(useAverage)
                swv = swv + weightVector;
                weightVector = swv/swvC;
                swvC = swvC + 1;
            end
        catch pr
            fprintf(pr.message + "\n");
        end
    end
    fprintf('finish iteration %d\n',t)
end
save learned_weight_vector.mat weightVector
fprintf('testing:\n')
sumRes = 0;
sumAnalyzed = zeros(3);
fileName = strcat('test_result_', num2str(identifier),'-', num2str(cv), '.txt');
fileId = fopen(fileName,'w');
fprintf(fileId, 'test parameters:\n');
fprintf(fileId, 'nw (neighbors weight): [');
fprintf(fileId, ' %4f', featureVector.nw);
fprintf(fileId, ']\n');
fprintf(fileId, 'cs (cosine similarity): %f\n', featureVector.cs);
fprintf(fileId, 'wr (wind related): %f\n', featureVector.wr);
fprintf(fileId, 's (straightness): %f\n', featureVector.s);
fprintf(fileId, 'er (edge related): %f\n', featureVector.er);
fprintf(fileId, 'l (length): %f\n', featureVector.l);
fprintf(fileId, 'T (num of iterations): %d\n', T);
fprintf(fileId, 'a (averaged wv): %d\n', useAverage);
fprintf(fileId, 'results:\n');
for i = 1:length(testFrames)
    load([name,'_frame_',num2str(testFrames(i)),'_tuftSet.mat']);
    load([name,'_frame_',num2str(testFrames(i)),'_tuftLabels.mat']);
    prediction = structuredPerceptron.predict(tuftSet, weightVector);
    [res, analyzed] = comparePrediction(prediction, tuftLabel);
    fprintf(fileId, '%6d ', analyzed);
    fprintf(fileId, 'frame %d result = %f %% \n', i, res);
    sumRes = sumRes + res;
    sumAnalyzed = sumAnalyzed + analyzed;
    %drawPlot(tuftSet, prediction);
end
sumRes = sumRes/length(testFrames);
fprintf(fileId, '%6d ', sumAnalyzed);
fprintf(fileId, 'total success = %f %% \n', sumRes);
fclose(fileId);
end

function [result, resMatrix] = comparePrediction(prediction, trueLabel)
    result = 1;
    resMatrix = zeros(3);
    for i = 1:length(trueLabel)
        ind = trueLabel(i, 1);
        if(prediction(ind) == trueLabel(i, 2))
            result = result + 1; %- abs((prediction(ind) - trueLabel(i, 2)));
        end
        resMatrix(prediction(ind)*2 + 1, trueLabel(i, 2)*2 + 1) = ...
            resMatrix(prediction(ind)*2 + 1, trueLabel(i, 2)*2 + 1) + 1;
    end
    result = (result * 100)/length(trueLabel);
end

function drawPlot(tuftSet, tags)
    for i = 1:length(tags)
        hold on;
        switch tags(i)
            case 0
                plot(tuftSet(i).pixelX, tuftSet(i).pixelY, 'r.');
            case 0.5
                plot(tuftSet(i).pixelX, tuftSet(i).pixelY, 'g.');
            case 1
                plot(tuftSet(i).pixelX, tuftSet(i).pixelY, 'b.');
        end
        %text(tuftSet(i).pixelX, tuftSet(i).pixelY, num2str(tags(i)));
        axis([0 1 0 1]);
    end
end
