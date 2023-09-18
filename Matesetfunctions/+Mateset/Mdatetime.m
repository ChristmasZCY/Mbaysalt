classdef Mdatetime 
% Ttime = Mateset.Mdatetime(Times)
% Ttime = Mateset.Mdatetime(time)
% Ttime = Mateset.Mdatetime(time,'seconds since 1970-01-01 00:00:00')
% Ttime = Mateset.Mdatetime(TIME,'yyyy-MM-dd HH:mm:ss')
% Ttime = Mateset.Mdatetime(string(TIME),'yyyy-MM-dd HH:mm:ss')
    properties
        time
        Times
        TIME
        TIME_str
        TIME_char
        units = 'seconds since 1970-01-01 00:00:00'
        units_datetime = datetime(1970,1,1,0,0,0);
        fmt = 'yyyy-MM-dd HH:mm:ss'
    end
    methods
        function obj = Mdatetime(ttime, varargin)

            varargin = read_varargin(varargin,{'fmt'},{obj.fmt}); obj.fmt = fmt;
            varargin = read_varargin(varargin,{'units'},{obj.units}); obj.units = units;
            varargin = read_varargin(varargin,{'units_datetime'},{obj.units_datetime}); obj.units_datetime = units_datetime;

            obj.time = [];
            obj.Times = NaT;
            obj.TIME = char;

            switch class(ttime)
                case 'datetime'  % datetime 直接赋值
                    obj.Times = datetime(ttime,'Format',obj.fmt);
                    obj.time = posixtime(obj.Times);
                    obj.TIME = char(datetime(obj.Times,'Format',obj.fmt));
                case {'double', 'single'}
                    obj.time = ttime;  % double or single 赋值,并计算datetime
                    [obj.Times, ~, obj.units_datetime] = cftime(ttime,obj.units);
                    obj.TIME = char(datetime(obj.Times,'Format',obj.fmt));
                case {'char','string'}
                    obj.TIME = ttime;
                    obj.Times = datetime(ttime,'InputFormat',obj.fmt);
                    if isnat(obj.Times)
                        osprints('WARNING', 'Mdatetime: input time convert to datetime failed, please try to transpose matrix.')
                        if input_yn('Do you want to transpose matrix?')
                            obj.Times = datetime(ttime','InputFormat',obj.fmt);
                        end
                    end
                    obj.time = posixtime(obj.Times);
            end
            obj.TIME_str = string(obj.TIME);
            obj.TIME_char = char(obj.TIME);
        end

        %% 当某一个属性被更改，其余一起更改
        % Times被更改
        function obj = set.Times(obj,value)
            obj.Times = value;
            obj.time = posixtime(obj.Times);
            obj.TIME = char(datetime(obj.Times,'Format',obj.fmt));
        end

            
    end
end
