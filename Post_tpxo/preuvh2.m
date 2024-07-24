function TIDE = preuvh2(lon, lat, dmt, tideList, TPXO_fileDir, data_midDir, varargin)
    %       Predict the tidal current velocity or elevation at a given time
    % =================================================================================================================
    % Parameters:
    %       lon:            longitude                     || required: True || type: double    || format: matrix
    %       lat:            latitude                      || required: True || type: double    || format: matrix
    %       dmt:            datetime 1D-array             || required: True || type: datetime  || format: 1D-array
    %       tideList:       tide list                     || required: True || type: string    || example: ["M2" "N2" "S2" "K2" "K1" "O1" "P1" "Q1"]
    %       TPXO_fileDir:   tpxo bin file dir             || required: True || type: char      || example: './TPXO9-atlas-v5/bin'
    %       data_midDir:    Combined file dir             || required: True || type: char      || example: './AreaBin'         
    %       varargin:   (options)                         || required: False|| as follow:
    %           INFO:       display process               || required: False|| type: namevalue || format: 'INFO','disp'
    %           Vname:      extract value name            || required: False|| type: namevalue || format: 'Vname','u'
    %           Parallel:   Parallel switch               || required: False|| type: namevalue || format: 20
    % =================================================================================================================
    % Returns:
    %       TIDE:
    %           .u:     tide current-u  || type: double || format: 1D or 2D
    %           .v:     tide current-v  || type: double || format: 1D or 2D
    %           .h:     tide seaLevel-h || type: double || format: 1D or 2D
    % =================================================================================================================
    % Updates:
    %       2024-05-27:     Created, by Christmas;
    % =================================================================================================================
    % Examples:
    %       TIDE = preuvh2(lon, lat, dmt, ["M2" "N2" "S2" "K2" "K1" "O1" "P1" "Q1"], './TPXO9-atlas-v5/bin', './AreaBin','Vname','z')
    %       TIDE = preuvh2(lon, lat, dmt, ["M2" "N2" "S2" "K2" "K1" "O1" "P1" "Q1"], './TPXO9-atlas-v5/bin', './AreaBin','Vname','uv')
    %       TIDE = preuvh2(lon, lat, dmt, ["M2" "N2" "S2" "K2" "K1" "O1" "P1" "Q1"], './TPXO9-atlas-v5/bin', './AreaBin','Vname','all')
    %       TIDE = preuvh2(lon, lat, dmt, ["M2" "N2" "S2" "K2" "K1" "O1" "P1" "Q1"], './TPXO9-atlas-v5/bin', './AreaBin')
    %       TIDE = preuvh2(lon, lat, dmt, ["M2" "N2" "S2" "K2" "K1" "O1" "P1" "Q1"], './TPXO9-atlas-v5/bin', './AreaBin', 'INFO', 'disp')
    %       TIDE = preuvh2(lon, lat, dmt, ["M2" "N2" "S2" "K2" "K1" "O1" "P1" "Q1"], './TPXO9-atlas-v5/bin', './AreaBin', 'Vname','all', 'INFO', 'disp')
    % =================================================================================================================

    varargin = read_varargin(varargin,{'INFO'}, {'none'});
    varargin = read_varargin(varargin,{'Vname'}, {'all'});
    varargin = read_varargin(varargin, {'Parallel'},{[]}); %#ok<*NASGU>
    INFO = INFO; %#ok<ASGSL,*NODEF> % beacause of parfor
    
    hug_filepath = fullfile(tempdir ,'hug_files.txt');
    tpxobin_filepath = fullfile(tempdir ,'tpxobin_file.txt');

    if ~isscalar(lon)  % not noe
        xdiff = mean(diff(lon(:)));
        ydiff = mean(diff(lat(:)));
    else
        xdiff = 0.1;
        ydiff = 0.1;
    end
    xlims = [min(lon(:))-2*xdiff,max(lon(:))+2*xdiff];
    ylims = [min(lat(:))-2*ydiff,max(lat(:))+2*ydiff];

    uFile = fullfile(TPXO_fileDir,sprintf('h_{%s}_tpxo9_atlas_30_v5',strjoin(lower(tideList),',')));
    hFile = fullfile(TPXO_fileDir,sprintf('u_{%s}_tpxo9_atlas_30_v5',strjoin(lower(tideList),',')));
    gFile = fullfile(TPXO_fileDir,'grid_tpxo9_atlas_30_v5');
    clear TPXO_fileDir
    
    writelines(uFile,tpxobin_filepath,'WriteMode','overwrite');
    writelines(hFile,tpxobin_filepath,'WriteMode','append');
    writelines(gFile,tpxobin_filepath,'WriteMode','append');
    
    makedirs(data_midDir)
    gFile_area = sprintf('%s/grid_area',data_midDir);
    writelines(sprintf('%s/h_area',data_midDir),hug_filepath,"WriteMode","overwrite")
    writelines(sprintf('%s/uv_area',data_midDir),hug_filepath,"WriteMode","append")
    writelines(gFile_area,hug_filepath,"WriteMode","append")
    
    if exist(gFile_area,"file") == 2
        ll_lims = grd_in(gFile_area);
    else
        ll_lims = [-Inf; -Inf; Inf; Inf];
    end
    box_old = [ll_lims(1) ll_lims(3);
           ll_lims(2) ll_lims(3);
           ll_lims(2) ll_lims(4);
           ll_lims(1) ll_lims(4);
           ll_lims(1) ll_lims(3)];
    box_new = [xlims(1) ylims(1);
           xlims(2) ylims(1);
           xlims(2) ylims(2);
           xlims(1) ylims(2);
           xlims(1) ylims(1)];
    [in, on] = inpolygon(box_new(:,1), box_new(:,2), box_old(:,1), box_old(:,2));  % box_new in box_old
    if all(in | on)
    else
        tpxo_atlas2local(tpxobin_filepath,hug_filepath,ylims,xlims);
    end
    clear xlims xdiff ylims ydiff ll_lims
    clear uFile hFile gFile  
    clear box_new box_old in on
    clear data_midDir

    rmfiles(tpxobin_filepath);
    
    if numel(lon) ~= numel(lat)
        error('lon,lat must be scatter or meshgrid!')
    end
    
    num = numel(lon);
    size_ll = size(lon);

    if ~isempty(Parallel)
        p = gcp('nocreate');
        if isempty(p)
            pool = parpool(Parallel);
            assignin('base',"pool",pool);
        end
    end

    %% zeta 
    switch Vname
    case {'all','z'}
        Cid = 1 : length(tideList);
        tide_zeta = nan(num, length(dmt));
        [amp, pha, ~] = tmd_extract_HC(hug_filepath, lat(:), lon(:), 'z', Cid);
        amp = amp';
        pha = pha';
        if ~isempty(Parallel)
            parfor i = 1 : num
                if mod(i,100) == 0
                    txt = sprintf('Predicting tide elevation: %4.4d / %4.4d', i, num);
                    switch INFO
                    case {'cprintf','osprint2'}
                        osprint2("INFO", txt);
                    case {'disp','fprintf','sprintf'}
                        fprintf('%s\n', txt);
                    end
                end
        
                tide_zeta_struct = create_tidestruc(tideList, amp(i,:), pha(i,:));
                tide_zeta(i,:) = t_predic(datenum(dmt), tide_zeta_struct, 'latitude', lat(i), 'synthesis', 0); %#ok<*DATNM>
            end
        else
            for i = 1 : num
                if mod(i,100) == 0
                    txt = sprintf('Predicting tide elevation: %4.4d / %4.4d', i, num);
                    switch INFO
                    case {'cprintf','osprint2'}
                        osprint2("INFO", txt);
                    case {'disp','fprintf','sprintf'}
                        fprintf('%s\n', txt);
                    end
                end
        
                tide_zeta_struct = create_tidestruc(tideList, amp(i,:), pha(i,:));
                tide_zeta(i,:) = t_predic(datenum(dmt), tide_zeta_struct, 'latitude', lat(i), 'synthesis', 0); %#ok<*DATNM>
            end
        end
        tide_zeta = real(tide_zeta);
        clear amp pha i Cid tide_zeta_struct txt
        tide_zeta = reshape(tide_zeta, [size_ll, length(dmt)]);
        TIDE.h = tide_zeta;
    end
    
    %% uv
    switch Vname
    case {'all','uv'}
        tide_uv = nan(num, length(dmt));
        % Extract the tide vector components
        fmaj = zeros(num, length(tideList));fmin = zeros(num, length(tideList));
        pha  = zeros(num, length(tideList));finc = zeros(num, length(tideList));
        if ~isempty(Parallel)
            parfor i = 1 : length(tideList)
                [fmaj(:,i), fmin(:,i), pha(:,i), finc(:,i)] = tmd_ellipse(hug_filepath, lat(:),lon(:), tideList{i});
            end
        else
            for i = 1 : length(tideList)
                [fmaj(:,i), fmin(:,i), pha(:,i), finc(:,i)] = tmd_ellipse(hug_filepath, lat(:),lon(:), tideList{i});
            end
        end
        rmfiles(tpxobin_filepath)
        clear i tpxobin_filepath
        % Convert unit from cm/s to m/s
        fmaj = fmaj / 100;
        fmin = fmin / 100;
        if ~isempty(Parallel)
            parfor i = 1 : num
                if mod(i,100) == 0
                    txt = sprintf('Predicting tide velocity: %4.4d / % 4.4d', i, num);
                    switch INFO
                    case {'cprintf','osprint2'}
                        osprint2("INFO", txt);
                    case {'disp','fprintf','sprintf'}
                        fprintf('%s\n', txt);
                    end
                end
                tide_uv_struct = create_tidestruc(tideList, fmaj(i,:), fmin(i,:), finc(i,:), pha(i,:));
                tide_uv(i, :) = t_predic(datenum(dmt), tide_uv_struct, 'latitude', lat(i), 'synthesis', 0);
            end
        else
            for i = 1 : num
                if mod(i,100) == 0
                    txt = sprintf('Predicting tide velocity: %4.4d / % 4.4d', i, num);
                    switch INFO
                    case {'cprintf','osprint2'}
                        osprint2("INFO", txt);
                    case {'disp','fprintf','sprintf'}
                        fprintf('%s\n', txt);
                    end
                end
                tide_uv_struct = create_tidestruc(tideList, fmaj(i,:), fmin(i,:), finc(i,:), pha(i,:));
                tide_uv(i, :) = t_predic(datenum(dmt), tide_uv_struct, 'latitude', lat(i), 'synthesis', 0);
            end
        end
        tide_u = real(tide_uv);
        tide_v = imag(tide_uv);
        clear fmaj fmin pha finc tide_uv_struct tide_uv txt i
        tide_u = reshape(tide_u, [size_ll, length(dmt)]);
        tide_v = reshape(tide_v, [size_ll, length(dmt)]);
        TIDE.u = tide_u;
        TIDE.v = tide_v;
    end
    clear tide_zeta tide_u tide_v INFO tideList
    rmfiles(hug_filepath);

end


%% get id
% % Extract the tide elevation components
% [~, ~, ~, conList] = tmd_extract_HC(TMD_filelist, lat(1), lon(1), 'z', []);
% Cid = zeros(size(tide_name));
% for j = 1 : length(tide_name)
%     k = find(ismember(upper(conList), tide_name{j}, 'rows'));
%     if isempty(k)
%         error(['Tide ' tide_name{j} ' is not included.'])
%     else
%         Cid(j) = k;
%     end
% end
% clear j k conList
