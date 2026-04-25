function dtype = calc_dtype(values, method, varargin)
    %       Calculates the appropriate netCDF data type for a given array of values.
    % =================================================================================================================
    % Parameter:
    %       values:         data array to analyze        || required: True   || type: array      || format: any numeric array
    %       method:         method used to write nc file || required: False  || type: string     || format: 'LowLevel' or 'HighLevel'
    %       varargin:        optional parameters
    % =================================================================================================================
    % Returns:
    %       dtype:         netCDF data type string       || type: string
    % =================================================================================================================
    % Updates:
    %       2026-04-25:     Created,                by Christmas;
    % =================================================================================================================
    % References:
    %       NetCDF类型      C类型               numpy类型 / dtype            MATLAB类型1      MATLAB类型2      默认缺测值常量    字节数             说明
    %       byte           signed char         np.int8                      int8            NC_BYTE         NC_FILL_BYTE     1        NetCDF3/4 有符号 8 位整数
    %       short          short               np.int16                     int16           NC_SHORT        NC_FILL_SHORT    2        NetCDF3/4 有符号 16 位整数
    %       int            int                 np.int32                     int32           NC_INT          NC_FILL_INT      4        NetCDF3/4 有符号 32 位整数
    %       int64          long long           np.int64                     int64           NC_INT64        NC_FILL_INT64    8        NetCDF4 有符号 64 位整数
    %       ubyte          unsigned char       np.uint8                     uint8           NC_UBYTE        NC_FILL_UBYTE    1        NetCDF4 无符号 8 位整数
    %       ushort         unsigned short      np.uint16                    uint16          NC_USHORT       NC_FILL_USHORT   2        NetCDF4 无符号 16 位整数
    %       uint           unsigned int        np.uint32                    uint32          NC_UINT         NC_FILL_UINT     4        NetCDF4 无符号 32 位整数
    %       uint64         unsigned long long  np.uint64                    uint64          NC_UINT64       NC_FILL_UINT64   8        NetCDF4 无符号 64 位整数
    %       float          float               np.float32                   single          NC_FLOAT        NC_FILL_FLOAT    4        单精度浮点
    %       double         double              np.float64                   double          NC_DOUBLE       NC_FILL_DOUBLE   8        双精度浮点
    %       char           char                'S1' / '|S1'                 char            NC_CHAR         NC_FILL_CHAR     1        单个字符（NetCDF classic 字符类型）
    %       string         -                   <U19 / str> / object         string          NC_STRING       NC_FILL_STRING   变长      xarray/Python 字符串；NetCDF4 常为变长字符串
    % =================================================================================================================
    % Example:
    %       dtype = calc_dtype(T2);
    %       dtype = calc_dtype(T2, 'LowLevel');
    %       dtype = calc_dtype(T2, 'HighLevel');
    % =================================================================================================================

    if nargin < 2
        method = 'LowLevel';
    end

    if isstring(values)
        if strcmpi(method, 'HighLevel'); dtype = 'string'; else; dtype = 'NC_STRING'; end
        return
    elseif ischar(values)
        if strcmpi(method, 'HighLevel'); dtype = 'char'; else; dtype = 'NC_CHAR'; end
        return
    end

    arr = values(:);
    arr = arr(isfinite(arr)); % 只考虑有限值，排除 NaN / Inf

    % 空数组
    if isempty(arr)
        if strcmpi(method, 'HighLevel'); dtype = 'single'; else; dtype = 'NC_FLOAT'; end
        return
    end

    % 如果是浮点，判断有没有小数部分
    if isfloat(arr)

        if all(arr == floor(arr))
            % 浮点但全是整数值，按整数范围判断
            valid_min = min(arr);
            valid_max = max(arr);
        else
            % 有小数部分，判断 single 是否足够
            arr_single = cast(single(arr), class(arr));
            diffv = abs(double(arr) - double(arr_single));
            tol = 1e-6 * abs(double(arr_single));

            if all(diffv <= tol)
                if strcmpi(method, 'HighLevel'); dtype = 'single'; else; dtype = 'NC_FLOAT'; end
            else
                if strcmpi(method, 'HighLevel'); dtype = 'double'; else; dtype = 'NC_DOUBLE'; end
            end
            return
        end

    else
        % 本身就是整数类型
        valid_min = min(arr);
        valid_max = max(arr);
    end

    % 按有符号整数范围选择最小类型
    if valid_min >= intmin('int8') && valid_max <= intmax('int8')
        if strcmpi(method, 'HighLevel'); dtype = 'int8'; else; dtype = 'NC_BYTE'; end
    elseif valid_min >= intmin('int16') && valid_max <= intmax('int16')
        if strcmpi(method, 'HighLevel'); dtype = 'int16'; else; dtype = 'NC_SHORT'; end
    elseif valid_min >= intmin('int32') && valid_max <= intmax('int32')
        if strcmpi(method, 'HighLevel'); dtype = 'int32'; else; dtype = 'NC_INT'; end
    elseif valid_min >= intmin('int64') && valid_max <= intmax('int64')
        if strcmpi(method, 'HighLevel'); dtype = 'int64'; else; dtype = 'NC_INT64'; end
    else
        if strcmpi(method, 'HighLevel'); dtype = 'double'; else; dtype = 'NC_DOUBLE'; end
    end

end
