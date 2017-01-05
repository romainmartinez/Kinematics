function [q] = positionanato(Q0, model)
GH = 22:24;

    function val = obj1(x)
        q = Q0;
        q(GH(1:2),:) = x;
        
        RL = S2M_rbdl('globalJCS', model ,q);
        
        zThorax = RL(1:3,3,2);
        zHum    = RL(1:3,3,5);
        val     = -(zThorax'*zHum);
    end

    function val = obj2(x)
        q = Q0;
        q(GH(3),:) = x;
        
        RL = S2M_rbdl('globalJCS', model ,q);
        
        xScapula = RL(1:3,1,4);
        xHum     = RL(1:3,1,5);
        val      = (xScapula'*xHum);
    end

Q0(GH(1:2)) = lsqnonlin(@obj1,[0,0]);
Q0(GH(3)) = lsqnonlin(@obj2,[0]);

S2M_rbdl_AnimateModel(model, Q0);
end

