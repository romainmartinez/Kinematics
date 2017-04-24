function bigstruct = select_weight(bigstruct, weight)
poids = [bigstruct.poids];
sexe = [bigstruct.sexe];

todelete_m = poids ~= weight(1) & sexe == 1; % men
todelete_w = poids ~= weight(2) & sexe == 2; % women

todelete = todelete_m + todelete_w;

bigstruct(logical(todelete)) = [];

