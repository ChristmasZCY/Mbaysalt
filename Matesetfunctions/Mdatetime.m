classdef Mdatetime 
    %       Mdatetime is a class for time conversion among datetime and posixtime and char and string
    % =================================================================================================================
    % Parameter:
    %      ttime:               time                    || required: True || type: datetime or posixtime or char or string
    %       varargin:           optional parameters     
    %           fmt:            format of datetime      || required: False|| type: char      || default: 'yyyy-MM-dd HH:mm:ss'
    %           units:          units of posixtime      || required: False|| type: char      || default: 'seconds since 1970-01-01 00:00:00'
    %           units_datetime: units of datetime       || required: False|| type: datetime  || default: datetime(1970,1,1,0,0,0)
    %           Cdatenum:       Convert from datenum    || required: False|| type: double    || example:  739341
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Update:
    %       ****-**-**:     Created, by Christmas;
    %       2024-04-03:     Added datenum, by Christmas
    %       2024-04-03:     Added Mdatetime(), by Christmas
    % =================================================================================================================
    % Example:
    %       Ttime = Mdatetime(Times)
    %       Ttime = Mdatetime(time)
    %       Ttime = Mdatetime(time,'units','seconds since 1970-01-01 00:00:00')
    %       Ttime = Mdatetime(TIME,'fmt','yyyy-MM-dd HH:mm:ss')
    %       Ttime = Mdatetime(string(TIME),'fmt','yyyy-MM-dd HH:mm:ss')
    %       Ttime = Mdatetime(739341, 'Cdatenum')
    % =================================================================================================================

    properties
        time
        Times
        TIME
        TIME_str
        TIME_char
        datenum
        units = 'seconds since 1970-01-01 00:00:00'
        units_datetime = datetime(1970,1,1,0,0,0);
        fmt = 'yyyy-MM-dd HH:mm:ss'
    end
    methods
        function obj = Mdatetime(ttime, varargin)

            varargin = read_varargin(varargin,{'fmt'},{obj.fmt}); obj.fmt = fmt;
            varargin = read_varargin(varargin,{'units'},{obj.units}); obj.units = units;
            varargin = read_varargin(varargin,{'units_datetime'},{obj.units_datetime}); obj.units_datetime = units_datetime;
            varargin = read_varargin2(varargin,{'Cdatenum'});

            obj.time = [];
            obj.datenum = [];
            obj.Times = NaT;
            obj.TIME = char;

            if ~exist('ttime','var')
                return
            end

            if isempty(Cdatenum)

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
                            osprint2('WARNING', 'Mdatetime: input time convert to datetime failed, please try to transpose matrix.')
                            if input_yn('Do you want to transpose matrix?')
                                obj.Times = datetime(ttime','InputFormat',obj.fmt);
                            end
                        end
                        obj.time = posixtime(obj.Times);
                end
                obj.datenum = datenum(obj.Times);
            else
                obj.datenum = ttime;
                obj.Times = datetime(obj.datenum, 'ConvertFrom','datenum');
                obj.time = posixtime(obj.Times);
                obj.TIME = char(datetime(obj.Times,'Format',obj.fmt));
            end
            obj.TIME_str = string(obj.TIME);
            obj.TIME_char = char(obj.TIME);
            
        end

        %% 当某一个属性被更改，其余一起更改(已废弃)
        % Times被更改
        function obj = set.Times(obj,value)
            obj.Times = value;
            obj.time = posixtime(obj.Times);
            obj.TIME = char(datetime(obj.Times,'Format',obj.fmt));
        end

            
    end
end
