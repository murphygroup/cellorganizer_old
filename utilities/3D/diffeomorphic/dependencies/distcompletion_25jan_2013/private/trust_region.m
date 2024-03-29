function varargout=trust_region(varargin)
% Trust-region optimization on Riemannian manifolds
%
% This code has been adapted from the RTR - Riemannian Trust-Region toolbox
% (P.-A. Absil, C. G. Baker, K. A. Gallivan)

% Inputs
fun_set=varargin{1};   
fun_obj=varargin{2};
x0=varargin{3};     
param=varargin{4};

user_tol = varargin{5};
user_vtol = varargin{6};
maxiter_tr = varargin{7};
verb = varargin{8};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set default parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p=size(x0,2);
Delta_bar = 10*p;   %Maximum trust-region radius
Delta0 = p;         %Initial trust-region radius
verbosity = 1;
debug     = 0;
min_inner = 0;
max_inner = intmax;
min_outer = 3;
max_outer = maxiter_tr;
epsilon   = user_tol; %Outer Convergence tolerance (1e-6)
vepsilon = user_vtol;
kappa = 0.1; %Inner kappa convergence tolerance (0.1)
theta = 1;  %Inner theta convergence tolerance
rho_prime = 0.1;  %Accept/reject parameter
useRand = 0;

% ***** Initializations *****

% initialize counters/sentinals
% allocate storage for dist, counters
k          = 0;  % counter for outer (TR) iteration.
stop_outer = 0;  % stopping criterion for TR.

% initialize solution and companion measures:
x = x0;
fx = feval(fun_set,'f',x,fun_obj,param); 
fgradx = feval(fun_set,'grad_f',x,fun_obj,param);

% initialize trust-region radius
Delta = Delta0;

% **********************
% ** Start of TR loop **
% **********************

costs = zeros(max_outer+1,1);
costs(1) = fx;

if verb
    %%%% Bark only when asked
fprintf('[%0.4d] cost = %g\n',0,costs(1));
end

while stop_outer==0,

    % update counter
    k = k+1;

    % *************************
    % ** Begin TR Subproblem **
    % *************************
    fx_old=fx;

    eta = 0*fgradx;

    % solve TR subproblem
    [eta,numit,stop_inner] = tCG(fun_set,x,fgradx,eta,Delta,theta,kappa,min_inner,max_inner,useRand,debug,fun_obj,param);
    
    % compute the retraction of the proposal (eta)
    x_prop  = feval(fun_set,'retraction',x,eta); 

    % compute function value of the proposal
    fx_prop = feval(fun_set,'f',x_prop,fun_obj,param);
    
    % do we accept the proposed solution or not?
    % compute the Hessian at the proposal
    Heta = feval(fun_set,'hessian',x,eta,fun_obj,param); 

    % check the performance of the quadratic model
    rhonum = fx-fx_prop;
    rhoden = -feval(fun_set,'metric',x,fgradx,eta) - 0.5*feval(fun_set,'metric',x,Heta,eta); 
    rho =   rhonum  / rhoden;

    % choose new TR radius based on performance
    trstr = '   ';
    if rho < 1/4
        trstr = 'TR-';
        Delta = 1/4*Delta;
    elseif rho > 3/4 && (stop_inner == 2 || stop_inner == 1),
        trstr = 'TR+';
        Delta = min(2*Delta,Delta_bar);
    end

    % choose new iterate based on performance
    oldgradx = fgradx;
    if rho > rho_prime,
        accept = true;
        accstr = 'acc';
        x    = x_prop;
        fx   = fx_prop;
        fgradx = feval(fun_set,'grad_f',x,fun_obj,param); %fns.fgrad(x);
        norm_grad = sqrt(feval(fun_set,'metric',x,fgradx,fgradx)); %sqrt(fns.g(x,fgradx,fgradx));
    else
        accept = false;
        accstr = 'REJ';
    end
    
    % ** Testing for Stop Criteria
    % min_outer is the minimum number of inner iterations
    % before we can exit. this gives randomization a chance to
    % escape a saddle point.
    if accept && k > min_outer && (abs(rhonum) < epsilon || abs(rhonum)/fx_old < vepsilon),
        stop_outer = 1;
    end

    if k >= max_outer,
        if (verbosity > 0),
            fprintf('Maximum number of iterations (%d) is reached',k);
        end
        stop_outer = 1;
    end

    costs(k+1) = fx;
    
    if verb
        %%% Bark only when asked
        fprintf('[%0.4d] cost = %g - radius = %g\n',k,costs(k+1),Delta);
    end
end  % of TR loop (counter: k)

varargout{1} = x;
varargout{2} = fx;
varargout{3} = costs(1:k+1);
return;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% truncated CG %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [eta,inner_it,stop_tCG] = tCG(fun_set,x,grad,eta,Delta,theta,kappa,min_inner,max_inner,useRand,debug,fun_obj,param);
% tCG - Truncated (Steihaug-Toint) Conjugate-Gradient
% minimize <eta,grad> + .5*<eta,Hess(eta)>
% subject to <eta,eta> <= Delta^2

% all terms involving the trust-region radius will utilize an inner product
% w.r.t. the preconditioner; this is because the iterates grow in
% length w.r.t. the preconditioner, guaranteeing that we will not
% re-enter the trust-region
%
% the following recurrences for Prec-based norms and inner
% products come from CGT2000, pg. 205, first edition
% below, P is the preconditioner
%
% <eta_k,P*delta_k> = beta_k-1 * ( <eta_k-1,P*delta_k-1> + alpha_k-1 |delta_k-1|^2_P )
% |delta_k|^2_P = <r_k,z_k> + beta_k-1^2 |delta_k-1|^2_P
%
% therefore, we need to keep track of
% 1)   |delta_k|^2_P
% 2)   <eta_k,P*delta_k> = <eta_k,delta_k>_P
% 3)   |eta_k  |^2_P
%
% initial values are given by:
%    |delta_0|_P = <r,z>
%    |eta_0|_P   = 0
%    <eta_0,delta_0>_P = 0
% because we take eta_0 = 0


eta = 0*grad;
r = grad;
e_Pe = 0;

r_r = feval(fun_set,'metric',x,r,r); %fns.g(x,r,r);
norm_r = sqrt(r_r);
norm_r0 = norm_r;
z=r;
z_r = r_r;
d_Pd = z_r;

% initial search direction
delta  = -z;    
e_Pd = 0;

% pre-assume termination b/c j == end
stop_tCG = 5;

% begin inner/tCG loop
j = 0;
for j = 1:max_inner,
    Hxd = feval(fun_set,'hessian',x,delta,fun_obj,param); 
    
    % compute curvature
    d_Hd = feval(fun_set,'metric',x,delta,Hxd); 

    alpha = z_r/d_Hd;
    % <neweta,neweta>_P = <eta,eta>_P + 2*alpha*<eta,delta>_P + alpha*alpha*<delta,delta>_P
    e_Pe_new = e_Pe + 2.0*alpha*e_Pd + alpha*alpha*d_Pd;

    if d_Hd <= 0 || e_Pe_new >= Delta^2,
        % want
        %  ee = <eta,eta>_prec,x
        %  ed = <eta,delta>_prec,x
        %  dd = <delta,delta>_prec,x
        tau = (-e_Pd + sqrt(e_Pd*e_Pd + d_Pd*(Delta^2-e_Pe))) / d_Pd;
        eta = eta + tau*delta;
        if d_Hd <= 0,
            stop_tCG = 1;     % negative curvature
        else
            stop_tCG = 2;     % exceeded trust region
        end
        break;
    end

    % no negative curvature and eta_prop inside TR: accept it
    e_Pe = e_Pe_new;
    eta = eta + alpha*delta;

    % update the residual
    r = r + alpha*Hxd;
   
    % re-tangentalize r
    r = feval(fun_set,'project',x,r); 

    % compute new norm of r
    r_r = feval(fun_set,'metric',x,r,r); 
    norm_r = sqrt(r_r);

    % check kappa/theta stopping criterion
   if j >= min_inner && norm_r <= norm_r0*min(norm_r0^theta,kappa)       
        % residual is small enough to quit
        if kappa < norm_r0^theta,
            stop_tCG = 3;  % linear convergence
        else
            stop_tCG = 4;  % superlinear convergence
        end
        break;
    end

    % precondition the residual
    z=r;
    
    % save the old z'*r
    zold_rold = z_r;
    % compute new z'*r
    z_r = r_r;

    % compute new search direction
    beta = z_r/zold_rold;
    delta = -z + beta*delta;
    % update new P-norms and P-dots
    e_Pd = beta*(e_Pd + alpha*d_Pd);
    d_Pd = z_r + beta*beta*d_Pd;

end  % of tCG loop
inner_it = j;
return;

