function T = textpoly( P )
% Represent coding polynomial as text.
%
% @input:   P, a binary vector of polynomial coefficients.
%
% @output:  T, the polynomial represented as text.
%           
% @author:  Luis M. Gato, lmiguelgato@gmail.com

m = length(P) - 1;

T = '';
for i = m+1:-1:3
    if P(m-i+2) == 1
       T =  strcat(T, ['D^' num2str(i-1) '+']);
    end
end
if P(m) == 1
    T =  strcat(T, 'D+');
end
if P(m+1) == 1
    T =  strcat(T, '1');
else
    T = T(1:end-1);
end

end

