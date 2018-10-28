
clear all
load('meanCompare_edgeonly_15cluster_10superpix.mat')
batchFrames=[1:round(length(meanCompare)*0.5),round(length(meanCompare)*0.5)+1:length(meanCompare)];
counter=1; 
for low=0.85
    for high=0.96
        count=1;
        if high>low
            for i=1:length(batchFrames)
                if meanCompare(batchFrames(i),3)==474
                    if meanCompare(batchFrames(i),1) <low
                        predicted(count,1)= 0; predicted(count,2)= meanCompare(batchFrames(i),2);
                    elseif meanCompare(batchFrames(i),1)>=low ...
                            && meanCompare(batchFrames(i),1)<=high
                        predicted(count,1)= 0.5; predicted(count,2)= meanCompare(batchFrames(i),2);
                    elseif meanCompare(batchFrames(i),1)>high
                        predicted(count,1)= 1; predicted(count,2)= meanCompare(batchFrames(i),2);
                    end
                count=count+1;    
                end
            end
            divresult=[0,0;0,0;0,0];result=0;
            for k = 1:length(predicted)
                if(predicted(k,1) == predicted(k,2))
                    result=result+1;
                    divresult(predicted(k,2)*2+1,1) = divresult(predicted(k,2)*2+1,1) + 1;
                end
                try
                    divresult(predicted(k,2)*2+1,2) = divresult(predicted(k,2)*2+1,2) + 1;
                catch
                    'pr'
                end
            end
            for mn=1:3
                meanresult(mn)=divresult(mn,1)/divresult(mn,2);
            end
            result=result/length(predicted);
            res=mean(meanresult);
            clear ('predicted'); clear('divresult');
            divresults(1:3,counter)=[low,high,res];
            results(1:3,counter)=[low,high,result];
            counter=counter+1;
        end
    end
end
%[X,Y] = meshgrid(0:0.01:1, 0:0.01:1);
%Qdivresults = griddata(divresults(1,:)',divresults(2,:)',divresults(3,:)',X,Y,'cubic');
%Qresults = griddata(results(1,:)',results(2,:)',results(3,:)',X,Y,'cubic');
figure(1)
%contourf(Qdivresults,[0:0.1:1],'LineStyle','none');
scatter3(divresults(1,:),divresults(2,:),divresults(3,:))
[Maxdiv,Idiv]=max(divresults(3,:));
fprintf('the averaged accuracy is %d\n', Maxdiv);
fprintf('Low %d\n', divresults(1,Idiv));
fprintf('High %d\n', divresults(2,Idiv));

xlabel ('Low')
ylabel ('High')


figure(2)
%contourf(Qresults,[0:0.1:1],'LineStyle','none');
scatter3(results(1,:),results(2,:),results(3,:))
[Max,I]=max(results(3,:));
fprintf('the Total accuracy is %d\n', Max);
fprintf('Low %d\n', results(1,I));
fprintf('High %d\n', results(2,I));
xlabel ('Low')
ylabel ('High')
