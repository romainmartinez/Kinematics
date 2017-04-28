function isbalanced(sex)
women = sum(sex == 2)/36;
men = sum(sex == 1)/36;

if women ~= men
    error('Number of participants is not balanced: please add names in the blacklist')
end

