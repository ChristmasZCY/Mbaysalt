clm
S = readstruct('stations.xml');
NetworkLink = S.Folder.NetworkLink;
for i = 1 : length(NetworkLink)
    disp(NetworkLink(i).Link.href)
    websave([convertStringsToChars(NetworkLink(i).name),'.xml'],NetworkLink(i).Link.href);
end

Kstruct = kmz2struct([convertStringsToChars(NetworkLink(i).name),'.xml']);
Kstruct2 = readstruct([convertStringsToChars(NetworkLink(i).name),'.xml']);








