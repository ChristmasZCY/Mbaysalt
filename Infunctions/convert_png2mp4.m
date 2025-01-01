function convert_png2mp4(din, fout, varargin)
    %       Convert png to mp4
    % =================================================================================================================
    % Parameter:
    %       din:   dir input            || required: True  || type: char      || example: './pics/*.png'
    %       fout:  file output          || required: True  || type: char      || example: './x.mp4'
    %       varargin:   (options)
    %           FrameRate: FrameRate    || required: False || type: namevalue || example: 'FrameRate',1
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Update:
    %       2024-12-28:     Created, by Christmas;
    % =================================================================================================================
    % Example:
    %       convert_png2mp4('./pics/*.png', './x.mp4');
    %       convert_png2mp4('./pics/*.png', './x.mp4', 'FrameRate', 3);
    % =================================================================================================================

    varargin = read_varargin(varargin, {'FrameRate'}, {3});

    [pathstr, name, ext] = fileparts(fout);
    fmid = fullfile(pathstr, [name, '.avi']);
    convert_fig2avi(fin,  fmid, 'FrameRate', FrameRate);
    convert_avi2mp4(fmid, fout, 'FrameRate', FrameRate);

    rmfiles(fmid);
end
