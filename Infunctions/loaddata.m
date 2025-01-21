function loaddata(varargin)

    Coordinate = 'auto';
    NAME.GridStruct = 'G';
    NAME.VarStruct = 'V';
    NAME.Ttimes = 'T';
    DRAW.plot = false;
    Global = 'NOGlobal';

    % if ~strcmp(get(0,'DefaultTextFontName'),'Times new Roman')
    %     initial();
    % end

    if isempty(varargin)
        [filename,path] = uigetfile("*.nc",'Select netCDF file');
        if isa(filename,"double") && isa(path,"double")
            return
        end
        fin = fullfile(path,filename); clear filename;
    else
        fin = varargin{1};
    end
    
    [GridStruct, VarStruct, Ttimes] = c_load_model(fin, 'Coordinate', Coordinate, Global);

    assignin("base", NAME.GridStruct, GridStruct);
    assignin("base", NAME.VarStruct, VarStruct);
    assignin("base", NAME.Ttimes, Ttimes);

    if DRAW.plot
        c = Mgrid(GridStruct,VarStruct);
        clf
        hold on
        c.draw.range
        c.draw.mesh
        % axis tight
        c.draw.coast('Resolution','c','Coordinate',Coordinate)
        % c.draw.image(VarStruct.uv_spd(:,1))

     end

end


