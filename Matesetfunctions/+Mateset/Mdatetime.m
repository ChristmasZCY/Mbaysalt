classdef Mdatetime 
    properties
        time
        Times
        TIME
        units = 'seconds since 1970-01-01 00:00:00'
        units_datetime = datetime(1970,1,1,0,0,0);
        fmt = 'yyyy-MM-dd HH:mm:ss'
    end
    methods
        function obj = Mdatetime(ttime, varargin)
            obj.time.data = [];
            % obj.time.units = obj.units;
            % obj.time.units_datetime = obj.units_datetime;

            obj.Times.data = NaT;
            obj.TIME.data = char;

            switch class(ttime)
            case 'datetime'  % datetime 直接赋值
                obj.Times.data = ttime;
                obj.time.data = posixtime(obj.Times.data);
                obj.TIME.data = char(datetime(obj.Times.data,'Format',obj.fmt));
            case {'double', 'single'}
                obj.time.data = ttime;  % double or single 赋值,并计算datetime
                if ~isempty(varargin) & strcmp(class(varargin{1}),{'char', 'string'})
                    obj.units = varargin{1};
                    varargin(1) = [];
                end
                [obj.Times.data, ~, obj.units_datetime] = cftime(ttime,obj.units);
                obj.TIME.data = char(datetime(obj.Times.data,'Format',obj.fmt));
            case 'char'
                if ~isempty(varargin) & strcmp(class(varargin{1}),{'char', 'string'})
                    obj.fmt = varargin{1};
                    varargin(1) = [];
                end
                obj.TIME.data = ttime;
                obj.Times.data = datetime(ttime,'InputFormat',obj.fmt);
                if isnat(obj.Times.data)
                    osprints('WARNING', 'Mdatetime: input time convert to datetime failed, please try to transpose matrix.')
                    if input_yn('Do you want to transpose matrix?')
                        obj.Times.data = datetime(ttime','InputFormat',obj.fmt);
                    end
                end
                obj.time.data = posixtime(obj.Times.data);
            end
        end

        %% 当某一个属性被更改，其余一起更改
        % time被更改
        function obj = set.time(obj,value)
            obj.time = value;
            [obj.Times.data, ~, ~] = cftime(obj.time.data,obj.units);
            obj.TIME.data = char(datetime(obj.Times.data,'Format',obj.fmt));
        end
        % Times被更改
        function obj = set.Times(obj,value)
            obj.Times = value;
            obj.time.data = posixtime(obj.Times.data);
            obj.TIME.data = char(datetime(obj.Times.data,'Format',obj.fmt));
        end

            
    end
end
