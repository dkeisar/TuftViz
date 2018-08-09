classdef LearningHandler
    properties
    end
    methods (Access = public)
        function this = LearningHandler()
            fprintf ("learning handler initialized\n");
        end
        
        function [uupdatedWeightVector,filteredTrainingSet,miniweightVector] = process(this, tufts,...
                labels, weightVector,miniweightVector)
            fprintf ("recieved new array of tufts of length %d\n", length(tufts));
            fprintf ("Now let's learn\n");
            [trainingSet,windangles] = this.buildTrainingSet(tufts);
            [firstPrediction,miniweightVector] = this.firstGuess(trainingSet, miniweightVector,labels);
            algoGuess = this.calculateBeliefPropagation(trainingSet, firstPrediction,windangles);
            filteredTrainingSet = this.filterLabeledOnly(algoGuess, labels);
            uupdatedWeightVector= this.gradientOfVectors(filteredTrainingSet,labels,weightVector,trainingSet);
        end
        
        function [predictions,updatedminiweightVector]= firstGuess(~, trainingSet, miniweightVector,labels)
            predictions = zeros(1,length(trainingSet));
            sz = size(trainingSet);
            trainingSet(:,(sz(2)-3):sz(2))=0;
            if norm(miniweightVector(:,3:sz(2)))>0
                miniweightVector = miniweightVector/norm(miniweightVector(:,3:(sz(2)-4)) , 1);
            end
            updatedminiweightVector = fmin_adam(@(miniweightVector)labelingMSEGradients(miniweightVector,...
                trainingSet(labels(:,1),3:(sz(2)-4)), labels(:,2)), miniweightVector(:,3:(sz(2)-4))', 0.1);
            updatedminiweightVector=updatedminiweightVector';
            updatedminiweightVector = updatedminiweightVector/norm(updatedminiweightVector , 1);
            updatedminiweightVector=[0,0,updatedminiweightVector,0,0,0,0];
            for i=1:sz(1)
                predictions(i) = dot(trainingSet(i,:), updatedminiweightVector);
            end
        end
        
        function [trainingSet,windangles] = buildTrainingSet(~, data)
            trainingSet = zeros(length(data), 10);
            for i=1:length(data)
                try 
                    trainingSet(i,1) = data(i).pixelX;
                end
                try 
                    trainingSet(i,2) = data(i).pixelY;
                end
                try 
                    trainingSet(i,3) = abs(cos(data(i).windRelatedAngle));
                    windangles(i)=data(i).windRelatedAngle;
                end
                try 
                    trainingSet(i,4) = data(i).straightness;
                end
                try 
                    trainingSet(i,5) = data(i).edgeRelatedAngle;
                end
                try 
                    trainingSet(i,6) = data(i).length;
                end
                try trainingSet(i,7) = data(i).neighbor_1;
                catch
                        trainingSet(i,8) = 0;
                end
                try trainingSet(i,8) = data(i).neighbor_2;
                catch
                        trainingSet(i,8) = 0;
                end
                try trainingSet(i,9) = data(i).neighbor_3;
                catch
                        trainingSet(i,9) = 0;
                end
                try trainingSet(i,10) = data(i).neighbor_4;
                catch
                        trainingSet(i,10) = 0;
                end
            end
        end
        
        function data = calculateBeliefPropagation(~, data, firstPrediction,windangles)
            sz = size(data);
            for i = 1:size(data,1)
                tuft = windangles(i);
                neighbours= data(i,(sz(2)-3):sz(2));
                for j = 1:4
                    if neighbours(j)~=0
                        neighbour = windangles(neighbours(j));
                        neighbours(j) = abs(cos((tuft - neighbour)))*firstPrediction(neighbours(j));
                    else
                        if j==1
                            neighbours(j)=1;
                        else
                           neighbours(j)=mean(neighbours(1:j-1));
                        end                        
                    end
                end
                data(i,sz(2)-3) = mean(neighbours(1:4));
                data(i,(sz(2)-2):sz(2)) = 0;
            end
            
        end
        
        function filteredData = filterLabeledOnly(~, trainingData, LabeledData)
            szfd = size(trainingData);
            szld = size(LabeledData);
            filteredData = zeros(szld(1), szfd(2));
            for i=1:szld(1)
                filteredData(i,:) = trainingData(LabeledData(i,1),:);
            end
        end
        
        function uupdatedWeightVector = gradientOfVectors(~,filteredTrainingSet,labels,weightVector,trainingSet)
            sz = size(trainingSet);
            global MLhandel
            if isfield(MLhandel,'labels')
                MLhandel.labels=[MLhandel.labels;labels];
            else
                MLhandel.labels=labels;
            end
            if ~isfield(MLhandel,'selectedFeatures')
                updatedWeightVector = fmin_adam(@(weightVector)labelingMSEGradients...
                    (weightVector, filteredTrainingSet(:,3:(sz(2)-3)), labels(:,2)), weightVector(:,3:(sz(2)-3))', 0.01);
                updatedWeightVector=updatedWeightVector';
                uupdatedWeightVector=[0,0,updatedWeightVector,0,0,0];
            else
                counter=1;
                for i=1:length(MLhandel.selectedFeatures)
                    if MLhandel.selectedFeatures(i)==1
                        selectedFeaturevector(counter)=i;
                        counter=counter+1;
                    end
                end
                updatedWeightVector = fmin_adam(@(weightVector)labelingMSEGradients...
                    (weightVector, filteredTrainingSet(:,selectedFeaturevector), labels(:,2)), ...
                    weightVector(:,selectedFeaturevector)', 0.01);
                updatedWeightVector=updatedWeightVector';
                counter=1;
                for i=1:length(MLhandel.selectedFeatures)
                    if selecedFeatures(i)==1
                        uupdatedWeightVector(i)=updatedWeightVector(counter);
                        counter=counter+1;
                    else
                        uupdatedWeightVector(i)=0;
                    end
                end
                uupdatedWeightVector(i+1:i+3)=0;
            end
        end
    end
end