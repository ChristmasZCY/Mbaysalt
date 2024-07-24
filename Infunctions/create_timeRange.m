function [Times, Ttimes] = create_timeRange(dmt_start, dmt_end, str_interval)
    %       Create datetime type time-Range
    % =================================================================================================================
    % Parameters:
    %       dmt_start:      time-Start          || required: True || type: datetime || example: datetime(2024, 05, 22, 0, 0, 0)
    %       dmt_end:        time-End            || required: True || type: datetime || example: datetime(2024, 06, 02, 0, 0, 0)
    %       str_interval:   time-Interval       || required: True || type: Text     || example: '1h'
    %       varargin:   (options)               || required: False|| as follow:
    % =================================================================================================================
    % Returns:
    %       Times:      time-Range      || type: datetime  || format: 1D
    %       Ttimes:     time-Range      || type: Mdatetime || format: 1D
    % =================================================================================================================
    % Updates:
    %       2024-05-27:     Created, by Christmas;
    % =================================================================================================================
    % Examples:
    %       [Times, Ttimes] = create_timeRange([2024, 05, 22, 0, 0, 0], [2024, 06, 02, 0, 0, 0], '1days');
    %       Times = create_timeRange(datetime(2024, 05, 22, 0, 0, 0), datetime(2024, 06, 02, 0, 0, 0), '1d');
    %       [Times, Ttimes] = create_timeRange(datetime(2024, 05, 22, 0, 0, 0), datetime(2024, 06, 02, 0, 0, 0), '1h');
    %       [Times, Ttimes] = create_timeRange(datetime(2024, 05, 22, 0, 0, 0), datetime(2024, 06, 02, 0, 0, 0), '1hour');
    %       [Times, Ttimes] = create_timeRange(datetime(2024, 05, 22, 0, 0, 0), datetime(2024, 06, 02, 0, 0, 0), '1hours');
    % =================================================================================================================
    
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
    
    Times = (datetime(dmt_start):dmt_interval:datetime(dmt_end))';
    if nargout > 1 
        Ttimes = Mdatetime(Times);
    end

end
