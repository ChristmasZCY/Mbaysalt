function [projection,lon_select,lat_select,gshhs,title_area, Fname_section] = select_proj_s_ll(area_name,varargin)
    % =================================================================================================================
    % discription:
    %       Select the projection and the area to plot
    % =================================================================================================================
    % parameter:
    %       area_name: area name          || required: True || type: char   || format: 'scs' 'ecs' 'global'
    %       projection: projection name   || required: True || type: char   || format: 'Mercator' 'Miller Cylindrical' 'Miller'
    %       gshhs: gshhs name             || required: True || type: char   || format: 'f' 'i' 'l'
    %       lon_select: longitude range   || required: True || type: double || format: [min max]
    %       lat_select: latitude range    || required: True || type: double || format: [min max]
    %       title_area: title name        || required: True || type: char   || format: 'South China Sea' 'East China Sea' 'Global'
    %       Fname_section: folder name    || required: True || type: char   || format: 'scs_project' 'scs_project2' 'southchinasea' 'eastchinasea' 'global'
    % =================================================================================================================
    % example:
    %       [projection,lon_select,lat_select,gshhs,title_area,Fname_section] = select_proj_s_ll('scs')
    %       scs_project  -->  南海结题
    %       scs_project2 -->  南海结题大区域
    %       scs          -->  南海
    %       ecs          -->  东海
    %       global       -->  全球
    % =================================================================================================================

    if strcmp(area_name, "scs_project")
        % 南海结题
        projection = 'Mercator';
        gshhs = 'f';
        lon_select = [105 124];
        lat_select = [15 23];
        title_area = 'South China Sea';
        Fname_section = 'scs_project';
    elseif strcmp(area_name,"scs_project2")
        % 南海结题大区域
        projection = 'Mercator';
        gshhs = 'f';
        lon_select = [95 125];
        lat_select = [0 25];
        title_area = 'South China Sea';
        Fname_section = 'scs_project2';
    elseif strcmp(area_name,"scs")
        % 南海
        projection = 'Miller Cylindrical';
        gshhs = 'i';
        lon_select = [95 125];
        lat_select = [-2 25];
        title_area = 'South China Sea';
        Fname_section = 'southchinasea';
    elseif strcmp(area_name,"ecs")
        % 东海
        projection = 'Miller';
        gshhs = 'i';
        lon_select = [117 135];
        lat_select = [21 42];
        title_area = 'East China Sea';
        Fname_section = 'eastchinasea';
    elseif strcmp(area_name,"global")
        % 全球
        projection = 'miller';
        gshhs = 'l';
        lon_select = [-180 180];
        lat_select = [-90 90];
        title_area = 'Global';
        Fname_section = 'global';
    end
end
