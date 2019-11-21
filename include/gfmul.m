function r = gfmul(a, b)
%GFMUL Multiplicacion sobre el campo GF(2^m)
%   Ver http://en.wikipedia.org/wiki/Finite_field_arithmetic
%
%   AUTHOR: Alejandro R. Lopez del Huerto (alejandro@pixeliris.com)

    global GF_TABLE_E GF_TABLE_L GF_GEN_ORDER

    if (a==0 || b==0) 
        r = 0;
    else
        r = GF_TABLE_L(a) + GF_TABLE_L(b);
        if r>GF_GEN_ORDER, r = r-GF_GEN_ORDER; end
        if (r>0)
            r = GF_TABLE_E(r);
        else
            r = 1;
        end
    end
end
