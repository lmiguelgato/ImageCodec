function I = bits2image( B, MN, P )
% Recover a digital image from a matrix of raw bits.
%
% @input:   B, a binary matrix composed of the image into bits.
%           MN = [M, N], number of rows (M) and columns (N) of the image.
%           P, the image quantization order (number of bits per pixel) per
%               channel (e.g. R, G and B).
%
% @output:  I, a digital image (three or two-dimensional matrix).
%           
% @author:  Luis M. Gato, lmiguelgato@gmail.com

L = size(B, 2);
M = MN(1);
N = MN(2);

I = zeros(M, ceil(size(B, 1)/M/P), L);
twos = pow2(P-1:-1:0)';
for l = 1:L
    tmp = vec2mat(B(:,l), P);
    I(:, :, l) = vec2mat(tmp*twos, M)';
end

switch P
    case 8
        I = uint8(I);
    case 16
        I = uint16(I);
    case 1
        I = logical(I);
    otherwise
        warning(['No matching image conversion. Default to 8-bit ' ...
            'unsigned integer'])
        I = uint8(I);
end

I = I(1:M, 1:N, :);

end