%% Housekeeping
close all; clear; clc;


%% Set parameters

pG = 1/2; pB = 1/2;

% Start with (arbitrary) values for rA, y1 and alpha
rA = 0.08;
alpha = 2/3;
y1 = 10; 

y2 = alpha*y1; y3 = alpha^2*y1; 
yG = alpha*y1; yB = alpha^2*y1;

% Specifiy epsilon (as fraction) so that inequality to derive ra is slack
eps_z = 0.9;
z_rA = eps_z * ( (sqrt(1+rA) - 1)/rA );
ra = z_rA*rA;

int1 = (1+ra)^2;
int2 = 1+rA;
check_int = int2-int1 % Needs to be positive


%% Deterministic case: endowment evolution and consumption allocation

a_1_star_det = 1/3 * y1 * (1 - (2*alpha/(1+ra)) + (alpha^2/(1+rA)) );
A_star_det =   1/3 * y1 * (1 + (alpha/(1+ra))   - ((2*alpha^2)/(1+rA)) );
c1_det = y1 - A_star_det - a_1_star_det;
c2_det = alpha*y1 + a_1_star_det*(1+ra);
c3_det = alpha^2*y1 + A_star_det*(1+rA);
U_det = log(c1_det)+log(c2_det)+log(c3_det);

% Plot results
t = 1:1:3;
figure(1)
plot(t,[y1,alpha*y1,alpha^2*y1],'-o','MarkerIndices',1:1:3,'MarkerSize',10,'LineWidth',2)
hold on
plot(t,[c1_det, c2_det, c3_det],'-x','MarkerIndices',1:1:3,'MarkerSize',10,'LineWidth',2)
hold off
title('Deterministic Environment')
xlabel('Period','FontSize',14)
ylabel('y,c','FontSize',14)
legend('Endowment','Consumption','FontSize',12)
xticks([1 2 3])


%% Stochastic case

% Plot endowment evolution relative to deterministic case

figure(2)
plot(t,[y1,y2,y3],'-o','MarkerIndices',1:1:3,'MarkerSize',14,'LineWidth',2)
hold on
plot(t,[y1,yG,y3],'-*','MarkerIndices',1:1:3,'MarkerSize',10,'LineWidth',2)
plot(t,[y1,yB,y3],'-*','MarkerIndices',1:1:3,'MarkerSize',10,'LineWidth',2)
hold off
title('Deterministic vs Stochastic Endowment')
xlabel('Period','FontSize',14)
ylabel('y','FontSize',14)
legend('Deterministic','Good State','Bad State','FontSize',12)
xticks([1 2 3])


%% Public Trust

% 1. Full insurance: omega = 1/alpha (qe coefficients as written in tex file)

fi_a = 3;
fi_b = y1*( (5*alpha)/(1+z_rA*rA) - (alpha^2)/(1+rA) - 1 );
fi_c = y1^2*(alpha/2)*(1/(1+z_rA*rA))*( (4*alpha)/(1+z_rA*rA) - (2*alpha^2)/(1+rA) - 2 );
fi_x = roots( [fi_a fi_b fi_c] )

% 2. Partial insurance: Iterate over omega: 1:0.001:1/alpha

omega_grid = 1:0.0001:1/alpha;
pi_x1 = nan(1,numel(omega_grid));
pi_x2 = nan(1,numel(omega_grid));

for i = 1:numel(omega_grid)
    l_omega = omega_grid(i);
    
    pi_a = 3;
    pi_b = y1*( ((5/2)*alpha*(1+l_omega*alpha))/(1+z_rA*rA) - (alpha^2)/(1+rA) - 1 );
    pi_c = y1^2*(alpha/2)*(1/(1+z_rA*rA))*( (4*alpha^2*l_omega)/(1+z_rA*rA) - (alpha^2*(1+l_omega*alpha))/(1+rA) - (1+l_omega*alpha) );
    
    pi_x = roots( [pi_a pi_b pi_c] );
    pi_x1(i) = pi_x(1);
    pi_x2(i) = pi_x(2);
    
end

figure1 = figure;
axes1 = axes('Parent',figure1);
hold(axes1,'on');
plot(omega_grid, pi_x2,'k','LineWidth',2)
ylabel('{\boldmath$a_1^*$}','FontSize',17,'Interpreter','latex');
xlabel('{\boldmath$\omega$}','FontSize',17,'Interpreter','latex');
title('Stochastic Endowment: Optimal Liquid Asset Choice for Different Trust');

box(axes1,'on');
annotation(figure1,'arrow',[0.85 0.90],[0.30 0.13],'LineWidth',1);
annotation(figure1,'arrow',[0.29 0.14],[0.82 0.88],'LineWidth',1);
annotation(figure1,'textbox', [0.77 0.31 0.12 0.09], ...
'String',{'Full','Insurance'},'LineStyle','none','FontSize',14,...
'FontName','Helvetica Neue','FitBoxToText','off');
annotation(figure1,'textbox',[0.30 0.78 0.11 0.07],...
'String',{'No','Insurance'},'LineStyle','none','FontSize',14,...
'FontName','Helvetica Neue','FitBoxToText','off');


%% Private Trust

theta = 4.4;

% Iterate over omega: 1:0.001:1/alpha

omega_grid = 1:0.0001:1/alpha;
priv_pi_x1 = nan(1,numel(omega_grid));
priv_pi_x2 = nan(1,numel(omega_grid));

for i = 1:numel(omega_grid)
    l_omega = omega_grid(i);
    
    priv_pi_a = 3;
    priv_pi_b = y1*( ((5/2)*alpha*(1+l_omega*alpha - ((l_omega - 1)/y1)*theta))/(1+z_rA*rA) - (alpha^2)/(1+rA) - 1 );
    priv_pi_c = y1^2*(alpha/2)*(1/(1+z_rA*rA))*( (4*(alpha^2*l_omega - (l_omega - 1)*(theta/y1)))/(1+z_rA*rA) - (alpha^2*(1+l_omega*alpha))/(1+rA) - (1+l_omega*alpha) - ((l_omega - 1)*theta / (y1*alpha)) - (alpha * theta * (l_omega - 1)/(y1*(1+rA))));
    
    priv_pi_x = roots( [priv_pi_a priv_pi_b priv_pi_c] );
    priv_pi_x1(i) = priv_pi_x(1);
    priv_pi_x2(i) = priv_pi_x(2);
    
end

figure1 = figure;
axes1 = axes('Parent',figure1);
hold(axes1,'on');
plot(omega_grid, priv_pi_x2,'k','LineWidth',2)
plot(omega_grid, pi_x2,'k','LineWidth',2)
ylabel('{\boldmath$a_1^*$}','FontSize',17,'Interpreter','latex');
xlabel('{\boldmath$\omega$}','FontSize',17,'Interpreter','latex');
title('Stochastic Endowment: Optimal Liquid Asset Choice for Different Trust');

box(axes1,'on');
annotation(figure1,'arrow',[0.85 0.90],[0.30 0.13],'LineWidth',1);
annotation(figure1,'arrow',[0.29 0.14],[0.82 0.88],'LineWidth',1);
annotation(figure1,'textbox', [0.77 0.31 0.12 0.09], ...
'String',{'Full','Insurance'},'LineStyle','none','FontSize',14,...
'FontName','Helvetica Neue','FitBoxToText','off');
annotation(figure1,'textbox',[0.30 0.78 0.11 0.07],...
'String',{'No','Insurance'},'LineStyle','none','FontSize',14,...
'FontName','Helvetica Neue','FitBoxToText','off');
