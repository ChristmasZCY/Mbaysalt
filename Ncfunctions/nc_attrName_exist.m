function STATUS = nc_attrName_exist(fin, attr_str, varargin)
    %       Check if attr_str in file var attribute Name
    % =================================================================================================================
    % Parameter:
    %       fin:             file name               || required: True || type: Text || format: 'test.nc'
    %       attr_str:        attribute str           || required: True || type: Text || format: 'WAVEWATCH'
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
    %       STATUS = nc_attrName_exist('test.nc', 'WAVEWATCH')
    %       STATUS = nc_attrName_exist('test.nc', 'WAVEWATCH', 'method', 'START')
    %       STATUS = nc_attrName_exist('test.nc', 'WAVEWATCH', 'hs', 'method', 'END')
    %       STATUS = nc_attrName_exist('test.nc', 'WAVEWATCH', 'GLOBAL', 'method', 'END')
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

    switch upper(varName)
        case {'GLOBAL', '-1'}
            AttributeNames = {nc_info.Attributes.Name};
        otherwise
            variableNames = {nc_info.Variables.Name};
            if ~any(strcmp(variableNames, varName))
                STATUS = 0;
                return
            end
            for i = 1:length(nc_info.Variables)
                if strcmp(nc_info.Variables(i).Name, varName)
                    AttributeNames = {nc_info.Variables(i).Attributes.Name};
                    break
                end
            end
    end

    switch upper(method)
    case 'AUTO'
        if contains(attr_str,{'*','?','+'})  % *WAVEWATCH*
            STATUS = any(cellfun(@(name) ~isempty(regexp(name, attr_str, 'once')), AttributeNames));
        else
            STATUS = any(strcmp(AttributeNames, attr_str));
        end
    case 'START'
        STATUS = any(cellfun(@(x) startsWith(x, attr_str), AttributeNames));
    case 'END'
        STATUS = any(cellfun(@(x) endsWith(x, attr_str), AttributeNames));
    case 'STRCMP'
        STATUS = any(cellfun(@(x) strcmp(x, attr_str), AttributeNames));
    case 'CONTAINS'
        STATUS = any(cellfun(@(x) contains(x, attr_str), AttributeNames));
    otherwise 
        error("Method_read must be one of 'AUTO', 'START', 'END', 'STRCMP', 'CONTAINS' !")
    end
end
