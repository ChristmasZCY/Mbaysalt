function map = interp_colormap(C, N, varargin)
    %       This function is used to generate a color map, means Gradient matrix generator
    %       渐变色矩阵生成器,a输入颜色矩阵,N表示把颜色矩阵a转变为N个色块的渐变颜色矩阵
    % =================================================================================================================
    % Parameter:
    %       C: color matrix              || required: True || type: double || format: martix
    %       N: number of color blocks    || required: True || type: double || format: scalar
    %       varargin{1}: mode            || required: False|| type: char   || format: scalar
    %       map: color map               || required: True || type: double || format: martix
    % =================================================================================================================
    % Example:
    %       map = interp_colormap(bb,60);
    % =================================================================================================================

    if isempty(varargin)
        str = 'mode1';
    else
        str = lower(varargin{1});
    end
    
    switch str
        case 'mode1'
            map = color2map(C, N);
        case 'mode2'
            ratio = varargin{2};
            if isempty(ratio) || abs(sum(ratio)-1) > 1e-8 || isequal(ratio, ratio(1)*ones(1,length(ratio))) || length(ratio) < size(C,1)-1
                error(['Ratio must be declared correctly. Ratio is a vector containing ', num2str(size(C,1)-1), '(The number of colors minus 1) unequal numbers that add up to 1.']);
            end
        
            CNum = round(ratio * N);
            S = sum(CNum);
            [~,idx] = max(CNum);
            if S > N
                CNum(idx) = CNum(idx)-(S-N);
            elseif S < N
                CNum(idx) = CNum(idx)+N-S;
            end
        
            map = [];
        
            for ii = 1 : length(CNum)
                temp1 = color2map(C( ii:ii+1,1:3), CNum(ii));
                temp2 = temp1(2:end-1,1:3);
                temp3 = [C(ii,1:3);temp2 ];
                if ii ~= length( CNum )
                    map = [map;temp3];
                else
                    map = [map;temp3;C(ii+1,1:3)];
                end
            end
    end
end

function cmap = color2map(C,N)
    num = size(C,1);
    vec = linspace(1,num,N);
    x = 1:num;
    cmap = interp1(x, C, vec, 'linear');
end
