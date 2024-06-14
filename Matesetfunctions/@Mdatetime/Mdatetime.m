classdef Mdatetime
    %       Mdatetime is a class for time conversion among datetime and posixtime and char and string
    % =================================================================================================================
    % Parameter:
    %      ttime:               time                    || required: True || type: datetime or posixtime or char or string
    %       varargin:   (optional)
    %           fmt:            format of datetime      || required: False|| type: char      || default: 'fmt','yyyy-MM-dd HH:mm:ss'
    %           units:          units of posixtime      || required: False|| type: char      || default: 'units','seconds since 1970-01-01 00:00:00'
    %           units_datetime: units of datetime       || required: False|| type: datetime  || default: 'units_datetime',datetime(1970,1,1,0,0,0)
    %           Cdatenum:       Convert from datenum    || required: False|| type: double    || example:  'Cdatenum'
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Update:
    %       ****-**-**:     Created,                            by Christmas;
    %       2024-04-03:     Added datenum,                      by Christmas;
    %       2024-04-03:     Added Mdatetime(),                  by Christmas;
    %       2024-04-04:     Rewrite length ,                    by Christmas;
    %       2024-04-15:     Added set value,                    by Christmas;
    %       2024-05-13:     Change judge method at 'set.TIME',  by Christmas;
    % =================================================================================================================
    % Example:
    %       Ttimes = Mdatetime(Times)
    %       Ttimes = Mdatetime(time)
    %       Ttimes = Mdatetime(time,'units','seconds since 1970-01-01 00:00:00')
    %       Ttimes = Mdatetime(TIME,'fmt','yyyy-MM-dd HH:mm:ss')
    %       Ttimes = Mdatetime(string(TIME),'fmt','yyyy-MM-dd HH:mm:ss')
    %       Ttimes = Mdatetime(739341, 'Cdatenum')
    % =================================================================================================================

    properties
        time        % posixtime
        Times       % datetime
        TIME        % char
        TIME_str    % string
        TIME_char   % char
        datenumC    % datenum
        units = 'seconds since 1970-01-01 00:00:00'
        units_datetime = datetime(1970,1,1,0,0,0);
        fmt = 'yyyy-MM-dd HH:mm:ss'
        TimeZone = 'UTC'
    end

    properties (SetAccess=private)
    end

    methods
        function obj = Mdatetime(ttime, varargin)

            varargin = read_varargin(varargin,{'fmt'},{obj.fmt}); obj.fmt = fmt;
            varargin = read_varargin(varargin,{'units'},{obj.units}); obj.units = units;
            varargin = read_varargin(varargin,{'units_datetime'},{obj.units_datetime}); obj.units_datetime = units_datetime;
            varargin = read_varargin(varargin,{'TimeZone'},{'UTC'}); obj.TimeZone = TimeZone;
            varargin = read_varargin2(varargin,{'Cdatenum'}); %#ok<NASGU>

            obj.time = [];
            obj.datenumC = [];
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
                        obj.time = ttime;  % double or single 赋值, 并计算datetime
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
                obj.datenumC = datenum(obj.Times); %#ok<*DATNM>
            else
                obj.datenumC = ttime;
                obj.Times = datetime(obj.datenumC, 'ConvertFrom','datenum');
                obj.time = posixtime(obj.Times);
                obj.TIME = char(datetime(obj.Times,'Format',obj.fmt));
            end
            obj.TIME_str = string(obj.TIME);
            obj.TIME_char = char(obj.TIME);
            obj.Times = datetime(obj.Times, 'Format', obj.fmt);

        end
    end

    methods (Hidden=true)
        function len = length(obj)
            len = length(obj.Times);
        end
        function len = len(obj)
            len = length(obj.Times);
        end
        function [M,I] = min(obj)
            [M,I] = min(obj.Times);
        end
        function [M,I] = max(obj)
            [M,I] = max(obj.Times);
        end
        function tf = isnat(obj)
            tf = isnat(obj.Times);
        end
    end

    methods
        % function obj = Change_TimeZone(obj, value)
        %     obj.TimeZone = value;
        % 
        % end
    end

    methods
        function obj = set.fmt(obj,value)
            %{
            % time                  X
            % Times                 X
            % TIME                  X
            % TIME_str              X
            % TIME_char             X
            % datenumC              O
            % units                 O
            % units_datetime        X
            % fmt                  XXX
            %}
            obj.fmt = value;
            if ~isempty(obj.Times) && ~isnat(obj.Times)
                TIME_new = char(datetime(obj.Times,'Format',obj.fmt));
                if ~isequaln(TIME_new, obj.TIME)
                    obj.Times = datetime(obj.Times,'Format',obj.fmt); %#ok<*MCSUP>
                    obj.TIME = char(obj.Times);
                    obj.TIME_str = string(obj.Times);
                    obj.TIME_char = char(datetime(obj.Times));
                    obj.units_datetime = datetime(obj.units_datetime,'Format',value);
                    obj.time = posixtime(obj.Times);
                end
            else
            end
        end

        function obj = set.time(obj,value)
            %{
            % time                 XXX
            % Times                 X
            % TIME                  X
            % TIME_str              X
            % TIME_char             X
            % datenumC              X
            % units                 O
            % units_datetime        O
            % fmt                   O
            %}
            obj.time = value;
            Times_new = cftime(obj.time, obj.units);
            if ~isempty(obj.Times) % && ~isnat(obj.Times)
                if ~isequaln(Times_new, obj.Times)
                    obj.Times = cftime(obj.time,obj.units);
                    obj.time = posixtime(obj.Times);
                    obj.TIME = char(obj.Times);
                    obj.TIME_str = string(obj.Times);
                    obj.TIME_char = char(obj.Times);
                    obj.datenumC = datenum(obj.Times);
                end
            end
            clear Times_new
        end

        function obj = set.Times(obj,value)
            %{
            % time                  X
            % Times                XXX
            % TIME                  X
            % TIME_str              X
            % TIME_char             X
            % datenumC              O
            % units                 O
            % units_datetime        O
            % fmt                   O
            %}
            obj.Times = value;
            obj.Times.Format = obj.fmt;
            time_new = posixtime(obj.Times);
            if ~isequaln(time_new, obj.time)
                % obj.time = posixtime(obj.Times);
                obj.time = seconds(duration((obj.Times - obj.units_datetime),"Format","s"));
                obj.TIME = char(obj.Times);
                obj.TIME_str = string(obj.Times);
                obj.TIME_char = char(obj.Times);
                obj.datenumC = datenum(obj.Times);
            end
            clear time_new
        end

        function obj = set.TIME(obj,value)
            %{
            % time                  X
            % Times                 X
            % TIME                 XXX
            % TIME_str              X
            % TIME_char             X
            % datenumC              X
            % units                 O
            % units_datetime        O
            % fmt                   O
            %}
            obj.TIME = value;
            % --> Christmas, Change judge method
            % try
            %     Times_new = datetime(obj.TIME,"Format",obj.fmt);
            % catch
            %     Times_new = datetime(obj.TIME);
            % end
            % if ~isequaln(Times_new, obj.Times)
            %     obj.Times = Times_new;
            TIME_old = char(obj.Times);
            if ~isequaln(TIME_old, obj.TIME)
                obj.Times = datetime(obj.TIME,"Format",obj.fmt);
                % <-- Christmas
                obj.Times.Format = obj.fmt;
                obj.time = posixtime(obj.Times);
                obj.TIME_str = string(obj.Times);
                obj.TIME_char = char(obj.Times);
                obj.datenumC = datenum(obj.Times);
            end
            clear Times_new
        end

        function obj = set.datenumC(obj,value)
            %{
            % time                  X
            % Times                 X
            % TIME                  X
            % TIME_str              X
            % TIME_char             X
            % datenumC             XXX
            % units                 O
            % units_datetime        O
            % fmt                   O
            %}
            obj.datenumC = value;
            Times_new = datetime(obj.datenumC,'ConvertFrom','datenum');
            if ~isequaln(Times_new, obj.Times)
                obj.Times = datetime(obj.datenumC,'ConvertFrom','datenum');
                obj.time = posixtime(obj.Times);
                obj.TIME = char(obj.Times);
                obj.TIME_str = string(obj.Times);
                obj.TIME_char = char(obj.Times);
            end
            clear Times_new
        end

        function obj = set.units(obj,value)
            %{
            % time                  X
            % Times                 O
            % TIME                  O
            % TIME_str              O
            % TIME_char             O
            % datenumC              O
            % units                XXX
            % units_datetime        X
            % fmt                   O
            %}
            obj.units = value;
            [~, ~, units_datetime_new] = cftime(obj.time,obj.units);
            if ~isequaln(units_datetime_new, obj.units_datetime)
                obj.units_datetime = units_datetime_new;
                obj.units_datetime.Format = obj.fmt;
                gap = duration((obj.Times - obj.units_datetime),"Format","s");
                obj.time = seconds(gap);

            end
        end

        function obj = set.TimeZone(obj,value)
            if ~ strcmp(obj.TimeZone, value)
                obj.TimeZone = value;
            end
        end

    end

end

