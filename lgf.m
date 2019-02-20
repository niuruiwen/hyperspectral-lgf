%% Matt Ruffner Jan 2019
% hyperspectral local graph fusion

% load indian pines dataset
load datasets\Indian_pines.mat

% reshape 145x145 image to column vector
IndP=reshape(indian_pines,[21025 220]);
XSpec=IndP;

% do pca on the hs data, multiply to find pc, back to image sizes
IndP=reshape(IndP*pca(IndP), [145 145 220]);

% first three terms of pca are 97% of signal energy
p=4; % p=4 principle components (PC)
M=3; % M=3 morphological operations per PC
D=p*(2*M+1);
IndP=IndP(:,:,1:p);

% var to hold final stackup
% order: pca1,op1,op2,op3,clo1,clo2,clo3,pca2,op1,op2...
XSpat=[]; 

for i=1:size(IndP,3)
    I = IndP(:,:,i); % orig pca image
    XSpat(:,:,(i-1)*(2*M+1)+1)=I;
    
    % 3 openings and 3 closings 
    m=2; % counter
    for nS=2:2:6
        % crete SE for morpho operations
        se=strel('diamond',nS);
        % perform an opening
        I=imopen(IndP(:,:,i),se);
        XSpat(:,:,(i-1)*(2*M+1)+m)=I;
        % perform a closing
        I=imclose(IndP(:,:,i),se);
        XSpat(:,:,(i-1)*(2*M+1)+m+3)=I;
        m=m+1;
    end
end
    
    
    