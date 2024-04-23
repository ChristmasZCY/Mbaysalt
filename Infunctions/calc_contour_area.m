function areaC = calc_contour_area(varargin)
    %       To calculate area of contour
    % =================================================================================================================
    % Parameters:
    %       varargin:       optional parameters
    %           C or h:     cout or hand                        || required: True  || type: double of Contour
    %           num:        Number of areas to be calculated    || required: False || type: double of Contour
    % =================================================================================================================
    % Returns:
    %       areaC:          Area of contour
    % =================================================================================================================
    % Updates:
    %       2024-04-23:     Created, by Christmas;
    % =================================================================================================================
    % Examples:
    %       areaC = calc_contour_area(C);
    %       areaC = calc_contour_area(h);
    % =================================================================================================================
    % Reference:
    %       https://blog.csdn.net/island_chenyanyu/article/details/133296666
    %       https://ww2.mathworks.cn/matlabcentral/answers/132216-how-do-i-calculate-area-enclosed-by-contour-lines#answer_337508
    % =================================================================================================================
    
    arguments(Input,Repeating)
        varargin
    end
    
    A = varargin{1};
    varargin(1) = [];
    
    if isa(A,"double")
        C = A;
    elseif isa(A,'matlab.graphics.chart.primitive.Contour')
        h = A;
    end
    clear A

    if exist("C","var")
        num = varargin{1};
        varargin(1) = [];
        areaC = zeros(num,1); % The number of areas to be calculated
        k=1; % i is for area loop. k is another couter
        if ~isempty(C)
            for i=1 : num
                xx = C(1,k+1:k+C(2,k)); % x data of a particular contour line
                yy = C(2,k+1:k+C(2,k)); % y data of a particular contour line
                areaC(i) = polyarea(xx,yy);
                k = k+C(2,k)+1; % Take our counter to the next target
                clear xx yy
                if k > size(C,2)
                    break
                end
            end
        end

    elseif exist("h","var")

        n = 0;
        i = 1;
        % ContourMatrix — 等高线定义
        % 共2行 %%%%%%%%%%% [ h.ContourMatrix == C ] %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 第1行 等值线1_value     X1 X2 ... Xn   等值线2_value     X1 X2 ... Xm  ……
        % 第2行 等值线1_点的数量n  Y1 Y2 ... Yn  等值线2_点的数量m  Y1 Y2 ... Ym  ……
        sz = size(h.ContourMatrix,2);
        nn(1) = h.ContourMatrix(2,1); %等值线1_点的数量n
        xx = h.ContourMatrix(1,2:nn(1)+1);%等值线1坐标X ：X1~Xn
        yy = h.ContourMatrix(2,2:nn(1)+1);%等值线1坐标Y ：Y1~Yn
        Carea(1) = polyarea(xx,yy);% 计算面积
        while n+nn(i)+i < sz
            n = n + nn(i);
            i = i + 1;
            nn(i)=h.ContourMatrix(2,n+i);
            xx = h.ContourMatrix(1,n+i+1:n+nn(i)+i);
            yy = h.ContourMatrix(2,n+i+1:n+nn(i)+i);
            Carea(i) = polyarea(xx,yy);
        end
        if length(varargin) >= 1 
            num = varargin{1};
            varargin(1) = [];
            areaC = zeros(num,1);

            areaC(1:length(Carea)) = Carea;
            areaC(num+1:end) = [];
        end

    end
    
    return

end


