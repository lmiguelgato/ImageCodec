function s = calcsynd( r, n, t )
%CALCSYND Calcula el vector de sindromes
%   Ver explicacion y diagrama de flujo en:
%   Communications System Toolbox -> User's Guide -> System Design -> Error
%   Detection and Correction -> BCH Codes
%
%   AUTHOR: Alejandro R. Lopez del Huerto (alejandro@pixeliris.com)

    global GF_TABLE_E

    s = zeros(1, 2*t);
    
    for j = 1:2*t
        k = 2*t-j+1;
        for i = 1:n, s(k) = gfadd(s(k), gfmul(r(i), gfexp2(GF_TABLE_E(j),i-1))); end
    end

end
