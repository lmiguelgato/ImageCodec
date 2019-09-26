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

B = image2bits(I.data);
