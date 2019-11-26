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
[B, Bm, P] = image2bits(I.data);
dt = toc;
disp([num2str(dt) ' s'])

if P ~= 8 || L ~= 1
    disp('Codec by layers only supports 8-level gray images.')
    if P ~= 8
        disp(['The selected image has ' num2str(P) ' levels.'])
    end
    if L ~= 1
        disp('The selected image is not gray-scaled.')
    end
    disp('Quitting ...')
    return;
end

message_len = size(B,1);    % M*N*P x 1

%% channel coding:
CL = [];
Ltx = zeros(P, 1);
L0 = zeros(P, 1);
switch codingScheme
    case 1
        % Hamming encoder
        m = [2 2 2 2 3 3 4 4];
        for p = 1:P
            if m(p) == 0
                disp(['Layer ' num2str(p) ' left uncoded'])
                CL = [CL; Bm(p,:)'];
                Ltx(p) = length(Bm(p,:));
                L0(p) = length(Bm(p,:));
            else
                disp(['Hamming encoder on layer ' num2str(p) ...
                    ' using polynomial ' textpoly(gfprimdf(m(p))) ' ...'])
                tic;
                [B, C, k, n, h, ~] = hamming_encoder(m(p), Bm(p,:)');
                CL = [CL; C];
                Ltx(p) = length(C);
                L0(p) = length(B);
                disp(['Coder efficiency:  ' num2str(k/n)])
                dt = toc;
                disp([num2str(dt) ' s'])
            end
        end
    case 2
        % BCH encoder
        m = [6 6  6 5  5  5 0 0 0];
        k = [7 7 10 6 11 21 0 0 0];     % Message length
        
        %m = [6 6 6 6 6 0 0 0];
        %k = [7 7 7 7 7 0 0 0];         % Message length
        
        n = 2.^m-1;   % Codeword length
        
        for p = 1:P
            if m(p) == 0
                disp(['Layer ' num2str(p) ' left uncoded'])
                CL = [CL; Bm(p,:)'];
                Ltx(p) = length(Bm(p,:));
                L0(p) = length(Bm(p,:));
            else
                t = bchnumerr(n(p),k(p));
                disp(['BCH encoder on layer ' num2str(p) ...
                    ' using polynomial ' ...
                    textpoly(bchgenpoly(n(p),k(p))) ' ...'])
                disp(['Error-correction capability:  ' num2str(t)])
                disp(['Coder efficiency:  ' num2str(k(p)/n(p))])
                tic;
                [B, C, ~] = bch_encoder(n(p), k(p), Bm(p,:)');
                C = logical(C.x);
                CL = [CL; C];
                Ltx(p) = length(C);
                L0(p) = length(B);
                dt = toc;
                disp([num2str(dt) ' s'])
            end
        end        
end

%% channel model:
disp('Modeling channel ...')
tic;
ber = 1e-1;             % desired bit error rate
CL_r = bsc(CL, ber);    % binary symmetric channel
[numerrs, pcterrs] = count_errors(CL, CL_r); % number of errors, actual ber
dt = toc;
disp([num2str(dt) ' s'])

%% channel decoding:
BLd = [];
BLr = [];
switch codingScheme
    case 1
        disp('Hamming decoder ...')
        Ltx_cum = cumsum(Ltx);
        startDecod = 1;
        ber_d = 0;
        for p = 1:P
            if m(p) ~= 0
                disp(['Decoding layer ' num2str(p) ' ...'])
                tic;
                [h,g,n,k] = hammgen(m(p));
                [B_d, B_r, ber_p] = ...
                    hamming_decoder(h, CL_r(startDecod:Ltx_cum(p)));
                BLd = [BLd; B_d];
                BLr = [BLr; B_r];
                dt = toc;
                disp([num2str(dt) ' s'])
            else
                ber_p = 0;
                BLd = [BLd; CL_r(startDecod:Ltx_cum(p))];
                BLr = [BLr; CL_r(startDecod:Ltx_cum(p))];
            end
            startDecod = Ltx_cum(p)+1;  
            ber_d = ber_d + ber_p;
        end
        ber_d = (numerrs-ber_d)/message_len;
    case 2
        disp('BCH decoder ...')
        Ltx_cum = cumsum(Ltx);
        startDecod = 1;
        ber_d = 0;
        for p = 1:P
            if m(p) ~= 0
                disp(['Decoding layer ' num2str(p) ' ...'])
                tic;
                [B_d, B_r, ber_p] = ...
                    bch_decoder(n(p), k(p), CL_r(startDecod:Ltx_cum(p)));
                BLd = [BLd; B_d];
                BLr = [BLr; B_r];
                dt = toc;
                disp([num2str(dt) ' s'])
            else
                ber_p = 0;
                BLd = [BLd; CL_r(startDecod:Ltx_cum(p))];
                BLr = [BLr; CL_r(startDecod:Ltx_cum(p))];
            end
            startDecod = Ltx_cum(p)+1;  
            ber_d = ber_d + ber_p;
        end
        ber_d = (numerrs-ber_d)/message_len;
end

%% recover image from a matrix of raw bits:
disp('Converting raw bits to image ...')
tic;
B_r = [];
B_d = [];
startDecod = 1;
L0_cum = cumsum(L0);
for p = 1:P
    temp = BLr(startDecod:L0_cum(p));    
    B_r = [B_r, temp(1:M*N)];
    temp = BLd(startDecod:L0_cum(p));    
    B_d = [B_d, temp(1:M*N)];
    startDecod = L0_cum(p)+1;
end
B_r = B_r';
B_d = B_d';

I_r = bits2image( B_r(:), [M, N], P );
I_d = bits2image( B_d(:), [M, N], P );
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
        
        figure('units','normalized','outerposition',[0 0 1 1])
        subplot 121
        imshow(I_r)
        title(['No channel coding: SNR = ' num2str(round(SNR_i)) ...
            ' dB (BER = ' num2str(pcterrs) ')'])

        subplot 122
        imshow(I_d)
        switch codingScheme
            case 1        
                title(['Hamming channel coding (by layers): ' ...
                    'SNR = \infty dB (BER = ' num2str(ber_d) ')'])
            case 2
                title(['BCH channel coding (by layers): ' ...
                    'SNR = \infty dB (BER = ' num2str(ber_d) ')'])
        end
    else
        mse_o = sum(sum(sum((I.data - I_d).^2)))/image_dim;
        SNR_o = 10*log10(image_peak/mse_o);
        disp('Image recovered with errors.')
        disp(['Input SNR  = ' num2str(SNR_i) ' dB'])
        disp(['Output SNR = ' num2str(SNR_o) ' dB'])
        disp(' ')
        disp(['Input BER  = ' num2str(pcterrs)])
        disp(['Output BER = ' num2str(ber_d)])
        
        figure('units','normalized','outerposition',[0 0 1 1])
        subplot 121
        imshow(I_r)
        title(['No channel coding: SNR = ' num2str(round(SNR_i)) ...
            ' dB (BER = ' num2str(pcterrs) ')'])

        subplot 122
        imshow(I_d)
        switch codingScheme
            case 1        
                title(['Hamming channel coding (by layers): SNR = ' ...
                   num2str(round(SNR_o)) ' dB (BER = ' num2str(ber_d) ')'])
            case 2
                title(['BCH channel coding (by layers): SNR = ' ... 
                   num2str(round(SNR_o)) ' dB (BER = ' num2str(ber_d) ')'])
        end
    end
end

figure
imshow(I.data)
title('Original image')