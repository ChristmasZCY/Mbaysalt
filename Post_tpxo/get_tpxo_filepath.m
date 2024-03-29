function [gfile_old, gfile_new, ...
          uvfile_old, uvfile_new, ...
          hfile_old, hfile_new] = get_tpxo_filepath(file_json)
    %       Get tpxo file path from json file
    % =================================================================================================================
    % Parameter:
    %       file_json: json file path              || required: True || type: char or string  ||  format: 'tpxo_file.json'
    % =================================================================================================================
    % Example:
    %       [gfile_old, gfile_new, uvfile_old, uvfile_new, hfile_old, hfile_new] = get_tpxo_filepath('tpxo_file.json')
    % =================================================================================================================

    jdata = json_load(file_json,'Method_load','MATLAB');
    tpxo_old_path = string(del_filesep(jdata.tpxo_path));
    tpxo_new_path = del_filesep(jdata.tpxo_fixed_coordinate_path);
    makedirs(tpxo_new_path)

    gfile_old = path_plus_fileCell(tpxo_old_path, jdata.tpxo_grid_uvh_coordinate);
    gfile_new = path_plus_fileCell(tpxo_new_path, jdata.tpxo_grid_fixed_coordinate);
    uvfile_old = cellstr(path_plus_fileCell(tpxo_old_path, jdata.tpxo_tide_uv_coordinate));
    uvfile_new = cellstr(path_plus_fileCell(tpxo_new_path, jdata.tpxo_tide_uv_fixed_coordinate));
    hfile_old = cellstr(path_plus_fileCell(tpxo_old_path, jdata.tpxo_tide_h_coordinate));
    hfile_new = cellstr(path_plus_fileCell(tpxo_new_path, jdata.tpxo_tide_h_fixed_coordinate));

end


function filepath = path_plus_fileCell(path, fileCell)
    path = string(del_filesep(path));
    file = string(fileCell);
    division = string(filesep);
    filepath = path + division + string(file);
end
