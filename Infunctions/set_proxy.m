function set_proxy(TF, varargin)
    %       Set proxy for web
    % =================================================================================================================
    % Parameters:
    %       varargin:       optional parameters      
    %           TF:       whether to use proxy            || required: True  || type: bool   || example: true
    %           host:     proxy host                      || required: False || type: text   || default: '127.0.0.1'
    %           port:     proxy port                      || required: False || type: text   || default: '7890'
    %           
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Updates:
    %       2024-02-09:     Created, by Christmas;
    % =================================================================================================================
    % Examples:
    %       set_proxy(true);
    %       set_proxy(false);
    %       set_proxy(true, 'host', '127.0.0.1');
    %       set_proxy(true, 'port', '7890');
    %       set_proxy(true, 'host', '127.0.0.1', 'port', '7890');
    % =================================================================================================================

    arguments(Input)
        TF = true
    end
    arguments(Input,Repeating)
        varargin
    end

    varargin = read_varargin(varargin, {'host'}, {'127.0.0.1'});
    varargin = read_varargin(varargin, {'port'}, {'7890'});
    
    if TF
        com.mathworks.mlwidgets.html.HTMLPrefs.setUseProxy(true) %#ok<*JAPIMATHWORKS>
        com.mathworks.mlwidgets.html.HTMLPrefs.setProxyHost('127.0.0.1')
        com.mathworks.mlwidgets.html.HTMLPrefs.setProxyPort('7890')
    else
        com.mathworks.mlwidgets.html.HTMLPrefs.setUseProxy(false)
        return
    end
    %% the proxy authentication is required
    % com.mathworks.mlwidgets.html.HTMLPrefs.setUseProxyAuthentication(false)
    % com.mathworks.mlwidgets.html.HTMLPrefs.setProxyUsername('test')
    % com.mathworks.mlwidgets.html.HTMLPrefs.setProxyPassword('test')
end
