module TB_Modulator_Assemblage;
reg Din;
reg [1:0]Freq,Mod;
reg clk;
wire [15:0] out;

Modulator_Assemblage Modulate(out,Din,Mod,Freq,clk);

initial
begin
$monitor("out=%d Din=%d Mod=%d Freq=%d clk=%b",out,Din,Mod,Freq,clk);
    clk=0;Din=0;
    Mod=2'b00;          //FSK
        Freq=2'b00;
            #512 Din=1;
            #512 Din=0;
        Freq=2'b01;
            #512 Din=1;
            #512 Din=0;
        Freq=2'b10;
            #512 Din=1;
            #512 Din=0;
        Freq=2'b11;
            #512 Din=1;
            #512 Din=0;
    Mod=2'b01;          //ASK
        Freq=2'b00;
            #512 Din=1;
            #512 Din=0;
        Freq=2'b01;
            #512 Din=1;
            #512 Din=0;
        Freq=2'b10;
            #512 Din=1;
            #512 Din=0;
        Freq=2'b11;
            #512 Din=1;
            #512 Din=0;

    Mod=2'b10;          //BPSK
        Freq=2'b00;
            #512 Din=1;
            #512 Din=0;
        Freq=2'b01;
            #512 Din=1;
            #512 Din=0;
        Freq=2'b10;
            #512 Din=1;
            #512 Din=0;
        Freq=2'b11;
            #512 Din=1;
            #512 Din=0;
    Mod=2'b11;          //QPSK
        Freq=2'b00;
            #64 Din=1;
            #64 Din=0;
            #512 Din=1;
            #512 Din=0;
            #64 Din=0;
            #64 Din=0;
            #64 Din=0;
            #64 Din=1;
            #64 Din=1;
            #64 Din=0;
            #64 Din=1;
            #64 Din=0;
        Freq=2'b01;
            #64 Din=1;
            #64 Din=0;
            #512 Din=1;
            #512 Din=0;
            #64 Din=0;
            #64 Din=0;
            #64 Din=0;
            #64 Din=1;
            #64 Din=1;
            #64 Din=0;
            #64 Din=1;
            #64 Din=0;
        Freq=2'b10;
            #64 Din=1;
            #64 Din=0;
            #512 Din=1;
            #512 Din=0;
            #64 Din=0;
            #64 Din=0;
            #64 Din=0;
            #64 Din=1;
            #64 Din=1;
            #64 Din=0;
            #64 Din=1;
            #64 Din=0;
        Freq=2'b11;
            #64 Din=1;
            #64 Din=0;
            #512 Din=1;
            #512 Din=0;
            #64 Din=0;
            #64 Din=0;
            #64 Din=0;
            #64 Din=1;
            #64 Din=1;
            #64 Din=0;
            #64 Din=1;
            #64 Din=0;
end
always
begin
    #1 clk=~clk;
end
endmodule

module TB_QPSK;
reg Din,clk,pulse;
wire [15:0] out;
QPSK qpsk_1(out,Din,clk,pulse);
initial
begin
$monitor("pulse=%b Din=%b out=%d",pulse,Din,out);
    clk=0;Din=0;pulse=0;
end
always
begin
    #4 clk=~clk;
end
always
begin
    #32 pulse=~pulse;
end
always
begin
    #32 Din=1;
    #32 Din=0;
    #32 Din=1;
    #128 Din=0;
    #32 Din=1;
    #32 Din=0;
    #64 Din=1;
    #96 Din=0;
end
endmodule

module TB_ASK;
reg Din,clk;
wire [15:0] out;
ASK ask_1(out,Din,clk);
initial
begin
$monitor("Din=%b out=%d",Din,out);
    clk=0;Din=0;
end
always
begin
    #1 clk=~clk;
end
always
begin
    #16 Din=~Din;
end
endmodule

module TB_FSK;
reg Din,clk;
wire [15:0] out;
FSK fsk_1(out,Din,clk);
initial
begin
$monitor("Din=%b out=%d",Din,out);
    clk=0;Din=0;
end
always
begin
    #1 clk=~clk;
end
always
begin
    #16 Din=~Din;
end
endmodule

module TB_BPSK;
reg Din,clk;
wire [15:0] out;
BPSK bpsk_1(out,Din,clk);
initial
begin
$monitor("Din=%b out=%d",Din,out);
    clk=0;Din=0;
end
always
begin
    #1 clk=~clk;
end
always
begin
    #16 Din=~Din;
end
endmodule


module TB_multiplier;
reg [15:0]a,b;
wire [31:0]p;

mult_16 mult_1(p,a,b);
initial
begin
$monitor("a=%d b=%d p=%d",a,b,p);
    #10 a=1423; b=3;
    #10 a=3; b=3;
    #10 a=23; b=3;
    #10 a=20001; b=3;
end
endmodule

module TB_wave;
reg clk;
wire [15:0]o;
wave_generator wave_1(o,clk);
initial
begin
    $monitor("o=%d",o);
    clk=0;
end
always
begin
    #1 clk=~clk;
end
endmodule

module TB_CWG;
reg [5:0]t;
wire [15:0]o;
cosine_wave_generator CWG(o,t);
integer i;
initial
begin
$monitor("o=%d",o);
    #5 t=0;
    for(i=0;i<64;i=i+1)
    begin
        #5 t=i;
    end
end
endmodule

module TB_SWG;
reg [5:0]t;
wire [15:0]o;
sine_wave_generator SWG(o,t);
integer i;
initial
begin
$monitor("o=%d",o);
    #5 t=0;
    for(i=0;i<64;i=i+1)
    begin
        #5 t=i;
    end
end
endmodule


module TB_counter;
reg clk;
wire [5:0]o;
counter count_1(o,clk);
initial
begin

    clk=0;
end
always
begin
    $monitor("o=%d",o);
    #2 clk=~clk;
end
endmodule

module TB_TFF;
reg t,clk;
wire q;
T_FF TFF_1(q,t,clk);
initial
begin
t=1;clk=0;
end
always
begin
    #2 clk=~clk;
end
endmodule

module TB_Adder;
reg [5:0]i1,i2;
wire [5:0]s;
wire c;
adder_6b Add_1(s,c,i1,i2);
initial
begin
    $monitor("i1=%d i2=%d  s=%d c=%b",i1,i2,s,c);
    #10 i1=0;i2=16;
    #10 i1=8;i2=12;
    #10 i1=60;i2=20;
    #10 i1=0;i2=16;
    #10 i1=1;i2=16;
    #10 i1=2;i2=16;
    #10 i1=3;i2=16;
    #10 i1=4;i2=16;
    #10 i1=5;i2=16;
    #10 i1=64;i2=16;
    #10 i1=63;i2=16;
end
endmodule

module TB_mux;
reg [31:0]i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11,i12,i13,i14,i15,i16,i17,i18,i19,i20,i21,i22,i23,i24,i25,i26,i27,i28,i29,i30,i31,i32,i33,i34,i35,i36,i37,i38,i39,i40,i41,i42,i43,i44,i45,i46,i47,i48,i49,i50,i51,i52,i53,i54,i55,i56,i57,i58,i59,i60,i61,i62,i63,i64;
reg [5:0]s;
wire [31:0]o;
mux_32_64w mux_32_64w_1(o,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11,i12,i13,i14,i15,i16,i17,i18,i19,i20,i21,i22,i23,i24,i25,i26,i27,i28,i29,i30,i31,i32,i33,i34,i35,i36,i37,i38,i39,i40,i41,i42,i43,i44,i45,i46,i47,i48,i49,i50,i51,i52,i53,i54,i55,i56,i57,i58,i59,i60,i61,i62,i63,i64,s);
integer i;
initial
begin
$monitor("s=%d o=%d",s,o);
    #1 i1=1;i2=2;i3=3;i4=4;i5=5;i6=6;i7=7;i8=8;
    i9=9;i10=10;i11=11;i12=12;i13=13;i14=14;i15=15;i16=16;
    i17=17;i18=18;i19=19;i20=20;i21=21;i22=22;i23=23;i24=24;
    i25=25;i26=26;i27=27;i28=28;i29=29;i30=30;i31=31;i32=32;
    i33=33;i34=34;i35=35;i36=36;i37=37;i38=38;i39=39;i40=40;
    i41=41;i42=42;i43=43;i44=44;i45=45;i46=46;i47=47;i48=48;
    i49=49;i50=50;i51=51;i52=52;i53=53;i54=54;i55=55;i56=56;
    i57=57;i58=58;i59=59;i60=60;i61=61;i62=62;i63=63;i64=64;        
    for(i=0;i<64;i=i+1)
    #10 s=i;
end
endmodule

module TB_demux;
reg i,s;
wire o1,o2;
demux DMX(o1,o2,i,s);
initial
begin
    s=0;
    i=1;
    #20 i=0;
    #20 s=1;
    i=1;
    #20 i=0;
end
endmodule