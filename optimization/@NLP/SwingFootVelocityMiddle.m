function [nlp] = SwingFootVelocityMiddle(nlp, rbm, grid_var)

%% Argument Validation
arguments
    nlp (1,1) NLP
    rbm (1,1) DynamicalSystem
    grid_var (1,1) struct
end


    
%preswing end of double vertical
for i=1:round(nlp.Settings.ncp/2)
    
    variables1 = {grid_var.(['pos_', num2str(i)]),...
            grid_var.(['vel_', num2str(i)])};
    variables2 = {grid_var.(['pos_', num2str(i+1)]),...
            grid_var.(['vel_', num2str(i+1)])};
        
         variablesFsw = {grid_var.(['pos_', num2str(i)]),...
            grid_var.(['vel_', num2str(i)])};
        variablesFsw{end+1} =grid_var.(['OriPosSwToe']);
        
    if 0.3*round(nlp.Settings.ncp/2)<=i && i<=round(nlp.Settings.ncp/2)*0.70
        
        [nlp] = AddConstraint(nlp, nlp.Problem.SwingFootForwardImpactVelocity.Function(variables1{:})-...
            nlp.Problem.SwingFootForwardImpactVelocity.Function(variables2{:})...
            , 0, inf, nlp.Problem.SwingFootForwardImpactVelocity.Name);
        
    end
    if 0.3*round(nlp.Settings.ncp/2)<=i && i<=round(nlp.Settings.ncp/2)*0.85
        [nlp] = AddConstraint(nlp, nlp.Functions.GRFyPreSwing(variables1{:})...
            , 4, inf, nlp.Problem.SwingFootForwardImpactVelocity.Name);
    end
    
           [nlp] = AddConstraint(nlp, nlp.Functions.GRFxPreSwing(variablesFsw{:})...
            , 0, inf, nlp.Problem.SwingFootForwardImpactVelocity.Name);
    
end