%% Matt Ruffner Jan 2019
% hyperspectral local graph fusion

% load indian pines dataset
load datasets\Indian_pines.mat

% reshape 145x145 image to column vector
InP=reshape(indian_pines,[21025 220]);

% do pca on the hs data
C=pca(InP);

% multiply to find pc
InP=InP*C;

% back to image sizes
InP=reshape(InP, [145 145 220]);

% first three terms of pca are 97% of signal energy
Emax=InP(:,:,1:3);

