classdef SageWrapper < handle
    properties 
        ns   % Sage global namespace (__dict__)
    end
    properties (Access = public)
        sage  % Python module handle for sage.all
    end
   properties(Constant,Hidden)
       DEFAULTPATH="/Applications/SageMath-10-6.app/Contents/Frameworks/Sage.framework/Versions/Current/venv/bin/python3"
   end
    methods
        function obj = SageWrapper(pythonExePath)
            if nargin < 1 || isempty(pythonExePath)
                pythonExePath = SageWrapper.DEFAULTPATH;
            end
            pe = pyenv;
            if strcmp(pe.Status, 'NotLoaded') || ~strcmp(pe.Executable, pythonExePath)
                pyenv('Version', pythonExePath);
            end
            obj.sage = py.importlib.import_module('sage.all');
            obj.ns = py.getattr(obj.sage, '__dict__');
        end

        function ret = exec(obj, expr)
            if nargout==0
                py.builtins.exec(expr, obj.ns, obj.ns);
            else
                ret = py.eval(expr, obj.ns, obj.ns);
            end
        end

        function exec_stmt(obj, stmt)
            py.builtins.exec(stmt, obj.ns, obj.ns);
        end

        function poly = alexander(obj, knotID)
            K = obj.sage.knots.Knot(int32(knotID));
            p = K.alexander_polynomial();
            poly = char(py.str(p));
        end

        function K = knot(obj, nameOrID)
            if isa(nameOrID,'char') || isa(nameOrID,'string')
                K = obj.sage.knots.Knot(char(nameOrID));
            else
                K = obj.sage.knots.Knot(int32(nameOrID));
            end
        end

        function s = poly_to_str(~, polyObj)
            s = char(py.str(polyObj));
        end

        function reset(obj)
            pe = pyenv;
            pyenv('Version', pe.Version);
            obj.sage = py.importlib.import_module('sage.all');
            obj.ns = py.getattr(obj.sage, '__dict__');
        end
    end
end
