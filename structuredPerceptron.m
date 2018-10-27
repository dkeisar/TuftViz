classdef structuredPerceptron
    methods (Static)
function updatedWeightVector = structuredPerceptronAlg(trainingSetRaw, y_trueRaw, w)
    global trainingSet
    global wCurr
    global currNbrs
    r = 1;
    [trainingSet, y_true] = structuredPerceptron.validateLabels(trainingSetRaw, y_trueRaw);    
    [trainingSet] = structuredPerceptron.buildTrainingSet(trainingSet);
    [topology] = structuredPerceptron.buildTopologyGraph();
    for j = 1:4
        wCurr = w(:,j);
        currNbrs = trainingSet(:,6 + j);    
        [y_pred] = structuredPerceptron.runViterbi(topology(:,j));    
        predFv = structuredPerceptron.buildGlobalFv(topology(:,j), y_pred);
        trueFv = structuredPerceptron.buildGlobalFv(topology(:,j), y_true);
        w(:,j) = w(:,j) + r*(trueFv - predFv);
    end
    [updatedWeightVector] = w;
end

function [prediction] = predict(data, w)
    global trainingSet
    global wCurr
    global currNbrs
    global featureVector
    [trainingSet] = structuredPerceptron.buildTrainingSet(data);
    [topology] = structuredPerceptron.buildTopologyGraph();
    y = ones(length(data),4);
    prediction = zeros(length(data),1);
    %weights = [0.25 0.25 0.25 0.25];
    weights = featureVector.nw;
    for i = 1:4
        if (weights(i) == 0)
            continue;
        end
        wCurr = w(:,i);
        currNbrs = trainingSet(:,6 + i);
        [y(:,i)] = structuredPerceptron.runViterbi(topology(:,i));
        %prediction = prediction + 0.1*(4-i+1)*y(:,i);
        prediction = prediction + weights(i)*y(:,i);
    end
    for i = 1:length(prediction)
        curr = prediction(i);
        if(curr > 0.7)
            prediction(i) = 1;
        else
            if(curr < 0.3)
                prediction(i) = 0;
            else
                prediction(i) = 0.5;
            end
        end
    end
end

function [predictedLabel] = runViterbi(topology)
    [bestScore, bestEdges] = structuredPerceptron.stepForward(topology);
    [predictedLabel] = structuredPerceptron.stepBackward(topology, bestScore, bestEdges);
end

function [trainingSet, labelSet] = validateLabels(trainingSetRaw, labelSetRaw)
    szTS = size(trainingSetRaw);
    szl = size(labelSetRaw);
    labelSet = zeros(szTS(2), 1);
    if(szTS(1) == szl(1))
        trainingSet = trainingSetRaw;
        return;
    end
    for i =1:szl(1)
        for j=1:1:szl(1)
           if(labelSetRaw(j,1) == i)
               labelSet(i) = labelSetRaw(j,2);
               break;
           end
        end
    end
    trainingSet = trainingSetRaw;
    %for i=1:length(labelSet)
        
    %end
end

function [trainingSet] = buildTrainingSet(data)
	trainingSet = zeros(length(data), 10);
	for i=1:length(data)
        try 
            trainingSet(i,1) = data(i).pixelX;
        catch
            trainingSet(i,1) = 0;
        end
        try 
            trainingSet(i,2) = data(i).pixelY;
        catch
            trainingSet(i,2) = 0;
        end
        try 
            trainingSet(i,3) = rad2deg(data(i).windRelatedAngle);
        catch
            trainingSet(i,3) = 0;
        end
        try 
            trainingSet(i,4) = data(i).straightness;
        catch
            trainingSet(i,4) = 0;
        end
        try 
            trainingSet(i,5) = data(i).edgeRelatedAngle;
        catch
            trainingSet(i,5) = 0;
        end
        try 
            trainingSet(i,6) = data(i).length;
        catch
            trainingSet(i,6) = 0;
        end
        try 
            trainingSet(i,7) = data(i).neighbor_1;
        catch
            trainingSet(i,7) = 0;
        end
        try 
            trainingSet(i,8) = data(i).neighbor_2;
        catch
            trainingSet(i,8) = 0;
        end
        try 
            trainingSet(i,9) = data(i).neighbor_3;
        catch
            trainingSet(i,9) = 0;
        end
        try 
            trainingSet(i,10) = data(i).neighbor_4;
        catch
            trainingSet(i,10) = 0;
        end
	end
end

function [bs, be] = stepForward(topology)
    global featureVector
    global trainingSet
    global wCurr
    global currNbrs
    possibleTags = [0 0.5 1];
    bs = ones(length(topology), length(possibleTags))*(-inf); %best score
    be = ones(length(topology), length(possibleTags))*(-1); %best edge
    for i = 1:length(topology) %run on each tuft
        self = topology(i);
        [nbrInd] = currNbrs(topology(i));
        if(nbrInd == 0)
            [allSeq] = structuredPerceptron.createNbrsSeq(1, length(possibleTags)); %create all possible sequences
        else
            [allSeq] = structuredPerceptron.createNbrsSeq(2, length(possibleTags)); %create all possible sequences
        end
        for j = 1:length(allSeq) %run on every possible tag sequence, calculate local representations
            seq = allSeq(j, :);
            selfTag = seq(length(seq));
            lfv = zeros(featureVector.FullSize, 1); %local feature vector
            if(nbrInd ~= 0) %calculate sequence score with wind related angle cosine similarity
                wra = [trainingSet(self,3) trainingSet(nbrInd,3)];
                entry = featureVector.calculateSeqCosineEntry(seq, wra);
                lfv(entry) = lfv(entry) + 1;
            end
            entry = featureVector.calcWindRelatedEntry(selfTag, trainingSet(self, 3));
            lfv(entry) = lfv(entry) + 1;
            entry = featureVector.calcStraightnessEntry(selfTag, trainingSet(self, 4));
            lfv(entry) = lfv(entry) + 1;
            entry = featureVector.calcEdgeRelatedAngleEntry(selfTag, trainingSet(self, 5));
            lfv(entry) = lfv(entry) + 1;
            entry = featureVector.calcLengthEntry(selfTag, trainingSet(self, 6));
            lfv(entry) = lfv(entry) + 1;
            % add score of parents nodes according to sequence tag
            curr = 0;
            if(nbrInd ~= 0)
               curr = bs(nbrInd, seq(1)*2 + 1);
            end
            curr = curr + dot(lfv,wCurr);
            % if the score is higher then previous score for self tag then
            % replace
            if curr > bs(self, selfTag*2 + 1)
                bs(self, selfTag*2 + 1) = curr;
                if(nbrInd ~= 0)
                    be(self, selfTag*2 + 1) = j - 1;
                end
            end
        end
    end
end

function [nbrsSeq] = createNbrsSeq(numOfNbrs, numOfTags)
    nbrsSeq =  zeros(numOfTags^numOfNbrs, numOfNbrs);
    t = length(nbrsSeq)-1;
    for j = 0:t
        str = dec2base(j, numOfTags, numOfNbrs);
        seq = str - '0';
        nbrsSeq(j + 1,:) = seq/2;
    end
end

function [prediction] = stepBackward(topology, bestScore, bestEdges)
    global currNbrs
    parentsPath = ones(length(topology), 2)*(-1);
    parentsPath(:,2) = -inf; 
    prediction = ones(length(topology), 1)*(-1);
    for i = length(bestScore):-1:1
        curr = topology(i);
        score = -inf;
        if(parentsPath(curr, 1) ~= -1)
            prediction(curr) = parentsPath(curr, 1);
            score = bestScore(i, (prediction(curr)*2) + 1);
        else
            [prediction(curr),score] = structuredPerceptron.getBestTagScore(bestScore(i,:));
        end
        nbr = currNbrs(curr);
        if(nbr ~= 0)
            str = dec2base(bestEdges(curr, prediction(curr)*2 + 1), 3, 2);
            seq = str - '0';
            seq = seq/2;
            if(score > parentsPath(nbr, 2))
                parentsPath(nbr, 1) = seq(1);
                parentsPath(nbr, 2) = score;
            end
        end
    end
end

function [tag, maxScore] = getBestTagScore(tagScroes)
    maxScore = -inf;
    for i = 1:length(tagScroes)
        if(tagScroes(i) > maxScore)
            tag = (i - 1)/2;
            maxScore = tagScroes(i);
        end
    end
end

function fv = buildGlobalFv(topology, y)
    global featureVector
    global trainingSet
    global currNbrs
    fv = zeros(featureVector.FullSize, 1);
    for i = 1:length(topology)
        curr = topology(i);
        nbr = currNbrs(curr);
        if(nbr ~= 0)
            % calculate sequence score
            seq = ones(length(nbr) + 1,1)*(-1);
            seq(2) = y(curr);
            seq(1) = y(nbr);
            wra = [trainingSet(curr,3) trainingSet(nbr,3)];
            sequenceEntryInd = featureVector.calculateSeqCosineEntry(seq, wra);
            fv(sequenceEntryInd) = fv(sequenceEntryInd) + 1;
        else
            sequenceEntryInd = featureVector.calcSelfTagOnly(y(curr));
            fv(sequenceEntryInd) = fv(sequenceEntryInd) + 1;            
        end
        entry = featureVector.calcWindRelatedEntry(y(curr), trainingSet(curr, 3));
        fv(entry) = fv(entry) + 1;
        entry = featureVector.calcStraightnessEntry(y(curr), trainingSet(curr, 4));
        fv(entry) = fv(entry) + 1;
        entry = featureVector.calcEdgeRelatedAngleEntry(y(curr), trainingSet(curr, 5));
        fv(entry) = fv(entry) + 1;
        entry = featureVector.calcLengthEntry(y(curr), trainingSet(curr, 6));
        fv(entry) = fv(entry) + 1;     
    end
end

function [topology] = buildTopologyGraph()
    global trainingSet
    n = 4;
    topology = zeros(length(trainingSet), n);
    for i = 1:n
        [topology(:,i)] = structuredPerceptron.build1ParentTopology(trainingSet(:,6 + i));
    end
end

function [topology] = build1ParentTopology(nbrs)
    unusedIndex = 1:1:length(nbrs);
    topology = ones(1, length(nbrs))*(-1);
    topIndex = 1;
    for i = 1:length(nbrs)
        if(nbrs(i) == 0)
            topology(topIndex) = i;
            topIndex = topIndex + 1;
        end
    end
    unusedIndex = setdiff(unusedIndex, topology);
    while (~isempty(unusedIndex))    
        nextInTopology = [];
        for i = 1:topIndex
            nextInTopology = union(nextInTopology, find(nbrs == topology(i)));
        end
        nextInTopology = intersect(nextInTopology, unusedIndex);
        for i = 1:length(nextInTopology)
            topology(topIndex) = nextInTopology(i);
            topIndex = topIndex + 1;            
        end
        if(isempty(nextInTopology))
            fprintf('oh no there is a circle.... we still have %d left to sort/n',length(unusedIndex));
            break;
        end
        unusedIndex = setdiff(unusedIndex, topology);
    end
end
    end
end