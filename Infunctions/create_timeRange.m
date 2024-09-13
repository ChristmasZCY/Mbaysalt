function [Times, Ttimes] = create_timeRange(dmt_start, varargin)
    %       Create datetime type time-Range
    % =================================================================================================================
    % Parameters:
    %       dmt_start:      time-Start          || required: True || type: datetime || example: datetime(2024, 05, 22, 0, 0, 0)
    %       1.
    %       dmt_end:        time-End            || required: True || type: datetime || example: datetime(2024, 06, 02, 0, 0, 0)
    %       str_interval:   time-Interval       || required: True || type: Text     || example: '1h'
    %       2.
    %       dmt_len:        time-Len            || required: True || type: double   || example: 20
    %       str_interval:   time-Interval       || required: True || type: Text     || example: '1h'
    %       varargin:   (options)               || required: False|| as follow:
    % =================================================================================================================
    % Returns:
    %       Times:      time-Range      || type: datetime  || format: 1D
    %       Ttimes:     time-Range      || type: Mdatetime || format: 1D
    % =================================================================================================================
    % Updates:
    %       2024-05-27:     Created,        by Christmas;
    %       2024-09-13:     Added usage2,   by Christmas;
    % =================================================================================================================
    % Examples:
    %       [Times, Ttimes] = create_timeRange([2024, 05, 22, 0, 0, 0], [2024, 06, 02, 0, 0, 0], '1days');
    %       Times = create_timeRange(datetime(2024, 05, 22, 0, 0, 0), datetime(2024, 06, 02, 0, 0, 0), '1d');
    %       [Times, Ttimes] = create_timeRange(datetime(2024, 05, 22, 0, 0, 0), datetime(2024, 06, 02, 0, 0, 0), '1h');
    %       [Times, Ttimes] = create_timeRange(datetime(2024, 05, 22, 0, 0, 0), datetime(2024, 06, 02, 0, 0, 0), '1hour');
    %       [Times, Ttimes] = create_timeRange(datetime(2024, 05, 22, 0, 0, 0), datetime(2024, 06, 02, 0, 0, 0), '1hours');
    %       Times = create_timeRange(datetime(2024, 05, 22, 0, 0, 0), 20, '1d');
    % =================================================================================================================

    narginchk(3, 3);
    if isa(varargin{1},"datetime")
        dmt_end = varargin{1};
    else
        dmt_len = varargin{1};
    end
    if exist("dmt_end", "var") || exist("dmt_len", "var")
        varargin(1) = [];
    end
    str_interval = varargin{1};
    varargin(1) = []; %#ok<NASGU>
    
    str_interval = convertStringsToChars(str_interval);
    letter = lower(regexp(str_interval, '[a-zA-Z]+', 'match'));
    number = str2double(regexp(str_interval, '\d+', 'match'));
    switch letter{1}
        case {'y','years','year'}
            dmt_interval = years(number);
        case {'d','days','day'}
            dmt_interval = days(number);
        case {'h','hours','hour'}
            dmt_interval = hours(number);
        case {'m','mins','minute'}
            dmt_interval = minutes(number);
        case {'s','seconds','second'}
            dmt_interval = seconds(number);
        otherwise
            error([' Wrong unit ''%s''\n' ...
                ' Please select one from ''%s'' ''%s'' ''%s'' ''%s'''], letter,'y','d','h','s')
    end

    if exist("dmt_end", "var")
        Times = (datetime(dmt_start):dmt_interval:datetime(dmt_end))';
    else
        dmt_end = dmt_start + dmt_interval*(dmt_len-1);
        Times = (datetime(dmt_start):dmt_interval:datetime(dmt_end))';
    end
    if nargout > 1 
        Ttimes = Mdatetime(Times);
    end

end
