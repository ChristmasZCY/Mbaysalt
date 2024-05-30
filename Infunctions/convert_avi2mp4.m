function convert_avi2mp4(fin, fout, varargin)
    %       Convert avi to mp4
    % =================================================================================================================
    % Parameter:
    %       fins:   file input          || required: True  || type: char      || example: './x.avi'
    %       fout:   file output         || required: True  || type: char      || example: './x.mp4'
    %       varargin:   (options)
    %           FrameRate: FrameRate    || required: False || type: namevalue || example: 'FrameRate',1
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Update:
    %       2024-05-30:     Created, by Christmas;
    % =================================================================================================================
    % Example:
    %       convert_avi2mp4('./x.avi', './x.mp4')
    %       convert_avi2mp4('./x.avi', './x.mp4', 'FrameRate', 1)
    % =================================================================================================================

    varargin = read_varargin(varargin, {'FrameRate'}, {3});
    
    videoFReader = VideoReader(fin);  % Read Video
    videoFWrite = VideoWriter(fout,'MPEG-4'); % Write Video
    videoFWrite.FrameRate = FrameRate;
    open(videoFWrite);
    for count = 1:abs(videoFReader.Duration*videoFReader.FrameRate)
        key_frame = read(videoFReader,count);
        writeVideo(videoFWrite,key_frame);
    end
    % close(videoFReader);
    close(videoFWrite);
end
