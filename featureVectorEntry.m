classdef featureVectorEntry
    properties (Access = public)
        % define all combinations of label sequences
        Sequence0
        Sequence1
        Sequence2
        % define combinations of cosine similarity of 2 tufts value (labeled into 2 levels) 
        % and if they have equal tagging
        CosineSimilaritySeq       
        Last
        HistoryDepth
    end
    methods (Access = public)
        function this = featureVectorEntry(labelSize, neighboursSize)
            fprintf ("initiating featureVector\n");
            this.HistoryDepth = neighboursSize;
            n = neighboursSize + 1;
            this.Sequence0 = 1;
            this.Sequence1 = this.Sequence0 + labelSize;
            this.Sequence2 = this.Sequence1 + labelSize^neighboursSize;            
            this.CosineSimilaritySeq = this.Sequence2 + labelSize^n;
            this.Last = this.CosineSimilaritySeq + 4;
            %this.Last = this.straightnessTagRealated + labelSize*3;
        end
        
        function [featureVector] = createCosineSimilarityVector(this, selfAngle, neighbours, tags) % array - last tag is the current
            th = 0.9;
            featureVector = zeros(this.Last, 1);
            selfTag = tags(length(tags));
            for i = 1:length(neighbours)
                value = abs(cos(selfAngle - neighbours(i)));
                if value > th && selfTag == tags(i)
                    featureVector(this.CosineSimilaritySeq + 1) = featureVector(this.CosineSimilaritySeq + 1) + 1;                   
                end
                if value > th && selfTag ~= tags(i)
                    featureVector(this.CosineSimilaritySeq + 2) = featureVector(this.CosineSimilaritySeq + 2) + 1;                    
                end
                if value < th && selfTag == tags(i)
                    featureVector(this.CosineSimilaritySeq + 3) = featureVector(this.CosineSimilaritySeq + 3) + 1;                    
                end
                if value < th && selfTag ~= tags(i)
                    featureVector(this.CosineSimilaritySeq + 4) = featureVector(this.CosineSimilaritySeq + 4) + 1;
                end
            end
        end
        
        function index = calcSequenceEntry(this, sequence)
            n = length(sequence);
            if n == 1
                index = this.Sequence0;
            else
                if n == 2
                    index = this.Sequence1;
                else
                    index = this.Sequence2;
                end
            end
            i = 1;
            for j = n:-1:1
                index = index + sequence(j)*2*i;
                i = i*3;
            end
        end
    end
end