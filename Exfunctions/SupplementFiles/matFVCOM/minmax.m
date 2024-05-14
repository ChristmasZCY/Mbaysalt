function out = minmax(var)
% Updates:
%       2024-05-13:  Added for NaT, by Christmas;

varmin = min(var(:));
varmax = max(var(:));


% n = size(var);
%
% nd = length(n);
%
% varmin = var;
% varmax = var;
% for i = 1 : nd
%
%     varmin = min(varmin);
%     varmax = max(varmax);
%
% end

if ismember(class(var), ["datetime","Mdatetime"])  % isa(var,"datetime")
    k = sum(isnat(var(:)));
else
    k = sum(isnan(var(:)));
end
if k>0
    if isa(var,"datetime")
        disp(['There are ' num2str(k) ' nat.'])
    else
        disp(['There are ' num2str(k) ' nan.'])
    end
end

out = [varmin varmax];
