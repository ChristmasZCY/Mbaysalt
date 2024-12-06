function map2gray(pin, pout, varargin)

    varargin = read_varargin(varargin, {'oceanWebFile'}, {'https://windytiles.mapy.cz/turist-en/12-3314-1799.png'});
    varargin = read_varargin(varargin, {'oceanPngFile'}, {'./ocean.png'});
    varargin = read_varargin(varargin, {'oceanMatFile'}, {'./ocean.mat'});  %#ok<*NASGU>
 
    if exist(oceanMatFile, "file")
        load(oceanMatFile, "RGB_ocean")
    else
        if ~exist(oceanPngFile, "file")
            websave(oceanPngFile, oceanWebFile);
        end
        [X_ocean, map_ocean] = imread(oceanPngFile);
        RGB_ocean = ind2rgb(X_ocean, map_ocean);
        save(oceanMatFile, "RGB_ocean");
    end
    
    [X_get, map_get] = imread(pin);
    RGB_get = ind2rgb(X_get,map_get);
    clearvars X_ocean map_ocean X_get map_get
    
    % alpha = createArray([size(RGB_get(:,:,1))],"FillValue",255);
    alpha = ones([size(RGB_get(:,:,1))]) * 255;
    
    sameIndex3 = RGB_get == RGB_ocean;
    sameIndex = sum(sameIndex3,3);
    alpha(sameIndex==3) = 0;
    imwrite(RGB_get, pout, 'Alpha', alpha);

end
