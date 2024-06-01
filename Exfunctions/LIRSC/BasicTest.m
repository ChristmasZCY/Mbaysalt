function BasicTest
image=imread('BasicTest.tif');
%Uncomment/comment folowing lines
LRout=LargestRectangle(image);
% LRout=LargestSquare(image);
% LCout=LargestCircle(image);