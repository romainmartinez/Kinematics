function isbalanced(sex)
women = sum(sex == 2)/6;
men = sum(sex == 1)/6;

if women ~= men
    error('Number of participants is not balanced: please add names in the blacklist')
end

