function [q] = positionanato(Q0, DoF)
GH = 22:24;

    function val = obj1(x)
        q = Q0;
        q(GH(1:2),:) = x;
        
        RL = S2M_rbdl('globalJCS', Stuff.model ,q);
        
        zThorax = RL(1:3,3,2);
        zHum    = RL(1:3,3,5);
        val     = -(zThorax'*zHum);
    end

    function val = obj2(x)
        q = Q0;
        q(GH(3),:) = x;
        
        RL = S2M_rbdl('globalJCS', Stuff.model ,q);
        
        xScapula = RL(1:3,1,4);
        xHum     = RL(1:3,1,5);
        val      = -(xScapula'*xHum);
    end

xopt = lsqnonlin(obj1,[0,0])
end

