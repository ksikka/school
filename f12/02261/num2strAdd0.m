function str = num2strAdd0(k)
%Converts integer k into a string but...
%0 -> 00
%1 -> 01
%2 -> 02
%3 -> 03
%4 -> 04
%5 -> 05
%6 -> 06
%7 -> 07
%8 -> 08
%9 -> 09

if (k >= 0 && k <= 9)
    str = strcat('0',num2str(k));
else
    str = num2str(k);
end

end

