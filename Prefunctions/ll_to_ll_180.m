function [Lon,varargout] = ll_to_ll_180(lon,varargin)
    % =================================================================================================================
    % discription:
    %       change the lon and lat 0-360 to -180-180
    % =================================================================================================================
    % parameter:
    %       lon: longitude               || required: True || type: double || format: -180-180
    %       varargin{n}: value to change || required: True || type: char   || format: martix
    %       Lon: changed longitude       || required: True || type: double || format: martix
    %       varargout{n}: changed value  || required: True || type: double || format: martix
    % =================================================================================================================
    % example:
    %       [Lon,temp,salt] = ll_to_ll_180(lon,temp,salt)
    % =================================================================================================================

    if ndims(lon) > 2
        error('lon must be 1D or 2D')
    end

    if size(lon,2) ~= 1 && size(lon,1) == 1
        lon = lon';
    end

    lon(lon>180) = lon(lon>180)-360;
    F = find(lon<0,1,'first');
    Lon = cat(1,lon(F:end,:),lon(1:F-1,:));

    if nargin == 1
        return
    end

    varargout{length(varargin)} = zeros(size(varargin{1}));

    for i = 1:length(varargin)
        ele = varargin{i};
        % 将ele向量化
        ele_size = size(ele);
        ele = reshape(ele,size(ele,1),size(ele,2),[]);

        % if ndims(ele) == 2
        %     varargout{i} = cat(1,ele(F:end,:),ele(1:F-1,:));
        % elseif ndims(ele) == 3
        %     varargout{i} = cat(1,ele(F:end,:,:),ele(1:F-1,:,:));
        % elseif ndims(ele) == 4
        %     varargout{i} = cat(1,ele(F:end,:,:,:),ele(1:F-1,:,:,:));
        % elseif ndims(ele) == 5
        %     varargout{i} = cat(1,ele(F:end,:,:,:,:),ele(1:F-1,:,:,:,:));
        % end

        ele = cat(1,ele(F:end,:),ele(1:F-1,:));
        % 将ele还原
        varargout{i} = reshape(ele,ele_size);

    end

end