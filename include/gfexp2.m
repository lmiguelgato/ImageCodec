function r = gfexp2(a, e)
%GFEXP2 Exponenciacion sobre el campo GF(2^m)
%   Ver http://en.wikipedia.org/wiki/Finite_field_arithmetic
%
%   AUTHOR: Alejandro R. Lopez del Huerto (alejandro@pixeliris.com)

    global GF_TABLE_E GF_TABLE_L GF_GEN_ORDER
   
    z = mod(e*GF_TABLE_L(a), GF_GEN_ORDER);
    if (e == 0 || z == 0)
        r = 1;
    else
        r = GF_TABLE_E(z);
    end
    
end

