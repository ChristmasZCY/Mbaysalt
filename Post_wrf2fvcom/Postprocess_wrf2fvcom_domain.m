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
    % Example:
    %       Postprocess_wrf2fvcom_domain('20231008',5)
    %       Postprocess_wrf2fvcom_domain('20231008',5,'domain',1)
    %       Postprocess_wrf2fvcom_domain('20231008',5,'conf_file','Post_wrf2fvcom.conf')
    %       Postprocess_wrf2fvcom_domain('20231008',5,'domain',2,'conf_file','Post_wrf2fvcom.conf')
    % =================================================================================================================
    % TODO:
    %   !!! Not finished yet !!!
    %   !!! Just for T2 now !!!
    % =================================================================================================================
    
    % read parameters
    varargin = read_varargin(varargin,{'domain'},{1});
    varargin = read_varargin(varargin,{'conf_file'},{'Post_wrf2fvcom.conf'});

    domain_number = domain; clear domain
    domain.number = domain_number; clear domain_number
    domain.name = num2str(domain.number,'d%02d');
    
    conf = read_conf(conf_file);
    
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
    osprint2('INFO','domain: %s',domain.name)
    NcOutfilename = ['temperature_',domain.region_name,'_',domain.resolution,'.nc'];
    
    for i = 1 : day_len
        ymd_run = ymd_dtm + days(i-1);
        fin = fullfile(conf.InputDir, char(ymd_run),NcInfilename);
        fout = fullfile(conf.OutputDir,domain.region_name,[char(ymd_dtm),'_',domain.region_name],'temperature',char(ymd_run),NcOutfilename);
        makedirs(fileparts(fout))
    
        if ~isfile(fin)  % 文件不存在exit
            error([fin,' is not exist !!!'])
        end
    
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
    
        % read NC file variables
        [~,~,Times,T2_ori] = ncread_llt_v(fin,'XLONG','XLAT','Times',[1 24],'T2');
        Ttimes = Mateset.Mdatetime(Times,'fmt','yyyy-MM-dd_HH:mm:ss');
        clear Times
    
        % read NC file attributes
        START_DATE = ncreadatt(fin,'/','START_DATE');
    
        % interp
        lon = reshape(domain_ll.lon_ori,[],1);
        lat = reshape(domain_ll.lat_ori,[],1);
        T2 = reshape(T2_ori,[],size(T2_ori,3));
    
    
        T2_dst = zeros(length(domain_ll.lat_dst),length(domain_ll.lon_dst),size(T2_ori,3));
        for it = 1 : size(T2_ori,3)
            T2_dst(:,:,it) = griddata(double(lon),double(lat),double(T2(:,it)),domain_ll.lon_dst,domain_ll.lat_dst');
        end
        T2_dst = permute(T2_dst,[2,1,3]);
        
        ncid = create_nc(fout,'NETCDF4');
        netcdf_wrf.wrnc_t2m(ncid, ...
            domain_ll.lon_dst, ...
            domain_ll.lat_dst, ...
            Ttimes.time, T2_dst, ...
            'GA',struct('START_DATE',START_DATE), ...
            'conf',conf)
    
    end


end
function TF = check_key_whether_in_mat(matfile,key)
    varsInfo = whos('-file',matfile);
    TF = any(strcmp({varsInfo.name}, key));
end
