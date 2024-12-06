function BBW_add_lonlat(f2dm, indir)

if ~exist(f2dm, 'file')
    error(['2dm file not exists: ' f2dm])
end
f = f_load_grid(f2dm);

% if exist(fout, 'file')
%     error(['nc file not exists: ' fnc])
% end

files = dir(indir);

for i = 1 : length(files)

    fout = [files(i).folder filesep files(i).name];
    disp(['=========' fout '=========='])

    disp('--- Write lon');
    ncwrite(fout, 'lon', f.x);

    disp('--- Write lat');
    ncwrite(fout, 'lat', f.y);

    disp('--- Write lonc');
    ncwrite(fout, 'lonc', f.xc);

    disp('--- Write latc');
    ncwrite(fout, 'latc', f.yc);
end
