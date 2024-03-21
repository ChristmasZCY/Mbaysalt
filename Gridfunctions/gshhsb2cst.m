function gshhsb2cst(fin, fout, varargin)
    % <a href="matlab: web('https://mp.weixin.qq.com/s/S1MFCHIQzBNdyrj96PJNeg')">Description</a>.
    % <a href="matlab: web('https://share.weiyun.com/5wJVmAHW')">Code download</a>.
    % ===========================================================================
    % Convert GSHHS coastline data from binary to mat format.
    % Download the data from
    % http://www.soest.hawaii.edu/wessel/gshhg/
    %--------------------------------------------------------------------------
    % Use the GSHHS data to generate a coastline file (cst).
    % The output can be used to generate a FVCOM grid by SMS.
    % The gshhs_?.mat is needed. (Use the 'convert_gshhs_b2mat.m' to get it)
    %--------------------------------------------------------------------------
    %
    % 2020-06-30    Created,    by Siqi Li, SMAST
    % 2024-03-21    Mereged,    by Christmas
    % ===========================================================================

    varargin = read_varargin(varargin,{'xlims'},{[]});
    varargin = read_varargin(varargin,{'ylims'},{[]});

    % Read the binary data
    data=gshhs(fin);
    
    % Count how many polygons
    npart=length(data);
    
    % First count how many points of coastline.
    node=zeros(npart,1);
    for i=1:npart
        node(i)=length(data(i,1).Lon);
    end
    n=sum(node);
    lon=zeros(n,1);
    lat=zeros(n,1);
    
    % Second get the lon and lat out.
    j1=0;
    j2=0;
    for i=1:npart
        j1=j2+1;
        j2=sum(node(1:i));
        lon(j1:j2)=data(i,1).Lon;
        lat(j1:j2)=data(i,1).Lat;
    end
    
    % % Save the lon and lat out into mat file.
    % save(fout,'lon','lat');
    
    % The longitude and latitude ranges.
    if isempty(xlims)
        xlims = minmax(lon);
    end

    if isempty(ylims)
        ylims = minmax(lat);
    end
    
    % The number of islands that are kept in the final results
    % You may remove some islands by set this number smaller
    % At least 1.
    nisland=500;
    %--------------------------------------------------------------------------
    
    % Read the gshhs_h.mat file and get the lon, lat variables.
    % load(f_gshhs);
    X=lon(:);
    Y=lat(:);
    
    % First delete the points that are out of the domain
    tmp=find(X<xlims(1) | X>xlims(2) | Y<ylims(1) | Y>ylims(2));
    X(tmp)=[];
    Y(tmp)=[];
    
    n=length(X);
    
    a=X(1:n-1);
    b=X(2:n);
    % After the step above, there may be some useless 'NaN', delete them.
    tmp=find(isnan(a) & isnan(b));
    X(tmp)=[];
    Y(tmp)=[];
    % The X and Y should start and end with 'NaN'.
    if(~isnan(X(1)))
        X=[nan;X];
        Y=[nan;Y];
    end
    if(~isnan(X(end)))
        X=[X;nan];
        Y=[Y;nan];
    end
    % Use 'NaN' as a tip to saperate different islands.
    t=find(isnan(X));
    t1=t(1:end-1);
    t2=t(2:end);
    tb=t2-t1+1;
    
    
    % For main land
    main(:,1)=X(t1(1):t2(1));main(:,2)=Y(t1(1):t2(1));
    % For island
    nisland=min(length(t)-2,nisland);
    island(:,1)=X(t(2):t(nisland+2));island(:,2)=Y(t(2):t(nisland+2));
    island_x=island(:,1);
    island_y=island(:,2);
    k=find(isnan(island_x));
    k1=k(1:end-1);
    k2=k(2:end);
    kb=k2-k1+1;
    
    % Check if every line is a loop.
    if (main(2,:)==main(end-1,:))
        if_main_loop=1;
    else
        if_main_loop=0;
    end
    for i=1:nisland
        if (island(k1(i)+1,:)==island(k2(i)-1,:))
            if_island_loop(i)=1;
        else
            if_island_loop(i)=0;
        end
    end
    
    % Correct the non-loop lines.
    % For the main coastline. This line may be changed for your own case.
    main_out=[main(1,:);xlims(2),ylims(1);main(2:end-1,:);xlims(2),ylims(1);main(end,:)];
    island_out=[island(k1(1):k2(1),:);island(k2(2)-1,:);island(k2(1)+1:end,:)];
    
    % Plot the coastline.
    plot(main_out(:,1),main_out(:,2),'b')
    hold on
    plot(island_out(:,1),island_out(:,2),'r')
    ylabel('Latitude (°)')
    xlabel('Longitude (°)')
    set(gca,'fontsize',14)
    set(gca,'xlim',xlims)
    set(gca,'ylim',ylims)
    
    
    
    % Wrtie into cst file.
    coast=[main_out ;island_out(2:end,:)];
    npart=sum(isnan(coast(:,1)))-1;
    tmp=find(isnan(coast(:,1)));
    a1=tmp(1:end-1);
    a2=tmp(2:end);
    part_k=[a1+1 a2-1];
    fid=fopen(fout,'w');
    fprintf(fid,'%s\n','COAST');
    fprintf(fid,'%d %f\n',npart,0.0);
    for i=1:npart
        if(coast(a1(i),:)==coast(a2(i),:))
            is_close=1;
        else
            is_close=0;
        end
        fprintf(fid,'%d %d\n',a2(i)-a1(i)-1,is_close);
        for j=a1(i)+1:a2(i)-1
            fprintf(fid,'%14.6f %14.6f %4.1f\n',coast(j,1),coast(j,2),0.0);
        end
    end
    fclose(fid);
end
