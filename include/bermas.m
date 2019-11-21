function [ L, epos ] = bermas( code, codelen, t )
%BERMAS Algoritmo Berlekamp-Massey
%   Ver explicacion y diagrama de flujo en:
%   Communications System Toolbox -> User's Guide -> System Design -> Error
%   Detection and Correction -> BCH Codes
%   NOTA: Todas las operaciones se hacen sobre el campo GF(2^m)
%
%   AUTHOR: Alejandro R. Lopez del Huerto (alejandro@pixeliris.com)

    m = log2(codelen+1);
    precalc(m); % precalcular las tablas para la aritmetica sobre el campo

    %tic % comenzar a contar el tiempo de decodificacion
    
    S = calcsynd( code, codelen, t ); % calcular el vector sindrome
    
    L = 0;
    k = -1;
    lambda = zeros(1,2*t);
    D = zeros(1,2*t);
    
    lambda(1) = 1;
    D(2) = 1;
    
    for n = 0:2*t-1
        d = 0;
        for i = 0:L, d = gfadd( d, gfmul( lambda(i+1), S(n-i+1) ) ); end
        
        if (d ~= 0)
            lambda2 = zeros(1,2*t);
            for i = 1:2*t, lambda2(i) = gfsub( lambda(i), gfmul(d,D(i)) ); end
            if (L < n-k)
                LL = n-k;
                k = n-L;
                D = lambda;
                for i = 1:2*t, D(i) = gfmul( D(i), gfminv(d) ); end
                L = LL;
            end
            lambda = lambda2;
        end
        D(2:2*t) = D(1:2*t-1);
        D(1) = 0;
    end
   
    epos = sort(gfroots2(lambda(1:L+1)));   % la posicion de los errores son el
                                            % inverso de las raices del polinomio lambda
                                         
    if (length(epos) ~= L)                  % si la cantidad de raices no coincide con la cantidad de errores
        L = -1;                             % se asume que hay mas errores de lo que se puede corregir
        epos = [];
    end
    
    %toc
end

