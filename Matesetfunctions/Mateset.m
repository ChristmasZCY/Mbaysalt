classdef Mateset < dynamicprops
    %       Mateset is a class for storing the data from netcdf file or matrix
    % =================================================================================================================
    % Parameter:
    %       varargin:        optional parameters     || required: False|| type: char string double single || format: None
    % =================================================================================================================
    % Example:
    %       Ms = Mateset(file)
    %       Ms = Mateset(x.lon,x.lat)
    %       Ms = Mateset(x.lon,x.lat,x.element)
    %       Ms = Mateset(x.lon,x.lat,x.Ttimes)
    %       Ms = Mateset(x.lon,x.lat,x.Ttimes,x.element)
    % =================================================================================================================

    properties
        lon
        lat
        Ttimes
        element
    end

    methods
        function obj = Mateset(varargin)
            % MATESET Construct an instance of this class
            switch class(varargin{1})
            case {'char', 'string'}
                if endsWith(varargin{1}, '.nc')
                    fnc = varargin{1};
                    varargin(1) = [];
                    [~,Dims_name, ~] = get_Dimensions_from_nc(fnc);
                    [obj.lon, obj.lat, depth, time] = read_ncfile_lldtv(fnc,'Lon_Name',Dims_name{1},'Lat_Name',Dims_name{2},'Time_Name',Dims_name{3},'Var_Name',{{'None'},{'NaN'}},'INFO');
                    if ~isempty(depth)
                        addprop(obj,'depth');
                        obj.depth = depth;
                    end
                    [~, obj.element] = Mateset.get_Variables_from_nc(fnc);
                    units = ncreadatt(fnc,'time','units');
                    obj.Ttimes = Mdatetime(time, units);
                end
            case {'single', 'double'}
                % lon lat
                obj.lon = varargin{1};
                obj.lat = varargin{2};
                varargin(1) =[];
                varargin(1)=[];
                try
                    if isa(varargin{1},'datetime')  || isa(varargin{1},'Mdatetime')
                        % time
                        if isa(varargin{1},'datetime')
                            obj.Ttimes = Mdatetime(varargin{1});
                        elseif isa(varargin{1},'Mdatetime')
                            obj.Ttimes = varargin{1};
                        end
                        varargin(1) = [];
                        if isa(varargin{1},'single') || isa(varargin{1},'double')
                            % depth
                            addprop(obj,'depth');
                            obj.depth = varargin{1};
                            varargin(1) = [];
                            if isa(varargin{1}, "struct")
                                % element
                                obj.element = varargin{1};
                                varargin(1) = [];
                            end
                        elseif isa(varargin{1}, "struct")
                            % element
                            obj.element = varargin{1};
                            varargin(1) = [];
                        end
                    elseif isa(varargin{1},'single') || isa(varargin{1},'double')
                        % depth
                        addprop(obj,'depth');
                        obj.depth = varargin{1};
                        varargin(1) = [];
                        if isa(varargin{1}, "struct")
                            % element
                            obj.element = varargin{1};
                            varargin(1) = [];
                        end
                    elseif isa(varargin{1}, "struct")
                        % element
                        obj.element = varargin{1};
                        varargin(1) = [];
                    end
                end
            end

        end

    end

end

