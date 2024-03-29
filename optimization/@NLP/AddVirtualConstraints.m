function [obj] = AddVirtualConstraints(obj, rbm, varargin)

arguments
    obj (1,1) NLP
    rbm (1,1) DynamicalSystem
end

arguments (Repeating)
    varargin (1,2) cell
end


if obj.Problem.Trajectory.Bool==0
    
   obj.Problem.Trajectory = VirtualConstraint();
end

    



if nargin <= 2
    error('Must specify the type of virtual constraints')
else    
    for i = 1:nargin-2
        tempArg = varargin{i};
        argIn.(tempArg{1}) = tempArg{2};
    end
end


if isfield(argIn, 'PolyType')
    mustBeMember(argIn.PolyType, {'Bezier'})
else
    error('''PolyType'' is a required argument for %s.', class(obj.Problem.Trajectory));
end
obj.Problem.Trajectory.PolyType = argIn.PolyType;

if isfield(argIn, 'GaitPhase')
    mustBeMember(argIn.GaitPhase, {'Double','Single'})
else
    error('''PolyType'' is a required argument for %s.', class(obj.Problem.Trajectory));
end
obj.Problem.Trajectory.GaitPhase = argIn.GaitPhase;


if isfield(argIn, 'PolyOrder')
    mustBeGreaterThanOrEqual(argIn.PolyOrder, 3)
else
    error('''PolyOrder'' is a required argument for %s.', class(obj.Problem.Trajectory));
end

switch obj.Problem.Trajectory.GaitPhase
    case 'Double'
        obj.Problem.Trajectory.PolyOrder.Double = argIn.PolyOrder;
    case 'Single'
        obj.Problem.Trajectory.PolyOrder.Single = argIn.PolyOrder;
end

if isfield(argIn, 'PolyPhase')
    mustBeMember(argIn.PolyPhase, {'time-based', 'state-based'})
else
    error('''PolyPhase'' is a required argument for %s.', class(obj.Problem.Trajectory));
end
obj.Problem.Trajectory.PolyPhase = argIn.PolyPhase;



import casadi.*

% phase variable at t = 0 (could be time or mechanical phase variable)
t_plus = SX.sym('phase_var_0');

% phase variable at t = T
t_minus = SX.sym('phase_var_T');

% normalized phase variable  
tau = SX.sym('norm_phase_var');




switch obj.Problem.Trajectory.PolyType

    case 'Bezier'
        
        % define the matrix of Bezier coefficients
        alpha = AddBezierCoefficients(obj.Problem.Trajectory, rbm);
        
        switch obj.Problem.Trajectory.GaitPhase
            case 'Double'
                % number of actuated DOF
                obj.Problem.Trajectory.PolyCoeffD.Double = Var('aD',1);
                obj.Problem.Trajectory.PolyCoeffD.Double.sym = alpha;
            case 'Single'
                obj.Problem.Trajectory.PolyCoeffS.Single = Var('aS',1);
                obj.Problem.Trajectory.PolyCoeffS.Single.sym = alpha;
        end

        
        % compute symbolic forms of desired trajectories and derivatives
        [phi, dphi, d2phi] = BezierTrajectory(obj.Problem.Trajectory, alpha, tau, t_minus, t_plus);

        
    otherwise
        error('Only Bezier polynomials are supported for now.')

end



parameterization_type = obj.Problem.Trajectory.PolyPhase;


% controller outputs and time derivatives
[Y, DY, DDY] = ControllerOutput(obj.Problem.Trajectory,...
    rbm, phi, dphi, d2phi, parameterization_type);


obj.Functions.Y_Controller = Function('f', {rbm.States.q.sym, alpha, tau, t_plus, t_minus}, {Y});
obj.Functions.DY_Controller = Function('f', {rbm.States.q.sym, rbm.States.dq.sym, alpha, tau, t_plus, t_minus}, {DY});
obj.Functions.DDY_Controller = Function('f', {rbm.States.q.sym, rbm.States.dq.sym, rbm.States.ddq.sym, alpha, tau, t_plus, t_minus}, {DDY});

switch obj.Problem.Trajectory.GaitPhase
    case 'Double'
        obj.Functions.Y_Double_Controller = Function('f', {rbm.States.q.sym, alpha, tau, t_plus, t_minus}, {Y});
        obj.Functions.DY_Double_Controller = Function('f', {rbm.States.q.sym, rbm.States.dq.sym, alpha, tau, t_plus, t_minus}, {DY});
        obj.Functions.DDY_Double_Controller = Function('f', {rbm.States.q.sym, rbm.States.dq.sym, rbm.States.ddq.sym, alpha, tau, t_plus, t_minus}, {DDY});
        
    case 'Single'
        obj.Functions.Y_Single_Controller = Function('f', {rbm.States.q.sym, alpha, tau, t_plus, t_minus}, {Y});
        obj.Functions.DY_Single_Controller = Function('f', {rbm.States.q.sym, rbm.States.dq.sym, alpha, tau, t_plus, t_minus}, {DY});
        obj.Functions.DDY_Single_Controller = Function('f', {rbm.States.q.sym, rbm.States.dq.sym, rbm.States.ddq.sym, alpha, tau, t_plus, t_minus}, {DDY});
        
end

end