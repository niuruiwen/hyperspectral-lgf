%% Matt Ruffner Jan 2019
% hyperspectral local graph fusion

% load indian pines dataset
load datasets/Indian_pines.mat

% reshape 145x145 image to column vector
IndP = reshape(indian_pines, [21025 220]);

% do pca on the hs data, multiply to find pc, back to image sizes
IndP = reshape(IndP * pca(IndP), [145 145 220]);

% first three terms of pca are 97% of signal energy
p = 4; % p=4 principle components (PC)
M = 3; % M=3 morphological operations per PC
D = p * (2 * M + 1);
IndP = IndP(:, :, 1:p);
X_Spec = reshape(IndP, [21025 4])';

% var to hold final stackup
% order: pca1,op1,op2,op3,clo1,clo2,clo3,pca2,op1,op2...
X_Spat = [];

for i = 1:size(IndP, 3)
    I = IndP(:, :, i); % orig pca image
    X_Spat(:, :, (i - 1) * (2 * M + 1) + 1) = I;
 
    % 3 openings and 3 closings
    m = 2; % counter
    for nS = 2:2:6
        % crete SE for morpho operations
        se = strel('diamond', nS);
        % perform an opening
        I = imopen(IndP(:, :, i), se);
        X_Spat(:, :, (i - 1) * (2 * M + 1) + m) = I;
        % perform a closing
        I = imclose(IndP(:, :, i), se);
        X_Spat(:, :, (i - 1) * (2 * M + 1) + m + 3) = I;
        m = m + 1;
    end
end

% reshape for consistency
X_Spat = reshape(X_Spat, [21025 D])';

% normalize spec and spat to same interval [0,1]
X_Spat = X_Spat ./ max(max(X_Spat));
X_Spec = X_Spec ./ max(max(X_Spec));

% stack spectral and spatial features
X_Sta = [X_Spec; X_Spat];

% prefill adjacency matrix
A = zeros(size(X_Sta, 2), size(X_Sta, 2));

h = waitbar(0, 'Processing adjacency matrix...');
for i = 1:size(A, 1)
    waitbar(i/size(A,1), h);
    v = zeros(1,size(A,2));
    parfor j = i + 1:size(A, 2)
        v(j) = sqrt(sum(X_Sta(:, i) .* X_Sta(:, j)));
    end
    A(i,:) = v;
end
close(h);

W = eye(248);
N = 21025;
B = 220;
D = 28;
d = 100;

save('A_Sta.mat', 'A', '-v7.3');

% size of sliding window
S = 7;
% knn sliding window
NN = zeros(S);
mx = 4;
my = 4;

win = A(1:S, 1:S);

for i = 1:length(NN)
    for j = 1:length(NN)
        NN(i, j) = sqrt(sum(win(mx, my) .* win(i, j)));
    end
end
