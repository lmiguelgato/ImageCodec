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

ber_d = 0;
for l = 1:L
    for b = 1:num_of_blocks
        secuencia_codif = C_r((b-1)*n+1:b*n, l);
        B_r((b-1)*k+1:b*k, l) = secuencia_codif(n-k+1:n);
        [err,epos] = bermas(secuencia_codif, n, t);
        ber_d = ber_d + err;
        if (err ~= -1)
            for i = 1:err
                secuencia_codif(epos(i)) = 1 - secuencia_codif(epos(i)); % invertir bits donde se encontro error
            end
        end
        B_d((b-1)*k+1:b*k, l) = secuencia_codif(n-k+1:n);
    end
end

end

