function encrypt_code(din, dout, varargin)
    %   Encrypt the code with pcode.
    % =================================================================================================================
    % Parameter:
    %       din:            directory of the code       || required: True  || type: char    || format: './Mbaysalt'
    %       dout:           output directory            || required: True  || type: char    || format: './Mbaysalt/encrypted'
    %       varargin:
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Update:
    %       2026-05-06:     Created, by Christmas;
    % =================================================================================================================
    % Example:
    %       encrypt_code('./Mbaysalt', './Mbaysalt_A');
    % =================================================================================================================

    srcDir = getPath(din); % 输入目录
    dstDir = getPath(dout); % 输出目录

    files = dir(fullfile(srcDir, '**', '*.m'));

    for k = 1:numel(files)
        srcFile = fullfile(files(k).folder, files(k).name);
        relPath = erase(files(k).folder, srcDir);
        outDir = fullfile(dstDir, relPath);

        if ~exist(outDir, 'dir')
            mkdir(outDir);
        end

        try
            pcode(srcFile, '-inplace', '-R2022a');
        catch ME1
            warning('Failed to encrypt %s: %s', srcFile, ME1.message);
            continue;
        end

        movefile(strrep(srcFile, '.m', '.p'), outDir);
    end

end
