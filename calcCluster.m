function [forScatterCluster,algLabeledTufts] = calcCluster(trainingSet,h,l, maxClusters,noOfSuperPixels, labelDistanceFactor, useHybryd,bw,plot)
%addpath(genpath("PRML-PRMLT-v1.7-1-g3f9d968"));
%method = 'Distance';
%subMethod = 'euclidean';

maxClust = maxClusters;
sz = size(trainingSet);
%reduceSet = [];

if ~(useHybryd)
    counter=1;
    for i=1:size(trainingSet,1)
        for j=1:size(trainingSet,2)
            a(counter,1:4)=[trainingSet(i,j,3:6)];
            b(counter,1)=sum([trainingSet(i,j,3)]);
            counter=counter+1;
        end
    end
    Max=max(mean(a));
    Min=min(mean(a));
    [reduceSettag, ~, ~, ~] = pca(a, 1);
    reduceSettag = rescale(reduceSettag,Min,Max);
    %reduceSettag=mean(a,2);
    counter=1;
    for i=1:size(trainingSet,1)
        for j=1:size(trainingSet,2)
            reduceSet(i,j)=reduceSettag(counter);
            counter=counter+1;
        end
    end
else
    [reduceSet] = calcPredictions(trainingSet);
end

clusterSet = [trainingSet(:,1:2), reduceSet*labelDistanceFactor];
for i=1:size(reduceSet,1)
    for j=1:size(reduceSet,2)
        try
                     data(1:3,(i-1)*size(reduceSet,2)+j)=...
                         [trainingSet(i,j,1),trainingSet(i,j,2),reduceSet(i,j)];
%             data(1:3,(i-1)*size(reduceSet,2)+j)=...
%                 [trainingSet(i,j,1),trainingSet(i,j,2),b((i-1)*size(reduceSet,2)+j)];
            
        end
    end
end
[~, model, ~] = mixGaussEm(data, maxClust);
[labels, R] = mixGaussPred(data, model);
labeledTufts = labels;

for i=1:size(reduceSet,1)
    for j=1:size(reduceSet,2)
        try
            flipped(i,j)=labeledTufts((i-1)*size(reduceSet,2)+j);
        end
    end
end
%flipped= flipud(flipped);
if plot==1
    figure(maxClust);
    scatter(data(1,:)*l,data(2,:)*h,[],labels);
    axis equal
end
[superpixeled,NumLabels] = superpixels(flipped,noOfSuperPixels);
realnoOfSuperPixels=max(max(superpixeled));
for i=1:size(reduceSet,1)
    for j=1:size(reduceSet,2)
        for k=1:realnoOfSuperPixels
            if  k==superpixeled(i,j)
                try sumSuperPixel(k,1)=sumSuperPixel(k,1)+superpixeled(i,j);
                    sumSuperPixel(k,2)=sumSuperPixel(k,2)+1;
                catch
                    sumSuperPixel(k,1)=superpixeled(i,j);
                    sumSuperPixel(k,2)=1;
                end
            end
        end
    end
end
for k=1:noOfSuperPixels
    try meanSuperPixel(k,1)=round(sumSuperPixel(k,1)/sumSuperPixel(k,2));
    end
end

for i=1:size(reduceSet,1)
    for j=1:size(reduceSet,2)
        for k=1:realnoOfSuperPixels
            if superpixeled(i,j)==k
                try sumClusterPixel(k,1)=sumClusterPixel(k,1)+data(3,(i-1)*size(reduceSet,2)+j);
                    sumClusterPixel(k,2)=sumClusterPixel(k,2)+1;
                catch
                    sumClusterPixel(k,1)=data(3,(i-1)*size(reduceSet,2)+j);
                    sumClusterPixel(k,2)=1;
                end
            end
        end
    end
end
for k=1:realnoOfSuperPixels
    try meanClusterPixel(k,1)=sumClusterPixel(k,1)/sumClusterPixel(k,2);
    end
end

for i=1:size(reduceSet,1)
    for j=1:size(reduceSet,2)
        for k=1:realnoOfSuperPixels
            if  k==superpixeled(i,j)
                try
                    %segmentedTuftArray(i,j)=meanSuperPixel(k,1);
                    valueTuftArray(i,j)=meanClusterPixel(k,1);
                    forScatterCluster((i-1)*size(reduceSet,2)+j)=meanClusterPixel(k,1);
                    if forScatterCluster((i-1)*size(reduceSet,2)+j) <0.8
                        algLabeledTuftsOnly((i-1)*size(reduceSet,2)+j)= 0;
                    elseif forScatterCluster((i-1)*size(reduceSet,2)+j)>=0.8 ...
                            && forScatterCluster((i-1)*size(reduceSet,2)+j)<=0.9
                        algLabeledTuftsOnly((i-1)*size(reduceSet,2)+j)= 0.5;
                    else
                        algLabeledTuftsOnly((i-1)*size(reduceSet,2)+j)= 1;
                    end
                catch
                    k ;
                end
            end
        end
    end
end
algLabeledTufts=[data(1,:);data(2,:);algLabeledTuftsOnly];

if plot==1
    figure(1);
    title(['After Clustering']);
    scatter(data(1,:)'*l,data(2,:)'*h,[],forScatterCluster');
    
    figure(2);
    title(['After Clustering']);
    [X,Y] = meshgrid(1:1:l, h:-1:1);
    Q = griddata(data(1,:)*l,data(2,:)*h,forScatterCluster,X,Y,'cubic');
    hold on
    ax=gca;
    fig=gcf;
    fig.Position=[ 100 100 l h];
    imagepos=[0 0 1 1];
    %show map
    axes('pos',imagepos)
    contourf(Q,[0:0.1:1],'LineStyle','none');
    axis equal
    
    %show image with alpha mask
    axes('pos',imagepos)
    imshow(bw)
    alpha 0.4
    delete(ax)
    hold off
end


% if(maxClusters <= 10)
%     maxClust = maxClusters + 1;
%     [~, model, ~] = mixGaussEm(clusterSet, maxClust);
%     [label, ~] = mixGaussPred(clusterSet, model);
%     figure(maxClust);
%     scatter(flipped(:,1)*l,flipped(:,2)*h,10,label);
%     axis equal
% end
%
% if(maxClusters > 1 && maxClusters <= 10)
%     maxClust = maxClusters - 1;
%     [~, model, ~] = mixGaussEm(clusterSet, maxClust);
%     [label, ~] = mixGaussPred(clusterSet, model);
%     figure(maxClust);
%     scatter(flipped(:,1)*l,flipped(:,2)*h,10,label);
%     axis equal
% end

end

function [answer] = calcPredictions(trainingSet)
global MLhandel
localweightVector = MLhandel.weightVector .* MLhandel.weightVector;

end