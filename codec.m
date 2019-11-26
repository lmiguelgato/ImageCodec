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

codingScheme = 2;   % 1 for Hamming, 2 for BCH

%% loading and pre-processing image:
[I.name, I.path] = uigetfile({ '*.jpeg;*.jpg;*.jpe', ...
    'JPEG (*.jpeg, *.jpg, *.jpe)'; '*.bmp;*.dib', ...
    'Windows BMP (*.bmp, *.dib)'; '*.gif', 'GIF (*.gif)'; ...
    '*.png', 'PNG (*.png)'; '*.svg', 'SVG (*.svg)'; ...
    '*.pbm', 'PBM (*.pbm)'; '*.pgm', 'PGM (*.pgm)'}, ...
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
tic;
[B, ~, P] = image2bits(I.data);
dt = toc;
disp([num2str(dt) ' s'])
message_len = size(B,1);    % M*N*P x 1

%% channel coding:
switch codingScheme
    case 1
        % Hamming encoder
        m = 3;              % the smaller the better error correction, but
                            % the lower code efficiency
        disp(['Hamming encoder using polynomial ' ...
            textpoly(gfprimdf(m)) ' ...'])
        tic;
        [B, C, k, n, h, num_of_blocks] = hamming_encoder(m, B);
        disp(['Coder efficiency:  ' num2str(k/n)])
        dt = toc;
        disp([num2str(dt) ' s'])
    case 2
        % BCH encoder
        m = 6;
        k = 10;       % Message length
        n = 2^m-1;   % Codeword length
        t = bchnumerr(n,k);
        disp(['BCH encoder using polynomial ' ...
            textpoly(bchgenpoly(n,k)) ' ...'])
        disp(['Error-correction capability:  ' num2str(t)])
        disp(['Coder efficiency:  ' num2str(k/n)])
        tic;
        [B, C, num_of_blocks] = bch_encoder(n, k, B);
        dt = toc;
        disp([num2str(dt) ' s'])
        C = logical(C.x);
end

%% channel model:
disp('Modeling channel ...')
tic;
ber = 1e-1;                             % bit error rate
C_r = bsc(C, ber);                      % binary symmetric channel
[numerrs, pcterrs] = count_errors(C, C_r);    % number of errors and actual ber
dt = toc;
disp([num2str(dt) ' s'])

%% channel decoding:
switch codingScheme
    case 1
        disp('Hamming decoder ...')
        tic;
        [B_d, B_r, ber_d] = hamming_decoder(h, C_r);
        ber_d = (numerrs-ber_d)/message_len;
        dt = toc;
        disp([num2str(dt) ' s'])
    case 2
        disp('BCH decoder ...')
        tic;
        [B_d, B_r, ber_d] = bch_decoder(n, k, C_r);
        ber_d = (numerrs-ber_d)/message_len;
        dt = toc;
        disp([num2str(dt) ' s'])
end

%% recover image from a matrix of raw bits:
disp('Converting raw bits to image ...')
tic;
I_r = bits2image( B_r, [M, N], P );
I_d = bits2image( B_d, [M, N], P );
dt = toc;
disp([num2str(dt) ' s'])

%% display results:
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
        disp(['Input BER  = ' num2str(pcterrs)])
        disp(['Output BER = ' num2str(ber_d)])
    else
        mse_o = sum(sum(sum((I.data - I_d).^2)))/image_dim;
        SNR_o = 10*log10(image_peak/mse_o);
        disp('Image recovered with errors.')
        disp(['Input SNR  = ' num2str(SNR_i) ' dB'])
        disp(['Output SNR = ' num2str(SNR_o) ' dB'])
        disp(' ')
        disp(['Input BER  = ' num2str(pcterrs)])
        disp(['Output BER = ' num2str(ber_d)])
    end
end

figure('units','normalized','outerposition',[0 0 1 1])
subplot 121
imshow(I_r)
title(['Without channel coding: BER = ' num2str(pcterrs)])

subplot 122
imshow(I_d)

switch codingScheme
    case 1        
        title(['With Hamming(' num2str(n) ',' ...
        num2str(k) ') channel coding: BER = ' num2str(ber_d)])
    case 2
        title(['With BCH(' num2str(n) ',' ...
        num2str(k) ') channel coding: BER = ' num2str(ber_d)])
end

figure
imshow(I.data)
title('Original image')