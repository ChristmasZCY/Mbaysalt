function convert_png2gif(din, fout, varargin)
    %       Convert png to mp4
    % =================================================================================================================
    % Parameter:
    %       din:   dir input            || required: True  || type: char      || example: './pics/*.png'
    %       fout:  file output          || required: True  || type: char      || example: './x.gif'
    %       varargin:   (options)
    %           DelayTime: DelayTime    || required: False || type: namevalue || example: 'DelayTime',.3
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Update:
    %       2025-05-14:     Created, by Christmas;
    % =================================================================================================================
    % Example:
    %       convert_png2gif('./pics/*.png', './x.gif');
    %       convert_png2gif('./pics/*.png', './x.gif', 'DelayTime', .3);
    % =================================================================================================================

    varargin = read_varargin(varargin, {'DelayTime'}, {.3});

    png_files = dir(din);
    png_files = sort({png_files.name});  % 自然排序（如 001.png, 002.png...）
    for i = 1:length(png_files)
        img = imread(fullfile(png_files(i).folder, png_files{i}));
        [A, map] = rgb2ind(img, 256);

        if i == 1
            imwrite(A, map, fout, 'gif', 'LoopCount', Inf, 'DelayTime', 'DelayTime');
        else
            imwrite(A, map, fout, 'gif', 'WriteMode', 'append', 'DelayTime', 'DelayTime');
        end
    end

    rmfiles(fmid);
end
