function model = yalmip2copt(interfacedata)

F_struc            = interfacedata.F_struc;
K                  = interfacedata.K;
% Q                = interfacedata.Q;
c                  = interfacedata.c;
lb                 = interfacedata.lb;
ub                 = interfacedata.ub;
x0                 = interfacedata.x0;
integer_variables  = interfacedata.integer_variables;
binary_variables   = interfacedata.binary_variables;
semicont_variables = interfacedata.semicont_variables;
n                  = length(c);

if ~isempty(ub)
    LB = lb;
    UB = ub;
    if ~isempty(binary_variables)
        LB(binary_variables) = round(LB(binary_variables));
        UB(binary_variables) = round(UB(binary_variables));
    end
    if ~isempty(integer_variables)
        LB(integer_variables) = round(LB(integer_variables));
        UB(integer_variables) = round(UB(integer_variables));
    end
else
    LB = -inf(n, 1);
    UB = inf(n, 1);
end

if ~isempty(semicont_variables)
    warning('WARNING: Semi-continuous or semi-integer variables not supported.');
end

if size(F_struc, 1) > 0
    B = full(F_struc(:, 1));
    A = -F_struc;
    A(:, 1) = [];
else
    B = [];
    A = [];
end

CTYPE   = char([ones(K.f, 1) * 69; ones(K.l, 1) * 76]);
VARTYPE = char(ones(length(c), 1) * 67);
if isempty(semicont_variables)
    VARTYPE(integer_variables) = 'I';
    VARTYPE(binary_variables)  = 'B';
else
    VARTYPE(setdiff(integer_variables, semicont_variables)) = 'I';
    VARTYPE(binary_variables) = 'B';
    VARTYPE(setdiff(semicont_variables, integer_variables)) = 'C';
    VARTYPE(intersect(semicont_variables, integer_variables)) = 'I';
end

% model.objsen = 'min';
model.objcon = full(interfacedata.f);
if isempty(A)
    model.A = spalloc(0, length(c), 0);
else
    model.A = sparse(A);
end
model.obj   = full(c);
model.lb    = LB;
model.ub    = UB;
model.vtype = VARTYPE;
% model.varnames = {};
model.sense = CTYPE;
model.rhs   = full(B);
% model.constrnames = {};

if ~isempty(K.sos.type)
    for i = 1:length(K.sos.type)
        if isa(K.sos.type(i), 'char')
            model.sos(i).type = str2num(K.sos.type(i));
        else
            model.sos(i).type = K.sos.type(i);
        end
        model.sos(i).vars    = full(K.sos.variables{i}(:)');
        model.sos(i).weights = full(K.sos.weight{i}(:)'); 
    end
end

interfacedata.options = pruneOptions(interfacedata.options);

model.params = interfacedata.options.copt;
if interfacedata.options.verbose == 0
    model.params.Logging = 0;
else
    model.params.Logging = 1;
end

if ~isempty(x0)
    model.start = x0;
end
