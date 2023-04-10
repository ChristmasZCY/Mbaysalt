function Depth = siglay_to_3d(h, siglay)
    % =================================================================================================================
    % discription:
    %       convert sigma layer to 3d depth for fvcom
    % =================================================================================================================
    % parameter:
    %       h:      bottom depth (m)                  || required: True || type: double || format: matrix
    %       siglay: sigma layer                       || required: True || type: double || format: matrix
    %       Depth:  3d depth (m)                      || required: True || type: double || format: matrix
    % =================================================================================================================
    % example:
    %       Depth = siglay_to_3d(h, siglay)
    % =================================================================================================================

    Depth = zeros([size(h), length(siglay)]);
    
    for i = 1: size(h, 1)

        for j = 1: size(h, 2)
            Depth(i,j,:) = h(i,j) * siglay;
        end

    end

end