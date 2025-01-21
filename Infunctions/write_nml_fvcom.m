function NML = write_nml_fvcom(NML, fout, varargin)
    %   Write NML file for FVCOM
    % =================================================================================================================
    % Parameters:
    %       NML:        NML Struct  || required: True || type: struct || example: read_nml_fvcom('*.nml')
    %       fout:       File NML    || required: True || type: Text   || example: '*.nml'
    %       varargin:   optional parameters     
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Updates:
    %       2025-01-13:     Created,    by Christmas; 
    % =================================================================================================================
    % Examples:
    %       
    %       fnml = '/Users/christmas/Documents/Code/Project/Server_Program/CalculateModel/FVCOM_WZtide3/Control/forecast_run.nml_exp';
    %       NML = read_nml_fvcom(fnml);
    %       write_nml_fvcom(NML, 'test_run.nml');
    % =================================================================================================================

    TOOLS = FVCOMTOOLS();
    if ~isfield(NML,'FVCOMTITLE')
        addStructFirst(NML, 'FVCOMTITLE',TOOLS.genFVCOMchar());
    end
    NML = TOOLS.delete_key(NML, 'EMPTYONE');
    
    fid = fopen(fout,"w");

    fields1 = fieldnames(NML);
    for ia = fields1'
        name1 = ia{1};
        if strcmp(name1, 'FVCOMTITLE')
            fprintf(fid,'%s\n',NML.(name1));
        elseif isa(NML.(name1),'struct')
            str = TOOLS.convertStruct2char(NML.(name1), name1);
            fprintf(fid,'%s\n',str);
        end
    end

end


function Struct = addStructFirst(struct,name,value)
    Struct.(name) = value;
    fields = fieldnames(struct);
    for i = 1:length(fields)
        Struct.(fields{i}) = struct.(fields{i});
    end
end
