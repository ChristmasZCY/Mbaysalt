clm
S = readstruct('stations.xml');
NetworkLink = S.Folder.NetworkLink;
outputDir = java.io.File(pwd).getCanonicalFile().toPath();

for i = 1:length(NetworkLink)
    disp(NetworkLink(i).Link.href)
    stationFile = download_station(outputDir, NetworkLink(i).name, NetworkLink(i).Link.href);
end

Kstruct = kmz2struct(stationFile);
Kstruct2 = readstruct(stationFile);

function filename = download_station(outputDir, name, url)
    % Download url as name.xml below outputDir; return the published absolute path.
    % Reject escapes (including symbolic links) and preserve existing files on failure.
    text = char(string(name));
    relative = [text, '.xml'];
    requested = java.io.File(relative).toPath();
    target = outputDir.resolve(requested).toFile().getCanonicalFile().toPath();
    if ~target.startsWith(outputDir) || target.equals(outputDir)
        error('Mbaysalt:StationPathEscape', 'Station "%s" resolves outside the download directory.', text);
    end

    stage = java.nio.file.Files.createTempFile(target.getParent(), '.station-', '.xml', javaArray('java.nio.file.attribute.FileAttribute', 0));
    cleanup = onCleanup(@() java.nio.file.Files.deleteIfExists(stage)); %#ok<NASGU>
    websave(char(stage.toString()), url);
    if java.nio.file.Files.size(stage) == 0
        error('Mbaysalt:EmptyStation', 'Station "%s" returned an empty file.', text);
    end
    opts = javaArray('java.nio.file.CopyOption', 2);
    opts(1) = java.nio.file.StandardCopyOption.ATOMIC_MOVE;
    opts(2) = java.nio.file.StandardCopyOption.REPLACE_EXISTING;
    java.nio.file.Files.move(stage, target, opts);
    filename = char(target.toString());
end
