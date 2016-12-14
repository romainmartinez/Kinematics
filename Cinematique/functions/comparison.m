function [test] = comparison(comparaison)
if comparaison == '%'
    test(1, :) = [7,  1];
    test(2, :) = [8,  2];
    test(3, :) = [10, 4];
    test(4, :) = [13, 7];
    test(5, :) = [14, 8];
    test(6, :) = [16,10];
    test(7, :) = [9,  3];
    test(8, :) = [11, 5];
    test(9, :) = [12, 6];
    test(10,:) = [15, 9];
    test(11,:) = [17,11];
    test(12,:) = [18,12];
elseif comparaison == '='
    test(1, :) = [1,  1];
    test(2, :) = [2,  2];
    test(3, :) = [4,  4];
    test(4, :) = [7,  7];
    test(5, :) = [8,  8];
    test(6, :) = [10,10];
    test(7, :) = [3,  3];
    test(8, :) = [5,  5];
    test(9, :) = [6,  6];
    test(10,:) = [9,  9];
    test(11,:) = [11,11];
    test(12,:) = [12,12];
end
end

