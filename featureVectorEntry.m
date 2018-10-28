classdef featureVectorEntry
    properties (Access = public)     
        FullSize
        HistoryDepth
        LabelSize
        cosineSimseqStart
        selfTagOnlyStart
        windRelatedAngleStart
        straightnessStart
        edgeRelatedAngleStart
        lengthStart
        %th
        cs = 0.92;
        wr = 0.77;
        s = 0.79;
        er = 0.93;
        l = 0.95;
        nw = [0.25 0.25 0.25 0.25];
    end
    methods (Access = public)
        function this = featureVectorEntry(labelSize, neighboursSize)
            fprintf ("initiating featureVector\n");
            this.LabelSize = labelSize;
            this.HistoryDepth = neighboursSize + 1;
            this.cosineSimseqStart = 1;
            this.selfTagOnlyStart = 19;
            this.windRelatedAngleStart = 22;
            this.straightnessStart = 28;
            this.edgeRelatedAngleStart = 34;
            this.lengthStart = 40;
            this.FullSize = 45;
        end
        
        function entry = calculateSeqCosineEntry(this, Tags, WRAs) %WRAs - wind related Angle
            th = this.cs;
            cosValue = abs(cosd(WRAs(1) - WRAs(2)));
            similars = 0;
            if(cosValue >= th)
                similars = 1;                
            end
            entry = this.tagSeqToNum(Tags) + 9*similars;                        
        end
        
        function entry = calcSelfTagOnly(this, tag)
            bias = tag*2;
            entry = this.selfTagOnlyStart + bias;
        end
        
       function entry = calcWindRelatedEntry(this, tag, value)
            th = this.wr;
            towardWinnd = 0;
            if(abs(cosd(value)) > th)
                towardWinnd = this.LabelSize;
            end
            entry = this.windRelatedAngleStart + towardWinnd + tag*2;
        end
        
        function entry = calcStraightnessEntry(this, tag, value)
            th = this.s;
            striaghtness = 0;
            if(value > th)
                striaghtness = this.LabelSize;
            end
            entry = this.straightnessStart + striaghtness + tag*2;
        end
        
        function entry = calcEdgeRelatedAngleEntry(this, tag, value)
            th = this.er;
            era = 0;
            if(value > th)
                era = this.LabelSize;
            end
            entry = this.edgeRelatedAngleStart + era + tag*2;
        end
        
        function entry = calcLengthEntry(this, tag, value)
            th = this.l;
            le = 0;
            if(value > th)
                le = this.LabelSize;
            end
            entry = this.lengthStart + le + tag*2;
        end
        
        function [seq] = numToTagSeq(this, num)
            val = num - 1;
            str = dec2base(val, this.LabelSize, this.HistoryDepth);
            seq = str - '0';
            seq = seq/2;
        end
        % [0 0] -> 00 -> 1
        % [0 0.5] -> 01 -> 2
        % [0 1] -> 02 -> 3
        % [0.5 0] -> 10 -> 4
        % [0.5 0.5] -> 11 -> 5
        function [num] = tagSeqToNum(this, tagSeq)
            j = 1;
            num = 0;
            for i = length(tagSeq):-1:1
                bit = tagSeq(i) * 2;
                num = num + bit*j;
                j = j*this.LabelSize;
            end
            num = num + 1;
        end
        
    end
end