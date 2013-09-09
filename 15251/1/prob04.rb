instructions = ['\{','\}','\varnothing','\leftarrow','\rightarrow', '\uparrow', '\downarrow', '\rhd']
N = Integer(STDIN.gets)
case N
    when 1
        instructions.each do |str|
            print(str) unless str.eql?(instructions[0]) || str.eql?(instructions[1])
        end
    when 2
        
end

