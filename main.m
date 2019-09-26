%% @brief:  Final project of Digital Signal Transmission, Master on Digital
%           Signal Processing, School of Engineering, UNAM, 2019.
%
% @use:     Select a digital image, which will be encoded, contaminated
%           with noise, and then decoded. The objective is to verify the
%           performance of some channel coding schemes for error detection 
%           and error correction. Compare the restored image with the
%           original, and verify the improvement in signal-to-noise ratio 
%           and in bit error rate when using channel coding.
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
image_dim = M*N*L;

%% convert image to a matrix of raw bits:
disp('Converting image to raw bits ...')
[B, P] = image2bits(I.data);

%% channel coding:
% Hamming
m = 3;                      % the smaller the better error correction, but 
                            % the lower code efficiency
[h,g,n,k] = hammgen(m);

message_len = M*N*P;
coded_len   = ceil(message_len*n/k);
C = zeros(coded_len, L);

% zero padding, if needed:
extra_len = mod(message_len, k);
if extra_len ~= 0
    B = cat(1, B, zeros(k-extra_len, L));
end

disp(['Hamming encoder using polynomial ' textpoly(gfprimdf(m)) ' ...'])
num_of_blocks = ceil(message_len/k);
for l = 1:L
    for b = 1:num_of_blocks
        C((b-1)*n+1:b*n, l) = rem(B((b-1)*k+1:b*k, l)'*g, 2);
    end
end

%% channel model:
disp('Modeling channel ...')
ber = 5e-3;                             % bit error rate
C_r = bsc(C, ber);                      % binary symmetric channel
[numerrs, pcterrs] = biterr(C, C_r);    % number of errors and actual ber

%% channel decoding:
trt = syndtable(h);         % truth table.

disp('Hamming decoder ...')
ber_d = 0;
B_r = zeros(size(B));
B_d = zeros(size(B));
for l = 1:L
    for b = 1:num_of_blocks
        B_r((b-1)*k+1:b*k, l) = C_r((b-1)*n+m+1:b*n, l);
        syndrome = rem(C_r((b-1)*n+1:b*n, l)' * h', 2);
        % error location:
        err = bi2de(fliplr(syndrome));
        err_loc = trt(err + 1, :);
        ber_d = ber_d + sum(err_loc);
        % corrected code
        ccode = rem(err_loc + C_r((b-1)*n+1:b*n, l)', 2);
        B_d((b-1)*k+1:b*k, l) = ccode(m+1:n);
    end
end
ber_d = (numerrs-ber_d)/message_len;

%% recover image from a matrix of raw bits:
disp('Converting raw bits to image ...')
I_r = bits2image( B_r, [M, N], P );
I_d = bits2image( B_d, [M, N], P );

disp(' ')
disp('Results:')
if sum(sum(sum(I_r == I.data))) == image_dim
    disp('Perfect image recovery. No errors found.')
else
    image_peak = double((max(max(max(I.data)))).^2);
    mse_i = sum(sum(sum((I.data - I_r).^2)))/image_dim;
    SNR_i = 10*log10(image_peak/mse_i);

    if sum(sum(sum(I_d == I.data))) == image_dim
        disp('Perfect image recovery. All errors were corrected!')
        disp(['Input SNR = ' num2str(SNR_i) ' dB'])
        disp(' ')
        disp(['Input BER = ' num2str(pcterrs)])
        disp(['Output BER = ' num2str(ber_d)])
    else
        mse_o = sum(sum(sum((I.data - I_d).^2)))/image_dim;
        SNR_o = 10*log10(image_peak/mse_o);
        disp('Image recovered with errors.')
        disp(['Input SNR = ' num2str(SNR_i) ' dB'])
        disp(['Output SNR = ' num2str(SNR_o) ' dB'])
        disp(' ')
        disp(['Input BER = ' num2str(pcterrs)])
        disp(['Output BER = ' num2str(ber_d)])
    end
end

figure('units','normalized','outerposition',[0 0 1 1])
subplot 121
image([1 N], [1 M], I_r);
title(['Without channel coding: BER = ' num2str(pcterrs)])

subplot 122
image([1 N], [1 M], I_d);
title(['With Hamming(' num2str(n) ',' num2str(k) ') channel coding: BER = ' num2str(ber_d)])
