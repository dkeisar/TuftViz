%% exampleScript.m
% This script can be used to perform image segmentation using Normalized
% Cuts (Shi and Malik, PAMI 2000) and various generalizations, including 
% Biased Normalized Cuts (Maji et al., Proc. CVPR 2011), Yu-Shi Normalized
% Cuts (Yu and Shi, PAMI 2004), Eriksson Normalized Cuts (Eriksson, Olsson,
% and Kahl, JMIV 2011), and ML-Constrained, CL-Constrained, and Semi-
% Supervised Normalized Cuts (Chew and Cahill, Proc. ICCV 2015).
%
% To illustrate these various techniques, we use an image from the PASCAL
% VOC database (Everingham et al., IJCV 2014), with manually provided
% paintbrush strokes in foreground and background regions.
%

%% read in image to segment
exampleDataDir = 'exampleData';
imgFile = fullfile(exampleDataDir,'2010_001457.jpg');
img = imread(imgFile);

%% display original image
figure; imshow(img); title('Original image');

%% read in manually provided class labels
foregroundClass = imread(fullfile(exampleDataDir,'Class1.jpg'));
backgroundClass = imread(fullfile(exampleDataDir,'Class2.jpg'));
C = cat(3,any(foregroundClass<200,3),any(backgroundClass<200,3));

%% overlay class labels on original image and display
[i,j] = find(C(:,:,1));
fgColor = squeeze(foregroundClass(i(1),j(1),:));
[i,j] = find(C(:,:,2));
bgColor = squeeze(backgroundClass(i(1),j(1),:));
imgChannelsOverlay = {img(:,:,1),img(:,:,2),img(:,:,3)};
for i = 1:3
    imgChannelsOverlay{i}(C(:,:,1)) = fgColor(i);
    imgChannelsOverlay{i}(C(:,:,2)) = bgColor(i);
end
imgOverlay = cat(3,imgChannelsOverlay{:});

figure; imshow(imgOverlay); title('Original image + foreground/background paintbrush strokes');

%% compute globalized probability of contour (gPb), as described in 
% Arbelaez et al., PAMI 2011. This uses the BSR toolbox from the UC
% Berkeley Computer Vision Group, available for download from here: 
%   http://www.eecs.berkeley.edu/Research/Projects/CS/vision/grouping/resources.html
% This toolbox works with MATLAB on Linux. Once the BSR toolbox is
% downloaded and placed on the MATLAB search path, the maximum gPb can be 
% computed for our image using the following code:
%
%   gPb_orient = globalPb(imgFile);
%   gPb = max(gPb_orient,[],3);
%
% For users who do not wish to install this package, we have precomputed 
% the gPb for this example image and have saved the result in a MAT file 
% that can be loaded in using the following command:
load(fullfile(exampleDataDir,'gPb.mat'));

%% display gPb
figure; imagesc(gPb); axis image; colorbar; title('Maximum globalized probability of contour');

%% compute SLIC Superpixels, as described in Achanta et al., PAMI 2012.
% This uses the VLfeat Toolbox available for download from here:
%   http://www.vlfeat.org/
% Once the VLfeat Toolbox is downloaded and placed on the MATLAB search
% path, SLIC Superpixels can be computed via the following commands:
%   
%   % convert to L*a*b*
%   cform = makecform('srgb2lab');
%   imlab = applycform(img,cform);
% 
%   % compute SLIC superpixels
%   regionSize = 10;
%   regularizer = 10000;
%   tic; spSegs = vl_slic(single(imlab), regionSize, regularizer); t = toc;
%   fprintf('Superpixel time: %g s\n',t);
% 
%   % place superpixel boundaries on image
%   [sx,sy]=vl_grad(double(spSegs), 'type', 'forward') ;
%   sidx = find(sx | sy) ;
%   S = img; S([sidx sidx+numel(img(:,:,1)) sidx+2*numel(img(:,:,1))]) = 0;
%
% For users who do not wish to install this package, we have precomputed 
% the spSegs and S for this example image and have saved the result in a 
% MAT file that can be loaded in using the following command:
load(fullfile(exampleDataDir,'SLIC_Data.mat'));

%% display superpixels
figure; imshow(S); title('SLIC Superpixels');

%% compute centroids of each superpixel
numSuperpixels = max(spSegs(:))+1;
meanPosition = zeros(numSuperpixels,2);

% arrays for row, col pixel position
[numRows,numCols,~] = size(img);
[r,c] = ndgrid(1:numRows,1:numCols);

% loop over each superpixel, computing centroids
for ii = 1:numSuperpixels
    
    % create mask for the i-1st superpixel
    mask = (spSegs==(ii-1));
    
    % compute average row and column position
    meanPosition(ii,1) = mean(r(mask));
    meanPosition(ii,2) = mean(c(mask));
    
end

%% determine which superpixels should be given constraints, and determine weights
CSupPix = false(numSuperpixels,2);
CSupPixWeights = zeros(numSuperpixels,2);
for ii = 1:numSuperpixels
    
    % create mask for the i-1st superpixel
    mask = (spSegs==(ii-1));
    numMaskPixels = sum(mask(:));
    
    % for each class, determine if any manually provided constraints
    % overlap the superpixel
    for jj = 1:2
        
        Ccurrent = C(:,:,jj);
        numPixelOverlap = sum(Ccurrent(mask));
        if numPixelOverlap>0
            CSupPix(ii,jj) = true;
            CSupPixWeights(ii,jj) = numPixelOverlap/numMaskPixels;
        end
        
    end
    
end

%% construct adjacency matrix
sigma = 0.1;
rad = max(numRows,numCols)/10;
fprintf('Computing adjacency matrix...\n')
tic; A = adjacencyMatrixGPbSuperpixels(meanPosition,gPb,rad,sigma); t = toc;
fprintf('\t Elapsed time: %g s\n',t);

%% compute unconstrained Normalized Cut and Biased Normalized Cut 
% first use only foreground paintbrush stroke
fprintf('Computing Shi-Malik NCut...\n');
tic; [YBiasedF,YUnc] = biasedNCut(A, 25, CSupPix(:,1)); t = toc;
fprintf('\t Elapsed time: %g s\n',t);

% second use only background paintbrush stroke
YBiasedB = biasedNCut(A, 25, CSupPix(:,2));

% interpolate results to pixel grid
fprintf('Interpolating Shi-Malik NCut solution to pixel grid...\n');
XUnc = interpSpectraSupPix(img,spSegs,meanPosition,1,YUnc);

fprintf('Interpolating Biased NCut solution (using foreground mask) to pixel grid...\n');
XBiasedF = interpSpectraSupPix(img,spSegs,meanPosition,1,YBiasedF);

fprintf('Interpolating Biased NCut solution (using background mask) to pixel grid...\n');
XBiasedB = interpSpectraSupPix(img,spSegs,meanPosition,1,YBiasedB);

%% display results
figure; imshow(XUnc,[]); title('Normalized Cuts');
figure; imshow(XBiasedF,[]); title('Biased Normalized Cuts, Foreground Constraints');
figure; imshow(XBiasedB,[]); title('Biased Normalized Cuts, Background Constraints');

%% compute Yu-Shi Normalized Cuts 
% first using only foreground paintbrush stroke
fprintf('Computing Yu-Shi NCut with foreground mask...\n');
tic; YYuShiF = yuShiNCut(A, 2, CSupPix(:,1)); t = toc;
fprintf('\t Elapsed time: %g s\n',t);

% interpolate results to pixel grid
fprintf('Interpolate results to pixel grid...\n');
XYuShiF = interpSpectraSupPix(img,spSegs,meanPosition,1,YYuShiF(:,2));

% second using only background paintbrush stroke
fprintf('Computing Yu-Shi NCut with background mask...\n');
tic; YYuShiB = yuShiNCut(A, 2, CSupPix(:,2)); t = toc;
fprintf('\t Elapsed time: %g s\n',t);

% interpolate results to pixel grid
fprintf('Interpolate results to pixel grid...\n');
XYuShiB = interpSpectraSupPix(img,spSegs,meanPosition,1,YYuShiB(:,2));

%% display results
figure; imshow(XYuShiF,[]); title('Yu-Shi Normalized Cuts, Foreground Constraints');
figure; imshow(XYuShiB,[]); title('Yu-Shi Normalized Cuts, Background Constraints');

%% construct lists of ML and CL constraints, and gamma weights, for 
% Eriksson and Semi-Supervised Normalized Cuts

% construct lists of ML constraints
constrInd = zeros(numRows*numCols,1);
MLcell = cell(2,1);
for ii = 1:2
    ind = find(CSupPix(:,ii));
    constrInd(ind) = ii;
    MLcell{ii} = completeGraph(ind);
end
ML = cat(1,MLcell{:});

% construct lists of CL constraints
ind1 = find(CSupPix(:,1));
ind2 = find(CSupPix(:,2));
n1 = numel(ind1);
n2 = numel(ind2);
ii = repmat(ind1(:),[1 n2]);
jj = repmat(ind2(:)',[n1 1]);
CL = [ii(:) jj(:)];

%% compute Eriksson Normalized Cuts 
fprintf('Computing Eriksson NCut with ML and CL constraints...\n');
tic; YEriksson = erikssonNCut(A, 2, ML, CL); t = toc;
fprintf('\t Elapsed time: %g s\n',t);

% interpolate results to pixel grid
fprintf('Interpolate results to pixel grid...\n');
XEriksson = interpSpectraSupPix(img,spSegs,meanPosition,1,YEriksson);

%% display results
figure; imshow(XEriksson,[]); title('Eriksson Normalized Cuts with both ML and CL Constraints');

%% compute gamma weights for ML and CL constraints in SSNCuts
numML = nchoosek(sum(sum(C(:,:,1))),2) + ...
    nchoosek(sum(sum(C(:,:,2))),2);
numCL = sum(sum(C(:,:,1)))*sum(sum(C(:,:,2)));
gamma = 100*(4*sum(A(:)))./[numML numCL];

%% compute Semi-Supervised Normalized Cuts using only ML constraints (both classes simultaneously) 
fprintf('Computing Semi-Supervised NCut with only ML constraints...\n');
tic; YML = semiSupervisedNormCut(A,2,ML,gamma(1),[],[],[],constrInd); t = toc;
YML = YML.*sign(YML(ind1(1)));
fprintf('\t Elapsed time: %g s\n',t);

% interpolate results to pixel grid
fprintf('Interpolate results to pixel grid...\n');
XML = interpSpectraSupPix(img,spSegs,meanPosition,1,YML);

%% display results
figure; imshow(XML,[]); title('Semi-Supervised Normalized Cuts with only ML Constraints');

%% compute Semi-Supervised Normalized Cuts using only CL constraints 
fprintf('Computing Semi-Supervised NCut with only CL constraints...\n');
tic; YCL = semiSupervisedNormCut(A,2,[],[],CL,gamma(2),[],constrInd); t = toc;
YCL = YCL.*sign(YCL(ind1(1)));
fprintf('\t Elapsed time: %g s\n',t);

% interpolate results to pixel grid
fprintf('Interpolate results to pixel grid...\n');
XCL = interpSpectraSupPix(img,spSegs,meanPosition,1,YCL);

%% display results
figure; imshow(XCL,[]); title('Semi-Supervised Normalized Cuts with only CL Constraints');

%% compute Semi-Supervised Normalized Cuts using both ML and CL constraints 
fprintf('Computing Semi-Supervised NCut with ML and CL constraints...\n');
tic; YSS = semiSupervisedNormCut(A,2,ML,gamma(1),CL,gamma(2),[],constrInd); t = toc;
YSS = YSS.*sign(YSS(ind1(1)));
fprintf('\t Elapsed time: %g s\n',t);

% interpolate results to pixel grid
fprintf('Interpolate results to pixel grid...\n');
XSS = interpSpectraSupPix(img,spSegs,meanPosition,1,YSS);
fprintf('Done.\n');

%% display results
figure; imshow(XSS,[]); title('Semi-Supervised Normalized Cuts with both ML and CL Constraints');
