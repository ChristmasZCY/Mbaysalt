classdef Mdraw

    properties(Access=private)
        GridStruct
        VarStruct
    end

    methods
        function obj = Mdraw(GridStruct, VarStruct)
            obj.GridStruct = GridStruct;
            if exist("Varsrtuct", "var")
                obj.VarStruct = VarStruct;
            end
        end

        function h = range(obj, varargin)
            st = dbstack; st = st(1);
            strpart = strsplit(st.file,'.');
            funName = strrep(st.name,[strpart{1} '.'],'');
            funHandle = createFun(obj, funName);
            funHandle(obj.GridStruct, varargin{:});
            h = funHandle(obj.GridStruct, varargin{:});
        end

        function h = mesh(obj, varargin)
            st = dbstack; st = st(1);
            strpart = strsplit(st.file,'.');
            funName = strrep(st.name,[strpart{1} '.'],'');
            funHandle = createFun(obj, funName);
            h = funHandle(obj.GridStruct, varargin{:});
        end

        function h = boundary(obj, varargin)
            st = dbstack; st = st(1);
            strpart = strsplit(st.file,'.');
            funName = strrep(st.name,[strpart{1} '.'],'');
            funHandle = createFun(obj, funName);
            h = funHandle(obj.GridStruct, varargin{:});
        end

        function [h, poly_coast] = coast(obj, varargin)
            st = dbstack; st = st(1);
            strpart = strsplit(st.file,'.');
            funName = strrep(st.name,[strpart{1} '.'],'');
            funHandle = createFun(obj, funName);
            [h, poly_coast] = funHandle(obj.GridStruct, varargin{:});
        end

        function h = mask_boundary(obj, varargin)
            st = dbstack; st = st(1);
            strpart = strsplit(st.file,'.');
            funName = strrep(st.name,[strpart{1} '.'],'');
            funHandle = createFun(obj, funName);
            h = funHandle(obj.GridStruct, varargin{:});
        end

        function h = image(obj, varargin)
            st = dbstack; st = st(1);
            strpart = strsplit(st.file,'.');
            funName = strrep(st.name,[strpart{1} '.'],'');
            funHandle = createFun(obj, funName);
            h = funHandle(obj.GridStruct, varargin{:});
        end

        function h = contour(obj, varargin)
            st = dbstack; st = st(1);
            strpart = strsplit(st.file,'.');
            funName = strrep(st.name,[strpart{1} '.'],'');
            funHandle = createFun(obj, funName);
            h = funHandle(obj.GridStruct, varargin{:});
        end

    end

    methods(Access=private)
        function funHandle  = createFun(obj, str)
            if isfield(obj.GridStruct, 'nv') && strcmp(obj.GridStruct.grid, 'TRI')
                funHandle = str2func(sprintf('f_2d_%s',str));
            elseif strcmp(obj.GridStruct.grid, 'GRID')
                funHandle = str2func(sprintf('w_2d_%s',str));
            else
            end
        end
    end
end
