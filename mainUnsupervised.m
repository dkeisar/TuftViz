function mainUnsupervised(imageTune,flag)
%UNTITLED3 Summary of this function goes 


%% choose rand image then segment and tune it
[bw,labeled,I] = segmentrandframe(imageTune);

create_grid_for_clustering(I,bw,labeled,imageTune,flag)
uiwait(gcf);

%% here will be the video part
end

