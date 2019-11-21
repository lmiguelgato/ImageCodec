function r = gfadd( a, b )
%GFADD Suma sobre el campo GF(2^m)
%   Ver http://en.wikipedia.org/wiki/Finite_field_arithmetic
%
%   AUTHOR: Alejandro R. Lopez del Huerto (alejandro@pixeliris.com)
    r = bitxor(a,b);
end

