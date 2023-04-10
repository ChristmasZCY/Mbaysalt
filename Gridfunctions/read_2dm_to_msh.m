function read_2dm_to_msh(varargin)
    % =================================================================================================================
    % discription:
    %       read 2dm file to msh file for Wave Watch III
    % =================================================================================================================
    % parameter:
    %       varargin{1}: replace point depth from land to sea  || required: True || type: int || format: -0.5
    %       varargin{2}: file                                  || required: False || type: string || format: 'file'
    %       varargin{3}: file of file                          || required: False || type: string || format: 'ECS6.2dm'
    %       varargin{4}: save_path                             || required: False || type: string || format: 'save_path'
    %       varargin{5}: save_path of save_path                || required: False || type: string || format: '/home/ocean/'
    %       varargin{6}: read_method                           || required: False || type: string || format: 'read_method'
    %       varargin{7}: read_method of read_method            || required: False || type: string || format: 'Christmas'
    % =================================================================================================================
    % example:
    %       read_2dm_to_msh(-0.5)
    %       read_2dm_to_msh(-0.5,'file','ECS6.2dm')
    %       read_2dm_to_msh(-0.5,'file','ECS6.2dm','save_path','/home/ocean/')
    %       read_2dm_to_msh(-0.5,'file','ECS6.2dm','read_method','read_method')
    % =================================================================================================================

    %% read conf file
    file = read_conf('Grid_functions.conf','f2dmfile');
    save_path = read_conf('Grid_functions.conf','save_path');
    read_method = read_conf('Grid_functions.conf','Read_Method');

    varargin = read_varargin(varargin,{'file'},{file});
    varargin = read_varargin(varargin,{'save_path'},{save_path});
    varargin = read_varargin(varargin,{'read_method'},{read_method});

    save_path = split_path(save_path);

    %% read 2dm file
    [~,name,suffix]=fileparts(file);
    osprint([name,suffix])
    switch read_method
        case 'Christmas'
            % ---> Christmas
            [sms,~,headerlines] = importdata(file);
            % boundary
            bound = read_conf('Grid_functions.conf','boundary')';
            % tri
            [x,~] = find(strcmp(sms.textdata,'ND'),1);
            tri = sms.data(1:x-headerlines-1,1:4);
            tri=[tri(:,1) ones(1,size(tri,1))'*3 tri(:,2:end)];
            % point
            [y,~] = find(strcmp(sms.textdata,'NS'),1);
            point = sms.data(x-headerlines:y-headerlines-1,1:4);
            clear x y sms headerlines file boundary suffix
            dl_dep = point(:,4);
            % <--- Christmas
        case 'Siqi'
            % ---> Siqi Li
            [lon,lat,nv,dl_dep,boundary,~,id] = read_2dm(file);
            % boundary
            bound = boundary{1}';
            clear boundary
            % tri
            tri = [(1:size(nv,1))' ones(1,size(nv,1))'*3 nv];
            % point
            point = [double(id) lon lat dl_dep];
            % <--- Siqi Li
        otherwise
            error('ERROR method')
    end

    % change th point whose depth is positive to negative
    cprintf('Blue', ['point depth < set min depth counts ',num2str(length(find(dl_dep>varargin{1}))),'\n'])
    cprintf('Blue', ['point max depth ',num2str(max(dl_dep,[],'all')),'m\n'])

    if nargin == 1
        cprintf('text',['replace point depth > ',num2str(varargin{1},'%3.2f'), ' m to ',num2str(varargin{1},'%3.2f'),'m','\n'])
        dl_dep(dl_dep>varargin{1}) = varargin{1};
    end
    % Wave Watch III need to read positive depth
    point(:,4) = -dl_dep;
    clearvars dl_dep

    %% write msh file
    Outputfile = [save_path,filesep,name,'.msh'];
    fid=fopen(Outputfile,'wt');
    fprintf(fid,'$MeshFormat\n');
    fprintf(fid,'2 0 8\n');
    fprintf(fid,'$EndMeshFormat\n');
    fprintf(fid,'$Nodes\n');
    fprintf(fid,'%12.0f',size(point,1));
    fprintf(fid,'\n');
    for i=1:size(point,1)
        fprintf(fid,'%7.0f',i);
        fprintf(fid,'%20.8f',point(i,2));
        fprintf(fid,'%20.8f',point(i,3));
        fprintf(fid,'%20.3f',point(i,4));
        fprintf(fid,'\n');
    end
    fprintf(fid,'$EndNodes\n');
    fprintf(fid,'$Elements\n');
    fprintf(fid,'%12.0f',size(bound,1)+size(tri,1));
    fprintf(fid,'\n');
    for i=1:size(bound,1)
        fprintf(fid,'%10i%10i%10i%10i%10i%10i',[i,15,2,0,0,bound(i)]);
        fprintf(fid,'\n');
    end
    for i=1:size(tri,1)
        fprintf(fid,'%10i%10i%10i%10i%10i%10i%10i%10i%10i',[size(bound,1)+i,2,3,0,i,5,tri(i,3:5)]);
        fprintf(fid,'\n');
    end
    fprintf(fid,'$EndElements');
    fclose(fid);

end