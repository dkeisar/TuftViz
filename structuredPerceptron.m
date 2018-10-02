function updatedWeightVector = structuredPerceptron(trainingSetRaw, y_trueRaw, weightVector)
    %trainingSet = csvread(path);
    %fid = fopen(path);
    %trainingSet = textscan(fid,'%s %d8 %f32','delimiter',',');
    %fclose(fid);
    global featureVector
    global trainingSet
    global w
    featureVector = featureVectorEntry(3, 2);
    r = 1;
    w = zeros(featureVector.Last, 1);
    [trainingSet, y_true] = validateLabels(trainingSetRaw, y_trueRaw);    
    [trainingSet] = buildTrainingSet(trainingSet);
    [topology, ~] = buildTopologyGraph();
    for t = 1:10
        [y_pred] = runViterbi(topology);
        predFv = buildGlobalFv(topology, y_pred);
        trueFv = buildGlobalFv(topology, y_true);
        w = w + r*(trueFv - predFv);
    end
    [updatedWeightVector] = w;
end

function [predictedLabel] = runViterbi(topology)
    global w
    [bestScore, bestEdges] = stepForward(topology);
    [predictedLabel] = stepBackward(topology, bestScore, bestEdges);
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
            trainingSet(i,3) = data(i).windRelatedAngle;
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

function [topology, rootNodes] = buildTopologyGraph()
    global trainingSet
    topology = ones(length(trainingSet),1);
    topology = topology*(-1);
    topIndex = 1;
    neighbours = trainingSet(:,7:8);
    unusedIndex0 = [1:1:length(trainingSet)];
    unusedIndex1 = [];
    for i = 1:length(neighbours)
        if neighbours(i,1) == 0 && neighbours(i,2) == 0
            for j = 1:length(unusedIndex0)
                if unusedIndex0(j) == i
                    unusedIndex0(j) = [];
                    rootNodes(j) = i;
                    break;
                end
            end
            topology(topIndex) = i;
            topIndex = topIndex+1;
            [unusedIndex0, unusedIndex1] = updateSets(unusedIndex0, unusedIndex1, neighbours, i);
        end
    end
    while ~isempty(unusedIndex0) || ~isempty(unusedIndex1)
        nodesIn = [];
        nodesInC = 1;
        neighbours1parnet = zeros(length(unusedIndex1), 2);
        for i = 1:length(unusedIndex1)
            if(nodeHasTwoParentsInTopology(unusedIndex1(i), neighbours, topology))
                nodesIn(nodesInC) = i;
                nodesInC = nodesInC + 1;
            end
            neighbours1parnet(i,:) = neighbours(unusedIndex1(i),:);
        end
        if(~isempty(nodesIn))
            for i =  1:length(nodesIn)
                j = nodesIn(i);
                topology(topIndex) = unusedIndex1(j);
                topIndex = topIndex + 1;
                nodesIn(i) = unusedIndex1(j);                
            end
            unusedIndex1 = setdiff(unusedIndex1, topology);
            [unusedIndex0, unusedIndex1] = updateSets(unusedIndex0, unusedIndex1, neighbours, nodesIn);
        else
            maxNbrs = 0;
            nodeInd = -1;
            complete2 = false;
            for i = 1:length(unusedIndex1)
                nbrs = find(neighbours1parnet == unusedIndex1(i));
                nbrs1 = find(neighbours(:,1) == unusedIndex1(i));
                nbrs2 = find(neighbours(:,2) == unusedIndex1(i));
                nbrs1 = intersect(nbrs1, unusedIndex0);
                nbrs2 = intersect(nbrs2, unusedIndex0);
                if(length(nbrs) > maxNbrs)
                    maxNbrs = length(nbrs);
                    nodeInd = i;
                    complete2 = true;
                else
                    if(~complete2 && length(nbrs) > 0)
                        maxNbrs = length(nbrs);
                        nodeInd = i;
                        complete2 = true;
                    else
                        if(~complete2 && length(nbrs1) + length(nbrs2) > maxNbrs)
                            maxNbrs = length(nbrs1) + length(nbrs2);
                            nodeInd = i;
                        end
                    end
                end
            end
            if(maxNbrs > 0)
                topology(topIndex) = unusedIndex1(nodeInd);
                topIndex = topIndex + 1;
                unusedIndex1(nodeInd) = [];
                [unusedIndex0, unusedIndex1] = updateSets(unusedIndex0, unusedIndex1, neighbours, topology(topIndex - 1));
            else
                
            end
        end
    end
end

function [setAnswer1, setAnswer2] = updateSets(set1, set2, neighbours, nodes)
    setAnswer1 = set1;
    setAnswer2 = set2;
    for i = 1:length(nodes)
        node = nodes(i);
        allIndices = union(find(neighbours(:,1) == node), find(neighbours(:,2) == node));
        temp = intersect(allIndices, setAnswer1);
        setAnswer2 = union(temp, setAnswer2);
        setAnswer1 = setdiff(setAnswer1, setAnswer2);
    end
end

function [answer] = nodeHasTwoParentsInTopology(node, neghibours, topology)
	par1 = neghibours(node, 1);
	par2 = neghibours(node, 2);
    var1 = find(topology == par1);
    var2 = find(topology == par2);
    answer = (~isempty(var1) && ~isempty(var2)) || (~isempty(var1) && par2 == 0);
end

function [bs, be] = stepForward(topology)
    global featureVector
    global trainingSet
    global w
    possibleTags = [0 0.5 1];
    bs = ones(length(topology), length(possibleTags))*(-inf); %best score seuquence
    be = ones(length(topology), length(possibleTags))*(-1); %bestEdge
    for i = 1:length(topology) %run on each tuft in the sequence
        [nbrsInd] = getPreNeighbours(i, topology);
        [nbrsSeq] = createNbrsSeq(length(nbrsInd) + 1, length(possibleTags)); %create all possible sequences
        for j = 1:length(nbrsSeq) %run on every possible tag, calculate local representations
            seq = nbrsSeq(j, :);
            selfTag = seq(length(nbrsInd) + 1);
            lfv = zeros(featureVector.Last, 1); %local feature vector
            if(~isempty(nbrsInd)) %calculate wind related angle cosine similarity
                ind = nbrsInd(1);
                lfv = lfv + featureVector.createCosineSimilarityVector(trainingSet(i,3), trainingSet(ind,3), seq);
            end
            % calculate sequence score
            sequenceEntryInd = featureVector.calcSequenceEntry(seq);
            lfv(sequenceEntryInd) = lfv(sequenceEntryInd) + 1;
            % add score of parents nodes according to sequence tag
            curr = computeCurrScore(bs, nbrsInd, seq);
            curr = curr + dot(lfv,w);
            % if the score is higher then previous score for self tag then
            % replace
            if curr > bs(i, selfTag*2 + 1)
                bs(i, selfTag*2 + 1) = curr;
                if(length(nbrsInd) > 0)
                    be(i, selfTag*2 + 1) = j - 1;
                end
            end
        end
    end
end

function [nbrsInd] = getPreNeighbours(curr, topology)
    global trainingSet
    nbrstemp = trainingSet(topology(curr),7:8);
    nbrsInd = [];
    j = 1;
    for i = 1:length(nbrstemp)
        if(nbrstemp(i) ~= 0)
            ind = find(topology == nbrstemp(i));
            if(ind < curr)
                nbrsInd(j) = ind;
                j = j + 1;
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

function curr = computeCurrScore(bs, nbrsInd, currSeq)
    curr = 0;
    for i = 1:length(nbrsInd)
        curr = bs(nbrsInd(i), currSeq(i)*2 + 1);
    end
end

function [prediction] = stepBackward(topology, bestScore, bestEdges)
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
            [prediction(curr),score] = getBestTagScore(bestScore(i,:));
        end
        [nbrsInd] = getPreNeighbours(i, topology);
        if(~isempty(nbrsInd))
            str = dec2base(bestEdges(i, prediction(curr)*2 + 1), 3, length(nbrsInd) + 1);
            seq = str - '0';
            seq = seq/2;
            for j = 1:length(nbrsInd)
                parInd = topology(nbrsInd(j));
                if(score > parentsPath(parInd, 2))
                    parentsPath(parInd, 1) = seq(j);
                    parentsPath(parInd, 2) = score;
                end
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
    fv = zeros(featureVector.Last, 1);
    for i = 1:length(topology)
        curr = topology(i);
        [nbrsInd] = getPreNeighbours(i, topology);
        seq = [];
        if(~isempty(nbrsInd))
            % calculate sequence score
            seq = ones(length(nbrsInd) + 1,1)*(-1);
            seq(length(nbrsInd) + 1) = y(curr);
            for j = 1:length(nbrsInd)
                seq(j) = y(topology(nbrsInd(j)));
            end
            sequenceEntryInd = featureVector.calcSequenceEntry(seq);
            fv(sequenceEntryInd) = fv(sequenceEntryInd) + 1;
        else
            sequenceEntryInd = featureVector.calcSequenceEntry(y(curr));
            fv(sequenceEntryInd) = fv(sequenceEntryInd) + 1;            
        end
        %calculate wind related angle cosine similarity
        if(~isempty(nbrsInd)) 
            ind = nbrsInd(1);
            fv = fv + featureVector.createCosineSimilarityVector(trainingSet(i,3), trainingSet(ind,3), seq);
        end        
    end
end