function [B_d, B_r, ber_d] = bch_decoder(n, k, C_r)
% Hamming decoder.
%
% @input:   n, number of encoded bits per block.
%           k, number of message bits per block.
%           C_r, BCH-encoded binary matrix.
%
% @output:  B_d, decoded binary matrix (after error correction).
%           B_r, decoded binary matrix (before error correction).
%           ber_d, bit error rate (detected errors only).
%           
% @author:  Luis M. Gato, lmiguelgato@gmail.com

L = size(C_r, 2);
num_of_blocks = size(C_r, 1)/n;
B_d = zeros(num_of_blocks*k, L);
B_r = zeros(size(B_d));
t = bchnumerr(n,k);
m = log2(n+1);

decoded = zeros(num_of_blocks, k);
cnumerr = zeros(num_of_blocks, 1);
ccode   = zeros(num_of_blocks, n);

ber_d = 0;
for l = 1:L
    tmp = vec2mat(C_r(:,l), n);
    tmp1 = tmp(:, 1:k)';
    B_r(:,l) = tmp1(:);
    
    code = gf(tmp, m);    
    for j = 1 : num_of_blocks
    
        % Call to core algorithm BERLEKAMP
        inputCode    = code(j,:);
        inputCodeVal = inputCode.x;
        b            = 1;  % narrow-sense codeword
        shortened    = 0;  % no shortened codewords
        inWidth      = length(code(j,:));
        [decodedInt, cnumerr(j), ccodeInt] = ...
        berlekamp(inputCodeVal, n, k, m, t, b, shortened, inWidth);

        decoded(j,:) = decodedInt;
        ccode(j,:)   = ccodeInt;
        
        B_d((j-1)*k+1:j*k, l) = decodedInt;
    end
    ber_d = ber_d + sum(cnumerr);
end

end

