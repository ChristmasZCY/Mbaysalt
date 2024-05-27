function []=tpxo_atlas2local(atlas_modfile,out_modfile,lat_lims,lon_lims);
    % makes multi-constituent outcut from single-constituent atlas files
    %
    % Lana Erofeeva, 2020
    % Christmas, 2024
    %
    % USAGE: atlas2local(atlas_modfile,out_modfile,lat_lims,lon_lims);
    %
    % atlas_modfile - 3 lines ascii control file pointing to atlas files
    % with wild card (*) instead of constituents, i.e.
    % control file Model_tpxo9_atlas:
    % Windows:
    % <your_path>\TPXO9_atlas\h_*_tpxo9_atlas_30*
    % <your path>\TPXO9_atlas\u_*_tpxo9_atlas_30*
    % <your path>\TPXO9_atlas\grid_tpxo9_atlas_30
    % Unix:
    % DATA/tpxo9_atlas_v2/h_*_tpxo9_atlas_30_v2
    % DATA/tpxo9_atlas_v2/u_*_tpxo9_atlas_30_v2
    % DATA/tpxo9_atlas_v2/grid_tpxo9_atlas_30
    %
    % out_modfile - 3 lines ascii control file showing where to output
    % tpxo-atlas elevations/transports/grid for your local area, i.e.
    % control file Model_myArea:
    % Windows:
    % DATA\MyArea\h_MyArea
    % DATA\MyArea\uv_MyArea
    % DATA\MyArea\grid_MyArea
    % Unix:
    % DATA/MyArea/h_MyArea
    % DATA/MyArea/uv_MyArea
    % DATA/MyArea/grid_MyArea
    %
    % lat_lims - latitude limits of your area
    % lon_lims - longitude limits of your area
    % Outcut will have the same resolution, the same constituents and
    % the same cell alignment as TPXO-atlas.
    % Your lat_lims, lon_lims will be re-aligned to TPXO9-atlas-grid
    %
    % Sample calls:
    %
    % Windows:
    % tpxo_atlas2local('DATA\Model_tpxo9_atlas','DATA\Model_Hawaii',[16 28],[185 208]);
    % tpxo_atlas2local('DATA\Model_tpxo9_atlas','DATA\Model_ES',[46 60],[-10,10]);
    % Unix:
    % tpxo_atlas2local('DATA/Model_tpxo9_atlas','DATA/Model_Hawaii',[16 28],[185 208]);
    % tpxo_atlas2local('DATA/Model_tpxo9_atlas','DATA/Model_ES',[46 60],[-10,10]);
    if nargin~=4 | length(lat_lims)~=2 | length(lon_lims)~=2,
        fprintf "Wrong usage!\n");help tpxo_atlas2local;return;
    end
    % sanity check
    if lat_lims(1)>lat_lims(2), tmp=lat_lims(1);lat_lims(1)=lat_lims(2);lat_lims(2)=tmp;end
    if lon_lims(1)>lon_lims(2), tmp=lon_lims(1);lon_lims(1)=lon_lims(2);lon_lims(2)=tmp;end
    %
    p=path;
    if isempty(findstr(p,'FUNCTIONS'))>0,
        addpath('.\FUNCTIONS');
    end
    if exist(atlas_modfile,'file')==0,
        fprintf('File %s does not exist\n',atlas_modfile);
        return
    else
        fid=fopen(atlas_modfile,'r');
        hname=fgetl(fid);uname=fgetl(fid);grname=fgetl(fid);
        fclose(fid);
    end
    if exist(out_modfile,'file')==0,
        fprintf('File %s does not exist\n',out_modfile);
        return
    else
        fid=fopen(out_modfile,'r');
        hname_out=fgetl(fid);uname_out=fgetl(fid);grname_out=fgetl(fid);
        fclose(fid);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % grid first
    if exist(grname,'file')==0,fprintf('No file %s exist\n',grname);return;end
    [ll_lims,hz,mz,iob] =  grd_in(grname);
    [n,m]=size(hz);
    dx = (ll_lims(2)-ll_lims(1))/n;
    dy = (ll_lims(4)-ll_lims(3))/m;
    lon = ll_lims(1)+dx/2:dx:ll_lims(2)-dx/2;
    lat = ll_lims(3)+dy/2:dy:ll_lims(4)-dy/2;
    ii=find(lon>=lon_lims(1) & lon<=lon_lims(2));
    jj=find(lat>=lat_lims(1) & lat<=lat_lims(2));
    th_lim1(1)=lat(jj(1))-1/60;th_lim1(2)=lat(jj(end))+1/60;
    if lon_lims(1)<0 & lon_lims(2)<0,lon_lims=lon_lims+360;end
    ph_lim1(2)=lon(ii(end))+1/60;
    if lon_lims(1)>0,
        ph_lim1(1)=lon(ii(1))-1/60;
    else, % passing through 0
        ii1=find(lon>lon_lims(1)+360);
        ii=[ii1,ii];
        ph_lim1(1)=lon(ii1(1))-1/60-360;
    end
    n1=length(ii);m1=length(jj);
    ll_lims1=[ph_lim1 th_lim1];
    fprintf('Your area limits aligned to TPXO9-atlas grid are\n');
    fprintf('lat: %10.3f %10.3f \n',th_lim1);
    fprintf('lon: %10.3f %10.3f \n',ph_lim1);
    fprintf('Saving TPXO9-atlas grid outcut in %s...',grname_out);
    grd_out(grname_out,ll_lims1,hz(ii,jj),mz(ii,jj),[],12);
    fprintf('done\n\n');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    switch computer('arch')
        case {'win32','win64'}
            [st,hfiles]=system(['dir /b/s/w ' hname]);
        case {'glnxa64','maci64','maca64'}
            [st,hfiles]=unix(['ls -1 ' hname]);
            % files = dir(hname);
            % files = arrayfun(@(x) fullfile(x.folder,x.name), files, 'UniformOutput', false);
            % hfiles = strjoin(files, '\n'); st = 1; clear files
            % hfiles = sprintf('%s\n',hfiles);
        otherwise
            error('platform error')
    end
    if st<0 | isempty(hfiles)>0,fprintf('No h-atlas files found, check %s\n',atlas_modfile);return;end
    switch computer('arch')
        case {'win32','win64'}
            [st,ufiles]=system(['dir /b/s/w ' uname]);
        case {'glnxa64','maci64','maca64'}
            [st,ufiles]=unix(['ls -1 ' uname]);
            % files = dir(uname);
            % files = arrayfun(@(x) fullfile(x.folder,x.name), files, 'UniformOutput', false);
            % ufiles = strjoin(files, '\n'); st = 1; clear files
            % ufiles = sprintf('%s\n',ufiles);
        otherwise
            error('platform error')
    end
    if st<0 | isempty(ufiles)>0,fprintf('No uv-atlas files found, check %s\n',atlas_modfile);return;end
    ind=regexp(hfiles,'\n');nf=length(ind);
    indu=regexp(ufiles,'\n');nf1=length(indu);
    %
    k1=1;cid=[];
    h=zeros(n1,m1,nf);
    for k=1:nf
        if k>1,k1=ind(k-1)+1;end
        hname=hfiles(k1:ind(k)-1);
        fprintf('Reading %s...',hname);
        [h0,th_lim0,ph_lim0]=h_in(hname,1);
        h(:,:,k)=h0(ii,jj);
        fprintf('done\n');
        switch computer('arch')
            case {'win32','win64'}
                ic=regexp(hname,'\h_');ic=ic+2;
            case {'glnxa64','maci64','maca64'}
                ic=regexp(hname,'/h_');ic=ic+3;
            otherwise
                error('platform error')
        end
    
        c4=hname(ic:ic+2);c4=strrep(c4,'_','');
        while length(c4)<4,c4=[c4 ' '];end
        cid=[cid c4];
    end
    fprintf('Elevation constituents: %s\n',cid);
    fprintf('Saving TPXO9-atlas elevation outcut in %s...',hname_out);
    h_out(hname_out,h,th_lim1,ph_lim1,cid);
    fprintf('done\n\n');
    k1=1;cid=[];
    clear h h0;
    u=zeros(n1,m1,nf1);v=u;
    for k=1:nf
        if k>1,k1=ind(k-1)+1;end
        uname=ufiles(k1:ind(k)-1);
        fprintf('Reading %s...',uname);
        [u0,v0,th_lim0,ph_lim0]=u_in(uname,1);
        u(:,:,k)=u0(ii,jj);v(:,:,k)=v0(ii,jj);
        fprintf('done\n');
        switch computer('arch')
            case {'win32','win64'}
                ic=regexp(uname,'\u_');ic=ic+2;
            case {'glnxa64','maci64','maca64'}
                ic=regexp(uname,'/u_');ic=ic+3;
            otherwise
                error('platform error')
        end
    
        c4=uname(ic:ic+2);c4=strrep(c4,'_','');
        while length(c4)<4,c4=[c4 ' '];end
        cid=[cid c4];
    end
    fprintf('\n');
    fprintf('Transport constituents: %s\n',cid);
    fprintf('Saving TPXO9-atlas transports outcut in %s...',uname_out);
    uv_out(uname_out,u,v,th_lim1,ph_lim1,cid);
    fprintf('done\n');
    return
end

