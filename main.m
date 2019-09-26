%% @brief:  Final project of Digital Signal Transmission, Master on Digital
%           Signal Processing, School of Engineering, UNAM, 2019.
%
% @use:     Select a digital image, which will be encoded, contaminated
%           with noise, and then decoded. The objective is to verify the
%           performance of some channel coding schemes for error detection 
%           and error correction. Compare the restored image with the
%           original, and verify the signal to noise ratio with and without
%           channel coding.
%
% @author:  Luis M. Gato, lmiguelgato@gmail.com

%% clean workspace and include dependencies:
close all
clear
clc

addpath('include')

%% loading and pre-processing image:
[I.name, I.path] = uigetfile({ '*.jpeg;*.jpg;*.jpe', 'JPEG (*.jpeg, *.jpg, *.jpe)'; '*.bmp;*.dib', 'Windows BMP (*.bmp, *.dib)'; '*.gif', 'GIF (*.gif)'; '*.png', 'PNG (*.png)'; '*.svg', 'SVG (*.svg)'; '*.pbm', 'PBM (*.pbm)'; '*.pgm', 'PGM (*.pgm)'}, ...
    'Select an image.', './input');

if (isequal(I.name,0) || isequal(I.path,0))
   disp('No valid image file was selected. Quitting ...')
   return;
end

I.data = imread([I.path I.name]);

[M, N, L] = size(I.data);

figure('Position', [100 100 N M])
image([1 N], [1 M], I.data);

%% convert image to a matrix of raw bits:
disp('Converting image to raw bits ...')
[B, P] = image2bits(I.data);

%% channel coding:
% Hamming
m = 3;
[h,g,n,k] = hammgen(m);

disp(['Hamming polynomial: ' textpoly(gfprimdf(m))])

message_len = M*N*P;
coded_len   = ceil(message_len*n/k);
C = zeros(coded_len, L);

extra_len = mod(message_len, k);
if extra_len ~= 0
    B = cat(1, B, zeros(extra_len, L));
end

disp('Hamming encoder ...')
num_of_blocks = ceil(message_len/k);
for l = 1:L
    for b = 1:num_of_blocks
        C((b-1)*n+1:b*n, l) = mod(B((b-1)*k+1:b*k, l)'*g, 2);
    end
end

%% recover image from a matrix of raw bits:
disp('Converting raw bits to image ...')
I_r = bits2image( B, [M, N], P );

if sum(sum(sum(I_r == I.data))) == M*N*L
    disp('Perfect image recovery!')
end










