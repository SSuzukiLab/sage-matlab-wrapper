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
            expr1=join(exprs(1:end-1),newline());
            if ~ismissing(expr1)
                py.builtins.exec(expr1, obj.ns, obj.ns);
            end
            assert(strlength(exprs(end)),"empty code. Check the end of script file.")
            if nargout==0
                py.builtins.exec(exprs(end), obj.ns, obj.ns);
            else
                ret = py.eval(exprs(end), obj.ns, obj.ns);
            end
        end
        function let(obj,arg1,arg2)
            obj.exec(sprintf("%s=%s",arg1,string(arg2)));
        end
        function ret=get.status(obj)
            ret=pyenv().Status;
        end
        
    end
    methods(Static)
        function ret=toDouble(arg)
            T=class(arg);
            if startsWith(class(arg),'py.')
                if isa(arg,'py.int')||isa(arg,'py.float')
                    ret=double(arg);
                elseif isa(arg,'py.list')
                    C=cell(arg);
                    if isa(C{1},'py.list')
                        C=cellfun(@double,C,Un=0);
                        ret=vertcat(C{:});
                    else
                        ret=double(arg);
                    end
                else
                    warning("unknown type conversion:%s",class(arg))
                    ret=SageWrapper.toDouble(list(arg));
                end
            elseif isa(arg,"double")
                ret=arg;
            end
        end
        function ret=toStr(arg,dim)
            if isa(arg,'double')
                if dim==2
                    ret="[["+join(join(string(arg),","),"],[")+"]]";
                elseif dim==1
                    ret="["+join(string(arg),",")+"]";
                end
            elseif isa(arg,'cell')
                if isa(arg{1},'double')
                    ret="[["+join(cellfun(@(x)join(string(x),","),arg),"],[")+"]]";
                end
            end
        end
         
        function reset()
            obj.ns = py.getattr(obj.sage, '__dict__');
            % py.builtins.exec('reset()', obj.ns, obj.ns);
            
        end   
    end
end
