function [B, C, num_of_blocks] = bch_encoder(n, k, B)
% BCH encoder.
%
% @input:   n, number of encoded bits per block.
%           k, number of message bits per block.
%           B, binary matrix to be BCH-encoded.
%
% @output:  B, binary matrix to be BCH-encoded (resized).
%           C, BCH-encoded binary matrix.
%           num_of_blocks, number of BCH-encoded blocks.
%           
% @author:  Luis M. Gato, lmiguelgato@gmail.com

message_len = size(B, 1);
L  = size(B, 2);

% zero padding, if needed:
extra_len = mod(message_len, k);
if extra_len ~= 0
    B = cat(1, B, zeros(k-extra_len, L));
end

num_of_blocks = ceil(message_len/k);
coded_len   = ceil(message_len/k)*n;

C = gf(zeros(coded_len, L));

for l = 1:L
    tmp = vec2mat(B(:,l)', k);
    tmp1 = bchenc(gf(tmp), n, k, 'beginning');
    C(:, l) = tmp1(:);
end

end

