function S = calc_validation(model, observation, varargin)
    %       To calculate data validation 
    % =================================================================================================================
    % Parameter:
    %      model:          model data          || required: True || type: double    || example:  [1 2 3 4 5 6 7 8 9 10]
    %      observation:    observation data    || required: True || type: double    || example:  [1 2 3 4 5 6 7 8 9 10]
    %       varargin:           optional parameters
    %           
    % =================================================================================================================
    % Returns:
    %       S:          struct data            || type: struct
    %           S.R:        Correlation coefficient
    %           S.Bias:     Bias
    %           S.SSE:      Sum of squared errors
    %           S.MSE:      Mean square error       反映模拟与实测的偏差
    %           S.RMSE:     Root mean square error  计算模拟和实测的偏差值，衡量模拟与实测的离散程度
    %           S.ACCU:     Accuracy
    %           S.MAE:      Mean absolute error     计算模拟与实测的绝对偏差，衡量模拟结果的精准度
    %           S.MAPE:     Mean absolute percentage error
    %           S.SI:       Scatter index
    %           S.MRE:      Mean Relative Error     计算绝对误差与模拟值之比，反映模拟误差与模拟值占比
    % =================================================================================================================
    % Update:
    %       2024-04-13:     Created,                        by Christmas;
    %       2024-09-19:     Fixed corrcoef with 'complete', by Christmas;    
    % =================================================================================================================
    % Example:
    %       S = calc_validation(model, observation);
    % =================================================================================================================
    % Reference:
    %       https://blog.csdn.net/u012735708/article/details/84337262 --> MSE RMSE MAE R2 Adjusted R-Square
    %       https://blog.csdn.net/Gou_Hailong/article/details/107818311 --> SSE MSE RMSE SSR SST R-square CORR 'Adjust R-square' STD
    %       https://blog.csdn.net/guolindonggld/article/details/87856780 --> MSE RMSEMAE MAPE SMAPE
    %       https://blog.51cto.com/weiyuqingcheng/3913324 --> RMSE MAE BIAS CORR ACCURATE
    %       https://blog.csdn.net/u011594486/article/details/43666871 --> RMS | RMSE
    %       https://datascience.stackexchange.com/questions/106178/how-could-we-interpret-a-si-scatter-index-and-rmse --> SI
    %       https://doi.org/10.1109/IGARSS.2018.8517731 --> SI
    %       https://doi.org/10.1016/j.horiz.2024.100098 --> RMSE MABE PRMSE MAPE
    % =================================================================================================================

    arguments (Input)
        model (1,:) {mustBeFloat}
        observation (1,:) {mustBeFloat}
    end
    arguments (Input, Repeating)
        varargin 
    end

    if numel(observation) ~= numel(model)
        error("Observation and model don't match !!!")
    end

    len = length(model);
    dif = model - observation;

    % R 相关系数
    R = corrcoef(observation, model, 'Rows', 'complete');  % complete 忽略NaN
    S.R = R(1,2);

    % Bias  偏差
    S.Bias = sum(dif)/len;

    % SSE   和方差/残差平方和 --> [0,+∞), 值越大误差越大
    S.SSE = sum((dif).^2);

    % MSE   均方误差 --> [0,+∞), 值越大误差越大
    S.MSE = S.SSE/len;

    % RMSE  均方根误差 --> [0,+∞), 值越大误差越大   % 波高大概在0.3-0.5
    S.RMSE = sqrt(S.MSE);

    % ACCE  准确率
    S.ACCE = 1 - S.RMSE;

    % MAE   平均绝对误差 --> [0,+∞), 值越大误差越大
    S.MAE = sum(abs(dif))/len;

    % MAPE  平均绝对百分比误差  --> [0,+∞), 值越大误差越大  !! 当真实值=0时，该公式不可用！自动去掉0项
    F = find(observation==0);
    obs_1 = observation;
    dif_1 = dif;
    obs_1(F) = [];
    dif_1(F) = [];
    S.MAPE = sum(abs((dif_1)./obs_1))/len;

    % SI   散度指数 --> [0,+∞), 值越大误差越大
    S.SI = std(dif,"omitnan") /mean(observation);
    
    % MRE 平均相对误差   相对误差（相对误差是指误差相对于真实值的比例）绝对值的平均值 
    % MRE可以反映相对误差的大小，但是不能反映绝对误差的大小。
    S.MRE = sum(abs(dif)/observation)/len;

    return
end

