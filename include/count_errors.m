function [num, ratio] = count_errors(A, B)


num = sum(abs(A-B));
ratio = num/length(A);
end

