function [obj] = SolveNLP(obj)

arguments
    obj (1,1) NLP
end

import casadi.*

% structure the nlp
prob = struct('f', obj.Cost, 'x', vertcat(obj.Vars{:}), 'g', vertcat(obj.Constr{:}));

% select the linear solver and sets options
[options] = IPOPToptions(obj);

% send the nlp to ipopt
solver = nlpsol('solver', 'ipopt', prob, options);

% solve the NLP
tic
sol = solver('x0', obj.VarsInit, 'lbx', obj.VarsLB, 'ubx', obj.VarsUB,...
            'lbg', obj.ConstrLB, 'ubg', obj.ConstrUB);
toc

obj.Sol = sol;

end