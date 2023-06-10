function varargout = erosion_coast_via_id(I_D,varargin)
    % =================================================================================================================
    % discription:
    %       erode the coastline via id
    % =================================================================================================================
    % parameter:
    %       varargin{n}: value of the grid point                 || required: True || type: double ||  format: matrix
    %       I_D: id and distance                                 || required: True || type: double ||  format: struct
    %       varargout{n}: value of the processed grid point      || required: True || type: double ||  format: matrix
    % =================================================================================================================
    % example:
    %       [Swh,Mwd] = erosion_coast_via_id(I_D,swh,mwd)
    % =================================================================================================================

    id = I_D.id;
    distance = I_D.distance;

    varargin = read_varargin(varargin,{'cycle_dim'},{false});

    if isvector(varargin{1})
        error('the input value must be a matrix')
    end
    if length(cycle_dim) ~= 1
        error('the cycle_dim must be a scalar')
    end
    size_var = size(varargin{1});

    if ~cycle_dim  % 不需要循环
        for i_v = 1 : length(varargin)
            value = varargin{i_v};
            Value = value;
            Value(id(:,1)) = mean(value(id(:,2:end)),2,'omitnan');
            varargout{i_v} = Value;
        end
    else
        if cycle_dim == 3
            for i_v = 1 : length(varargin)
                value = varargin{i_v};
                Value = value;
                for iz = 1 : size_var(3)
                    VAalue = value(:,:,iz);
                    VAalue(id(:,1)) = mean(VAalue(id(:,2:end)),2,'omitnan');
                    Value(:,:,iz) = VAalue; clear VAalue
                end
                varargout{i_v} = Value;
            end
        elseif cycle_dim == 4
            for i_v = 1 : length(varargin)
                value = varargin{i_v};
                Value = value;
                for it = 1 : size_var(4)
                    VAalue = value(:,:,:,it);
                    VAalue(id(:,1)) = mean(VAalue(id(:,2:end)),2,'omitnan');
                    Value(:,:,:,it) = VAalue;
                end
                varargout{i_v} = Value;
            end
        end

end