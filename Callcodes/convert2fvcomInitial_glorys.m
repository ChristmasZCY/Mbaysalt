function convert2fvcomInitial_glorys(fout, fgrid, lon_glorys, lat_glorys, depth, Times, t0, s0)
    %       Convert GLORYS data to FVCOM initial file format.
    % =================================================================================================================
    % Parameters:
    %       fout:           output file name                || required: True || type: String   || example: './fvcom_initial.nc'
    %       fgrid:          FVCOM grid structure            || required: True || type: Struct   || from: f_load_grid
    %       lon_glorys:     longitude of GLORY              || required: True || type: scalar   || example: 1D
    %       lat_glorys:     latitude of GLORY               || required: True || type: scalar   || example: 1D
    %       depth:          depth of GLORYS                 || required: True || type: scalar   || example: 1D
    %       Times:          time of GLORYS                  || required: True || type: datetime || example: datetime(2024, 4, 2)
    %       t0:             temperature of GLORYS           || required: True || type: scalar   || example: 3D
    %       s0:             salinity of GLORYS              || required: True || type: scalar   || example: 3D
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Updates:
    %       2026-06-30:     Created, by Christmas;
    % =================================================================================================================
    % Examples:
    %    convert2fvcomInitial_glorys(fout, fgrid, lon_ori, lat_ori, depth, Times, t_ori, s_ori)
    % =================================================================================================================

    lon_ori = lon_glorys;
    lat_ori = lat_glorys;
    [Lat_ori, Lon_ori] = meshgrid(lat_ori, lon_ori);
    weight_2d = interp_2d_calc_weight("ID", Lon_ori, Lat_ori, fgrid.x, fgrid.y);

    t1 = interp_2d_via_weight(t0, weight_2d);
    s1 = interp_2d_via_weight(s0, weight_2d);

    % 去掉陆地点，让陆地点也有值，便于插值
    % 陆地点自由表层有值
    I_D = erosion_coast_cal_id(fgrid.x, fgrid.y, s1(:,1), 2600, 1);
    t2 = erosion_coast_via_id(I_D, t1);
    s2 = erosion_coast_via_id(I_D, s1);

    % 找到每个点最深处数据对应的层号（从0开始）（参考calcIndex_bottom_vari_from_standard_level）
    depth_num = len(depth);
    a = 1:1:depth_num;
    b = repmat(a, size(t2,1), 1);  % 和 t2 size相同
    b(isnan(t2)) = NaN;
    Index = max(b,[],2);
    F = sum(isnan(Index));
    if F
        error("NaN: %d . \n" + ...
            "Need to Increase 'erosion_coast_cal_id': 'K', 'judge_num'.", F);
    end
    % Index(isnan(Index)) = 0;

    % 浅点的 深层NaN（无水位置）都用 最深层（有水位置）的数据替换
    for inode = 1: fgrid.node
        t2(inode,isnan(t2(inode,:))) = t2(inode,Index(inode));
        s2(inode,isnan(s2(inode,:))) = s2(inode,Index(inode));
    end

    % 垂向插值
    depth2 = [depth', 6000, 6500, 7000, 7500, 8000, 8500, 9000, 9500, 10000];
    F = find(depth2 > max(fgrid.h),1);
    depth2 = depth2(1:F);
    weight_ve = interp_vertical_calc_weight(repmat(depth', fgrid.node, 1),repmat(depth2, fgrid.node, 1));

    t3 = interp_vertical_via_weight(t2,weight_ve);
    s3 = interp_vertical_via_weight(s2,weight_ve);

    if all(depth2> 0) 
        depth2 = -depth2;
    end

    write_initial_ts(fout, depth2, t3, s3, datenum(Times));

end
