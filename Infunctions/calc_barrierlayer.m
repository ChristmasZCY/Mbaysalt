function [MLD_total, BLT_total] = calc_barrierlayer(lon, lat, depth, T, S)
    %       Calculate barrier-layer
    % =================================================================================================================
    % Parameters:
    %       lon:    longitude       || required: True  || type: 1D
    %       lat:    latitude        || required: True  || type: 1D
    %       depth:  depth           || required: True  || type: 1D
    %       T:      sea temperature || required: True  || type: 4D(lon-lat-depth-time)
    %       S:      sea salinity    || required: True  || type: 4D(lon-lat-depth-time)
    % =================================================================================================================
    % Returns:
    %       MLD_total: mixed layer depth (meter)        ||type: 3D(lon-lat-time) 混合层厚度 混合层深度
    %       BLT_total: barrier layer thickness (meter)  ||type: 3D(lon-lat-time) 障碍层厚度
    % =================================================================================================================
    % Updates:
    %       ****-**-**:     Created,                by Jiaqi Dou;
    %       2025-07-23:     Code Refactoring,       by Christmas;
    % =================================================================================================================
    % Examples:
    %       lon = nr('./data/salinity_20250513.nc','longitude');
    %       lat = nr('./data/temperature_20250513.nc', 'latitude');
    %       depth = nr('./data/temperature_20250513.nc', 'depth');
    %       T = nr('./data/temperature_20250513.nc', 'to');
    %       S = nr('./data/salinity_20250513.nc', 'so');
    %       [MLD_total, BLT_total] = calc_barrierlayer(lon, lat, depth, T, S);
    % =================================================================================================================
    % References:
    %       于瑶, 吴松华. 基于2007—2018年Argo数据分析全球混合层和障碍层时空特征[J]. 中国海洋大学学报(自然科学版), 2021, 51(12): 123-132. 
    % =================================================================================================================

    MLD_total = nan(size(T,[1,2,4]));
    BLT_total = nan(size(T,[1,2,4]));
    for it = 1 :size(T,4)
        t0 = T(:,:,:,it);
        s0 = S(:,:,:,it);

        ref_depth_idx = find(depth >= 10, 1, 'first');

        %根据深度和纬度计算海水压力
        depth_3d = repmat(reshape(depth, 1, 1, []), len(lon), len(lat), 1);
        [lat_2d, ~] = meshgrid(lat, lon);
        pres = nan(size(T,[1,2,3]));
        dens = nan(size(T,[1,2,3]));
        for ih = 1: len(depth)
            pres(:,:,ih) = sw_pres(squeeze(depth_3d(:,:,ih)),lat_2d);%单位db
            %根据温度，盐度和压力计算海水密度
            dens(:,:,ih) = sw_dens(squeeze(s0(:,:,ih)),squeeze(t0(:,:,ih)),squeeze(pres(:,:,ih)));%单位kg/m^3
        end

        % 参考深度处的温度和盐度
        ref_temp = t0(:,:,ref_depth_idx);
        ref_salt = s0(:,:,ref_depth_idx);
        ref_pres = pres(:,:,ref_depth_idx);
        ref_dens = sw_dens(ref_salt,ref_temp-0.2,ref_pres);%单位kg/m^3


        % 初始化MLD_T, MLD_D和MLD
        MLD_T = nan(size(T,[1,2]));
        MLD_D = nan(size(T,[1,2]));
        MLD = nan(size(T,[1,2]));  % 混合层厚度 混合层深度
        BLT = nan(size(T,[1,2]));  % 障碍层厚度

        % 计算每个网格点的MLD_T（基于温度的混合层深度）
        temp_threshold = ref_temp - 0.2;

        for i = 1: len(lon)
            for j = 1: len(lat)
                % 检查当前位置是否有足够的数据
                if all(isnan(squeeze(t0(i,j,:)))) || all(isnan(squeeze(s0(i,j,:))))
                    MLD_T(i,j) = NaN;
                    continue;
                end

                % 获取当前位置温度剖面
                temp_profile = squeeze(t0(i,j,:));

                % 检查参考温度是否有效
                if isnan(ref_temp(i,j))
                    MLD_T(i,j) = NaN;
                    continue;
                end

                % 寻找第一个低于温度阈值的深度
                MLD_T_idx = find(temp_profile <= temp_threshold(i,j), 1, 'first');

                if isempty(MLD_T_idx)
                    % 如果没有找到低于阈值的温度，设为有效温度数据的最大深度
                    valid_depths = depth(~isnan(temp_profile));
                    if ~isempty(valid_depths)
                        MLD_T(i,j) = max(valid_depths);
                    else
                        MLD_T(i,j) = NaN; % 如果没有有效数据，设为NaN
                    end
                    %MLD_T(i,j) = max(depth);
                elseif MLD_T_idx == 1
                    % 如果第一个点就低于阈值，使用该深度
                    MLD_T(i,j) = depth(MLD_T_idx);
                else
                    % 在找到的索引和前一个索引之间进行线性插值
                    t1 = temp_profile(MLD_T_idx-1);
                    t2 = temp_profile(MLD_T_idx);
                    d1 = depth(MLD_T_idx-1);
                    d2 = depth(MLD_T_idx);

                    % 线性插值计算确切的深度
                    MLD_T(i,j) = d1 + (d2-d1)*(temp_threshold(i,j)-t1)/(t2-t1);
                end
            end
        end


        % 计算每个网格点的MLD_D（基于密度的混合层深度）
        for i = 1: len(lon)
            for j = 1: len(lat)
                % 检查当前位置是否有足够的数据
                if all(isnan(squeeze(dens(i,j,:))))
                    MLD_D(i,j) = NaN;
                    continue;
                end

                % 获取当前位置密度剖面
                dens_profile = squeeze(dens(i,j,:));

                % 检查参考密度阈值是否有效
                if isnan(ref_dens(i,j))
                    MLD_D(i,j) = NaN;
                    continue;
                end

                % 寻找第一个高于密度阈值的深度
                MLD_D_idx = find(dens_profile >= ref_dens(i,j), 1, 'first');

                if isempty(MLD_D_idx)
                    % 如果没有找到高于阈值的密度，设为有效数据的最大深度
                    valid_depths = depth(~isnan(dens_profile));
                    if ~isempty(valid_depths)
                        MLD_D(i,j) = max(valid_depths);
                    else
                        MLD_D(i,j) = NaN; % 如果没有有效数据，设为NaN
                    end
                    %MLD_D(i,j) = max(depth);
                elseif MLD_D_idx == 1
                    % 如果第一个点就高于阈值，使用该深度
                    MLD_D(i,j) = depth(MLD_D_idx);
                else
                    % 在找到的索引和前一个索引之间进行线性插值
                    d1 = dens_profile(MLD_D_idx-1);
                    d2 = dens_profile(MLD_D_idx);
                    z1 = depth(MLD_D_idx-1);
                    z2 = depth(MLD_D_idx);

                    % 线性插值计算确切的深度
                    MLD_D(i,j) = z1 + (z2-z1)*(ref_dens(i,j)-d1)/(d2-d1);
                end
            end
        end



        % 确定最终的MLD和计算BLT
        for i = 1: len(lon)
            for j = 1: len(lat)
                % 跳过无效数据点
                if isnan(MLD_T(i,j)) || isnan(MLD_D(i,j))
                    MLD(i,j) = NaN;
                    BLT(i,j) = NaN;
                    continue;
                end

                % 计算障碍层厚度
                BLT(i,j) = MLD_T(i,j) - MLD_D(i,j);

                % 根据论文方法确定最终MLD
                if abs(MLD_T(i,j) - MLD_D(i,j)) < 1e-6  % 几乎相等
                    % 温度跃层与密度跃层重合
                    MLD(i,j) = MLD_T(i,j);
                elseif MLD_T(i,j) < MLD_D(i,j)
                    % 存在补偿层
                    MLD(i,j) = MLD_T(i,j);
                else % MLD_T(i,j) > MLD_D(i,j)
                    % 存在障碍层
                    MLD(i,j) = MLD_D(i,j);
                end
            end
        end
        BLT_total(:,:,it) = BLT;
        BLT_total(BLT_total<0) = 0;
        MLD_total(:,:,it) = MLD_T;
    end

end
