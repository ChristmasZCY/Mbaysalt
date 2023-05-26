function varargout = mask_depth_data(Standard_depth_mask, varargin)
    % =================================================================================================================
    % discription:
    %       mask the data with the Standard_depth_mask(from the function of "make_mask_depth_data")
    % =================================================================================================================
    % parameter:
    %       Standard_depth_mask: the mask matrix || required: True || type: double || format: martix
    %       varargin{n}: value to be masked      || required: True || type: char   || format: martix
    %       varargout{n}: masked value           || required: True || type: double || format: martix
    % =================================================================================================================
    % example:
    %       [Temp] = mask_depth_data(Standard_depth_mask, Temp);
    %       [Temp, Salt] = mask_depth_data(Standard_depth_mask, Temp, Salt);
    % =================================================================================================================

    val_mask = Standard_depth_mask;  % val_mask的0值对应的是需要被mask掉的部分
    val_num = length(varargin);
    varargout = cell(0);

    % -----> 借鉴了ll_to_ll.m中的思路
    dims_var = ndims(varargin{1});
    varargin_var = cat(dims_var + 1, varargin{:});
    varargin_var = squeeze(varargin_var);

    size_varargin_var = size(varargin_var);
    ele = reshape(varargin_var, size_varargin_var(1), size_varargin_var(2), size_varargin_var(3), []);

    % =====
    Standard_depth_mask_1 = repmat(Standard_depth_mask, [1, 1, 1, size(ele, 4)]);
    ele(not(Standard_depth_mask_1)) = NaN;
    % =====

    ele = reshape(ele, size_varargin_var);
    ele_dims = ndims(ele);
    size_ele = size(ele); % 获取 ele 的大小

    ele_2dims = reshape(ele, [], size_ele(end));
    for i = 1 : size_ele(end)
        varargout{i} = reshape(ele_2dims(:,i), size_ele(1:end-1));
    end
    % <-----

    % for num = 1 : val_num
    %     val = varargin{num};
    %     val(not(val_mask)) = NaN;
    %     Viss(:,:,:,num) = val;
    % end

    % for num = 1 : val_num
    %     varargout{num} = Viss(:,:,:,num);
    % end

end