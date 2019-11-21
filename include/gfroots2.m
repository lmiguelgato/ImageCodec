function r = gfroots2( lambda )
%GFROOTS2 Funcion simple para hallar las raices de un polinomio sobre el
%campo GF(2^m)
%   Utiliza Chien's Search
%
%   AUTHOR: Alejandro R. Lopez del Huerto (alejandro@pixeliris.com)

	global GF_TABLE_E GF_GEN_ORDER

    n = length(lambda)-1;
    
    r = [];
    for i=0:GF_GEN_ORDER-1
        s = lambda(1);
        for j=2:n+1
            s = gfadd(s, lambda(j)); 
            lambda(j) = gfmul(GF_TABLE_E(j-1), lambda(j));
        end
        if s == 0, r = [r i+1]; end
    end

end
