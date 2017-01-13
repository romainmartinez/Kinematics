function [q_optim] = positionanato(Q0, model)

GH = 22:24;

RL = S2M_rbdl('globalJCS', model ,Q0); 

zThorax  = RL(1:3,3,2);
xScapula = RL(1:3,1,4);

options = optimoptions('lsqnonlin','Display','iter');

    function val = obj1(x)
        q = Q0;
        q(GH(1:2)) = x;

        RL = S2M_rbdl('globalJCS', model ,q); 
        
        zHum    = RL(1:3,3,5);
        val     = zThorax-zHum;
    end

    function val = obj2(x)
        q = Q0;
        q(GH(3)) = x;

        RL = S2M_rbdl('globalJCS', model ,q);


        xHum     = RL(1:3,1,5);
        val      = xScapula-xHum;
    end

Q0(GH(1:2)) = lsqnonlin(@obj1,[0,0],[],[],options);


Q0(GH(3))   = lsqnonlin(@obj2,[0],[],[],options);

% % verifier l'alignement
S2M_rbdl_ShowModel(model, Q0, 'rt', true, 'comi', false, 'tags', true, 'com', false)
axis equal


q_optim = Q0;
end