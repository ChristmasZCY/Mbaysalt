function [Lon,varargout] = ll_to_ll_360(lon,varargin)
    % =================================================================================================================
    % discription:
    %       change the lon and lat -180-180 to 0-360
    % =================================================================================================================
    % parameter:
    %       lon: longitude               || required: True || type: double || format: 0-360
    %       varargin{n}: value to change || required: True || type: char   || format: martix
    %       Lon: changed longitude       || required: True || type: double || format: martix
    %       varargout{n}: changed value  || required: True || type: double || format: martix
    % =================================================================================================================
    % example:
    %       [Lon,temp,salt] = ll_to_ll_360(lon,temp,salt)
    % =================================================================================================================


    if ndims(lon) > 2
        error('lon must be 1D or 2D')
    end

    if size(lon,2) ~= 1 && size(lon,1) == 1
        lon = lon';
    end

    lon(lon<0) = lon(lon<0)+360;
    [F,~] = find(lon>180);
    Lon = cat(1,lon(F(end)+1:end,:),lon(F(1:end),:));

    if nargin == 1
        return
    end

    for i = 1:length(varargin)
        ele = varargin{i};
        % 将ele向量化
        ele_size = size(ele);
        ele = reshape(ele,size(ele,1),size(ele,2),[]);

        % if ndims(ele) == 2
        %     varargout{i} = cat(1,ele(F(end)+1:end,:),ele(F(1:end),:));
        % elseif ndims(ele) == 3
        %     varargout{i} = cat(1,ele(F(end)+1:end,:,:),ele(F(1:end),:,:));
        % elseif ndims(ele) == 4
        %     varargout{i} = cat(1,ele(F(end)+1:end,:,:,:),ele(F(1:end),:,:,:));
        % elseif ndims(ele) == 5
        %     varargout{i} = cat(1,ele(F(end)+1:end,:,:,:,:),ele(F(1:end),:,:,:,:,:));
        % end

        ele = cat(1,ele(F(end)+1:end,:),ele(F(1:end),:));
        % 将ele还原
        varargout{i} = reshape(ele,ele_size);

    end

end