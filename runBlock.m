% script to setup data and run blockProcessLGF.m
% 

load datasets/Indian_pines.mat

% make subset of data for quickness of testing 
x = indian_pines(1:32,1:32,:);

A = blockProcessLGF(x, 5, 5);