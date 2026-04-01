function [scale_factor, add_offset, data2] = calc_scale_offset(data, dtype, varargin)
    %       Calculate the scale and offset for netCDF variable
    % =================================================================================================================
    % Parameters:
    %       data:    the data to be scaled and offset               || required: True  || type: matrix
    %       dtype:   data type, such as 'int16'', etc.              || required: False || type: char   || default: 'int16'
    %       varargin: (optional)
    % =================================================================================================================
    % Returns:
    %       scale_factor:   the scale factor for netCDF variable
    %       add_offset:     the add offset for netCDF variable
    %       data2:          data after scaling and offsetting, i.e., data2 = (data - add_offset) / scale_factor
    % =================================================================================================================
    % Updates:
    %       2026-03-30:     Created, by Christmas;
    % =================================================================================================================
    % Examples:
    %       [scale_factor, add_offset] = calc_scale_offset(data);
    %       [scale_factor, add_offset] = calc_scale_offset(data, 'int16');
    %       [scale_factor, add_offset, data2] = calc_scale_offset(data, 'int16');
    % =================================================================================================================
    % Reference:
    %   See also CALC_SCALE_OFFSET
    %   <a href="matlab: matlab.desktop.editor.openAndGoToLine(which('calc_scale_offset.m'), 2); ">see Description</a>
    %   data2 = (data - add_offset) / scale_factor
    %   data = data2 * scale_factor + add_offset
    % =================================================================================================================

    arguments(Input)
        data
        dtype char {mustBeMember(dtype, {'int8', 'uint8', 'int16', 'uint16', 'int32', 'uint32'})} = 'int16'
    end
    arguments(Repeating)
        varargin
    end

    % 判断data是不是全nan，如果是，则设置scale_factor为1，add_offset为0，并返回
    if all(isnan(data(:)))
        scale_factor = 1;
        add_offset = 0;
        if nargout > 2
            data2 = cast(data, dtype);
        end
        return;
    end

    valid_min = min(data(:),[],'omitnan');
    valid_max = max(data(:),[],'omitnan');

    packed_min = double(intmin(dtype))+1;
    packed_max = double(intmax(dtype))-1;

    % Calculate the scale
    if isaequal(valid_min, valid_max)
        scale_factor = 1; % Avoid division by zero
        add_offset = valid_min; % Set offset to the constant value

    else
        scale_factor = (valid_max - valid_min) / (packed_max - packed_min);
        add_offset = valid_min - packed_min * scale_factor;
    end
    if nargout > 2
        data2 = (data - add_offset) / scale_factor;
        data2 = cast(data2, dtype);
    end

end
