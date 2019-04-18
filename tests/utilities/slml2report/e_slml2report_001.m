testpath = which('test_report');
testpath(1:end-38)

instances = { 'models/3D/lamp2.mat', 'models/3D/mit.mat', 'models/3D/tfr.mat', 'models/3D/nuc.mat' };
disp('Generating report using only protein parameters');
param = ml_initparam([],struct('includenuclear',false,'includecell',false,'includeprot',true));
slml2report(instances,param)
disp('Hit enter to test again with specified independent variable');
pause
indvar = [1:4];
label = 'Model num';
slml2report(instances,param,label,indvar)
disp('Hit enter to generate report for all parameters');
pause
param = ml_initparam([],struct('includenuclear',true,'includecell',true,'includeprot',true));
slml2report(instances,param)
