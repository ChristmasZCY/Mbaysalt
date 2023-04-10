function  varargout = standard_filename(varargin)
    % =================================================================================================================
    % discription:
    %       This function is used to make standard filename
    % =================================================================================================================
    % parameter:
    %       varargin{1}:  prefix                      || required: True || type: string || format: 'adt'
    %       varargin{2}:  longitude                   || required: True || type: double || format: [120.5, 121.5]
    %       varargin{3}:  latitude                    || required: True || type: double || format: [30.5, 31.5]
    %       varargin{4}:  time                        || required: True || type: string || format: '20221110'
    %       varargin{5}:  resolution                  || required: True || type: string || format: '5'
    %       varargout{1}: standard filename           || required: True || type: string || format: 'adt_120.50W_121.50E_30.50S_31.50N_20221110_5.nc'
    % =================================================================================================================
    % example:
    %       standard_filename('adt', [120.5, 121.5], [30.5, 31.5], '20221110', '5')
    % =================================================================================================================

    pres = varargin{1};
    Lon = varargin{2};
    Lat = varargin{3};
    time_filename = varargin{4};
    res = varargin{5};
    if min(Lon) < 0; Lon_1 = [num2str(abs(min(Lon)), '%3.2f'), 'W']; else; Lon_1 = [num2str(min(Lon), '%3.2f'), 'E']; end
    if max(Lon) < 0; Lon_2 = [num2str(abs(max(Lon)), '%3.2f'), 'W']; else; Lon_2 = [num2str(max(Lon), '%3.2f'), 'E']; end
    if min(Lat) < 0; Lat_1 = [num2str(abs(min(Lat)), '%2.2f'), 'S']; else; Lat_1 = [num2str(min(Lat), '%2.2f'), 'N']; end
    if max(Lat) < 0; Lat_2 = [num2str(abs(max(Lat)), '%2.2f'), 'S']; else; Lat_2 = [num2str(max(Lat), '%2.2f'), 'N']; end
    varargout{1} = [pres,'_', Lon_1, '_', Lon_2, '_', Lat_1, '_', Lat_2, '_', (time_filename),'_',res ,'.nc'];

end
