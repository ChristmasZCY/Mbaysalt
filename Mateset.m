classdef Mateset < dynamicprops
    properties
        lon
        lat
        time
        Times
        Mtime
        depth
        element

    end

    methods
        function self = Mateset(varargin)
            % MATESET Construct an instance of this class
            switch class(varargin{1})
            case {'char', 'string'}
                if endsWith(varargin{1}, '.nc')
                    fnc = varargin{1};
                    varargin(1) = [];
                    [self.lon,self.lat,self.depth,self.time,swh,mdts,TIME] = read_ncfile_lldtv(fnc,'Lon_Name','longitude','Lat_Name','latitude','Time_Name','time','Var_Name',{{'swh'},{'mdts'},{'TIME'}},'INFO');
                    units = ncreadatt(fnc,'time','units');
                    self.Mtime = Mateset.Mdatetime(self.time, units);
                    self.Times = self.Mtime.Times.data;
                end
            case {'single', 'double'}
                % TODO:
                self.Mlon = varargin{1};
                self.Mlat = varargin{2};
                if isa(varargin{3},'datetime')
                    self.MTimes = varargin{3};
                else
                    % addprop(self,'Mtime');
                    self.Mtime = varargin{3};
                end
                % if nargin > 3
                %     for i = 1:2:length(varargin)
                %         addprop(self,varargin{i});
                %         self.(varargin{i}) = varargin{i+1};
                %     end
                % end
            end

        end
    end

end

