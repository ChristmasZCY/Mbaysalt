function TOOLS = FVCOMTOOLS(funcName)
    %   FVCOM Tools, contains some useful functions for FVCOM model.
    % =================================================================================================================
    % Parameters:
    %       funcName:   input file name || required: False || type: Text || example: 'genFVCOMchar'
    %       varargin:       optional parameters
    % =================================================================================================================
    % Returns:
    %       TOOLS:      FVCOM Tools Struct  || type: struct
    % =================================================================================================================
    % Updates:
    %       2025-01-13:     Created,     by Christmas;
    % =================================================================================================================
    % Examples:
    %       TOOLS = FVCOMTOOLS();
    %       TOOLS = FVCOMTOOLS('genFVCOMchar');
    % =================================================================================================================

    TOOLS = struct();

    % ======== Christmas's Functions========
    TOOLS.read_nml_fvcom                = @read_nml_fvcom;              % 读取FVCOM NML文件
    TOOLS.write_nml_fvcom               = @write_nml_fvcom;             % 写入FVCOM NML文件
    TOOLS.genNML_default                = @genNML_default;              % 生成FVCOM默认NML结构体
    TOOLS.genFVCOMchar                  = @genFVCOMchar;                % 生成FVCOM Title字符串
    TOOLS.convertStruct2char            = @convertStruct2char;          % 将结构体转换为NML字符串
    TOOLS.delete_key                    = @delete_key;                  % 删除NML中的key,如'EMPTYONE'
    TOOLS.checkNML                      = @checkNML;                    % 检查NML结构体
    TOOLS.nmlDomain2FORMAT_WRITE        = @nmlDomain2FORMAT_WRITE;      % 将NML结构体转换为写入格式结构体
    TOOLS.replace_str                   = @replace_str;                 % 替换字符串,如nml_START_DATE-->2019-01-01 00:00:00
    % ======== Siqi's Functions========
    if exist('read_grd', 'file') == 2
        TOOLS.Siqi.read_grd             = @read_grd;                    % Read grd file
        TOOLS.Siqi.write_grd            = @write_grd;                   % Write grd file
        TOOLS.Siqi.read_dep             = @read_dep;                    % Read dep file
        TOOLS.Siqi.write_dep            = @write_dep;                   % Write dep file
        TOOLS.Siqi.read_cor             = @read_cor;                    % Read cor file
        TOOLS.Siqi.write_cor            = @write_cor;                   % Write cor file
        TOOLS.Siqi.read_spg             = @read_spg;                    % Read spg file
        TOOLS.Siqi.write_spg            = @write_spg;                   % Write spg file
        TOOLS.Siqi.read_obc             = @read_obc;                    % Read obc file
        TOOLS.Siqi.write_obc            = @write_obc;                   % Write obc file
        TOOLS.Siqi.read_sigma           = @read_sigma;                  % Read sigma file
        TOOLS.Siqi.write_sigma          = @write_sigma;                 % Write sigma file
        TOOLS.Siqi.write_station        = @write_station;               % Write station file
        TOOLS.Siqi.convert_fvcom_time   = @convert_fvcom_time;          % Convert time to fvcom format
    else
        TOOLS.Siqi = struct('');
    end

    if nargin > 0
        if ~isfield(TOOLS, funcName)
            error('FVCOMTOOLS:funcName', ...
                 ['The function name is not exist in FVCOMTOOLS. \n' ...
                  'Support functions are %s'], strjoin(fieldnames(TOOLS),', '));
        end
        TOOLS = TOOLS.(funcName);
    end

end


function Str = genFVCOMchar(ver, varargin)
    %   Generate FVCOM Title String
    % =================================================================================================================
    % Parameters:
    %       ver:        FVCOM Version  || required: False || type: Text || default: 'none'
    %       varargin:       optional parameters
    % =================================================================================================================
    % Returns:
    %       Str:      FVCOM Title String  || type: Text
    % =================================================================================================================
    % Updates:
    %       2025-01-13:     Created,     by Christmas;
    % =================================================================================================================
    % Examples:
    %       TOOLS = FVCOMTOOLS();
    %       Str = TOOLS.genFVCOMchar();
    % =================================================================================================================
    % References:
    %{
     !================================================================!
       _______  _     _  _______  _______  _______  ______     _____
      (_______)(_)   (_)(_______)(_______)(_______)(_____ \   (_____)
       _____    _     _  _        _     _  _  _  _  _____) )  _  __ _
      |  ___)  | |   | || |      | |   | || ||_|| |(_____ (  | |/ /| |
      | |       \ \ / / | |_____ | |___| || |   | | _____) )_|   /_| |
      |_|        \___/   \______) \_____/ |_|   |_|(______/(_)\_____/
      -- Beta Release
     !================================================================!
     !                                                                !
     !========DOMAIN DECOMPOSITION USING: METIS 4.0.1 ================!
     !======Copyright 2024, Regents of University of Minnesota========!
     !                                                                !
    %}
    % =================================================================================================================

    if nargin == 0
        Str = [' !================================================================!' newline ...
               '           _______  _     _  _______  _______  _______             ' newline ...
               '          (_______)(_)   (_)(_______)(_______)(_______)            ' newline ...
               '           _____    _     _  _        _     _  _  _  _             ' newline ...
               '          |  ___)  | |   | || |      | |   | || ||_|| |            ' newline ...
               '          | |       \ \ / / | |_____ | |___| || |   | |            ' newline ...
               '          |_|        \___/   \______) \_____/ |_|   |_|            ' newline ...
               '   -- Version 5.0 Release                                          ' newline ...
               ' !================================================================!' newline ...
               ' !                                                                !' newline ...
               ' !========DOMAIN DECOMPOSITION USING: METIS 4.0.1 ================!' newline ...
               ' !======Copyright 1998, Regents of University of Minnesota========!' newline ...
               ' !                                                                !'];
    elseif floor(ver) == 3
        Str = [' !================================================================!' newline ...
               '   _______  _     _  _______  _______  _______  ______     _____  ' newline ...
               '  (_______)(_)   (_)(_______)(_______)(_______)(_____ \   (_____) ' newline ...
               '   _____    _     _  _        _     _  _  _  _  _____) )  _  __ _ ' newline ...
               '  |  ___)  | |   | || |      | |   | || ||_|| |(_____ (  | |/ /| |' newline ...
               '  | |       \ \ / / | |_____ | |___| || |   | | _____) )_|   /_| |' newline ...
               '  |_|        \___/   \______) \_____/ |_|   |_|(______/(_)\_____/ ' newline ...
               '  -- Beta Release                                                 ' newline ...
               ' !================================================================!' newline ...
               ' !                                                                !' newline ...
               ' !========DOMAIN DECOMPOSITION USING: METIS 4.0.1 ================!' newline ...
               ' !======Copyright 1998, Regents of University of Minnesota========!' newline ...
               ' !                                                                !'];
    end
end


function Str = convertStruct2char(Struct, NAME, varargin)
    %   Convert Struct to String
    % =================================================================================================================
    % Parameters:
    %       Struct:     NML struct      || required: True || type: struct
    %       NAME:       NML title name  || required: True || type: Text
    %       varargin:       optional parameters
    % =================================================================================================================
    % Returns:
    %       Str:        NML char  || type: Text
    % =================================================================================================================
    % Updates:
    %       2025-01-13:     Created,     by Christmas;
    % =================================================================================================================
    % Examples:
    %       TOOLS = FVCOMTOOLS();
    %       NML = TOOLS.genNML_default();
    %       Str = TOOLS.convertStruct2char(NML.NML_CASE, 'NML_CASE');
    % =================================================================================================================
    % References:
    %{
     Struct.CASE_TITLE = 'FVCOM';
     Struct.TIMEZONE = 'UTC';
     Struct.DATE_FORMAT = 'YMD';
     Struct.DATE_REFERENCE = 'default';
     Struct.START_DATE = '2019-01-01 00:00:00';
     Struct.END_DATE = '2019-01-01 00:00:00';
     NAME = 'NML_CASE';
    % -->
        &NML_CASE
        CASE_TITLE = 'FVCOM',
        TIMEZONE = 'UTC',
        DATE_FORMAT = 'YMD',
        DATE_REFERENCE = 'default',
        START_DATE = '2019-01-01 00:00:00',
        END_DATE = '2019-01-01 00:00:00',
        /
    %}
    % =================================================================================================================

    Struct = nmlDomain2FORMAT_WRITE(Struct);

    LEN.key = max(cellfun(@(x) length(x), fieldnames(Struct)));
    LEN.value = max(structfun(@(x) length(x), Struct));

    Str = [' &' NAME newline];  % &NML_CASE
    fields = fieldnames(Struct);
    for i = 1:length(fields)
        % 左边的长度为LEN.key, 右边的长度为LEN.value
        if startsWith(fields{i}, 'ANNOTATION__')
            key = replace(fields{i}, 'ANNOTATION__', '! ');
        else
            key = fields{i};
        end
        Str = [Str ' ' pad(key, LEN.key) ' = ' pad(Struct.(fields{i}), LEN.value) ',' newline];
%        Str = [Str ' ' pad(fields{i}, LEN.key) ' = ' pad(Struct.(fields{i}), LEN.value) ', ' newline];
    end
    Str = [Str ' /'];  % /
end


function NML = delete_key(NML, keyname, varargin)
    %   删除NML.NML_CASE中的'EMPTYONE'
    % =================================================================================================================
    % Parameters:
    %       NML:    NML struct      || required: True || type: struct
    %       keyname:    key name    || required: True || type: Text
    %       varargin:       optional parameters
    % =================================================================================================================
    % Returns:
    %       NML:        NML struct  || type: struct
    % =================================================================================================================
    % Updates:
    %       2025-01-13:     Created,     by Christmas;
    % =================================================================================================================
    % Examples:
    %       TOOLS = FVCOMTOOLS();
    %       NML = TOOLS.genNML_default();
    %       NML = TOOLS.delete_key(NML, 'EMPTYONE');
    % =================================================================================================================

    fields = fieldnames(NML);
        for ia = fields'
            field = ia{1};
            if strcmp(field, 'FVCOMTITLE')
                continue
            end
            % 如果NML.(field)的key有EMPTYONE开头的，删除此key
            key = fieldnames(NML.(field));
            for i = 1 : len(key)
                if startsWith(key{i}, keyname)
                    NML.(field) = rmfield(NML.(field), key{i});
                end
            end

        end
end


function NML = genNML_default(varargin)
    %   Gerenate default NML struct from FVCOM_DEFAULT.nml
    % =================================================================================================================
    % Parameters:
    %       varargin:       optional parameters
    % =================================================================================================================
    % Returns:
    %       NML:        NML struct  || type: struct
    % =================================================================================================================
    % Updates:
    %       2025-01-13:     Created,     by Christmas;
    % =================================================================================================================
    % Examples:
    %       TOOLS = FVCOMTOOLS();
    %       NML = TOOLS.genNML_default();
    % =================================================================================================================

    mfilepath = mfilename('fullpath');
    NML_default = fullfile(fileparts(fileparts(mfilepath)), 'Examples','FVCOM_DEFAULT.nml');
    NML = read_nml_fvcom(NML_default);

end


function NML_domain = nmlDomain2FORMAT_WRITE(NML_domain, varargin)
    %   Convert NML struct to FORMAT_WRITE struct
    % =================================================================================================================
    % Parameters:
    %       NML_domain:     NML domain struct              || required: True || type: struct
    %       varargin:       optional parameters
    % =================================================================================================================
    % Returns:
    %       NML_domain:     FORMAT_WRITE domain struct     || type: struct
    % =================================================================================================================
    % Updates:
    %       2025-01-14:     Created,     by Christmas;
    % =================================================================================================================
    % Examples:
    %       TOOLS = FVCOMTOOLS();
    %       NML = TOOLS.genNML_default();
    %       NML_FORMAT_WRITE = TOOLS.nmlDomain2FORMAT_WRITE(NML.NML_CASE);
    % =================================================================================================================

    fields = fieldnames(NML_domain);
    for i = 1:length(fields)

        % datetime to char
        if isa(NML_domain.(fields{i}), 'datetime')
            NML_domain.(fields{i}) = datestr(NML_domain.(fields{i}), 'yyyy-mm-dd HH:MM:SS');
        end
        if isa(NML_domain.(fields{i}), 'char')
            % add the first '
            if ~ startsWith(NML_domain.(fields{i}), '''')
                NML_domain.(fields{i}) = ['''' NML_domain.(fields{i})];
            end
            % add the last '
            if ~ endsWith(NML_domain.(fields{i}), '''')
                NML_domain.(fields{i}) = [NML_domain.(fields{i}) ''''];
            end
        end
        % 0 to '0.0000000E+00' and logical to 'T' or 'F'
        if isa(NML_domain.(fields{i}), 'double') && NML_domain.(fields{i}) == 0
            NML_domain.(fields{i}) = num2str(NML_domain.(fields{i}),'%0.7E');
        elseif isa(NML_domain.(fields{i}), 'logical')
            if NML_domain.(fields{i})
                NML_domain.(fields{i}) = 'T';
            else
                NML_domain.(fields{i}) = 'F';
            end
        end
        % double to str
        if isa(NML_domain.(fields{i}), 'double')
            NML_domain.(fields{i}) = num2str(NML_domain.(fields{i}), '%.2f');
        end
    end
end


function NML = checkNML(NML, varargin)
    %   Check NML struct
    % =================================================================================================================
    % Parameters:
    %       NML:        NML struct  || required: True || type: struct
    %       varargin:       optional parameters
    % =================================================================================================================
    % Returns:
    %       NML:        NML struct  || type: struct
    % =================================================================================================================
    % Updates:
    %       2025-01-13:     Created,     by Christmas;
    % =================================================================================================================
    % Examples:
    %       TOOLS = FVCOMTOOLS();
    %       NML = TOOLS.genNML_default();
    %       NML = TOOLS.checkNML(NML);
    % =================================================================================================================

end


function replace_str(fin, fout, oldStr, newStr, varargin)
    %   Replace old string with new string
    % =================================================================================================================
    % Parameters:
    %       fin:        input file      || required: True || type: File  || example: '*.nml'
    %       fout:       output file     || required: True || type: File  || example: '*.nml'
    %       oldStr:     old string      || required: True || type: Text  || example: 'nml_START_DATE'
    %       newStr:     new string      || required: True || type: Text  || example: '2019-01-01 00:00:00'
    %       varargin:       optional parameters
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Updates:
    %       2025-01-14:     Created,     by Christmas;
    % =================================================================================================================
    % Examples:
    %       TOOLS = FVCOMTOOLS();
    %       TOOLS.replace_str('test_run.nml', 'test2_run.nml', 'nml_START_DATE', '2019-01-01 00:00:00');
    % =================================================================================================================

    C_old = fileread(fin);
    C_new = replace(C_old, oldStr, newStr);

    fid = fopen(fout, 'w');
    fprintf(fid, '%s', C_new);
    fclose(fid);

end
