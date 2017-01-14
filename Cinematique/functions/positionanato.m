function [q_optim] = positionanato(Q0, model)
% todo : z humerus-bras et x poignet - coude
% | référence | aligné |
% |-----------|--------|
% | zThorax   | zArm   |ok
% | xScapula  | xArm   |ok
% | zArm      | zLoArm |
% | xWrist    | xLoArm |
%%

GH =  25:27;

%%
RL = S2M_rbdl('globalJCS', model ,Q0);

zThorax  = RL(1:3,3,2); % coord | sequence | segment
xScapula = RL(1:3,1,4);

options = optimoptions('lsqnonlin','Display','iter');

%% | zThorax   | zArm   |
    function val = obj1(x)
        q = Q0;
        q(GH(1:2)) = x;
        
        RL = S2M_rbdl('globalJCS', model ,q);
        
        zArm    = RL(1:3,3,5);
        val     = zThorax-zArm;
    end

Q0(GH(1:2)) = lsqnonlin(@obj1,[0,0],[],[],options);

%% | xScapula  | xArm   |
    function val = obj2(x)
        q = Q0;
        q(GH(3)) = x;
        
        RL = S2M_rbdl('globalJCS', model ,q);
        
        xArm     = RL(1:3,1,5);
        val      = xScapula-xArm;
    end

Q0(GH(3))   = lsqnonlin(@obj2,0,[],[],options);

% %%
%
% RL = S2M_rbdl('globalJCS', model ,Q0);
%
% zThorax  = RL(1:3,3,2);
% zArm  = RL(1:3,3,2);
%
% %% | zArm      | zLoArm |
%     function val = obj3(x)
%         q = Q0;
%         q(GH(3)) = x;
%
%         RL = S2M_rbdl('globalJCS', model ,q);
%
%
%         xArm     = RL(1:3,1,5);
%         val      = xScapula-xArm;
%     end
%
% Q0(GH(3))   = lsqnonlin(@obj2,0,[],[],options);
%
% %% | xWrist    | xLoArm |
%     function val = obj4(x)
%         q = Q0;
%         q(GH(3)) = x;
%
%         RL = S2M_rbdl('globalJCS', model ,q);
%
%
%         xArm     = RL(1:3,1,5);
%         val      = xScapula-xArm;
%     end
%
% Q0(GH(3))   = lsqnonlin(@obj2,0,[],[],options);

% % verifier l'alignement
S2M_rbdl_ShowModel(model, Q0, 'rt', true, 'comi', false, 'tags', true, 'com', false)
axis equal
axis tight


q_optim = Q0;
end