classdef test_ometiff2tile < matlab.unittest.TestCase
    %TEST_OMETIFF2TILE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Test)
        function test_2d_image( testCase )
            disp('Given a 2D ometiff: Verify that the dimensions of the output tile image is as expected')
            directory = pwd;
            ans = demo2D00();            
            filename = './imgs/cell1/cell1.ome.tif';
            ans = ometiff2tile(filename);
            testCase.verifyEqual( size(ans), [5394, 513] );
            delete('./log');
            delete('./imgs');
        end
        
        function test_3d_image( testCase )
            disp('Given a 3D ometiff: Verify that the dimensions of the output tile image is as expected')
            directory = pwd;
            ans = demo3D00();            
            filename = './img/cell1/cell1.ome.tif';
            ans = ometiff2tile(filename);
            testCase.verifyEqual( size(ans), [1470, 5876] );
            delete('./log');
            delete('./img');
        end
    end
    
end

