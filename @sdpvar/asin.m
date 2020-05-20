function varargout = asin(varargin)
%ASIN (overloaded)

switch class(varargin{1})

    case 'sdpvar'
        varargout{1} = InstantiateElementWise(mfilename,varargin{:});

    case 'char'

        operator = struct('convexity',@convexity,'monotonicity','increasing','definiteness','none','model','callback');        
        operator.bounds = @bounds;
        operator.derivative = @(x)((1 - x.^2).^-0.5);
        operator.range = [-pi/2 pi/2];
        operator.domain = [-1 1];

        varargout{1} = [];
        varargout{2} = operator;
        varargout{3} = varargin{3};

    otherwise
        error('SDPVAR/ASIN called with CHAR argument?');
end

function [L,U] = bounds(xL,xU)
L = asin(xL);
U = asin(xU);

function vexity = convexity(xL,xU)
if xL >= 0  
    vexity = 'convex';
elseif xU <= 0
    vexity = 'concave';
else
    vexity = 'none';
end