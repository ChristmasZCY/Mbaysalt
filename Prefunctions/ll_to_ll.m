function [Lon,varargout] = ll_to_ll(lon,varargin)
    % =================================================================================================================
    % discription:
    %       change the lon and lat 0-360 to -180-180 or -180-180 to 0-360
    % =================================================================================================================
    % parameter:
    %       lon: longitude               || required: True || type: double || format: 0-360 or -180-180
    %       varargin{n}: value to change || required: True || type: char   || format: martix
    %       Lon: changed longitude       || required: True || type: double || format: martix
    %       varargout{n}: changed value  || required: True || type: double || format: martix
    % =================================================================================================================
    % example:
    %       [Lon,temp,salt] = ll_to_ll(lon,temp,salt)
    % =================================================================================================================

    % check input
    if nargin < 2
        error('ll_to_ll:input','Not enough input arguments.');
    end

    % check lon and lat
    if ~isnumeric(lon) || ~isnumeric(varargin{1})
        error('ll_to_ll:input','lon and lat must be numeric.');
    end

    % check lon and lat format
    if max(lon) > 360 or min(lon) < -180
        error('ll_to_ll:input','lon and lat must be 0-360 or -180-180.');
    end

    % check varargin
    if nargin > 2
        for i = 1:length(varargin)
            if ~isnumeric(varargin{i})
                error('ll_to_ll:input','varargin must be numeric.');
            end
        end
    end

    if size(lon,2) ~= 1 && size(lon,1) == 1
        lon = lon';
    end

    % check lon range
    if max(lon,[],'all') < 180 && min(lon,[],'all') > 0
        Lon = lon;
        varargout = varargin;
        return
    end

    dims_var = ndims(varargin{1});
    varargin_var = cat(dims_var + 1, varargin{:});
    varargin_var = squeeze(varargin_var);

    size_varargin_var = size(varargin_var);
    ele = reshape(varargin_var, size_varargin_var(1), size_varargin_var(2), []);

    % change lon and lat
    if max(lon) > 180
        % disp('change lon and lat to -180-180')
        % if length(varargin) == 1
        %     [Lon,varargout{1}] = ll_to_ll_180(lon,varargin{:});
        % elseif length(varargin) == 2
        %     [Lon,varargout{1},varargout{2}] = ll_to_ll_180(lon,varargin{:});
        % elseif length(varargin) == 3
        %     [Lon,varargout{1},varargout{2},varargout{3}] = ll_to_ll_180(lon,varargin{:});
        % elseif length(varargin) == 4
        %     [Lon,varargout{1},varargout{2},varargout{3},varargout{4}] = ll_to_ll_180(lon,varargin{:});
        % elseif length(varargin) == 5
        %     [Lon,varargout{1},varargout{2},varargout{3},varargout{4},varargout{5}] = ll_to_ll_180(lon,varargin{:});
        % elseif length(varargin) == 6
        %     [Lon,varargout{1},varargout{2},varargout{3},varargout{4},varargout{5},varargout{6}] = ll_to_ll_180(lon,varargin{:});
        % elseif length(varargin) == 7
        %     [Lon,varargout{1},varargout{2},varargout{3},varargout{4},varargout{5},varargout{6},varargout{7}] = ll_to_ll_180(lon,varargin{:});
        % elseif length(varargin) == 8
        %     [Lon,varargout{1},varargout{2},varargout{3},varargout{4},varargout{5},varargout{6},varargout{7},varargout{8}] = ll_to_ll_180(lon,varargin{:});
        % ends
        [Lon,ele] = ll_to_ll_180(lon,ele);

    elseif min(lon) < 0
        % disp('change lon and lat to 0-360')
        % if length(varargin) == 1
        %     [Lon,varargout{1}] = ll_to_ll_360(lon,varargin{:});
        % elseif length(varargin) == 2
        %     [Lon,varargout{1},varargout{2}] = ll_to_ll_360(lon,varargin{:});
        % elseif length(varargin) == 3
        %     [Lon,varargout{1},varargout{2},varargout{3}] = ll_to_ll_360(lon,varargin{:});
        % elseif length(varargin) == 4
        %     [Lon,varargout{1},varargout{2},varargout{3},varargout{4}] = ll_to_ll_360(lon,varargin{:});
        % elseif length(varargin) == 5
        %     [Lon,varargout{1},varargout{2},varargout{3},varargout{4},varargout{5}] = ll_to_ll_360(lon,varargin{:});
        % elseif length(varargin) == 6
        %     [Lon,varargout{1},varargout{2},varargout{3},varargout{4},varargout{5},varargout{6}] = ll_to_ll_360(lon,varargin{:});
        % elseif length(varargin) == 7
        %     [Lon,varargout{1},varargout{2},varargout{3},varargout{4},varargout{5},varargout{6},varargout{7}] = ll_to_ll_360(lon,varargin{:});
        % elseif length(varargin) == 8
        %     [Lon,varargout{1},varargout{2},varargout{3},varargout{4},varargout{5},varargout{6},varargout{7},varargout{8}] = ll_to_ll_360(lon,varargin{:});
        % end
        [Lon,ele] = ll_to_ll_360(lon,ele);
    end

    [M,F,C] = mode(Lon);
    if F > 1
        FF = find(Lon == M,1);
        Lon(FF) = [];
        ele(FF,:,:) = [];
        size_varargin_var(1) = size(Lon,1);
    end

    ele = reshape(ele, size_varargin_var);
    ele_dims = ndims(ele);
    size_ele = size(ele); % 获取 ele 的大小


    Method_split_ele = 'reshape';
    % Method_split_ele = 'repmat';
    % Method_split_ele = 'mat2cell';

    % ================
    % 将 ele 拆分为单个元素 
    %                     如 size(ele) = [1800,900,16,24,5]
    %                     则 varargout{1} = ele(:,:,:,:,1)
    %                        varargout{2} = ele(:,:,:,:,2)
    %                        ......
    %                        varargout{5} = ele(:,:,:,:,5)
    %                     如 size(ele) = [1800,900,24,5]
    %                     则 varargout{1} = ele(:,:,:,1)
    %                        ......
    %                        varargout{5} = ele(:,:,:,5)
    % 可以看出，ele 的最后一个维度的大小就是 varargout 的length, 但是由于输入的变量的维度数不同，所以需要使方法来拆分 ele
    % ================

    if length(varargin) == 1
        varargout{1} = ele;
    else
        switch Method_split_ele
            case 'repmat'
                % 历时 3.077064 秒
                for i = 1 : length(varargin)
                    subs{i} = repmat({':'}, 1, ele_dims); % 创建一个与 ele 大小相同的子索引
                    subs{i}{ele_dims} = i; % 将要选择的维度的子索引设置为 i
                    varargout{i} = ele(subs{i}{:}); % 选择要选择的维度的所有元素并将其存储在
                end

            case 'mat2cell'
                % 历时 3.275914 秒
                for i = 1 : length(size_ele) - 1
                    subs{i} = size(ele,i);
                end
                varargout = mat2cell(ele,subs{:},ones(1,size_ele(end)));

            case 'reshape'
                % 历时 3.113021 秒
                ele_2dims = reshape(ele, [], size_ele(end));
                for i = 1 : size_ele(end)
                    varargout{i} = reshape(ele_2dims(:,i), size_ele(1:end-1));
                end
            end
    end


end