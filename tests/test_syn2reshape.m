% 1. Missing inputs
testCase = matlab.unittest.TestCase.forInteractiveUse;
[~] = verifyError(testCase,@() syn2reshape(),'MATLAB:minrhs');

% 2. Non-existing input variable
testCase = matlab.unittest.TestCase.forInteractiveUse;
[~] = verifyError(testCase,@() syn2reshape(img),'MATLAB:UndefinedFunction');

% 3. Wrong input values
img1 = 'stringNotImg';
testCase = matlab.unittest.TestCase.forInteractiveUse;
[~] = verifyError(testCase,@() syn2reshape(img1),'MATLAB:UndefinedFunction');