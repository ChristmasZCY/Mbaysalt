function varOut = erosion_coast_via_id(I_D, varIn, varargin)
    %       erode the coastline via id
    % =================================================================================================================
    % Parameter:
    %       varargin{n}: value of the grid point                 || required: True || type: double ||  format: matrix
    %       I_D: id and distance                                 || required: True || type: double ||  format: struct
    %       VarIn: Input variable                                || required: True || type: double ||  format: matrix
    %       varargin:       optional parameters      
    %           cycle_dim:  Cycle dimensionality                 || required: False|| type: Text   ||  default: false
    % =================================================================================================================
    % Returns:
    %       varOut: value of the processed grid point            || required: True || type: double ||  format: matrix
    % =================================================================================================================
    % Update:
    %       ****-**-**:     Created, by Christmas;
    %       2024-04-07:     Changed to one var, by Christmas;
    % =================================================================================================================
    % Example:
    %       Swh = erosion_coast_via_id(I_D,swh)
    % =================================================================================================================

    id = I_D.id;
    distance = I_D.distance;

    varargin = read_varargin(varargin,{'cycle_dim'},{false});

    if isvector(varIn)
        error('the input value must be a matrix')
    end
    if length(cycle_dim) ~= 1
        error('the cycle_dim must be a scalar')
    end
    size_var = size(varIn);

    if ~cycle_dim  % 不需要循环
        varOut = varIn;
        varOut(id(:,1)) = mean(varIn(id(:,2:end)),2,'omitnan');
    else
        if cycle_dim == 3
            varOut = varIn;
            for iz = 1 : size(varIn, 3)
                VAalue = varIn(:,:,iz);
                VAalue(id(:,1)) = mean(VAalue(id(:,2:end)),2,'omitnan');
                varOut(:,:,iz) = VAalue; clear VAalue
            end
        elseif cycle_dim == 4
            varOut = varIn;
            for it = 1 : size(varIn, 4)
                VAalue = varIn(:,:,:,it);
                VAalue(id(:,1)) = mean(VAalue(id(:,2:end)),2,'omitnan');
                varOut(:,:,:,it) = VAalue; clear VAalue
            end
        end

    end
end
