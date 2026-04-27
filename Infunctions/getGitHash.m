function hash = getGitHash(din, varargin)
    %       Get git hash of the current code
    % =================================================================================================================
    % Parameter:
    %       din:            directory of the code       || required: True  || type: char    || format: './Mbaysalt'
    %       varargin:
    %           len:            length of git hash      || required: False || type: string  || format: 'short' or 'long'     || default: 'short'
    %           opts:           options for git hash    || required: False || type: string  || format: 'local' or 'remote'   || default: 'local'
    %           method:         method to get git hash  || required: False || type: string  || format: 'MATLAB' or 'cmd'     || default: 'auto'
    % =================================================================================================================
    % Returns:
    %       hash:           git hash                || required: True || type: char || format: 'abc1234' or 'abc1234def5678'
    % =================================================================================================================
    % Update:
    %       2026-03-31:     Created, by Christmas;
    % =================================================================================================================
    % Example:
    %       hash = getGitHash('./Mbaysalt');
    %       hash = getGitHash('~/Mbaysalt', 'long');
    %       hash = getGitHash('./Mbaysalt', 'short', 'remote');
    %       hash = getGitHash('./Mbaysalt', 'long', 'local');
    %       hash = getGitHash('./Mbaysalt', 'long', 'local', 'MATLAB');
    % =================================================================================================================

    narginchk(1, 4);

    % 从可变参数中获取len、opts和method的值，如果没有提供则使用默认值
    % 匹配提取
    % len: short or long
    % opts: local or remote
    % method: MATLAB or cmd or auto

    for i = 1:length(varargin)

        if strcmpi(varargin{i}, 'short')
            len = 'short';
        elseif strcmpi(varargin{i}, 'long')
            len = 'long';
        elseif strcmpi(varargin{i}, 'local')
            opts = 'local';
        elseif strcmpi(varargin{i}, 'remote')
            opts = 'remote';
        elseif strcmpi(varargin{i}, 'MATLAB')
            method = 'MATLAB';
        elseif strcmpi(varargin{i}, 'cmd')
            method = 'cmd';
        elseif strcmpi(varargin{i}, 'auto')
            method = 'auto';
        else
            error('Invalid input: %s. Valid options are ''short'', ''long'', ''local'', ''remote'', ''MATLAB'', ''cmd'', or ''auto''.', varargin{i});
        end

    end

    if ~exist('len', 'var')
        len = 'short';
    end

    if ~exist('opts', 'var')
        opts = 'local';
    end

    if ~exist('method', 'var')
        method = 'auto';
    end

    if strcmpi(method, 'auto')

        if ~isMATLABReleaseOlderThan("R2023b") && strcmpi(opts, 'remote') == 0
            method = 'MATLAB';
        else
            method = 'CMD';
            setenv('GIT_SSL_NO_VERIFY', '1'); % export GIT_SSL_NO_VERIFY=1
        end

    end

    din = getPath(din);

    switch upper(method)
        case 'CMD'

            switch lower(opts)
                case 'local'
                    cmd = sprintf('git -C "%s" rev-parse --%s HEAD', din, len);
                    [~, hash] = system(cmd);
                    hash = strtrim(hash); % 去除前后空格

                    if strcmpi(len, 'long')
                        hash = strsplit(hash, '--long'); % 按--long分割字符串
                        hash = strtrim(hash{2}); % 获取第二个部分，即hash值
                    end

                case 'remote'
                    % cmd = sprintf('git -C "%s" ls-remote origin HEAD', din);
                    cmd = sprintf('git -C "%s" ls-remote |grep HEAD', din);
                    [~, hash] = system(cmd);
                    hash = strtrim(hash); % 去除前后空格
                    hash = strsplit(hash, '\t'); % 按制表符分割字符串
                    hash = strtrim(hash{1}); % 获取第一个部分，即hash值
                    hash = strsplit(hash, '\n'); % 按换行符分割字符串
                    hash = strtrim(hash{2}); % 获取第二个部分，即hash值

                    if strcmpi(len, 'short')
                        hash = hash(1:7); % 取前7位
                    end

                otherwise
                    error('Invalid options. Use ''local'' or ''remote''.');
            end

        case 'MATLAB'

            switch lower(opts)
                case 'local'
                    Grepo = gitrepo(din);
                    hash = Grepo.LastCommit.ID;
                    hash = convertStringsToChars(hash); % 转换为char类型

                    if strcmpi(len, 'short')
                        hash = hash(1:7); % 取前7位
                    end

                case 'remote'
                    error('Getting remote git hash is not supported in MATLAB method. Use ''CMD'' or ''auto'' method instead.');

                otherwise
                    error('Invalid options. Use ''local'' or ''remote''.');
            end

        otherwise
            error('Invalid method. Use ''MATLAB'', ''CMD'', or ''auto''.');
    end

end
