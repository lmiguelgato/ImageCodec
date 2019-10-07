function [B_d, ber_d] = bch_decoder(n, k, C_r)
% Hamming decoder.
%
% @input:   n, number of encoded bits per block.
%           k, number of message bits per block.
%           C_r, BCH-encoded binary matrix.
%
% @output:  B_d, decoded binary matrix (after error correction).
%           ber_d, bit error rate (detected errors only).
%           
% @author:  Luis M. Gato, lmiguelgato@gmail.com

L = size(C_r, 2);
B_d = zeros(size(C_r, 1)/n*k, L);

ber_d = 0;
for l = 1:L
    tmp = vec2mat(C_r(:,l)', n);
    [tmp1, numerr] = bchdec(gf(tmp), n, k, 'beginning');
    ber_d = ber_d + numerr;
    tmp2 = tmp1.x;
    B_d(:, l) = tmp2(:);
end
end

