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
    for i_v = 1 : nargin - 1
        value = varargin{i_v};
        Value = value;
        Value(id(:,1))=nanmean(value(id(:,2:end)),2);
        varargout{i_v} = Value;
    end

end