function [q_optim] = positionanato(Q0, model)
% todo : z humerus-bras et x poignet - coude
% | référence | aligné |
% |-----------|--------|
% | zThorax   | zArm   |ok
% | xScapula  | xArm   |ok
% | zArm      | zLoArm |
% | xWrist    | xLoArm |
%% todo : remplacer xLoArm par xArm

Arm    = 22:24;
loArm2 = 26;
loArm1 = 25;

%%
RL = S2M_rbdl('globalJCS', model ,Q0);

% RL --> coord | sequence | segment
zThorax  = RL(1:3,3,2);
xScapula = RL(1:3,1,4);

options = optimoptions('lsqnonlin','Display','iter');

%% | zThorax | zArm |
    function val = obj1(x)
        q = Q0;
        q(Arm(1:2)) = x;
        
        RL = S2M_rbdl('globalJCS', model ,q);
        
        zArm = RL(1:3,3,5);
        val  = zThorax-zArm;
    end

Q0(Arm(1:2)) = lsqnonlin(@obj1,[0,0],[],[],options);

%% | xScapula | xArm |
    function val = obj2(x)
        q = Q0;
        q(Arm(3)) = x;
        
        RL = S2M_rbdl('globalJCS', model ,q);
        
        xArm = RL(1:3,1,5);
        val  = xScapula-xArm;
    end

Q0(Arm(3))   = lsqnonlin(@obj2,0,[],[],options);

%% | zArm | zLoArm |
RL = S2M_rbdl('globalJCS', model ,Q0);

zArm  = RL(1:3,3,5);

    function val = obj3(x)
        q = Q0;
        q(loArm2) = x;
        
        RL = S2M_rbdl('globalJCS', model ,q);
        
        zLoArm = RL(1:3,3,7);
        val    = zArm-zLoArm;
    end



%% | xWrist | xLoArm |
RL = S2M_rbdl('globalJCS', model ,Q0);

xWrist  = RL(1:3,1,8);

    function val = obj4(x)
        q = Q0;
        q(loArm1) = x;
        
        RL = S2M_rbdl('globalJCS', model ,q);
        
        
        xLoArm = RL(1:3,1,6);
        val    = xWrist-xLoArm;
    end

Q0(loArm1)   = lsqnonlin(@obj4,0,[],[],options);
Q0(loArm2)   = lsqnonlin(@obj3,0,[],[],options);
%% plot
S2M_rbdl_ShowModel(model, Q0, 'rt', true, 'comi', false, 'tags', true, 'com', false)
axis equal
axis tight


q_optim = Q0;
end