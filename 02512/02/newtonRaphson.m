function [ a,k1,k2 ] = newtonRaphson( a0,k10,k20, da, dk, r, t, f )

    function [x] = F(a,k1,k2,tval)
        x = a*exp(-1*k1*tval) + (1-a)*exp(-1*k2*tval);
    end

    function [pa] = partialOfFwA(a,k1,k2,t,f)
        pa = 0;
        for i=1:length(t)
            pa = pa + 2*(exp(-1*k1*t(i))-exp(-1*k2*t(i)))*(F(a,k1,k2,t(i)) - f(i));
        end
    end
    function [pa] = partialOfFwK1(a,k1,k2,t,f)
        pa = 0;
        for i=1:length(t)
            pa = pa + 2*(a*t(i)*exp(-1*k1*t(i)))*(F(a,k1,k2,t(i)) - f(i));
        end
    end
    function [pa] = partialOfFwK2(a,k1,k2,t,f)
        pa = 0;
        for i=1:length(t)
            pa = pa + 2*((1-a)*t(i)*exp(-1*k2*t(i)))*(F(a,k1,k2,t(i)) - f(i));
        end
    end

    function [gf] = gradientOfObjectiveFun(a,k1,k2,t,f)
        gf = [partialOfFwA(a,k1,k2,t,f);...
              partialOfFwK1(a,k1,k2,t,f);...
              partialOfFwK2(a,k1,k2,t,f)];
    end

    function [h] = J(a,k1,k2,t,f,deltaA, deltaK)
        h = zeros(3,3);
        h(1,1) = (partialOfFwA(a + deltaA,k1,k2,t,f) - partialOfFwA(a,k1,k2,t,f))/deltaA;
        h(2,1) = (partialOfFwA(a,k1 + deltaK,k2,t,f) - partialOfFwA(a,k1,k2,t,f))/deltaK;
        h(3,1) = (partialOfFwA(a,k1,k2 + deltaK,t,f) - partialOfFwA(a,k1,k2,t,f))/deltaK;
        
        h(1,2) = (partialOfFwK1(a + deltaA,k1,k2,t,f) - partialOfFwK1(a,k1,k2,t,f))/deltaA;
        h(2,2) = (partialOfFwK1(a,k1 + deltaK,k2,t,f) - partialOfFwK1(a,k1,k2,t,f))/deltaK;
        h(3,2) = (partialOfFwK1(a,k1,k2 + deltaK,t,f) - partialOfFwK1(a,k1,k2,t,f))/deltaK;
        
        h(1,3) = (partialOfFwK2(a + deltaA,k1,k2,t,f) - partialOfFwK2(a,k1,k2,t,f))/deltaA;
        h(2,3) = (partialOfFwK2(a,k1 + deltaK,k2,t,f) - partialOfFwK2(a,k1,k2,t,f))/deltaK;
        h(3,3) = (partialOfFwK2(a,k1,k2 + deltaK,t,f) - partialOfFwK2(a,k1,k2,t,f))/deltaK;
    end

    v = [a0; k10; k20];

    for i=1:r
        y = linsolve(J(v(1), v(2), v(3), t, f, da, dk),...
                         gradientOfObjectiveFun(v(1), v(2), v(3), t, f));
        v = v - y;
    end
    
    a = v(1);
    k1 = v(2);
    k2 = v(3);

end

