% script to setup data and run blockProcessLGF.m
% 

load datasets/Indian_pines.mat

% make subset of data for quickness of testing 
x = indian_pines(1:32,1:32,:);
[N,M] = meshgrid([1:size(x,2)],[1:size(x,1)]);

A = blockProcessLGF(x, 3, 5);

%%% A = graph weight matrix
%%% M = row coordinate of graph nodes
%%% N = col coordinate of graph nodes
G = graph(A > 0, 'upper');

%%% now visualize the graph
figure(1);
plot(G);

%%% visualize the connections between pixels
figure(2);
imagesc(x(:,:,1));
colormap(gray());
hold on;
h = plot(G, 'XData', N(:),'YData', M(:));
set(h, 'linewidth', 2);
