function tryNcutClustering;
% demoNcutClustering
% 
% demo for NcutClustering
% also initialize matlab paths to subfolders
% Timothee Cour, Stella Yu, Jianbo Shi, 2004.

disp('Ncut Clustering demo');

%% make up a point data set
load ('for_cluster.mat')
data=for_cluster';
data(3,:)=data(3,:)*100;
figure(1); 
axis([0 1200 0 500]);
for i=1:length(data')
    text (data(1,i),data(2,i),num2str(round(data(3,i)))); 
end

disp('This is the input data points to be clustered, press Enter to continue...');

disp('Compute clustering...');

% compute similarity matrix
[W,Dist] = compute_relation(data);

% clustering graph in
nbCluster = 4;
tic;
[NcutDiscrete,NcutEigenvectors,NcutEigenvalues] = ncutW(W,nbCluster);
disp(['The computation took ' num2str(toc) ' seconds']);
figure(3);
plot(NcutEigenvectors);

% display clustering result
cluster_color = ['rgbmyc'];
figure(2);clf;
for j=1:nbCluster,
    id = find(NcutDiscrete(:,j));
    plot(data(1,id),data(2,id),[cluster_color(j),'s'], 'MarkerFaceColor',cluster_color(j),'MarkerSize',5); hold on; 
end
hold off; axis image;
disp('This is the clustering result');
disp('The demo is finished.');
