function status = gitc(command, varargin)
    %       git command line
    % =================================================================================================================
    % Parameters:
    %       varargin:       optional parameters
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Updates:
    %       2024-11-06:     Created,        by Christmas;
    %       TODO:
    % =================================================================================================================
    % Examples:
    %       gitc clone
    %       gitc pull
    %       gitc push
    % =================================================================================================================

    arguments(Input)
        command {mustBeMember(command, {'init', 'repo', 'add', 'rm', 'commit', 'clone', 'pull', 'push'})}
    end
    arguments(Input,Repeating)
        varargin
    end

    varargin = read_varargin(varargin, {'exe'}, {'/usr/bin/git'});

    if ~isMATLABReleaseOlderThan("R2023b")
        Git.method = 'MATLAB';
    else
        Git.method = 'SYSTEM';
    end

    STATUS = 0;
    switch command
        case 'init' % git init
            switch Git.method
            case 'MATLAB'
                cmd = 'gitinit';
            case 'SYSTEM'
                cmd = sprintf('%s init', exe);
            end

        case 'repo'  % git repo
            switch Git.method
            case 'MATLAB'
                cmd = 'gitrepo';
            case 'SYSTEM'
                cmd = sprintf('%s login', exe);
            end

        case 'add'  % git add
            switch Git.method
            case 'MATLAB'
                cmd = 'add';
            case 'SYSTEM'
                cmd = sprintf('%s add', exe);
            end

        case 'rm' % git rm
            switch Git.method
            case 'MATLAB'
                cmd = 'rm';
            case 'SYSTEM'
                cmd = sprintf('%s rm', exe);
            end

        case 'commit'  % git commit
            switch Git.method
            case 'MATLAB'
                cmd = 'commit';
            case 'SYSTEM'
                cmd = sprintf('%s commit', exe);
            end

        case 'clone'  % git clone
            switch Git.method
            case 'MATLAB'
                cmd = 'gitclone';
            case 'SYSTEM'
                cmd = sprintf('%s clone', exe);
            end

        case 'pull'  % git pull
            cmd = sprintf('%s pull', exe);

        case 'push'  % git push
            cmd = sprintf('%s push', exe);

        otherwise
            error(" Try 'git --help' for help. \n" + ...
                  " Error: No such command '%s'", command);
    end

%    status = system(cmd);
    disp(cmd);

end


