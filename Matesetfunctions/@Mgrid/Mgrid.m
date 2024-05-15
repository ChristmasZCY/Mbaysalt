classdef Mgrid

    properties
        GridStruct
        draw
    end

    methods
        
        function obj = Mgrid(GridStruct)
            obj.GridStruct = GridStruct;
            obj.draw = Mdraw(GridStruct);
        end

        function outputArg = fun1(obj,varargin)
            outputArg = obj.Property1 + inputArg;
        end
    end
end
