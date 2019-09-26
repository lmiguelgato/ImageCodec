function B = image2bits( I )

% Convert a digital image into raw bits.
%
% @input:   I, a digital image (three or two-dimensional matrix).
%
% @output:  B, a binary matrix composed of the image into bits.

[M, N, L] = size(I);
B = zeros(8*M*N, L);

for l = 1:L
    temp = dec2bin(I(:,:,l), 8)';
    B(:, l) = temp(:) - 48;
end

end

