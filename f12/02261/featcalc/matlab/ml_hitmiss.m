function [changed_image,oper] = ml_hitmiss(changed_image,struct_elem,image_exp)
%need to be documented 
[r,c] = size(image_exp);
r = r - 4;
c = c - 4;

hits = 0; 
oper = 0;

for n = 2 : c+1
    for m = 2 : r+1
        x = n - 1;
        for w = 0 : 2
            y = m - 1;
            for z = 0 : 2
                if struct_elem(w+z*3+1) == image_exp(x+y*(c+4)+1)
                    hits = hits + 1;
                elseif struct_elem(w+z*3+1) == 2
                        hits = hits + 1;
                end
                y = y + 1;
            end
            x = x + 1;
        end
        
        if hits == 9
            changed_image((n-2)+(m-2)*c+1) = 1;
            oper = oper + 1;
        else
            changed_image((n-2)+(m-2)*c+1) = 0;
        end
        hits = 0;
    end
end
