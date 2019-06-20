%1.missing inputs
testCase = matlab.unittest.TestCase.forInteractiveUse;
[~] = verifyError(testCase,@() im2reshape(),'MATLAB:minrhs');

%2.non-existing input variable
testCase = matlab.unittest.TestCase.forInteractiveUse;
[~] = verifyError(testCase,@() im2reshape(img),'MATLAB:UndefinedFunction');

% %3.wrong input values
% img='ss';
% % img(1,1,1)='1';
% testCase = matlab.unittest.TestCase.forInteractiveUse;
% [~] = verifyError(testCase,@() im2reshape(img),'MATLAB:UndefinedFunction');