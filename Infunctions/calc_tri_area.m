function S = calc_tri_area(side1, side2, side3, varargin)
    %       Calculate triangle area by length of side
    % =================================================================================================================
    % Parameters:
    %       side1:  length of side 1     || required: True || type: float || example: 3
    %       side2:  length of side 2     || required: True || type: float || example: 4
    %       side3:  length of side 3     || required: True || type: float || example: 5
    %       varargin:   (optional)
    % =================================================================================================================
    % Returns:
    %        S:     area of triangle     || type: float
    % =================================================================================================================
    % Updates:
    %       2025-01-09: Created,    by Christmas;
    % =================================================================================================================
    % Examples:
    %       S = calc_tri_area(3, 4, 5)
    % =================================================================================================================
    % References:
    %
    %    See also CALC_AREA
    % =================================================================================================================

    arguments(Input)
        side1 (:,:) {mustBeFloat}
        side2 (:,:) {mustBeFloat}
        side3 (:,:) {mustBeFloat}
    end

    arguments (Input,Repeating)
        varargin
    end

    Rearth = 6371.0e3;
    side1 = side1/Rearth;  % Convert to radians
    side2 = side2/Rearth;  % Convert to radians
    side3 = side3/Rearth;  % Convert to radians
    psum = 0.5*(side1+side2+side3);  % half of perimeter
    pm = sin(psum).*sin(psum-side1).*sin(psum-side2).*sin(psum-side3);  % area of triangle
    pm = sqrt(pm)./(2.0*cos(side1*0.5).*cos(side2*0.5).*cos(side3*0.5));  % area of triangle
    qmjc = 2.0*asin(pm);
    S = Rearth*Rearth*qmjc;

end

