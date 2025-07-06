classdef SageWrapper < handle
    properties(Constant)
        H SageWrapper=SageWrapper() 
    end
    properties 
        ns   % Sage global namespace (__dict__)
    end
    properties(Dependent)
        status
    end
    properties (Access = public)
        sage  % Python module handle for sage.all
    end
   properties(Constant,Hidden)
       PythonPath=readlines("SagePythonPath.txt") % this depends on platform
   end
    methods(Access=private)
        function obj = SageWrapper()
            obj.connect(obj.PythonPath)
        end
    end
    methods
        function connect(obj,pythonExePath)
            if nargin < 2 || isempty(pythonExePath)
                pythonExePath = SageWrapper.PythonPath;
            end
            pe = pyenv;
            if strcmp(pe.Status, 'NotLoaded') || ~strcmp(pe.Executable, pythonExePath)
                pyenv('Version', pythonExePath);
            end
            obj.sage = py.importlib.import_module('sage.all');
            obj.ns = py.getattr(obj.sage, '__dict__');
        end
        function ret = exec(obj, exprs)
            expr=join(exprs,newline());
            if nargout==0
                py.builtins.exec(expr, obj.ns, obj.ns);
            else
                ret = py.eval(expr, obj.ns, obj.ns);
            end
        end
        function let(obj,arg1,arg2)
            obj.exec(sprintf("%s=%s",arg1,string(arg2)));
        end
        function ret=get.status(obj)
            ret=pyenv().Status;
        end

    end
end
