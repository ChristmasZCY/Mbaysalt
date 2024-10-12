function initial(opt)
    %       To set the default parameters of the figure
    % =================================================================================================================
    % Parameters:
    %       opt:        set or recover               || required: positional || type: Text   || format: 'set' or 'recover'
    %       varargin: (optional)
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Updates:
    %       ****-**-**:     Created,                                                by Siqi Li;
    %       2024-09-25:     Added recover, set,                                     by Christmas;
    % =================================================================================================================
    % Examples:
    %       initial();
    %       initial('recover');
    %       initial('set');
    % =================================================================================================================

    arguments(Input)
        opt (1, 1) string {mustBeMember(opt, ["set", "recover"])} = "set"
    end

    narginchk(0, 1);
    if nargin == 0
        opt = 'set';
    end

    % warning off;
    format long g;
    figure(10)
    close(10)

    path = fileparts(mfilename("fullpath"));
    filepath_save = fullfile(path, 'initial.mat');
    if ~isfile(filepath_save)
        DEFAULT = get_DEFAULT();
        save(filepath_save, 'DEFAULT');
    else
        DEFAULT = load(filepath_save, 'DEFAULT');
    end
    
    switch lower(opt)
    case 'recover'
        fileds_default = fieldnames(DEFAULT);
        for i = 1:length(fileds_default)
            set(0, fileds_default{i}, DEFAULT.(fileds_default{i}));
        end
    case 'set'
        SET = make_SET();
        fields_os = fieldnames(SET.OS);
        for i = 1:length(fields_os)
            set(0, fields_os{i}, SET.OS.(fields_os{i}));
        end
        if contains(computer, 'MAC')
            fields_mac = fieldnames(SET.MAC);
            for i = 1:length(fields_mac)
                set(0, fields_mac{i}, SET.MAC.(fields_mac{i}));
            end
        elseif contains(computer, 'WIN')
            fields_win = fieldnames(SET.WIN);
            for i = 1:length(fields_win)
                set(0, fields_win{i}, SET.WIN.(fields_win{i}));
            end
        elseif contains(computer, 'LNX')
            fields_lnx = fieldnames(SET.LNX);
            for i = 1:length(fields_lnx)
                set(0, fields_lnx{i}, SET.LNX.(fields_lnx{i}));
            end
        else
            disp('Not recognized OS')
        end
    otherwise
        error('Not recognized opt')
    end
end


function DFP = make_WIN_DefaultFigurePosition(bl_x, bl_y, scale)
    DFP = [bl_x bl_y bl_x+scale*850 bl_y+scale*1100];
end


function DEFAULT = get_DEFAULT()
%    DEFAULT.DefaultAxesXGrid = get(0, 'DefaultAxesXGrid');  % Axes grid
%    DEFAULT.DefaultAxesYGrid = get(0, 'DefaultAxesYGrid');  % Axes grid
    DEFAULT.DefaultAxesBox = get(0, 'DefaultAxesBox');  % Box on
    DEFAULT.DefaultTextFontName = get(0, 'DefaultTextFontName');  % Text font
    DEFAULT.DefaultAxesFontName = get(0, 'DefaultAxesFontName');  % Axis font
    DEFAULT.DefaultLegendFontName = get(0, 'DefaultLegendFontName');  % Legend font
    DEFAULT.defaultAxesTickDir = get(0, 'defaultAxesTickDir');  % Set the Axes tick direction out
    DEFAULT.defaultAxesTickDirMode = get(0, 'defaultAxesTickDirMode');  % Set the Axes tick direction out
    DEFAULT.defaultAxesXMinorTick = get(0, 'defaultAxesXMinorTick');  % Set the Axes tick direction out
    DEFAULT.defaultAxesYMinorTick = get(0, 'defaultAxesYMinorTick');  % Set the Axes tick direction out

    DEFAULT.DefaultTextFontSize = get(0, 'DefaultTextFontSize');  % Text font size
    DEFAULT.DefaultAxesFontSize = get(0, 'DefaultAxesFontSize');  % Axes font size
    DEFAULT.DefaultLegendFontSize = get(0, 'DefaultLegendFontSize');  % Legend font size
    DEFAULT.DefaultLineLineWidth = get(0, 'DefaultLineLineWidth');  % Line width
    DEFAULT.DefaultContourLineWidth = get(0, 'DefaultContourLineWidth');  % Line width
    DEFAULT.DefaultFigurePosition = get(0, 'DefaultFigurePosition');  % Figure location
    DEFAULT.DefaultFigureColormap = get(0, 'DefaultFigureColormap');  % Colormap
end

function SET = make_SET()
%    SET.OS.DefaultAxesXGrid = 'on';
%    SET.OS.DefaultAxesYGrid = 'on';
    SET.OS.DefaultAxesBox = 'on';
    SET.OS.DefaultTextFontName = 'Times new Roman';
    SET.OS.DefaultAxesFontName = 'Times new Roman';
    SET.OS.DefaultLegendFontName = 'Times new Roman';
    SET.OS.defaultAxesTickDir = 'out';
    SET.OS.defaultAxesTickDirMode = 'manual';
    SET.OS.defaultAxesXMinorTick = 'on';
    SET.OS.defaultAxesYMinorTick = 'on';
    % MAC
    SET.MAC.DefaultTextFontSize = 20;
    SET.MAC.DefaultAxesFontSize = 20;
    SET.MAC.DefaultLegendFontSize = 20;
    SET.MAC.DefaultLineLineWidth = 2.3;
    SET.MAC.DefaultContourLineWidth = 2.3;
    SET.MAC.DefaultFigurePosition = [228 355 1012 622];
    % WIN
    SET.WIN.DefaultTextFontSize = 13;
    SET.WIN.DefaultAxesFontSize = 13;
    SET.WIN.DefaultLegendFontSize = 13;
    SET.WIN.DefaultLineLineWidth = 1.3;
    SET.WIN.DefaultContourLineWidth = 1.3;
    SET.WIN.DefaultFigurePosition = make_WIN_DefaultFigurePosition(2, 50, 0.62);
    SET.WIN.DefaultFigureColormap = 'turbo';
    % LNX
    SET.LNX.DefaultTextFontSize = 16;
    SET.LNX.DefaultAxesFontSize = 16;
    SET.LNX.DefaultLegendFontSize = 16;
    SET.LNX.DefaultLineLineWidth = 1.3;
    SET.LNX.DefaultContourLineWidth = 1.3;
    SET.LNX.DefaultFigurePosition = [1 39 1+0.9*850 39+0.9*1100];
    SET.LNX.DefaultFigureColormap = make_LNX_turbo0();
end

function turbo0 = make_LNX_turbo0()
    turbo0 = [0.1900    0.0718    0.2322
              0.1948    0.0834    0.2615
              0.1996    0.0950    0.2902
              0.2041    0.1065    0.3184
              0.2086    0.1180    0.3461
              0.2129    0.1295    0.3731
              0.2171    0.1409    0.3996
              0.2211    0.1522    0.4256
              0.2250    0.1635    0.4510
              0.2288    0.1748    0.4758
              0.2324    0.1860    0.5000
              0.2358    0.1972    0.5237
              0.2392    0.2083    0.5469
              0.2423    0.2194    0.5694
              0.2454    0.2304    0.5914
              0.2483    0.2414    0.6129
              0.2511    0.2524    0.6337
              0.2537    0.2633    0.6541
              0.2562    0.2741    0.6738
              0.2585    0.2849    0.6930
              0.2607    0.2957    0.7116
              0.2628    0.3064    0.7297
              0.2647    0.3171    0.7472
              0.2665    0.3277    0.7641
              0.2682    0.3382    0.7805
              0.2697    0.3488    0.7963
              0.2710    0.3593    0.8116
              0.2723    0.3697    0.8262
              0.2733    0.3801    0.8404
              0.2743    0.3904    0.8539
              0.2751    0.4007    0.8669
              0.2758    0.4110    0.8794
              0.2763    0.4212    0.8912
              0.2767    0.4313    0.9025
              0.2769    0.4415    0.9133
              0.2770    0.4515    0.9235
              0.2770    0.4615    0.9331
              0.2768    0.4715    0.9421
              0.2765    0.4814    0.9506
              0.2760    0.4913    0.9586
              0.2754    0.5011    0.9659
              0.2747    0.5109    0.9728
              0.2738    0.5207    0.9790
              0.2727    0.5304    0.9846
              0.2711    0.5402    0.9893
              0.2688    0.5500    0.9930
              0.2659    0.5598    0.9958
              0.2625    0.5697    0.9977
              0.2586    0.5796    0.9988
              0.2542    0.5895    0.9990
              0.2495    0.5994    0.9983
              0.2443    0.6094    0.9970
              0.2387    0.6193    0.9949
              0.2329    0.6292    0.9920
              0.2268    0.6391    0.9885
              0.2204    0.6490    0.9844
              0.2138    0.6589    0.9796
              0.2071    0.6687    0.9742
              0.2002    0.6784    0.9683
              0.1933    0.6881    0.9619
              0.1862    0.6977    0.9550
              0.1792    0.7073    0.9476
              0.1722    0.7168    0.9398
              0.1653    0.7262    0.9316
              0.1584    0.7355    0.9231
              0.1517    0.7447    0.9142
              0.1452    0.7538    0.9050
              0.1389    0.7628    0.8955
              0.1328    0.7716    0.8858
              0.1270    0.7804    0.8759
              0.1215    0.7890    0.8658
              0.1164    0.7974    0.8556
              0.1117    0.8057    0.8452
              0.1074    0.8138    0.8348
              0.1036    0.8218    0.8244
              0.1003    0.8296    0.8139
              0.0975    0.8371    0.8034
              0.0953    0.8446    0.7930
              0.0938    0.8518    0.7826
              0.0929    0.8588    0.7724
              0.0927    0.8655    0.7623
              0.0932    0.8721    0.7524
              0.0945    0.8784    0.7427
              0.0966    0.8845    0.7332
              0.0996    0.8904    0.7239
              0.1034    0.8960    0.7150
              0.1081    0.9014    0.7060
              0.1137    0.9067    0.6965
              0.1201    0.9119    0.6866
              0.1273    0.9170    0.6763
              0.1353    0.9220    0.6656
              0.1439    0.9268    0.6545
              0.1532    0.9315    0.6431
              0.1632    0.9361    0.6314
              0.1738    0.9405    0.6194
              0.1849    0.9448    0.6071
              0.1966    0.9490    0.5947
              0.2088    0.9530    0.5820
              0.2214    0.9569    0.5691
              0.2345    0.9607    0.5561
              0.2480    0.9642    0.5430
              0.2618    0.9677    0.5298
              0.2760    0.9709    0.5165
              0.2904    0.9740    0.5032
              0.3051    0.9770    0.4899
              0.3201    0.9797    0.4765
              0.3352    0.9823    0.4632
              0.3504    0.9848    0.4500
              0.3658    0.9870    0.4369
              0.3813    0.9891    0.4239
              0.3968    0.9910    0.4110
              0.4123    0.9927    0.3983
              0.4278    0.9942    0.3857
              0.4432    0.9955    0.3735
              0.4585    0.9966    0.3614
              0.4738    0.9976    0.3496
              0.4888    0.9983    0.3382
              0.5036    0.9988    0.3270
              0.5182    0.9991    0.3162
              0.5325    0.9992    0.3058
              0.5466    0.9991    0.2958
              0.5603    0.9987    0.2862
              0.5736    0.9982    0.2771
              0.5865    0.9974    0.2685
              0.5989    0.9964    0.2604
              0.6109    0.9951    0.2528
              0.6223    0.9937    0.2458
              0.6332    0.9919    0.2394
              0.6436    0.9900    0.2336
              0.6539    0.9878    0.2283
              0.6643    0.9852    0.2237
              0.6746    0.9825    0.2196
              0.6849    0.9794    0.2160
              0.6953    0.9761    0.2129
              0.7055    0.9726    0.2103
              0.7158    0.9688    0.2082
              0.7260    0.9647    0.2064
              0.7361    0.9604    0.2050
              0.7462    0.9559    0.2041
              0.7562    0.9512    0.2034
              0.7661    0.9463    0.2031
              0.7759    0.9411    0.2031
              0.7856    0.9358    0.2034
              0.7952    0.9303    0.2039
              0.8047    0.9245    0.2046
              0.8141    0.9186    0.2055
              0.8233    0.9125    0.2066
              0.8324    0.9063    0.2079
              0.8413    0.8999    0.2093
              0.8501    0.8933    0.2107
              0.8587    0.8865    0.2123
              0.8671    0.8797    0.2139
              0.8753    0.8727    0.2155
              0.8833    0.8655    0.2172
              0.8911    0.8583    0.2188
              0.8987    0.8509    0.2204
              0.9061    0.8434    0.2219
              0.9132    0.8358    0.2233
              0.9200    0.8281    0.2246
              0.9267    0.8203    0.2257
              0.9330    0.8124    0.2267
              0.9391    0.8044    0.2274
              0.9449    0.7963    0.2280
              0.9504    0.7882    0.2283
              0.9556    0.7801    0.2284
              0.9605    0.7718    0.2281
              0.9651    0.7635    0.2275
              0.9693    0.7552    0.2266
              0.9732    0.7468    0.2254
              0.9768    0.7384    0.2237
              0.9800    0.7300    0.2216
              0.9829    0.7214    0.2192
              0.9855    0.7125    0.2165
              0.9878    0.7033    0.2136
              0.9899    0.6938    0.2104
              0.9916    0.6841    0.2071
              0.9931    0.6741    0.2035
              0.9944    0.6639    0.1997
              0.9953    0.6534    0.1958
              0.9961    0.6428    0.1916
              0.9965    0.6319    0.1874
              0.9968    0.6209    0.1830
              0.9967    0.6098    0.1784
              0.9964    0.5985    0.1738
              0.9959    0.5870    0.1690
              0.9952    0.5755    0.1641
              0.9942    0.5639    0.1592
              0.9930    0.5521    0.1542
              0.9915    0.5404    0.1491
              0.9899    0.5285    0.1440
              0.9880    0.5167    0.1388
              0.9859    0.5048    0.1337
              0.9836    0.4929    0.1285
              0.9811    0.4810    0.1233
              0.9784    0.4692    0.1182
              0.9755    0.4574    0.1130
              0.9723    0.4456    0.1080
              0.9690    0.4340    0.1029
              0.9656    0.4224    0.0980
              0.9619    0.4109    0.0931
              0.9580    0.3996    0.0883
              0.9540    0.3884    0.0836
              0.9498    0.3773    0.0790
              0.9454    0.3664    0.0746
              0.9408    0.3557    0.0703
              0.9361    0.3451    0.0662
              0.9313    0.3348    0.0622
              0.9262    0.3247    0.0584
              0.9211    0.3149    0.0548
              0.9157    0.3053    0.0513
              0.9102    0.2960    0.0481
              0.9046    0.2870    0.0452
              0.8989    0.2782    0.0424
              0.8930    0.2698    0.0399
              0.8869    0.2615    0.0375
              0.8807    0.2533    0.0352
              0.8742    0.2453    0.0330
              0.8676    0.2373    0.0308
              0.8608    0.2294    0.0288
              0.8538    0.2217    0.0268
              0.8466    0.2141    0.0249
              0.8393    0.2065    0.0231
              0.8317    0.1991    0.0213
              0.8240    0.1918    0.0197
              0.8161    0.1846    0.0181
              0.8080    0.1775    0.0166
              0.7997    0.1706    0.0152
              0.7913    0.1637    0.0139
              0.7826    0.1569    0.0126
              0.7738    0.1503    0.0115
              0.7648    0.1437    0.0104
              0.7556    0.1373    0.0094
              0.7462    0.1310    0.0085
              0.7366    0.1248    0.0077
              0.7269    0.1187    0.0069
              0.7169    0.1127    0.0063
              0.7068    0.1068    0.0057
              0.6965    0.1010    0.0052
              0.6860    0.0954    0.0048
              0.6754    0.0898    0.0045
              0.6645    0.0844    0.0042
              0.6534    0.0790    0.0041
              0.6422    0.0738    0.0040
              0.6308    0.0687    0.0040
              0.6192    0.0637    0.0041
              0.6075    0.0588    0.0043
              0.5955    0.0540    0.0045
              0.5834    0.0493    0.0049
              0.5710    0.0447    0.0053
              0.5585    0.0403    0.0058
              0.5458    0.0359    0.0064
              0.5330    0.0317    0.0070
              0.5199    0.0276    0.0078
              0.5066    0.0235    0.0086
              0.4932    0.0196    0.0095
              0.4796    0.0158    0.0106];
end