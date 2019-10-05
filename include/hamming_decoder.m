function [B_d, B_r, ber_d] = hamming_decoder(h, C_r)
% Hamming decoder.
%
% @input:   h, parity check matrix.
%           C_r, Hamming-encoded binary matrix.
%
% @output:  B_d, decoded binary matrix (after error correction).
%           B_r, decoded binary matrix (before error correction).
%           ber_d, bit error rate (detected errors only).
%           
% @author:  Luis M. Gato, lmiguelgato@gmail.com

trt = syndtable(h);         % truth table.
m = size(h, 1);
n = size(h, 2);
ber_d = 0;
L = size(C_r, 2);
B_r = zeros(size(C_r, 1)/n*(n-m), L);
B_d = zeros(size(B_r));
pow2vector = flip(2.^(0:m-1))';
ht = h';
for l = 1:L
    tmp = vec2mat(C_r(:,l), n);
    tmp1 = tmp(:, m+1:n)';
    B_r(:,l) = tmp1(:);
    syndrome = rem(tmp * ht, 2);
    % error location:
    err = syndrome * pow2vector;
    err_loc = trt(err + 1, :);
    ber_d = ber_d + sum(sum(err_loc));
    % corrected code:
    ccode = rem(err_loc + tmp, 2);
    tmp = ccode(:, m+1:n)';
    B_d(:,l) = tmp(:);
end

end

