function varargout = time_to_TIME(ptime, varargin)
    % =================================================================================================================
    % discription:
    %       To get TIME, TIME_reference, TIME_start_date, TIME_end_date, time_filename
    % =================================================================================================================
    % parameter:
    %       ptime:           time                    || required: True  || type: double || format: posixtime
    %       time_format:     time format             || required: False || type: string || format: 'yyyy-MM-dd HH:mm:ss'
    %       out_type:        output type             || required: False || type: string || format: 'char' or 'string'
    % =================================================================================================================
    % example:
    %       [TIME, TIME_reference, TIME_start_date, TIME_end_date, time_filename] = time_to_TIME(ptime)
    %       [TIME, TIME_reference, TIME_start_date, TIME_end_date, time_filename] = time_to_TIME(ptime, 'time_format', 'yyyy-MM-dd HH:mm:ss', 'out_type', 'char')
    % =================================================================================================================

    varargin = read_varargin(varargin, {'time_format'}, {'yyyy-MM-dd HH:mm:ss'});
    varargin = read_varargin(varargin, {'out_type'}, {'char'});
    Time = datetime(ptime,'ConvertFrom','posixtime');
    TIME = datetime(Time,'format','yyyy-MM-dd HH:mm:ss');

    TIME_reference = datetime(Time(1),'Format','yyyy-MM-dd');   % TIME:units的时间部分
    TIME_start_date = datetime(Time(1),  'Format','yyyy-MM-dd HH:mm:ss'); % TIME:start_date部分
    TIME_end_date = datetime(Time(end),'Format','yyyy-MM-dd HH:mm:ss'); % TIME:end_date部分
    time_filename = datetime(Time(1),'Format','yyyyMMdd'); % 文件名的时间部分

    switch out_type
        case 'char'
            TIME = char(TIME);
            TIME_reference = char(TIME_reference);
            TIME_start_date = char(TIME_start_date);
            TIME_end_date = char(TIME_end_date);
            time_filename = char(time_filename);

        case 'srting'
            TIME = string(TIME);
            TIME_reference = string(TIME_reference);
            TIME_start_date = string(TIME_start_date);
            TIME_end_date = string(TIME_end_date);
            time_filename = string(time_filename);

        otherwise
            error('out_type must be char or string')
    end

    varargout{1} = TIME;
    varargout{2} = TIME_reference;
    varargout{3} = TIME_start_date;
    varargout{4} = TIME_end_date;
    varargout{5} = time_filename;

end