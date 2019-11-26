function [B, Bm, P] = image2bits( I, P )
% Convert a digital image into raw bits.
%
% @input:   I, a digital image (three or two-dimensional matrix).
%           P, the desired quantization order (number of bits per pixel) 
%              per channel (e.g. R, G and B).
%
% @output:  B, a binary matrix composed of the image into bits.
%           P, the definitive quantization order (number of bits per pixel)
%              per channel (e.g. R, G and B).
%           
% @author:  Luis M. Gato, lmiguelgato@gmail.com

P_default = 8;

if isa(I, 'uint16')
    P_default = 16;
elseif isa(I, 'logical')
    P_default = 1;
end

if nargin == 1
    P = P_default;      % default quantization order
end

if P < P_default
    P = P_default;
    warning(['The quantization order is too small. Changed to ' ...
        num2str(P_default) ' bits.'])
end

[M, N, L] = size(I);
B = zeros(P*M*N, L);
Bm = zeros(P, M*N, L);

for l = 1:L
    temp = dec2bin(I(:,:,l), P)';
    B(:, l) = temp(:) - 48;
    Bm(:, :, l) = temp - 48;
end

end