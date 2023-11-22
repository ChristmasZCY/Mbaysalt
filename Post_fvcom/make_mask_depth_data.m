function Standard_depth_mask = make_mask_depth_data(grid_depth, standard_depth)
    %       Make mask to mask the data which is deeper than the grid depth(for 'mask_depth_data.m')
    % =================================================================================================================
    % Parameter:
    %       grid_depth: grid depth               || required: True || type: double || format: martix
    %       standard_depth: standard depth       || required: True || type: double || format: martix
    %       Standard_depth_mask: mask            || required: True || type: logical|| format: martix
    % =================================================================================================================
    % Example:
    %       Standard_depth_mask = make_mask_depth_data(grid_depth, standard_depth);
    % =================================================================================================================

    % standard为[0,5,10,20,30,50,70,100,150,200,300,500,1000,1500,2000,3000]的标准层深度
    % grid为网格层深度, 制作mask, 用于mask掉standard>grid的数据
    % grid 为 lon*lat*1
    % standard 为 depth
    % mask 为 lon*lat*depth
    Standard_depth_mask = zeros(size(grid_depth,1),size(grid_depth,2),length(standard_depth));

    for i  = 1 : size(Standard_depth_mask,1)
        for j = 1 : size(Standard_depth_mask,2)
            F = find((standard_depth - grid_depth(i,j)) <= 0);
            if isempty(F)
                Standard_depth_mask(i, j, :) = 0;
            else
                Standard_depth_mask(i, j, 1:F(end)) = 1;
                if F(end) < length(standard_depth)
                    Standard_depth_mask(i, j, F(end)+1:end) = 0;
                end
            end
        end
    end
    Standard_depth_mask = logical(Standard_depth_mask);

end
