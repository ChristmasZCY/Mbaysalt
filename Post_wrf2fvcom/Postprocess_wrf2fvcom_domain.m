function Postprocess_wrf2fvcom_domain(yyyymmdd,day_len,varargin)
    %       Postprocess wrf2fvcom output of domain
    % =================================================================================================================
    % Parameter:
    %       yyyymmdd:        start date              || required: True || type: char   || format: '20200101'
    %       day_len:         length of days          || required: True || type: int    || format: 5
    %       varargin:        optional parameters      
    %           domain:      domain number           || required: False|| type: int    || format: 1
    %           conf_file:   conf file               || required: False|| type: char   || format: 'Post_wrf2fvcom.conf'
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Update:
    %       2023-**-**:     Created, only for t2m.  by Christmas;
    %       2023-12-26:     Added wind.             by Christmas;
    %       2023-10-18:     Modified to a function, by Christmas;
    % =================================================================================================================
    % Example:
    %       Postprocess_wrf2fvcom_domain('20231008',5)
    %       Postprocess_wrf2fvcom_domain('20231008',5,'domain',1)
    %       Postprocess_wrf2fvcom_domain('20231008',5,'conf_file','Post_wrf2fvcom.conf')
    %       Postprocess_wrf2fvcom_domain('20231008',5,'domain',2,'conf_file','Post_wrf2fvcom.conf')
    % =================================================================================================================
    % TODO:
    %   !!! Not finished yet !!!
    %   !!! Just for T2 and wind at 10m now !!!
    % =================================================================================================================
    
    % read parameters
    varargin = read_varargin(varargin,{'domain'},{1});
    varargin = read_varargin(varargin,{'conf_file'},{'Post_wrf2fvcom.conf'});

    domain_number = domain; clear domain
    domain.number = domain_number; clear domain_number
    domain.name = num2str(domain.number,'d%02d');
    
    conf = read_conf(conf_file);
    SWITCH = read_switch(conf); % 读取开关
    Method_interpn  = conf.Method_interpn;         % 插值方法  --> 'Siqi_ESMF'
    
    ymd_dtm = datetime(yyyymmdd,"Format","yyyyMMdd");
    NcInfilename = [conf.NCprefix, domain.name, '.nc'];
    
    if domain.name == 'd03'
        domain.region_name = 'scs';
        domain.resolution = '36';
    elseif domain.name == 'd04'
        domain.region_name = 'ecs';
        domain.resolution = '34';
    else
        error('Domain has not configured !!!')
    end
    osprint2('INFO',sprintf('domain: %s',domain.name))
    NcOutfilename.t2m = ['temperature_',domain.region_name,'_',domain.resolution,'.nc'];
    NcOutfilename.wind10m = ['wind_',domain.region_name,'_',domain.resolution,'.nc'];
    
    for i = 1 : day_len
        ymd_run = ymd_dtm + days(i-1);
        fin = fullfile(conf.InputDir, char(ymd_run),NcInfilename);
        fout.t2m = fullfile(conf.OutputDir,domain.region_name,[char(ymd_dtm),'_',domain.region_name],'temperature',char(ymd_run),NcOutfilename.t2m);
        fout.wind10m = fullfile(conf.OutputDir,domain.region_name,[char(ymd_dtm),'_',domain.region_name],'wind',char(ymd_run),NcOutfilename.wind10m);
        structfun(@(x) makedirs(fileparts(x)),fout); % 创建文件夹
    
        if ~isfile(fin)  % 文件不存在exit
            error([fin,' is not exist !!!'])
        end

        if SWITCH.read_ll_from_nc  % 从mat文件中读取
            if i == 1 % 只运行一次
                if isfile(conf.GridMatFile) && check_key_whether_in_mat(conf.GridMatFile, domain.name)
                    domain_ll = load(conf.GridMatFile, domain.name).(domain.name);
                else
                    domain_ll = make_domain_ll(fin);
                    eval([domain.name,' = domain_ll;']);
                    if ~isfile(conf.GridMatFile)
                        makedirs(fileparts(conf.GridMatFile))
                        save(conf.GridMatFile, domain.name, '-nocompression');
                    else
                        save(conf.GridMatFile, domain.name, '-append', '-nocompression');
                    end
                    clear(domain.name) % 清除'd03'变量
                end
            end
        else
            domain_ll = load(conf.GridMatFile, domain.name).(domain.name);
        end
    
        % read NC file variables
        [~,~,Times,~] = ncread_llt_v(fin,'XLONG','XLAT','Times',[1 24],'T2');
        if SWITCH.t2m
            T2_ori = nr(fin,'T2',[1,1,1],[Inf,Inf,24]);
            T2_dst = zeros(length(domain_ll.lon_dst),length(domain_ll.lat_dst),24);
        end
        if SWITCH.wind10m
            U10_ori = nr(fin,'U10',[1,1,1],[Inf,Inf,24]);
            V10_ori = nr(fin,'V10',[1,1,1],[Inf,Inf,24]);
            U10_dst = zeros(length(domain_ll.lon_dst),length(domain_ll.lat_dst),24);
            V10_dst = zeros(length(domain_ll.lon_dst),length(domain_ll.lat_dst),24);
        end
        
        Ttimes = Mateset.Mdatetime(Times,'fmt','yyyy-MM-dd_HH:mm:ss');
        clear Times
    
        % read NC file attributes
        START_DATE = ncreadatt(fin,'/','START_DATE');

                % make weight
        switch Method_interpn
            case {'Siqi_ESMF'}
                % weight
                file_weight = conf.WeightFile_Siqi_ESMF;
                if SWITCH.make_weight
                    exe = conf.ESMF_exe;
                    % ESMFMAFILE = conf.ESMF_MAFILE;
                    GridFile_wrf = conf.GridFile_wrf;
                    GridFile_std = conf.GridFile_std;
                    ESMF_NCweightfile = conf.ESMF_NCweightfile;
                    ESMF_RegridMethod = conf.ESMF_RegridMethod;
                    [Lat_m,Lon_m] = meshgrid(domain_ll.lat_dst,domain_ll.lon_dst);
                    tic
                    esmf_write_grid(GridFile_wrf, 'WRF', domain_ll.lon_ori, domain_ll.lat_ori);
                    esmf_write_grid(GridFile_std, 'WRF', Lon_m,Lat_m);
                    esmf_regrid_weight(GridFile_wrf, GridFile_std, ESMF_NCweightfile, 'exe', exe, 'Src_loc', 'corner', 'Method', ESMF_RegridMethod); 
                    Weight_2d = esmf_read_weight(ESMF_NCweightfile);
                    rmfiles(file_weight)
                    save(file_weight,'Weight_2d','-v7.3','-nocompression');
                    clear Lon_m Lat_m
                    osprint2('INFO',['Calculate 2d weight costs ',num2str(toc),' 秒'])
                else
                    Weight_2d = load(file_weight).Weight_2d;
                end
                clear GridFile_wrf GridFile_std ESMF_NCweightfile ESMFMAFILE ESMF_RegridMethod exe file_weight

                for it = 1: length(Ttimes.time) % time循环
                    if SWITCH.wind10m
                        T2_dst(:,:,it) = esmf_regrid(T2_ori(:,:,it),Weight_2d,'Dims',[length(domain_ll.lon_dst),length(domain_ll.lat_dst)]);
                    end
                    if SWITCH.wind10m
                        U10_dst(:,:,it) = esmf_regrid(U10_ori(:,:,it),Weight_2d,'Dims',[length(domain_ll.lon_dst),length(domain_ll.lat_dst)]);
                        V10_dst(:,:,it) = esmf_regrid(V10_ori(:,:,it),Weight_2d,'Dims',[length(domain_ll.lon_dst),length(domain_ll.lat_dst)]);
                    end
                end

            otherwise
                error('Method_interpn must be Siqi_ESMF!')
        end     
        
        if SWITCH.t2m
            ncid = create_nc(fout.t2m,'NETCDF4');
            netcdf_wrf.wrnc_t2m(ncid, domain_ll.lon_dst, domain_ll.lat_dst, Ttimes.time, T2_dst, 'GA',struct('START_DATE',START_DATE), 'conf',conf)
        end
        if SWITCH.wind10m
            ncid = create_nc(fout.wind10m,'NETCDF4');
            netcdf_wrf.wrnc_wind10m(ncid, domain_ll.lon_dst, domain_ll.lat_dst, Ttimes.time,U10_dst,V10_dst, 'GA', struct('START_DATE',START_DATE), 'conf',conf)
        end
    end
end


function TF = check_key_whether_in_mat(matfile,key)
    varsInfo = whos('-file',matfile);
    TF = any(strcmp({varsInfo.name}, key));
end

function SWITCH = read_switch(struct)
    % 从struct中读取以SWITCH.开头的变量，将变量写入到switch结构体中
    % eg: 将struct中的Switch_erosion写入到switch.erosion中
    key = fieldnames(struct);
    for i = 1 : length(key)
        if ~isempty(regexp(key{i},'^Switch_','once'))
            SWITCH.(key{i}(8:end)) = struct.(key{i});
        end
    end
end
