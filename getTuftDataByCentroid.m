function [tuftData, isValid] = getTuftDataByCentroid(tuftSet, centroid, h, l,WindAngle)
isValid = false;
tuftData=[];
sz = size(tuftSet);
for ii = 1: sz(2)
    tuftX(ii) = tuftSet(ii).pixelX;
    tuftY(ii) = tuftSet(ii).pixelY;
end
[D,index]=min(pdist2([centroid.X,centroid.Y]...
    ,[tuftX'*l ,tuftY'*h]));

tuftData = [tuftSet(index).pixelX, tuftSet(index).pixelY, cos(abs(WindAngle-tuftSet(index).windRelatedAngle)),...
    tuftSet(index).straightness, tuftSet(index).edgeRelatedAngle, tuftSet(index).length,...
    tuftSet(index).neighbor_1, tuftSet(index).neighbor_2, tuftSet(index).neighbor_3, tuftSet(index).neighbor_4];
isValid = true;

end