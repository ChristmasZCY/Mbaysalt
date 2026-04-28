function fill_value = calc_fillvalue(dtype, varargin)
    %       Calculates fill value constant for a given netCDF data type.
    % =================================================================================================================
    % Parameter:
    %       dtype:          netCDF data type string       || required: True   || type: string     || example: 'NC_FLOAT', 'int16', 'string', etc.
    %       varargin: (optional) Additional arguments for future use
    % =================================================================================================================
    % Returns:
    %       fill_value:    fill value constant for the given netCDF data type
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
    %       fill_value = calc_fillvalue('NC_FLOAT');
    %       fill_value = calc_fillvalue('int16');
    %       fill_value = calc_fillvalue('string');
    % =================================================================================================================

    dtype = string(dtype);

    switch upper(dtype)
        case {"SINGLE", "NC_FLOAT"}
            fill_value = realmax('single');
        case {"DOUBLE", "NC_DOUBLE"}
            fill_value = realmax('double');
        case {"INT8", "NC_BYTE"}
            fill_value = intmin('int8');
        case {"INT16", "NC_SHORT"}
            fill_value = intmin('int16');
        case {"INT32", "NC_INT"}
            fill_value = intmin('int32');
        case {"INT64", "NC_INT64"}
            fill_value = intmin('int64');
        case {"UINT8", "NC_UBYTE"}
            fill_value = intmax('uint8');
        case {"UINT16", "NC_USHORT"}
            fill_value = intmax('uint16');
        case {"UINT32", "NC_UINT"}
            fill_value = intmax('uint32');
        case {"UINT64", "NC_UINT64"}
            fill_value = intmax('uint64');
        case {"CHAR", "NC_CHAR"}
            fill_value = netcdf.getConstant('NC_FILL_CHAR');
        case {"STRING", "NC_STRING"}
            fill_value = netcdf.getConstant('NC_FILL_STRING');
        otherwise
            error('Unsupported data type: %s', dtype);
    end

end
