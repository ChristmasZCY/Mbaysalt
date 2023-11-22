function varargout = mask2data(mask_matfile,varargin)
    %       mask the data with the mask
    % =================================================================================================================
    % Parameter:
    %       mask_matfile: mat file name               || required: True || type: char    || format: 'elevation.mat'
    %       varargin:     data to be masked           || required: True || type: double  || format: matrix
    %       varargout:    masked data                 || required: True || type: double  || format: matrix
    % =================================================================================================================
    % Example:
    %       [Temp,Salt,Zeta,Depth,U,V,W] = mask2data(file_matmask,Temp,Salt,Zeta,Depth,U,V,W);
    % =================================================================================================================



    val_num = length(varargin);
    varargout = cell(0);

    val_mask = load(mask_matfile).Elevation;
    for num = 1 : val_num
        val = varargin{num};
        Imv = zeros(size(val));

        for i = 1 : size(val,3)
            for j = 1 : size(val,4)
                imv = val(:,:,i,j);
                imv(not(val_mask)) = NaN;
                Imv(:,:,i,j) = imv;
            end
        end

        varargout{num} = Imv;
    end

end
