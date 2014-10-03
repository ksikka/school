function [names,features,slfnames] = myfeatcalc(tricolorimg)

for i=1:length(tricolorimg)
    for j=1:3
        [names{i}{j},features{i}{j},slfnames{i}{j}]=...
            mlfeat_set(tricolorimg{i}(:,:,j),[],[],'har',[],[]);
    end
end

end

