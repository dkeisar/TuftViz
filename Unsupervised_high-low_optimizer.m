clc
load('clusterGrid_for_christmov.mat')
batchFrames=[1:round(length(meanCompare)*0.35),round(length(meanCompare)*0.65):length(meanCompare)];
for low=0.6:0.01:1
    for high=0.6:0.01:1
        if high>low
            for i=1:length(ii)
                if meanCompare(batchFrames(i)) <low
                    algLabeledTuftsOnly((i-1)*size(reduceSet,2)+j)= 0;
                elseif meanCompare(batchFrames(i))>=low ...
                        && meanCompare(batchFrames(i))<=high
                    algLabeledTuftsOnly((i-1)*size(reduceSet,2)+j)= 0.5;
                else
                    algLabeledTuftsOnly((i-1)*size(reduceSet,2)+j)= 1;
                end
            end
        end
    end
end