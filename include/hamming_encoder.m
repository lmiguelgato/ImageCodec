function [B, C, k, n, h, num_of_blocks] = hamming_encoder(m, B)
% Hamming encoder.
%
% @input:   m, number of redundancy bits.
%           B, binary matrix to be Hamming-encoded.
%
% @output:  B, binary matrix to be Hamming-encoded (resized).
%           C, Hamming-encoded binary matrix.
%           k, number of message bits per block.
%           n, number of encoded bits per block.
%           h, parity check matrix.
%           num_of_blocks, number of Hamming-encoded blocks.
%           
% @author:  Luis M. Gato, lmiguelgato@gmail.com

L  = size(B, 2);

[h,g,n,k] = hammgen(m);

message_len = size(B, 1);
coded_len   = ceil(message_len/k)*n;
C = zeros(coded_len, L);

% zero padding, if needed:
extra_len = mod(message_len, k);
if extra_len ~= 0
    B = cat(1, B, zeros(k-extra_len, L));
end

num_of_blocks = ceil(message_len/k);
for l = 1:L
    tmp = rem(vec2mat(B(:,l), k)*g, 2)';
    C(:,l) = tmp(:);
end
end

