function bigstruct = select_weight(bigstruct, weight, samesex)
poids = [bigstruct.poids];
sexe = [bigstruct.sexe];

switch samesex
    case 2 % women vs women
        bigstruct = hackweight(bigstruct,weight,samesex);
    case 1 % men vs men
        bigstruct = hackweight(bigstruct,weight,samesex);
    case 0 % men vs women
        todelete_m = poids ~= weight(1) & sexe == 1; % men
        todelete_w = poids ~= weight(2) & sexe == 2; % women
        
        todelete = todelete_m + todelete_w;
        
        bigstruct(logical(todelete)) = [];
    otherwise
        error('please, choose  ''samesex'' [0, 1 (men) or 2 (women)]')
end
end

function bigstruct = hackweight(bigstruct,weight,samesex)
% This function replace the sex with the opposite when the weight is different. This
% allows to keep the current code to run SPM on the same sex, such as :
% men 12 kg vs men 6 kg | women 12 kg vs women 6 kg
if samesex == 2
    todelete = [bigstruct.sexe] == 1; % delete men
elseif samesex == 1
    todelete = [bigstruct.sexe] == 2 | [bigstruct.poids] == 18; % delete women and 18 kg
else
    error('debug.')
end

bigstruct(logical(todelete)) = [];

change_weight_1 = [bigstruct.poids] == weight(1);
change_weight_2 = [bigstruct.poids] == weight(2);

[bigstruct(logical(change_weight_1)).sexe] = deal(1); % men = weight(1)
[bigstruct(logical(change_weight_2)).sexe] = deal(2); % women = weight (2)
end

