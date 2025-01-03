function TIDE = preuvh2(lon, lat, dmt, tideList, TPXO_fileDir, data_midDir, varargin)
    %       Predict the tidal current velocity or elevation at a given time
    % =================================================================================================================
    % Parameters:
    %       lon:                longitude                   || required: True || type: double    || format: matrix
    %       lat:                latitude                    || required: True || type: double    || format: matrix
    %       dmt:                datetime 1D-array           || required: True || type: datetime  || format: 1D-array
    %       tideList:           tide list                   || required: True || type: string    || example: ["M2" "N2" "S2" "K2" "K1" "O1" "P1" "Q1"]
    %       TPXO_fileDir:       tpxo bin file dir           || required: True || type: char      || example: './TPXO9-atlas-v5/bin'
    %       data_midDir:        Combined file dir           || required: True || type: char      || example: './AreaBin'         
    %       varargin:   (options)   as follow:
    %           INFO:           display mode                || required: False|| type: namevalue || example: 'INFO','disp'
    %           Vname:          extract value name          || required: False|| type: namevalue || example: 'Vname','u'
    %           Parallel:       Parallel switch             || required: False|| type: namevalue || example: 'Parallel', 20
    %           tideconS:       Output tidecon switch       || required: False|| type: flag      || example: 'tideconS'
    %           createOnly:     create combined file only   || required: False|| type: flag      || example: 'createOnly'
    % =================================================================================================================
    % Returns:
    %       TIDE:
    %           .u:                 tide current-u      || type: double || format: 1D or 2D or 3D
    %           .v:                 tide current-v      || type: double || format: 1D or 2D or 3D
    %           .h:                 tide tideLevel-h    || type: double || format: 1D or 2D or 3D
    %           .hcon.amp:          zeta(amp)           || type: double || format: 1D or 2D or 3D
    %           .hcon.pha:          zeta(pha)           || type: double || format: 1D or 2D or 3D
    % =================================================================================================================
    % Updates:
    %       2024-05-27:     Created,                        by Christmas;
    %       2024-10-11:     Check lon/lat range,            by Christmas;
    %       2024-12-20:     Fixed parfor INFO and parpool,  by Christmas;
    %       2024-12-20:     Perfected get Cid,              by Christmas;
    %       2024-12-27:     Added for more data,            by Christmas;
    %       2025-01-03:     Get amp pha, no need to get z,  by Christmas;
    % =================================================================================================================
    % Reerences:
    %       tpxo7.2只有9个分潮。是从所有潮总分离出来9个，其他的都掺杂在这9个里面
    %       tpxo10有25个，等同于tpxo7.2的9个
    % =================================================================================================================
    % Examples:
    %       
    %       [Lat,Lon] = meshgrid(lat,lon);
    %       dmt = Ttimes.Times;
    %       tideList = ["M2" "N2" "S2" "K2" "K1" "O1" "P1" "Q1"];
    %       tideList = [];
    %       TPXO_fileDir = './TPXO9-atlas-v5/bin';
    %       TPXO_fileDir = './TPXO9/bin/DATA';
    %
    %   **CASE1**:
    %
    %       TIDE = preuvh2(Lon, Lat, dmt, tideList, TPXO_fileDir, './AreaBin','createOnly');  % create file only
    %       TIDE = preuvh2(Lon, Lat, dmt, tideList, [], './AreaBin');                         % if 'AreaBin' is OK!
    %       TIDE = preuvh2(Lon, Lat, dmt, tideList, TPXO_fileDir, './AreaBin', 'Vname','z');
    %       TIDE = preuvh2(Lon, Lat, dmt, tideList, TPXO_fileDir, './AreaBin', 'Vname','uv');
    %       TIDE = preuvh2(Lon, Lat, dmt, tideList, TPXO_fileDir, './AreaBin', 'Vname','all');
    %       TIDE = preuvh2(Lon, Lat, dmt, tideList, TPXO_fileDir, './AreaBin', 'Vname','all', 'INFO', 'disp');
    %       TIDE = preuvh2(Lon, Lat, dmt, tideList, TPXO_fileDir, './AreaBin', 'Vname','all', 'INFO', 'disp','Parallel',20);
    %       
    %   **CASE2**:
    %       hcon = preuvh2(fn.x, fn.y, Ttimes.Times, tide_name, TPXO_filepath, din_tide, 'INFO','none','Vname','z','tideconS').hcon;
    %       tide_zeta = nan(fn.node, len(Ttimes));
    %       for i = 1:len(hcon.tideList)
    %       switch hcon.tideList(i)
    %       case 'M2'
    %           hcon.amp(:,:,i) = hcon.amp(:,:,i);
    %           hcon.pha(:,:,i) = hcon.pha(:,:,i);
    %       end
    %       for i = 1:fn.node
    %           tide_zeta_struct = create_tidestruc(hcon.tideList, squeeze(hcon.amp(i,:,:)), squeeze(hcon.pha(i,:,:)));
    %           tide_zeta(i,:) = t_predic(Ttimes.datenumC, tide_zeta_struct, 'latitude', fn.y(i), 'synthesis', 0);
    %       end
    %
    %   <a href="matlab: matlab.desktop.editor.openDocument(which('Example_predict_tide.m')); ">See also Example_predict_tide</a>
    % =================================================================================================================

    varargin = read_varargin(varargin,{'INFO'}, {'none'});
    varargin = read_varargin(varargin,{'Vname'}, {'all'});
    varargin = read_varargin(varargin, {'Parallel'},{[]}); %#ok<*NASGU>
    varargin = read_varargin2(varargin, {'tideconS'});
    varargin = read_varargin2(varargin, {'createOnly'});
    INFO = lower(INFO);  %#ok<*NODEF> % beacause of parfor
    Vname = lower(Vname);
    switch INFO
    case {'cprintf','osprint2'}
        INFO = 'osprint2';
    case {'disp','fprintf','sprintf'}
        INFO = 'disp';
    otherwise
        INFO = 'none';
    end
    
    hug_filepath = fullfile(tempdir ,'hug_files.txt');  % /tmp/hug_files.txt (contains ./AreaBin/h_area ./AreaBin/uv_area ./AreaBin/grid_area)
    tpxobin_filepath = fullfile(tempdir ,'tpxobin_file.txt'); % /tmp/tpxobin_file.txt (contains ./TPXO9-atlas-v5/bin/h_*.nc ./TPXO9-atlas-v5/bin/u_*.nc ./TPXO9-atlas-v5/bin/grid_*.nc)

    if min(lat(:)) <-90 || max(lat(:)) > 90  % check lat range
        error('lat range not in [-90 90], but [%.2f ~ %.2f]',minmax(lat))
    end

    makedirs(data_midDir)  % ./AreaBin/
    hFile_area = sprintf('%s/h_area',   data_midDir);  % ./AreaBin/h_area
    uFile_area = sprintf('%s/uv_area',  data_midDir);  % ./AreaBin/uv_area
    gFile_area = sprintf('%s/grid_area',data_midDir);  % ./AreaBin/grid_area
    writelines(hFile_area, hug_filepath,"WriteMode","overwrite");  % ./AreaBin/h_area
    writelines(uFile_area, hug_filepath,"WriteMode","append");     % ./AreaBin/uv_area
    writelines(gFile_area, hug_filepath,"WriteMode","append");     % ./AreaBin/grid_area

    if isscalar(lon)  % 单点
        xdiff = 0.1;
        ydiff = 0.1;
    elseif numel(lon) == length(lon)  % 散点
        xdiff = mean(diff(lon(:)));
        ydiff = mean(diff(lat(:)));
    else  % 网格
        xdiff = max(diff(lon(:)));
        ydiff = max(diff(lat(:)));
    end

    xlims = [min(lon(:))-2*xdiff,max(lon(:))+2*xdiff];
    ylims = [min(lat(:))-2*ydiff,max(lat(:))+2*ydiff];

    %% AreaBin
    % check TPXO_fileDir
    if exist(TPXO_fileDir,"dir")
        SWITCH.create = true;
    else
        SWITCH.create = false;
    end

    if SWITCH.create
        [~, name, ext] = fileparts(strip(ls(fullfile(TPXO_fileDir,"grid*"))));
        filenameCheck = [name,ext]; clear name ext  % grid_tpxo10_atlas_30_v2.nc

        % check version
        if contains(filenameCheck,'atlas')
            SWITCH.atlas = true;
        else
            SWITCH.atlas = false;
        end

        if isempty(tideList)
            osprint2('INFO','Use all tpxo file !!!')
        end
    
        switch SWITCH.atlas
        case true
        
            % hFile = fullfile(TPXO_fileDir,sprintf('h_{%s}_tpxo10_atlas_30_v2',strjoin(lower(tideList),',')));
            % uFile = fullfile(TPXO_fileDir,sprintf('u_{%s}_tpxo10_atlas_30_v2',strjoin(lower(tideList),',')));
            % gFile = fullfile(TPXO_fileDir,'grid_tpxo10_atlas_30_v2');
            if ~isempty(tideList)
                hFile = fullfile(TPXO_fileDir,sprintf('h_{%s}_%s',strjoin(lower(tideList),','),replace(filenameCheck,'grid_','')));  % h_{M2,N2,S2,K2,K1,O1,P1,Q1}_grid_tpxo10_atlas_30_v2.nc
                uFile = fullfile(TPXO_fileDir,sprintf('u_{%s}_%s',strjoin(lower(tideList),','),replace(filenameCheck,'grid_','')));  % u_{M2,N2,S2,K2,K1,O1,P1,Q1}_grid_tpxo10_atlas_30_v2.nc
            else
                hFile = fullfile(TPXO_fileDir,sprintf('h_*_%s',replace(filenameCheck,'grid_','')));  % h_*_grid_tpxo10_atlas_30_v2.nc
                uFile = fullfile(TPXO_fileDir,sprintf('u_*_%s',replace(filenameCheck,'grid_','')));  % u_*_grid_tpxo10_atlas_30_v2.nc
            end
            gFile = fullfile(TPXO_fileDir,filenameCheck);  % grid_tpxo10_atlas_30_v2.nc
            
            writelines(hFile,tpxobin_filepath,'WriteMode','overwrite');  % ./**/h_{M2,N2,S2,K2,K1,O1,P1,Q1}_grid_tpxo10_atlas_30_v2.nc
            writelines(uFile,tpxobin_filepath,'WriteMode','append');     % ./**/u_{M2,N2,S2,K2,K1,O1,P1,Q1}_grid_tpxo10_atlas_30_v2.nc
            writelines(gFile,tpxobin_filepath,'WriteMode','append');     % ./**/grid_tpxo10_atlas_30_v2.nc
        case false
            if contains(filenameCheck,'YS')
                hFile = strip(ls(fullfile(TPXO_fileDir,'hf*')));
                uFile = strip(ls(fullfile(TPXO_fileDir,'uv*')));
                gFile = strip(ls(fullfile(TPXO_fileDir,'grid*')));
            else
                hFile = strip(ls(fullfile(TPXO_fileDir,'h_tpxo*')));
                uFile = strip(ls(fullfile(TPXO_fileDir,'u_tpxo*')));
                gFile = strip(ls(fullfile(TPXO_fileDir,'grid_tpxo*')));
            end
        end
    end
        
    if exist(gFile_area, "file") == 2
        ll_lims = grd_in(gFile_area);
    else
        ll_lims = [-Inf; -Inf; Inf; Inf];
        if ~exist(TPXO_fileDir,"dir")
            error('''%s'' and ''%s'' are not exist !!!', TPXO_fileDir, gFile_area);
        end
    end
    clear TPXO_fileDir

    box_old = [ll_lims(1) ll_lims(3);
               ll_lims(2) ll_lims(3);
               ll_lims(2) ll_lims(4);
               ll_lims(1) ll_lims(4);
               ll_lims(1) ll_lims(3)];
    box_new = [xlims(1)   ylims(1);
               xlims(2)   ylims(1);
               xlims(2)   ylims(2);
               xlims(1)   ylims(2);
               xlims(1)   ylims(1)];
    [in, on] = inpolygon(box_new(:,1), box_new(:,2), box_old(:,1), box_old(:,2));  % box_new in box_old
    if all(in | on)
        if isempty(tideList)
            warning(['Please check \n' ...
                     '%s \n' ...
                     '%s \n' ...
                     'whether contains all tide or not !!!'], hFile_area, uFile_area)
        end
    else
        switch SWITCH.atlas
        case true
            tpxo_atlas2local(tpxobin_filepath, hug_filepath, ylims, xlims);
            % tpxo_atlas2local_unix(tpxobin_filepath, hug_filepath, ylims, xlims);
        case false
            copyfile(hFile, hFile_area, "f");  % cp h_tpxo9.v1.nc ./AreaBin/h_area
            copyfile(uFile, uFile_area, "f");  % cp u_tpxo9.v1.nc ./AreaBin/uv_area
            copyfile(gFile, gFile_area, "f");  % cp grid_tpxo9.v1.nc ./AreaBin/grid_area
        end
    end
    clear xlims xdiff ylims ydiff ll_lims
    clear hFile uFile gFile
    clear hFile_area uFile_area gFile_area
    clear box_new box_old in on
    clear data_midDir

    rmfiles(tpxobin_filepath);

    if ~isempty(createOnly)
        rmfiles(hug_filepath);
        TIDE.u = NaN; TIDE.v = NaN; TIDE.h = NaN;
        return
    else
        if numel(lon) ~= numel(lat)
            error('lon,lat must be scatter or meshgrid!')
        end
        num = numel(lon);
        size_ll = size(lon);
    end

    [~, ~, ~, conList] = tmd_extract_HC(hug_filepath, lon(1), lat(1), 'z', []);
    %{ 
    tideList      = ["M2" "N2" "S2" "K2" "K1" "O1" "P1" "Q1"];
    conList       = ["M2" "N2" "S2" "K2" "K1" "O1" "Q1","Ma"];
    assemble      = ["M2" "N2" "S2" "K2" "K1" "O1" "Q1"];
    assemble_lack = ["Ma"];
    % ==================
    for j = 1 : length(tideList)
        k = find(ismember(upper(conList), tideList{j}, 'rows'));
        if isempty(k)
            error(['Tide ' tideList{j} ' is not included.'])
        else
            Cid(j) = k;
        end
    end
    % ==================
    %}
    if isempty(tideList)
        tideList = strip(upper(string(conList)'));
        I_conList = 1:len(tideList);
    else
        [assemble,I_conList,I_tideList] = intersect(strip(upper(string(conList)')),tideList); %#ok<ASGLU>
        if ~all(ismember(tideList,assemble))
            assemble_lack = setdiff(tideList,assemble);  % 取差集
            error('Tide %s is not included !',strjoin(assemble_lack))
        end
        clear I_tideList I_tideList I_tideList
    end

    if ~isempty(Parallel)
        p = gcp('nocreate');
        if isempty(p)
            p = parpool("Threads", Parallel);
            assignin('base',"pool",p);
        end
    end

    %% zeta 
    switch Vname
    case {'all','z','zeta','h'}
        Cid = I_conList;
        tide_zeta = nan(num, length(dmt));
        [amp, pha, ~] = tmd_extract_HC(hug_filepath, lat(:), lon(:), 'z', Cid);
        amp = amp';
        pha = pha';
        if ~isempty(Parallel)
            if ~strcmp(INFO, 'none')
                hbar = parfor_pgb(num);
            end
            parfor i = 1 : num
                tide_zeta_struct = create_tidestruc(tideList, amp(i,:), pha(i,:));
                tide_zeta(i,:) = t_predic(datenum(dmt), tide_zeta_struct, 'latitude', lat(i), 'synthesis', 0); %#ok<*DATNM>
                
                if mod(i,100) == 0 & ~strcmp(INFO, 'none')
                    hbar.iterate(100);
                end
            end
            if ~strcmp(INFO, 'none')
                hbar.close;
            end
        else
            for i = 1 : num
                tide_zeta_struct = create_tidestruc(tideList, amp(i,:), pha(i,:));
                tide_zeta(i,:) = t_predic(datenum(dmt), tide_zeta_struct, 'latitude', lat(i), 'synthesis', 0); %#ok<*DATNM>

                if mod(i,100) == 0
                    txt = sprintf('Predicting tide elevation: %4.4d / %4.4d', i, num);
                    switch INFO
                    case 'osprint2'
                        osprint2("INFO", txt);
                    case 'disp'
                        fprintf('%s\n', txt);
                    end
                end
        
            end
        end
        tide_zeta = real(tide_zeta);
        tide_zeta = reshape(tide_zeta, [size_ll, length(dmt)]);
        TIDE.h = tide_zeta;
        if ~isempty(tideconS)
            TIDE.hcon.tideList = tideList;
            TIDE.hcon.amp = reshape(amp, [size_ll, size(amp,2)]);
            TIDE.hcon.pha = reshape(pha, [size_ll, size(amp,2)]);
        end
        clear amp pha i Cid tide_zeta_struct txt
    end
    
    %% uv
    switch Vname
    case {'all','uv','u','v','current'}
        tide_uv = nan(num, length(dmt));
        % Extract the tide vector components
        fmaj = zeros(num, length(tideList));fmin = zeros(num, length(tideList));
        pha  = zeros(num, length(tideList));finc = zeros(num, length(tideList));
        % 函数或变量 'ic1' 无法识别。--> 分潮在data_midDir中不存在
        if ~isempty(Parallel)
            lat1 = lat(:); lon1 = lon(:);
            parfor i = 1 : length(tideList)
                [fmaj(:,i), fmin(:,i), pha(:,i), finc(:,i)] = tmd_ellipse(hug_filepath, lat1, lon1, tideList{i});
            end
            clear lat1 lon1
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
            if ~strcmp(INFO, 'none')
                hbar = parfor_pgb(num);
            end
            parfor i = 1 : num
                tide_uv_struct = create_tidestruc(tideList, fmaj(i,:), fmin(i,:), finc(i,:), pha(i,:));
                tide_uv(i, :) = t_predic(datenum(dmt), tide_uv_struct, 'latitude', lat(i), 'synthesis', 0);
            
                if mod(i,100) == 0 & ~strcmp(INFO, 'none')
                    hbar.iterate(100);
                end
            end
            if ~strcmp(INFO, 'none')
                hbar.close;
            end
        else
            for i = 1 : num
                tide_uv_struct = create_tidestruc(tideList, fmaj(i,:), fmin(i,:), finc(i,:), pha(i,:));
                tide_uv(i, :) = t_predic(datenum(dmt), tide_uv_struct, 'latitude', lat(i), 'synthesis', 0);
                
                if mod(i,100) == 0
                    txt = sprintf('Predicting tide velocity: %4.4d / % 4.4d', i, num);
                    switch INFO
                    case 'osprint2'
                        osprint2("INFO", txt);
                    case 'disp'
                        fprintf('%s\n', txt);
                    end
                end
            end
        end
        tide_u = real(tide_uv);
        tide_v = imag(tide_uv);
        tide_u = reshape(tide_u, [size_ll, length(dmt)]);
        tide_v = reshape(tide_v, [size_ll, length(dmt)]);
        TIDE.u = tide_u;
        TIDE.v = tide_v;
        clear fmaj fmin pha finc tide_uv_struct tide_uv txt i
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
