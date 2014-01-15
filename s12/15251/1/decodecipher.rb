#05
#XV UUUZ hGgKNY lWBMU Il'k ftINLq aaEWTTSfh IPCT oW gBQNE.
#Kg RGIY TZW PtaV SeaZtg HAUW mDc JAnW skmt DjSkC QP Ygmf AQHE SfR qZKNY ah IW cDSe WC ojc3c XcG RWDYabv.
#pG WadZ EZQBSTZN JG TZWft UQSl gT IPG NaYVI WP TZW TxZUT VSm DN VHW ZiCb CNV ZS LQNL TW hwMTE gXhtV NAlWf.
#XN aOm UOC'b HIfV VxU UEfV VxU CN WeOxT CT SVOBJNAfShpVFRWoRDbEMmVcIMFU

#VWQD dmQz, OQDkhStL, CNV jSBMOBWj...
#The art majors are crafty!



#k => s
#b => t

cipher = Hash.new
cipher['k'] = 's'
cipher['b'] = 't'


str = 'XV UUUZ hGgKNY lWBMU Il\'k ftINLq aaEWTTSfh IPCT oW gBQNE.
Kg RGIY TZW PtaV SeaZtg HAUW mDc JAnW skmt DjSkC QP Ygmf AQHE SfR qZKNY ah IW cDSe WC ojc3c XcG RWDYabv.
pG WadZ EZQBSTZN JG TZWft UQSl gT IPG NaYVI WP TZW TxZUT VSm DN VHW ZiCb CNV ZS LQNL TW hwMTE gXhtV NAlWf.
XN aOm UOC\'b HIfV VxU UEfV VxU CN WeOxT CT SVOBJNAfShpVFRWoRDbEMmVcIMFU

VWQD dmQz, OQDkhStL, CNV jSBMOBWj...'

#words = str.split(' ')
puts "Original: #{str}"
str.bytes.to_a.each do |b|
    b_str = b.chr.to_s
    b = cipher[b_str].bytes.to_a.first if cipher.has_key?(b_str)
end
puts "Decoded: #{str}"
