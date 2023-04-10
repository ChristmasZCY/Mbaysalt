function [projection,lon_select,lat_select,gshhs] = select_proj_s_ll(varargin)
    %% scs_project 南海结题
    %% scs 南海
    %% ecs 东海
    %% global 全球

    if strcmp(varargin{1}, "scs_project")
        % 南海结题
        projection = 'Mercator';
        gshhs = 'f';
        lon_select = [105 124];
        lat_select = [15 23];
    elseif strcmp(varargin{1},"scs_project2")
        % 南海结题大区域
        projection = 'Mercator';
        gshhs = 'f';
        lon_select = [95 125];
        lat_select = [0 25];
    elseif strcmp(varargin{1},"scs")
        % 南海
        projection = 'Miller Cylindrical';
        gshhs = 'i';
        lon_select = [95 125];
        lat_select = [-2 25];
    elseif strcmp(varargin{1},"ecs")
        % 东海
        projection = 'Miller Cylindrical';
        gshhs = 'i';
        lon_select = [117 127];
        lat_select = [23 41];
    elseif strcmp(varargin{1},"global")
        % 全球
        projection = 'miller';
        gshhs = 'l';
        lon_select = [-180 180];
        lat_select = [-90 90];
    end
end