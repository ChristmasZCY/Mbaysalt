clm

%--------------------------------Setting-----------------------------------
% initial
f2dm = '/Users/christmas/Desktop/项目/网格/ECS/ECS_6/ECS6_20230614_fixed_depth_bound.2dm'; % 2dm file
dep_dir = '/Users/christmas/Documents/资料&材料/水深数据/近岸水深'; % depth file directory
dep_files = dir([dep_dir '/*.txt']); % depth file name
fig_dir = './'; % figure save directory
dist_min = 5e-2; % minimum distance to find the nodes in coverage
missing_value = -32767; % missing value in depth file

% Read grid
f = f_load_grid(f2dm);

for ifile = 1:length(dep_files)
    % Read depth
    fdep = [dep_dir '/' dep_files(ifile).name];
    data = load(fdep);
    data(data(:, 3) == missing_value, :) = [];
    dep_x = data(:, 1);
    dep_y = data(:, 2);
    dep_z = -data(:, 3);

    % Find the nodes in coverage
    [id, R] = knnsearch([dep_x dep_y], [f.x f.y]);
    k = find(R < dist_min);

    if isempty(k)
        continue
    end

    % Figure limits
    xlims = minmax(f.x(k));
    ylims = minmax(f.y(k));
    xlims = [xlims(1) - 0.1 xlims(2) + 0.1];
    ylims = [ylims(1) - 0.1 ylims(2) + 0.1];
    diff_xlims = diff(xlims);
    diff_ylims = diff(ylims);

    if diff_xlims / diff_ylims < 4/3
        xlims = [xlims(1) - (4 * diff_ylims - 3 * diff_xlims) / 6 xlims(2) + (4 * diff_ylims - 3 * diff_xlims) / 6];
    elseif diff_xlims > diff_ylims
        ylims = [ylims(1) - (3 * diff_xlims - 4 * diff_ylims) / 8 ylims(2) + (3 * diff_xlims - 4 * diff_ylims) / 8];
    end

    % Depth interpolation
    % DTC depth
    h1 = f.h;
    % China coastal depth
    F = scatteredInterpolant(dep_x, dep_y, dep_z, 'linear', 'none');
    h2 = nan(f.node, 1);
    h2(k) = F(f.x(k), f.y(k));
    k = find(~isnan(h2));
    h2(k) = F(f.x(k), f.y(k));
    % Merged depth
    h3 = h1;
    h3(k) = h2(k);

    zlims = [-5 max(h2)];
    cm = cm_load('Turbo');
    close all
    figure('Position', [1 1 1000 737])
    ax1 = subplot('Position', [0.1 - 0.03 0.55 0.4 0.42]);
    hold on
    plane_range(xlims, ylims);
    f_2d_mesh(f, 'LineWidth', 0.01);
    plot(dep_x, dep_y, 'r.')
    plot(f.x(k), f.y(k), 'b.', 'MarkerSize', 5)
    ax2 = subplot('Position', [0.515 - 0.03 0.55 0.4 0.42]);
    hold on
    plane_range(xlims, ylims);
    f_2d_image(f, h2);
    f_2d_mesh(f, 'LineWidth', 0.01);
    caxis(zlims)
    ax3 = subplot('Position', [0.1 - 0.03 0.12 0.4 0.42]);
    hold on
    plane_range(xlims, ylims);
    f_2d_image(f, h1);
    f_2d_mesh(f, 'LineWidth', 0.01);
    caxis(zlims)
    ax4 = subplot('Position', [0.515 - 0.03 0.12 0.4 0.42]);
    hold on
    plane_range(xlims, ylims);
    f_2d_image(f, h3);
    f_2d_mesh(f, 'LineWidth', 0.01);
    caxis(zlims)

    colormap(ax2, cm);
    colormap(ax3, cm);
    colormap(ax4, cm);
    xlabel(ax3, 'Longitude (^oE)')
    xlabel(ax4, 'Longitude (^oE)')
    ylabel(ax1, 'Latitude (^oN)')
    ylabel(ax3, 'Latitude (^oN)')
    set(ax1, 'xticklabel', '')
    set(ax2, 'xticklabel', '')
    set(ax2, 'yticklabel', '')
    set(ax4, 'yticklabel', '')
    mf_label(ax1, 'Coverage', 'topleft')
    mf_label(ax2, 'Updated', 'topleft')
    mf_label(ax3, 'DTC', 'topleft')
    mf_label(ax4, 'Merged', 'topleft')

    cb = colorbar(ax4, 'Location', 'east');
    cb.Position = [0.92 0.128 0.022 0.736];
    cb.Title.String = 'Depth (m)';
    cb.Title.FontSize = 16;

    i = strfind(dep_files(ifile).name, '高程点');
    ffig = [fig_dir '/' dep_files(ifile).name(1:i - 1) '.png'];
    mf_save(ffig)

end
