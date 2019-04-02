function A = blockProcessLGF(X, K, k)
%
%   X = hyperspectral image
%   K = radius of sliding window
%   k = number of adjacent pixels
%

[R,C,T] = size(X);

% reshape 145x145 image to column vector
X_Spec = reshape(X, [R*C T]);

% do pca on the hs data, multiply to find pc, back to image sizes
X_Spec = reshape(X_Spec * pca(X_Spec), [R C T]);

% first three terms of pca are 97% of signal energy
p = 4; % p=4 principle components (PC)
M = 3; % M=3 morphological operations per PC
D = p * (2 * M + 1);
X_Spec = X_Spec(:,:,1:p);

% var to hold final stackup
% order: pca1,op1,op2,op3,clo1,clo2,clo3,pca2,op1,op2...
X_Spat = [];

for i = 1:size(X_Spec, 3)
    I = X_Spec(:, :, i); % orig pca image
    X_Spat(:, :, (i - 1) * (2 * M + 1) + 1) = I;
 
    % 3 openings and 3 closings
    m = 2; % counter
    for nS = 2:2:6
        % crete SE for morpho operations
        se = strel('diamond', nS);

        % perform an opening
        I = imopen(X_Spec(:, :, i), se);
        X_Spat(:, :, (i - 1) * (2 * M + 1) + m) = I;
        
        % perform a closing
        I = imclose(X_Spec(:, :, i), se);
        X_Spat(:, :, (i - 1) * (2 * M + 1) + m + 3) = I;
        m = m + 1;
    end
end

% normalize spec and spat to same interval [0,1]
X_Spat = X_Spat ./ max(max(X_Spat));
X_Spec = X_Spec ./ max(max(X_Spec));

% concatenate spectral and spatial features
X_Sta = cat(3, X_Spec, X_Spat);

% convert 3D matrix into a 2D matrix with one row per pixel
X_Sta = reshape(X_Sta, [R*C size(X_Sta,3)]);

% prefill adjacency matrix indicating neighbors inside 2K+1 x 2K+1 window
A = zeros(R*C, R*C);
index = 1;
for c=1:R
    for r=1:C
        W = -ones(R,C);
        W(max(r-K,1):min(r+K,R),max(c-K,1):min(c+K,C)) = 1;
        A(index,:) = W(:)';
        index = index+1;
    end;
end;

% now process each row (pixel by pixel)
for r = 1:size(A,1)
    % get the spatial and spectral signature of
    % the current pixel at the center of the window
    x = X_Sta(r,:);
    
    % find just the pixels inside the sliding window
    L = find(A(r,:) == 1);
    
    % initialize the cost vector for all pixels in the sliding window
    Da = zeros(size(L));
    Db = zeros(size(L));
    
    % get the distances for each pixel in the sliding window
    for l=1:length(L)
        y = X_Sta(L(l),:);
        d = (x-y).^2;
        Da(l) = sqrt(sum(d(1:4)));
        Db(l) = sqrt(sum(d(5:end)));
    end;
   
    % find the kNN in each distance vector
    [da, i] = sort(Da);
    Da = 0 * Da;
    Da(i(1:k)) = 1;
    
    [db, i] = sort(Db);
    Db = 0 * Db;
    Db(i(1:k)) = 1;

    % write back the distances to the adjacency matrix
    A(r,L) = Da .* Db;
end;

return;
