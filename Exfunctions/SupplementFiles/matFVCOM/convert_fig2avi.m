%==========================================================================
%
%
% input  :
%
% output :
%
% Siqi Li, SMAST
% yyyy-mm-dd
%
% Updates:
%           Added imresize, by Christmas;
%
%==========================================================================
function convert_fig2avi(fin, fout, varargin)


varargin = read_varargin(varargin, {'FrameRate'}, {3});


files = dir(fin);

n = length(files);

writerObj = VideoWriter(fout);
writerObj.FrameRate = FrameRate;
open(writerObj);
for K = 1 : n
    filename = [files(K).folder '/' files(K).name];
    thisimage = imread(filename);
    % --> 
    if K == 1
        fixedSize = size(thisimage);
    end
    if ~isequal(size(thisimage), fixedSize)
        thisimage = imresize(thisimage, [fixedSize(1), fixedSize(2)]);
        osprint2('WARNING','Resize image, please check!')
    end
    % <--
    writeVideo(writerObj, thisimage);
end
close(writerObj);
end
