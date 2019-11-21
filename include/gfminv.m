function r = gfminv( a )
%GFMINV Inverso multiplicativo sobre el campo GF(2^m)
%   Ver http://en.wikipedia.org/wiki/Finite_field_arithmetic
%
%   AUTHOR: Alejandro R. Lopez del Huerto (alejandro@pixeliris.com)

    global GF_TABLE_E GF_TABLE_L GF_GEN_ORDER

    r = GF_TABLE_E(GF_GEN_ORDER - GF_TABLE_L(a));
end

