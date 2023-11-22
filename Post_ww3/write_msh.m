function write_msh(fout, x, y, nv, h, ns)
    %       Write the msh file
    % =================================================================================================================
    % Parameter:
    %       fout: the name of the msh file                       || required: True  || type: string ||  format: string
    %       x: x coordinate of the grid point                    || required: True  || type: double ||  format: matrix
    %       y: y coordinate of the grid point                    || required: True  || type: double ||  format: matrix
    %       nv: triangle connectivity of the grid point          || required: True  || type: double ||  format: matrix
    %       h: depth of the grid point                           || required: False || type: double ||  format: matrix
    %       ns: open boundary of the grid point                  || required: False || type: double ||  format: matrix
    % =================================================================================================================
    % Example:
    %       write_msh('test.msh', x, y, nv, h, ns)
    %       write_msh('test.msh', x, y, nv, h)
    %       write_msh('test.msh', x, y, nv)
    % =================================================================================================================

    node=length(x);
    nele=size(nv,1);
    
    if exist('h', 'var')
        if isnan(h)
            h = zeros(node,1);
        end
    else
        h = zeros(node,1);
    end
    
    if ~exist('ns', 'var')
        ns = [];
    end
    
    lon = x;
    lat = y;
    dep = h;
    
    fid=fopen(fout,'w');
    fprintf(fid,'$MeshFormat\n');
    fprintf(fid,'2 0 8\n');
    fprintf(fid,'$EndMeshFormat\n');
    fprintf(fid,'$Nodes\n');
    fprintf(fid,'%12.0f',node);
    fprintf(fid,'\n');
    
    for i = 1 : node
        fprintf(fid,'%7.0f',i);
        fprintf(fid,'%20.8f',lon(i));
        fprintf(fid,'%20.8f',lat(i));
        fprintf(fid,'%20.3f',dep(i));
        fprintf(fid,'\n');
    end
    fprintf(fid,'$EndNodes\n');
    fprintf(fid,'$Elements\n');
    fprintf(fid,'%12.0f',size(ns,1)+nele);
    fprintf(fid,'\n');
    for i=1:size(ns,1)
        fprintf(fid,'%10i%10i%10i%10i%10i%10i',[i,15,2,0,0,ns(i)]);
        fprintf(fid,'\n');
    end
    for i=1:nele
        fprintf(fid,'%10i%10i%10i%10i%10i%10i%10i%10i%10i',[length(ns)+i,2,3,0,i,5,nv(i,:)]);
        fprintf(fid,'\n');
    end
    fprintf(fid,'$EndElements');
    fclose(fid);

end
