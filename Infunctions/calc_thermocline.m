function [max_grad_total, thickness_total, upper_bound_total, lower_bound_total] = calc_thermocline(depth, T)
% CALC_THERMOCLINE 以原有 1 米 PCHIP 和最大平均梯度连续段计算温跃层。
% Inputs:
%   depth: single/double、严格递增的一维深度坐标，单位 m，正值向下。
%   T: single/double、lon-lat-depth-time 温度数组，单位 degrees C；NaN 为缺测。
% Outputs:
%   max_grad_total: double、lon-lat-time，所选连续段的最大绝对梯度，单位 degrees C/m。
%   thickness_total: double、lon-lat-time，所选连续段厚度，单位 m。
%   upper_bound_total, lower_bound_total: double、lon-lat-time，所选段的上下边界，单位 m。
%   全缺测剖面四项均为 NaN；未检出跃层时强度为 NaN，厚度为 0，上下边界取最深梯度中点。
% Errors: 有效剖面不足以构成 1 米梯度区间时抛出，维度或 PCHIP 输入无效时透传 MATLAB 错误。
% 同有效深度掩码的剖面分组、每批最多 256 条，限制 1 米插值临时数组的内存。
% 候选区间只控制要计算的节点，未修改原有 0.2/0.05 degrees C/m 阈值和选段规则。
nx=size(T,1); ny=size(T,2); nt=size(T,4); nz=size(T,3);
profiles=reshape(permute(T,[3 1 2 4]),nz,[]);
[patterns,~,groups]=unique(~isnan(profiles)','rows');
out=nan(size(profiles,2),4);
for group=1:size(patterns,1)
    mask=patterns(group,:)';
    if ~any(mask), continue; end
    z=depth(mask);
    zq=(ceil(min(z)):floor(max(z)))';
    if numel(zq)<2, error('calc_thermocline:ShortProfile','有效深度不足以形成 1 米梯度区间。'); end
    zmid=zq(1:end-1)+diff(zq)/2;
    if max(z)<=200, cutoff=0.2; else, cutoff=0.05; end
    indices=find(groups==group);
    % 每池最多 4096 条剖面按最深候选区间排序，减少浅剖面随深剖面扩大插值范围。
    % 仅调整批次成员，结果仍按 chosen 写回原空间/时间索引。
    for poolFirst=1:4096:numel(indices)
        poolRange=poolFirst:min(poolFirst+4095,numel(indices));
        pool=indices(poolRange);
        poolValues=profiles(mask,pool);
        poolSecants=abs(diff(double(poolValues),1,1)./diff(double(z(:))));
        poolRounding=32*double(eps(max(abs(poolValues),[],1)));
        poolPossible=3*poolSecants+poolRounding>=cutoff;
        deepest=max(poolPossible.*reshape(1:size(poolPossible,1),[],1),[],1);
        [~,poolOrder]=sort(deepest);
        indices(poolRange)=pool(poolOrder);
    end
    for first=1:256:numel(indices)
        chosen=indices(first:min(first+255,numel(indices)));
        block=nan(numel(chosen),4);
        block(:,2)=0; block(:,3)=zmid(end); block(:,4)=zmid(end);
        values=profiles(mask,chosen);
        % PCHIP 两端导数与区间割线同号、各不超过其 3 倍；Hermite 导数对
        % 两端系数线性，系数范围四角的绝对值均不超过 3 倍割线，可安全筛除。
        % 加入 32 个温度 ULP 的余量，覆盖 single 插值及相减的舍入。
        secants=abs(diff(double(values),1,1)./diff(double(z(:))));
        rounding=32*double(eps(max(abs(values),[],1)));
        possible=any(3*secants+rounding>=cutoff,2);
        if any(~isfinite(values(:))), possible(:)=true; end
        candidates=false(numel(zq)-1,1);
        for interval=reshape(find(possible),1,[])
            left=max(1,double(floor(z(interval))-zq(1)+1));
            right=min(numel(candidates),double(ceil(z(interval+1))-zq(1)));
            if left<=right, candidates(left:right)=true; end
        end
        queryStarts=zq(find(candidates));
        if isempty(queryStarts), out(chosen,:)=block; continue; end
        queryPoints=unique([queryStarts;queryStarts+1]);
        [~,left]=ismember(queryStarts,queryPoints);
        [~,right]=ismember(queryStarts+1,queryPoints);
        temperatures=interp1(z,values,queryPoints,'pchip');
        gradients=abs(temperatures(right,:)-temperatures(left,:));
        activeMid=queryStarts+0.5;
        selected=gradients>=cutoff;
        % 单候选区间时仍保持空连接数组和分段累计值为列向量。
        connected=reshape(diff(queryStarts)==1,[],1);
        starts=selected&~[false(1,numel(chosen));selected(1:end-1,:)&connected];
        ends=selected&~[selected(2:end,:)&connected;false(1,numel(chosen))];
        [beginRow,column]=find(starts);
        beginRow=beginRow(:); column=column(:);
        [endRow,~]=find(ends);
        endRow=endRow(:);
        if ~isempty(beginRow)
            segment=cumsum(reshape(starts(selected),[],1));
            values=reshape(double(gradients(selected)),[],1);
            count=endRow-beginRow+1;
            sums=accumarray(segment,values,[numel(beginRow),1]);
            peaks=accumarray(segment,values,[numel(beginRow),1],@max);
            averages=cast(sums./count,'like',gradients);
            bestAverage=accumarray(column,double(averages),[numel(chosen),1],@max,-inf);
            best=double(averages)==bestAverage(column);
            winner=accumarray(column(best),find(best),[numel(chosen),1],@min,0);
            % 段均值接近时回到原 mean 顺序，避免累计方式改变并列段选择。
            roundoff=(count+4).*double(eps(cast(peaks,'like',gradients)));
            maxRoundoff=accumarray(column,roundoff,[numel(chosen),1],@max,0);
            near=(bestAverage(column)-double(averages))<=2*maxRoundoff(column);
            ambiguous=find(accumarray(column,double(near),[numel(chosen),1])>1);
            for k=reshape(ambiguous,1,[])
                segments=find(column==k); exactBest=-inf;
                for s=reshape(segments,1,[])
                    average=mean(gradients(beginRow(s):endRow(s),k));
                    if average>exactBest, winner(k)=s; exactBest=average; end
                end
            end
            found=find(winner>0);
            s=winner(found);
            block(found,1)=peaks(s);
            block(found,3)=activeMid(beginRow(s));
            block(found,4)=activeMid(endRow(s));
            block(found,2)=block(found,4)-block(found,3);
        end
        out(chosen,:)=block;
    end
end
max_grad_total=reshape(out(:,1),nx,ny,nt);
thickness_total=reshape(out(:,2),nx,ny,nt);
upper_bound_total=reshape(out(:,3),nx,ny,nt);
lower_bound_total=reshape(out(:,4),nx,ny,nt);
end
