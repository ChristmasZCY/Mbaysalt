clear;clc;
[status,result] = dos('ifconfig');
% if contains(result,'192.168.9')
%     disp('Christmas''s MacBook')
%     dout_turist = './turist-en/';
%     dout_gray = './wavegray/';
if contains(result,'99.99.99.7')
    disp('99.99.99.7')
    dout_turist = '/data/Output_9105/gisfiles/tiles/turist-en/';
    dout_gray = '/data/Output_9105/gisfiles/tiles/wavegray/';
elseif contains(result,'99.99.99.105')
    disp('99.99.99.105')
    dout_turist = '/data/gisfiles/tiles/turist-en/';
    dout_gray = '/data/gisfiles/tiles/wavegray/';
end
URL_base = 'https://windytiles.mapy.cz/turist-en/';

% parpool(20)
for i = 12
    parfor j = 0:2^i-1
        for k = 0:2^i-1
            fprintf('%d-%d-%d.png\n', i, j, k)
            URL_turist = sprintf('%s/%d-%d-%d.png', URL_base, i, j, k);
            fout_turist = [fullfile(dout_turist, num2str(i), num2str(j), num2str(k)),'.png'];
            fout_gray = [fullfile(dout_gray, num2str(i), num2str(j), num2str(k)),'.png'];
            makedirs(fileparts(fout_turist), fileparts(fout_gray));
            try
                if ~exist(fout_turist, "file")
                    websave(fout_turist, URL_turist);
                end
                map2gray(fout_turist, fout_gray)
            catch ME1
                fprintf('\nWRONG:%d-%d-%d.png\n', i, j, k)
                writelines(sprintf('WRONG: %d-%d-%d.png\n', i, j, k), 'WRONG.txt','WriteMode','append');
            end
        end
    end
end
% map2gray("x.png","O.png","oceanMatFile","ocean.mat");
