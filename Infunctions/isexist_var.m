function vout = isexist_var(vin, conf)
    % =================================================================================================================
    % discription:
    %       Check whether assigned variable, if not, assign default value
    % =================================================================================================================
    % parameter:
    %       vin: variable to be checked                        || required: True  || type: cell  || format: {"Lon_Name","Lon_Name"}
    %       conf: default value                                || required: True  || type: cell  || format: {"lon","lat"}
    %       vout: variable after checking                      || required: True  || type: cell  || format: {"lon","lat"}
    % =================================================================================================================
    % example:
    %       vout = isexist_var({"Lon_Name","Lat_Name"}, {"lon","lat"})
    % =================================================================================================================

    
    vin = convertStringsToChars(vin);
   
    % if iscell(vin) 
    %     vin = vin{1};
    % end
    
    if islogical(vin)
        if  ~vin
            vout = conf;
        else
            vout = vin;
        end
    else
        vout = vin;
    end
end