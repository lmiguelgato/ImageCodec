function precalc( m )
%PRECALC Precalcula y hace globales las tablas para aritmetica en GF(2^m)
%   Utiliza las funciones de MATLAB para trabajo con campos. Estas tablas 
%   se generan una sola vez al comienzo de la aplicacion, o simplemente se 
%   generan en MATLAB y se cargan como constantes en las aplicaciones que 
%   las utilicen. 
%
%   AUTHOR: Alejandro R. Lopez del Huerto (alejandro@pixeliris.com)

    global GF_ALPHA GF_TABLE_E GF_TABLE_L GF_ORDER GF_GEN_ORDER

    GF_ALPHA     = 2; % elemento primitivo
    GF_ORDER     = 2^m; % orden del campo
    GF_GEN_ORDER = GF_ORDER-1; % orden del generador
   
    % tabla de potencias
    GF_TABLE_E = zeros(1,GF_GEN_ORDER);
    for i = 1:GF_GEN_ORDER
        z = gf(2,m) ^ i;
        GF_TABLE_E(i) = z.x; 
    end
    
    % tabla de logaritmos
    GF_TABLE_L = zeros(1,GF_GEN_ORDER);
    for i = 1:GF_GEN_ORDER
        z = log(gf(i,m));
        GF_TABLE_L(i) = z; 
    end
    %Cuando decidas pasar a Java y tengas fijo CodewordLength_N_BCH, salvas estas tablas variables globales
    % en un txt y no las generas desde matlab sino que copias esos valores
    % dentro de la apk java
    
end
