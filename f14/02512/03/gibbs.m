function [heatmap] = gibbs(C,a,n,r)
    X = zeros(r+1,a);
    Y = zeros(r+1,a);
    heatmap = zeros(n,n);

    % Initialization
    % bug: this only works if a = n
    X(1,:) = 1:n;
    Y(1,:) = 1:n;

    
    
    function [val] = e_tot(X_values, Y_values, i, x_i, y_i)
        e_r = -1 * C / sqrt(x_i^2 + y_i^2);
        e_cs = 1:n;
        for jj = 1:n
            if jj ~= i
                e_cs(jj) = 1 / sqrt((x_i - X_values(jj))^2+(y_i - Y_values(jj))^2);
            else
                e_cs(jj) = 0; % so that this value wont affect the sum
            end
        end
        val = e_r + sum(e_cs);
    end

    function [val] = sample_from(prob_x_i_equals_j)
        
        u = unifrnd(0,1);
        
        val = 1;
        for ii = 1:n
            if (u < prob_x_i_equals_j(ii))
                val = ii;
                break;
            else
                u = u - prob_x_i_equals_j(ii);
            end
            
        end
    end

    % iterate r times
    for t = 2:r+1
        % for each variable (or organism)
        for i = 1:a
            % for each possible value of x_i
            e_totals = 1:n;

            % Sample x_i
            for j = 1:n
                e_totals(j) = exp(-1 * e_tot(X(t-1,:), Y(t-1,:), i, j, Y(t-1,i)));
            end
            
            sum_e_totals = sum(e_totals);

            prob_x_i_equals_j = 1:n;
            for j = 1:n
                prob_x_i_equals_j(j) = e_totals(j) / sum_e_totals;
            end
            X(t,i) = sample_from(prob_x_i_equals_j);
            
            % Sample y_i
            for j = 1:n
                e_totals(i) = exp(-1*e_tot(X(t-1,:), Y(t-1,:), i, X(t-1,i), j));
            end
            sum_e_totals = sum(e_totals);

            prob_y_i_equals_j = 1:n;
            for j = 1:n
                prob_y_i_equals_j(j) = e_totals(j) / sum_e_totals;
            end
            Y(t,i) = sample_from(prob_y_i_equals_j);
            heatmap(X(t,i),Y(t,i)) = heatmap(X(t,i),Y(t,i)) + 1;
        end
    end

    hsum = 0;
    for i=1:n
        for j=1:n
           hsum = hsum + heatmap(i,j);
        end
    end
    for i=1:n
        for j=1:n
           heatmap(i,j) = heatmap(i,j) / hsum;
        end
    end

    
end

