function selected = verif_gui(inputData)
% verif plot
selected = [];

for idelta = {'deltahand', 'deltaGH', 'deltaSCAC', 'deltaRoB'}
    %         idx = clean_data(inputData.(idelta{:})', 'idx');
    idx = clean_data(inputData.(idelta{:})(setdiff(1:end,selected),:)', 'idx');
    selected = vertcat(selected, idx);
    % Construct a questdlg to continue or quit the current for loop
    if ~contains(idelta, 'deltaRoB') % last iteration: don't need question
        choice = questdlg('continue to next delta?', ...
            'Quit or continue?', ...
            'Yes, continue','No, quit','Yes, continue');
        switch choice
            case 'Yes, continue'
                continue
            case 'No, quit'
                break
        end
    end
    
end