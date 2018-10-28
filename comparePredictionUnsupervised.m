function [result,compare] = comparePredictionUnsupervised(frameNum, algLabeledTufts)
load(['christ.mov.MOV_frame_',num2str(frameNum),'_tuftLabels.mat'])
load(['christ.mov.MOV_frame_',num2str(frameNum),'_tuftSet.mat'])

for i=1:length(tuftLabel)
    tuftLabel(i,3:4)=[tuftSet(tuftLabel(i,1)).pixelX,tuftSet(tuftLabel(i,1)).pixelY];
end
prediction=zeros(4,length(algLabeledTufts));
for i=1:length(algLabeledTufts)
    min=inf;
    for k=1:length(tuftLabel)
        if min>=(abs(algLabeledTufts(1,i)-tuftLabel(k,3))...
                + abs(algLabeledTufts(2,i)-tuftLabel(k,4)))
            min=(abs(algLabeledTufts(1,i)-tuftLabel(k,3))...
                + abs(algLabeledTufts(2,i)-tuftLabel(k,4)));
            kk=k;
        end
    end
     prediction(1:4,kk)=algLabeledTufts(1:4,i);
end

result = 1;
for i = 1:length(tuftLabel)
    ind = tuftLabel(i, 1);
    compare(i,1:2)=[prediction(4,ind);tuftLabel(i, 2)];
    if(prediction(3,ind) == tuftLabel(i, 2))
        result = result + 1;
    end
end
result = result/length(tuftLabel);
end