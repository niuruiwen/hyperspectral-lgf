% script to setup data and run blockProcessLGF.m
% 

load datasets/Indian_pines.mat

% make subset of data for quickness of testing 
x = indian_pines(1:32,1:32,:);

A = blockProcessLGF(x, 3, 5);

x=reshape(A,[32 32 1024]);

for i=1:1024
    imagesc(x(:,:,i))
    drawnow
end
