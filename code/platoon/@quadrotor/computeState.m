function x1 = computeState(obj, u, x0)
% function x1 = computeState(obj, u, x0)
% Computes (DOES NOT update!) state based on control; use updateState to
% update the state
% 
% Inputs:   obj - current quardotor object
%           u   - control (defaults to previous control)
%           x0  - initial state (defaults to current state)
%
% Outputs:  x1  - final state
%
% Mo Chen, 2015-05-24

% If no control is specified, use previous control
if nargin < 2
    u = obj.u; 
end

% If no state is specified, use current state
if nargin < 3
    x0 = obj.x; 
end

% Forward Euler (unstable for large dt)
% x1  = x0 + (obj.A*x0 + obj.B*u)*obj.dt;

% Backwards Euler (unconditionally stable)
x1  = (eye(obj.nx) - obj.dt*obj.A)\(x0 + obj.B*u *obj.dt);

end