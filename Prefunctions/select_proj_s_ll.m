function Sproj = select_proj_s_ll(area_name,varargin)
    % =================================================================================================================
    % discription:
    %       Select the projection and the area to plot
    % =================================================================================================================
    % parameter:
    %       area_name: area name              || required: True || type: char   || format: 'scs' 'ecs' 'global'
    %       Sproj.
    %           projection: projection name   || required: True || type: char   || format: 'Mercator' 'Miller Cylindrical' 'Miller'
    %           lon_select: longitude range   || required: True || type: double || format: [min max]
    %           lat_select: latitude range    || required: True || type: double || format: [min max]
    %           gshhs: gshhs name             || required: True || type: char   || format: 'f' 'i' 'l'
    %           title_area: title name        || required: True || type: char   || format: 'South China Sea' 'East China Sea' 'Global'
    %           Fname_section: folder name    || required: True || type: char   || format: 'scs_project' 'scs_project2' 'southchinasea' 'eastchinasea' 'global'
    % =================================================================================================================
    % example:
    %       Sproj = select_proj_s_ll('scs')
    %       scs_project  -->  南海结题
    %       scs_project2 -->  南海结题大区域
    %       scs          -->  南海
    %       ecs          -->  东海
    %       global       -->  全球
    % =================================================================================================================

    if strcmp(area_name, "scs_project")
        % 南海结题
        Sproj.projection = 'Mercator';
        Sproj.gshhs = 'f';
        Sproj.lon_select = [105 124];
        Sproj.lat_select = [15 23];
        Sproj.title_area = 'South China Sea';
        Sproj.Fname_section = 'scs_project';
    elseif strcmp(area_name,"scs_project2")
        % 南海结题大区域
        Sproj.projection = 'Mercator';
        Sproj.gshhs = 'f';
        Sproj.lon_select = [95 125];
        Sproj.lat_select = [0 25];
        Sproj.title_area = 'South China Sea';
        Sproj.Fname_section = 'scs_project2';
    elseif strcmp(area_name,"scs")
        % 南海
        Sproj.projection = 'Miller Cylindrical';
        Sproj.gshhs = 'l';
        Sproj.lon_select = [95 125];
        Sproj.lat_select = [-2 25];
        Sproj.title_area = 'South China Sea';
        Sproj.Fname_section = 'southchinasea';
    elseif strcmp(area_name,"ecs")
        % 东海
        Sproj.projection = 'Miller';
        Sproj.gshhs = 'l';
        Sproj.lon_select = [117 135];
        Sproj.lat_select = [21 42];
        Sproj.title_area = 'East China Sea';
        Sproj.Fname_section = 'eastchinasea';
    elseif strcmp(area_name,"global")
        % 全球
        Sproj.projection = 'miller';
        Sproj.gshhs = 'l';
        Sproj.lon_select = [-180 180];
        Sproj.lat_select = [-90 90];
        Sproj.title_area = 'Global';
        Sproj.Fname_section = 'global';
    end
end
