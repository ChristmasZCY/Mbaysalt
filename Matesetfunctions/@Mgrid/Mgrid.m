classdef Mgrid

    properties
        GridStruct
        draw
    end

    methods
        
        function obj = Mgrid(GridStruct, Varsrtuct)
            obj.GridStruct = GridStruct;
            if ~exist("Varsrtuct", "var")
                obj.draw = Mdraw(GridStruct);
            else
                obj.draw = Mdraw(GridStruct, Varsrtuct);
            end
        end

        function outputArg = fun1(obj,varargin)
            outputArg = obj.Property1 + inputArg;
        end
    end
end
