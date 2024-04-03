function STATUS = nc_attrValue_exist(fin, attr_str, varargin)
    %       Check if attr_str in file var attribute Value
    % =================================================================================================================
    % Parameter:
    %       fin:             file name               || required: True || type: Text || format: 'test.nc'
    %       attr_str:        attribute str           || required: True || type: Text || format: 'FVCOM'
    %       varargin:       optional parameters      
    %           varName:    variable name            || required: False|| type: Text || default: 'GLOBAL'
    %           method:     method to check          || required: False|| type: Text || default: 'AUTO'
    % =================================================================================================================
    % Returns:
    %       STATUS:          1 if the variable exists, 0 otherwise
    % =================================================================================================================
    % Update:
    %       2024-04-03:     Created, by Christmas;
    % =================================================================================================================
    % Example:
    %       STATUS = nc_attrValue_exist('test.nc', 'FVCOM')
    %       STATUS = nc_attrValue_exist('test.nc', 'FVCOM', 'method', 'START')
    %       STATUS = nc_attrValue_exist('test.nc', 'FVCOM', 'hs', 'method', 'END')
    %       STATUS = nc_attrValue_exist('test.nc', 'FVCOM', 'GLOBAL', 'method', 'END')
    % =================================================================================================================
    
    arguments (Input)
        fin {mustBeFile}
        attr_str {mustBeText}
    end

    arguments (Input, Repeating)
        varargin 
    end

    varargin = read_varargin(varargin, {'method'}, {'AUTO'});

    if ~isempty(varargin)
        varName = varargin{1};
    else
        varName = 'GLOBAL';
    end

    nc_info = ncinfo(fin);
    
    switch varName
        case {'GLOBAL', '-1'}
            AttributeValues = {nc_info.Attributes.Value};
        otherwise
            variableNames = {nc_info.Variables.Value};
            if ~any(strcmp(variableNames, varName))
                STATUS = 0;
                return
            end
            for i = 1:length(nc_info.Variables)
                if strcmp(nc_info.Variables(i).Value, varName)
                    AttributeValues = {nc_info.Variables(i).Attributes.Value};
                    break
                end
            end
    end

    switch upper(method)
    case 'AUTO'
        if contains(attr_str,{'*','?','+'})  % *WAVEWATCH*
            STATUS = any(cellfun(@(name) ~isempty(regexp(name, attr_str, 'once')), AttributeValues));
        else
            STATUS = any(strcmp(AttributeValues, attr_str));
        end
    case 'START'
        STATUS = any(cellfun(@(x) startsWith(x, attr_str), AttributeValues));
    case 'END'
        STATUS = any(cellfun(@(x) endsWith(x, attr_str), AttributeValues));
    case 'STRCMP'
        STATUS = any(cellfun(@(x) strcmp(x, attr_str), AttributeValues));
    case 'CONTAINS'
        STATUS = any(cellfun(@(x) contains(x, attr_str), AttributeValues));
    otherwise 
        error("Method_read must be one of 'AUTO', 'START', 'END', 'STRCMP', 'CONTAINS' !")
    end
end
