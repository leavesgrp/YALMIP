function output = callcopt(interfacedata)

options = interfacedata.options;
numvars = length(interfacedata.c);
problem = yalmip2copt(interfacedata);

if interfacedata.options.savedebug
    save coptdebug problem
end

if options.showprogress; showprogress('Call COPT', options.showprogress); end
solvertime = tic;
solution   = copt_solve(problem, problem.params);
solvertime = toc(solvertime);

if isfield(solution, 'x')
    x = solution.x(1:numvars);
else
    x = zeros(numvars, 1);
end

if isfield(solution, 'pi')
    % Do we have reversed sign-convention?
    D_struc = -solution.pi;
else
    D_struc = [];
end

switch solution.status
    case 'optimal'
        status = 0;
    case 'infeasible'
        status = 1;
    case 'unbounded'
        status = 2;
    case {'timeout', 'nodelimit'}
        status = 3;
    case 'numerical'
        status = 4;
    case 'interrupted'
        status = 16;
    case 'unstarted'
        status = -4;
    otherwise
        status = -1;
end

if interfacedata.options.savesolverinput
    solverinput.model = problem;
else
    solverinput = [];
end

if interfacedata.options.savesolveroutput
    solveroutput.result = solution;
else
    solveroutput = [];
end

infostr = yalmiperror(status, interfacedata.solver.tag);

output  = createOutputStructure(x, D_struc, [], status, infostr, solverinput, solveroutput, solvertime);
