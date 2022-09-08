#!/usr/bin/python3
import os
import argparse

def saveConfigFile(fileName, conf):

    with open(fileName, "w") as f:
        f_content = "Sregisterin_m2s_valid,registerin_m2s_last,registerin_m2s_data_address,registerin_m2s_data_value,registerin_m2s_data_clk\n"
        f_content+= "Sregisterin_m2s_valid,registerin_m2s_last,registerin_m2s_data_address,registerin_m2s_data_value,registerin_m2s_data_clk\n"
        f_content += "0,0,0,0,0\n"
        f_content += "0,0,0,0,0\n"
        f_content += "0,0,0,0,0\n"
        for x in conf:
            #print("-------")
            #print(x)
            #print("-------")
            f_content += str(x)

        f_content += "1,1,0,0,0\n"
       
        for _ in range(1003-len(f_content.split("\n"))):
            f_content += "0,0,0,0,0\n"

        
        #print(f_content)

        f.write(f_content)


class registerEntry:
    def __init__(self,addr, value, Offset = 0):
        self.addr = addr
        self.value = value 
        self.offset = Offset
            
        

    def __str__(self):
        if self.value is None:
            return ""
        #print(self.value, self.offset)
        #print(type(self.value).__name__)
        #print(type(self.offset).__name__)
        val = int(self.value)+ self.offset
        #print(val)
        val = val if val >0 else 0
        
        return "1,0,"+str(self.addr)+","+str(val)+",0\n"





def HV_DAC(ASIC_NR, ChannelNR , value):
    addr = 0xC0 << 8
    addr+= ASIC_NR <<4 
    addr+= ChannelNR
    ret = registerEntry(addr,value)
    return ret 
def read_file(fileName):
    with open(fileName) as f:
        return f.readlines()



def set_hv_dac(ASIC_NR, ChannelNR , value):
    reg = HV_DAC(ASIC_NR,ChannelNR,value)
    hv_asic = registerEntry(4002,ASIC_NR)
    hv_channel = registerEntry(4001,ChannelNR)
    #print(reg)
    saveConfigFile("reg.csv",[reg, hv_asic, hv_channel ])
    os.system("./run_on_hardware_csv.sh roling_register_tb_csv  reg.csv roling_register_tb_csv_out.csv  192.168.1.20 2001")
    os.system("./run_on_hardware_csv.sh roling_register_tb_csv  reg.csv roling_register_tb_csv_out.csv  192.168.1.20 2001")
    f = read_file("roling_register_tb_csv_out.csv")
    #print(f[100])
    line = f[100]
    sp = line.split(";")[14]
    #print(sp)
    ret = int(sp)
    return ret
    
def process_range(ASIC_NR, ChannelNR,values,FileName ="iv_ip_1.csv" ):
    with open(FileName ,"w") as f:
        line = "ASIC_NR; ChannelNR; Voltage; current\n"
        f.write(line)
        for a in ASIC_NR:
            for c in ChannelNR:
                for v in values:
                    r = set_hv_dac(a,c,v)
                    line = str(a) +"; " + str(c) +"; "+ str(v) +"; " + str(r) +"\n"
                    print(line)
                    f.write(line)

def to_range(str_range):
    sp = str_range.split(":")
    if len(sp) == 1:
        return [int(sp[0])]
    if len(sp) == 2:
        return range( int(sp[0] ), int(sp[1]) )
    if len(sp) == 3:
        return range( int(sp[0] ) , int(sp[2]) , int(sp[1]))
    raise Exception("wrong number of parameters")

def main():

    parser = argparse.ArgumentParser(description='Creates Test benches for a given entity')
    parser.add_argument('--asic_nr', help='asic number starting from 0',default="0")
    parser.add_argument('--ChannelNR', help='Channel number starting from 0',default="0")
    parser.add_argument('--values', help='HV Trim DAC Values\n example:\n0:10  = from 0 to 10 \n0:5:100 = from 0 to 100 step 5',default="0:10")
    args = parser.parse_args()

    ASIC_NR = to_range(args.asic_nr)
    Channel = to_range(args.ChannelNR)
    values = to_range(args.values)
    process_range(ASIC_NR,Channel,values)
    
        




    


main()