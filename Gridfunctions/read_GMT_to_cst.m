function GMT2cst(fin, fout, varargin)
    % =================================================================================================================
    % discription:
    %       Transform GMT/ACSII Coastline data imported by GEODAS to SMS's cst format
    %       将GEODAS导入的GMT/ACSII岸线数据转换为SMS的cst格式
    % =================================================================================================================
    % parameter:
    %       fin:            input file              || required: True || type: string || format: 'D:\data\coastline.dat'
    %       fout:           output file             || required: True || type: string || format: 'D:\data\coastline.cst'
    % =================================================================================================================
    % example:
    %       GMT2cst('D:\data\coastline.dat','D:\data\coastline.cst')
    % =================================================================================================================
    % History:
    %       2023-10-17:     Created, by Zetao WU;
    %       2023-10-18:     Modified to a function, by Christmas;
    % =================================================================================================================


data = readmatrix(strcat(fin));
[row,~] = find(isnan(data(:,1)));
temp = [];
dd = row(1)-1;
temp = [temp;dd];
for i = 2:length(row)
    dd = row(i)-row(i-1)-1;
    temp = [temp;dd];
end
dd = length(data)-row(length(row));
temp = [temp;dd];
data(row,:) = [];%删除nan
fidID=fopen(strcat(fout),'w');%建立文件
%写入头文件
fprintf(fidID,'%s\n','COAST');
fprintf(fidID,'%i\n',length(temp));
%写入第一个岸线
fprintf(fidID,'%i     %i\n',temp(1),0);
for j = 1:temp(1)
    fprintf(fidID,'%i     %i\n',data(j,:));
end
% 循环写入中间岸线
for i=2:length(temp)
    fprintf(fidID,'%i     %i\n',temp(i),0);% 保存
    for j = 1:temp(i)
        ad = sum(temp(1:i-1));
        fprintf(fidID,'%i     %i\n',data(ad+j,:));
    end
end
fclose(fidID);

end

