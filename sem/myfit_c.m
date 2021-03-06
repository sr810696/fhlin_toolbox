function [f,SEM] = myfit_c(x, xfix, SEM, maximize)

% FORMAT [f,SEM] = myfit_c(x, xfix, SEM, maximize) 
% This function will be called over and over again by the optimisation routine
%_______________________________________________________________________
%
% Input Parameters:
%
% x        	- 1 x n vector of n free parameter Estimates
% xfix 		- 2 x n vector. xfix(1,:) = values
%		  		xfix(2,:) = parameter to fix
% SEM		- see spm_sem.m
%
% OUTPUT
% f        	- the function value to be optimised
% SEM		- updated array SEM
%
% Example : 	x    = [.6 .2 .8 .1 .5 .7]
%
%		ConX = [0 1 0;
%			0 0 0;
%			0 2 0];
%			
%		ConZ = [3 0 6;
%			0 4 0;
%			0 0 5];
%
% After substitution:
%		A    = [0 .6  0;
%			0  0  0;
%			0 .2  0];
%			
%		S    = [.8   0 .7;
%			 0  .1  0;
%			 0   0 .5];
%



% Implements SEM with ML Estimation
%-----------------------------------------------------------
% The implied covariance matrix is calculated according to
% Est = inv(I_A)*S*inv(I_A)';


totdf =  sum([SEM.df]);
allf  =  0;

x(find(x>1))  = 1;
x(find(x<-1)) = -1;

for k = 1:size(SEM,2)
 
 Obs  = SEM(k).Cov;
 ConX = SEM(k).ConX;
 ConZ = SEM(k).ConZ;
 df   = SEM(k).df;
 Fil  = SEM(k).Fil;

 %Combine free and fixed parameters in x
 %-------------------------------------- 
 for f=1:size(xfix,2)
  x(xfix(2,f)) = xfix(1,f);	%fill in fixed parameters
 end

 %Set up A
 %--------
 F           = find(ConX);
 A    	     = zeros(size(ConX));
 f           = x(ConX(F));
 A(F)        = f;
 %Set up S
 %--------
 F           = find(ConZ);
 S    	     = zeros(size(ConZ));
 f           = x(ConZ(F));
 S(F)        = abs(f);        % Do not allow neg covariances


 I = eye(size(ConZ));

 invI_A = inv(I-A);

 %Calculate implied covariance matrix
 %-----------------------------------
 Est = Fil*invI_A*S*invI_A'*Fil';

 Res = Obs - Est;
 %figure(5);
 %subplot(2,1,k);
 %colormap gray
 %imagesc(Res);
 
 p = size(Obs,1);

 %Objective function (ML)
 %-----------------------
 f    = log(det(Est))+trace(Obs*inv(Est))-log(det(Obs))-p;
 allf = allf + f*df/totdf;

 
 SEM(k).A   = A;
 SEM(k).S   = S;
 SEM(k).f   = f;
 SEM(k).Res = Res;
 SEM(k).Est = Est;

end % for k=1:...


% Maximize or minimize ?
%-----------------------
if maximize
 f = -allf;
else
 f = allf;
end














































 