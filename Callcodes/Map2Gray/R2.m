clear;clc;
[status,result] = dos('ifconfig');
% if contains(result,'192.168.9')
%     disp('Christmas''s MacBook')
%     dout_turist = './turist-en/';
%     dout_gray = './wavegray/';
if contains(result,'99.99.99.7')
    disp('99.99.99.7')
    % dout_turist = '/data/Output_9105/gisfiles/tiles/turist-en/';
    % dout_gray = '/data/Output_9105/gisfiles/tiles/wavegray/';
    dout_turist = '/storage/gisfiles/tiles/turist-en_512/';
    dout_gray = '/storage/gisfiles/tiles/wavegray_512/';
elseif contains(result,'99.99.99.105')
    disp('99.99.99.105')
    dout_turist = '/data/gisfiles/tiles/turist-en/';
    dout_gray = '/data/gisfiles/tiles/wavegray/';
end
% URL_base = 'https://windytiles.mapy.cz/turist-en/';
URL_base = 'https://tiles.windy.com/v1/maptiles/outdoor/256%402x';

options = weboptions('Timeout',15);

% parpool(20)
for i = 12
    for j = 0:1:2^i-1
       parfor k = 0:1:2^i-1
            fprintf('%d-%d-%d.png\n', i, j, k)
            % URL_turist = sprintf('%s/%d-%d-%d.png', URL_base, i, j, k);
            URL_turist = sprintf('%s/%d/%d/%d/', URL_base, i, j, k);
            fout_turist = [fullfile(dout_turist, num2str(i), num2str(j), num2str(k)),'.png'];
            fout_gray = [fullfile(dout_gray, num2str(i), num2str(j), num2str(k)),'.png'];
            makedirs(fileparts(fout_turist), fileparts(fout_gray));
            tick = 0;
            while true
                try
                    if ~exist(fout_turist, "file")
                        websave(fout_turist, URL_turist, options);
                    end
                    map2gray(fout_turist, fout_gray);
                    break;
                catch ME1
                    % MATLAB:imagesci:png:libraryFailure
                    if strcmp(ME1.identifier,'MATLAB:imagesci:png:libraryFailure')
                        disp('PNG file corrupted, deleting it.')
                        rmfiles(fout_turist)
                    end
                    if tick > 3
                        fprintf('\nWRONG:%d-%d-%d.png\n', i, j, k)
                        writelines(sprintf('WRONG: %d/%d/%d.png %s \n', i, j, k, ME1.identifier), 'WRONG12.txt','WriteMode','append');
                        break;
                    end
                    tick = tick + 1;

                end
            end
        end
    end
end
% map2gray("x.png","O.png","oceanMatFile","ocean.mat");
