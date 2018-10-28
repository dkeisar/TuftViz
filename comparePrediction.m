function result = comparePrediction(prediction, trueLabel)
    result = 1;
    for i = 1:length(trueLabel)
        ind = trueLabel(i, 1);
        if(prediction(ind) == trueLabel(i, 2))
            result = result + 1;
        end
    end
    result = result/length(trueLabel);
end