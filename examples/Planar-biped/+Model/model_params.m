function model_prms = model_params()

    L_lower_leg = 0.327; % m
    L_upper_leg = 0.32; % m 
    L_torso     = 0.0; % m
       
    % distance from proximal joint
    Lcom_torso = 0;
    Lcom_lower_leg = 0.097;
    Lcom_upper_leg = 0.092;
       
    % for plotting
    M_lower_leg = 0.73;%3.2/4; % kg
    M_upper_leg = 2.43;%6.8/4; % kg
    M_torso     = 3.55;%12.0/4; % kg
    
    model_prms.Inertia_lower_leg=0.02;
    model_prms.Inertia_upper_leg=0.06;
    
    model_prms.L_lower_leg = L_lower_leg;
    model_prms.L_upper_leg = L_upper_leg;    
    model_prms.L_torso = L_torso;

    model_prms.Lcom_lower_leg = Lcom_lower_leg;
    model_prms.Lcom_upper_leg = Lcom_upper_leg;    
    model_prms.Lcom_torso = Lcom_torso;
    
    model_prms.M_lower_leg = M_lower_leg;
    model_prms.M_upper_leg = M_upper_leg;    
    model_prms.M_torso = M_torso;

    % color of the links
    model_prms.C_leg1 = [1 0 0];
    model_prms.C_leg2 = [0 0 1];    
    model_prms.C_torso = [0 0.7 0];
    
end