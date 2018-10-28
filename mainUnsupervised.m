function mainUnsupervised(imageTune,useHybryd)
%UNTITLED3 Summary of this function goes


%% choose rand image then segment and tune it
%[bw,labeled,I,frameNum] = segmentrandframe(imageTune);
RESULT=[0];
frameNums=[4,22,28,30,31,42,49,58,73,78,85,102,104,107,121,125,147,151,153,168,169,193,202,204,210,233,239,266,297,300,301,303,313,321,329,330,332,356,367,370,371,384,387,399,412,413,418,474,485];
%         frameCurrentNum=round(rand(1)*length(frameNums));
%     if frameCurrentNum==0
%         frameCurrentNum=round(rand(1)*length(frameNums));
%     end
load('clusterGrid_for_christmov.mat')

global MLhandel
MLhandel.gridindex=gridindex;
MLhandel.gridindexY=gridindexY;
MLhandel.gridindexX=gridindexX;
labelDistanceFactor = 12;
MLhandel.noMaxCluster=15;
MLhandel.noOfSuperPixels=10;
for i=1:48
    result(i)=0;
    counter=1;
    
    
    for j=1:20
        try
            frameNum=frameNums(i);
            [bw,labeled,I,frameNum] = segmentrandframe(imageTune,frameNum);
            
            %  create_grid_for_clustering(I,bw,labeled,imageTune,flag)
            %   uiwait(gcf);
            
            %% Cluster
            plot=0; %plot plots
            [tuftSet,labeledTufts,algLabeledTufts] = clusterStepOne(bw,labeled,I,imageTune,useHybryd,plot,labelDistanceFactor);
            %% here will be the video part
            
            [resultt,compare] = comparePredictionUnsupervised(frameNum, [algLabeledTufts;labeledTufts]);
            result(i)=resultt+result(i);
            if exist('Compare')
                Compare=[Compare,compare];
            else
                Compare=compare;
            end
            counter=counter+1;
            fprintf('end of inner iteration %d of the %d iteration\n', j, i);
        catch pr
            pr
        end
    end
    try
        for m=1:(size(Compare,2)/2)
            if exist('sumCompare')
                sumCompare=Compare(:,m*2-1)+sumCompare;
            else
                sumCompare=Compare(:,m*2-1);
            end
        end
        if exist('meanCompare')
            meanCompare=[meanCompare;[sumCompare/(size(Compare,2)/2),Compare(:,2),linspace(frameNum,frameNum,size(Compare,1))']];
        else
            meanCompare(:,1:2)=[sumCompare/(size(Compare,2)/2),Compare(:,2)];
            meanCompare(:,3)=frameNum;
        end
    catch
        'compare is not in the same size'
    end
    try
        clear('Compare');clear('sumCompare');
    catch 'nothing to clear'
    end
    result(i)=result(i)/counter;
    fprintf('end of iteration %d\n', i);
    
end
filename = 'meanCompare_pca_15cluster_10superpix_dis12.mat';
save(filename,'meanCompare')
RESULT=[RESULT,result]
end


