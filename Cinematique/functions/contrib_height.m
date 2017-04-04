function [Data] = contrib_height(Data)

HipsEyes = [Data.hauteur] == 2;        % détecter hauteur = hips-eyes
norma = vertcat(Data.normalization);
hips = mean(norma(HipsEyes,1));        % hauteur des hanches moyenne
eyes = mean(norma(HipsEyes,2));        % hauteur des yeux moyenne

for itrial = length(Data):-1:1
    % 1) normalisation
    Data(itrial).H = (Data(itrial).H - hips) / (eyes - hips)*100;
    
    % 2) contribution
    Data(itrial).deltahand = Data(itrial).H(:,:,1) - Data(itrial).H(:,:,2);
    Data(itrial).deltaGH = Data(itrial).H(:,:,2) - Data(itrial).H(:,:,3);
    Data(itrial).deltaSCAC = Data(itrial).H(:,:,3) - Data(itrial).H(:,:,4);
    Data(itrial).deltaRoB = Data(itrial).H(:,:,4) - Data(itrial).H(:,:,5);
end

