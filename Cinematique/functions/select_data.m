function bigstruct = select_data(bigstruct, varargin)
% | trial | height                | weight |
% |-------|-----------------------|--------|
% | 1     | H1 (*hips-shoulders*) | 6      |
% | 2     | H2 (*hips-eyes*)      | 6      |
% | 3     | H3 (*shoulders-hips*) | 6      |
% | 4     | H4 (*shoulders-eyes*) | 6      |
% | 5     | H5 (*eyes-hips*)      | 6      |
% | 6     | H6 (*eyes-shoulders*) | 6      |
% | 7     | H1 (*hips-shoulders*) | 12     |
% | 8     | H2 (*hips-eyes*)      | 12     |
% | 9     | H3 (*shoulders-hips*) | 12     |
% | 10    | H4 (*shoulders-eyes*) | 12     |
% | 11    | H5 (*eyes-hips*)      | 12     |
% | 12    | H6 (*eyes-shoulders*) | 12     |
% | 13    | H1 (*hips-shoulders*) | 18     | men only
% | 14    | H2 (*hips-eyes*)      | 18     | men only
% | 15    | H3 (*shoulders-hips*) | 18     | men only
% | 16    | H4 (*shoulders-eyes*) | 18     | men only
% | 17    | H5 (*eyes-hips*)      | 18     | men only
% | 18    | H6 (*eyes-shoulders*) | 18     | men only

% 1) keep data with the height selected (varargin{1})
bigstruct([bigstruct.hauteur] ~= 2) = [];

% 2) delete 18 kg condition (to keep a balanced design)
bigstruct([bigstruct.poids] == 18) = [];
