module Modulator_Assemblage(out,Din,Mod,Freq,clk);
input Din;                              //Input Data stream
input [1:0]Freq,Mod;                    //Freq selects frequency range of output modulated wave, Mod selects type of modulation
input clk;
output [15:0] out;                      //output modulated signal


wire [5:0]clk_;
wire CLK;
wire [15:0] w1,w2,w3,w4;                //w1-BPSK Modulated Signal, w2-QPSK Modulated Signal, w3-FSK Modulated Signal, w4-ASK Modulated Signal   

counter CLK_divide(clk_,clk);                           //clk_[0]=clk/2 clk_[1]=clk/4 clk_[2]=clk/8  <= in terms of frequencies
mux_4w mux_1(CLK,clk,clk_[0],clk_[1],clk_[2],Freq);     //Selects clock of appropriate frequency based on input Freq 

FSK fsk(w1,Din,CLK);                    //FSK Modulator
ASK ask(w2,Din,CLK);                    //ASK Modulator
BPSK bpsk(w3,Din,CLK);                  //BPSK Modulator
QPSK qpsk(w4,Din,CLK,clk_[5]);          //QPSK Modulator


mux_16_4w mux_16_4w_1(out,w1,w2,w3,w4,Mod);         //Selects appropriate modulation based on input Mod

endmodule

module QPSK(out,Din,clk,pulse);             //QPSK Modulator
input Din,clk,pulse;                        //pulse varies in every 64ps
output [15:0]out;

wire [5:0]r;
reg [5:0]t;
reg [1:0]s;                     //stores 2-bit symbol
reg q1,q2;

initial
begin
    t=0;
end
always@(posedge clk)
begin
    t=t+1;
end
always@(negedge pulse)          //symbol is obtained on negative edge of pulse
begin
    s[1]=q2;
    s[0]=q1;
    if(s==2'b01)
        t=t+16;
    else if(s==2'b10)
        t=t+32;
    else if(s==2'b11)
        t=t+48;
end
always@(pulse)
begin
    if(pulse==0)                //pulse=0 value stored in q1
        q1=Din;
    else
        q2=Din;                  //pulse=1 value stored in q2
end
andgat and_1[5:0](r,6'b111111,t);
sine_wave_generator SWG_1(out,r);
endmodule

module ASK(out,Din,clk);                //ASK Modulator
input Din,clk;                          //Din=input data stream 
output [15:0] out;                      //Modulated signal

wire [15:0] wave,HA_wave;               //wave-normal amplitude sinusoidal wave, HA_wave-High amplitude sinusoidal wave
wire [5:0]t;                            //t - running variable(0->63) that selects appropriate sine value from sine wave generator

counter count_1(t,clk);                 //t counts 0->63 based on clk
sine_wave_generator SWG(wave,t);                        //wave=sine value corresponding to t
mult_16 mult_1(HA_wave,wave,16'b0000000000001010);      //HA_wave=10xwave
mux_16 mux_1(out,16'b00010011100010000,HA_wave,Din);                     //Din=1 => High amplitude , Din=0 => Zero amplitude 
endmodule

module FSK(out,Din,clk);                //FSK Modulator
input Din,clk;                          //Din=input data stream 
output [15:0] out;                      //Modulated signal

wire clk_b2,clk_b4,CLK;                 
wire [5:0]t;

T_FF tff_1(clk_b2,1'b1,clk);            //clk_b2=clk/2
T_FF tff_2(clk_b4,1'b1,clk_b2);         //clk_b4=clk_b2/2=clk/4

mux mux_1(CLK,clk_b4,clk,Din);          //Din=1 => CLK=clk , Din=0 => CLK=clk_b4
counter count_1(t,CLK);                 //t counts 0->63 based on CLK
sine_wave_generator SWG(out,t);         //out=sine value corresponding to t
endmodule

module BPSK(out,Din,clk);               //BPSK Modulator
input Din,clk;                          //Din=input data stream 
output [15:0] out;                      //Modulated signal

wire [15:0]wave,wave_Pi;                //wave_Pi=sinusoidal wave with a phase diff of Pi
wire [5:0]t;

counter count_1(t,clk);                 //t counts 0->63 based on CLK
sine_wave_generator SWG(wave,t);        //Generate sinusoidal wave in accordance to t
sine_wave_Pi_shift SWG_1(wave_Pi,t);    //Generate sinusoidal wave with a Pi phase diff
mux_16 mux_1(out,wave_Pi,wave,Din);     //Din=1 => phase diff=0  , Din=0 => phase diff=180 degreee
endmodule


module demux(o1,o2,i,s);            //1x2 DEMUX

input i,s;
output o1,o2;
wire x,s_,w1,w2,w3,w4;

not(s_,s);
and(w1,s_,i);
and(w2,s,i);
and(w3,s,x);
and(w4,s_,x);
or(o1,w1,w3);
or(o2,w2,w4);
endmodule

module mux(o,i1,i2,s);                  //2x1 MUX
input i1,i2,s;
output o;
wire x1,x2,sc;
not(sc,s);
and(x1,i1,sc);
and(x2,i2,s);
or(o,x1,x2);
endmodule

module mux_4w(o,i1,i2,i3,i4,s);         //4x1 MUX
input i1,i2,i3,i4;
input [1:0]s;
output o;
wire w1,w2;

mux mux_1(w1,i1,i2,s[0]);
mux mux_2(w2,i3,i4,s[0]);
mux mux_3(o,w1,w2,s[1]);
endmodule

module mux_16(o,i1,i2,s);           //2x1 MUX with 16-bit I/O
input [15:0]i1,i2;
input s;
output [15:0]o;
mux mux_1[15:0](o,i1,i2,s);
endmodule

module mux_16_4w(o,i1,i2,i3,i4,s);  //4x1 MUX with 16-bit I/O
input [15:0]i1,i2,i3,i4;
input [1:0]s;
output [15:0]o;
wire [15:0]w1,w2;

mux_16 mux_1(w1,i1,i2,s[0]);
mux_16 mux_2(w2,i3,i4,s[0]);
mux_16 mux_3(o,w1,w2,s[1]);
endmodule

module mux_16_8w(o,i1,i2,i3,i4,i5,i6,i7,i8,s);  //8x1 MUX with 16-bit I/O
input [15:0]i1,i2,i3,i4,i5,i6,i7,i8;
input [2:0]s;
output [15:0]o;
wire [15:0]x1,x2,x3,x4;
wire [15:0]y1,y2;

mux_16 mux_16_1(x1,i1,i2,s[0]);
mux_16 mux_16_2(x2,i3,i4,s[0]);
mux_16 mux_16_3(x3,i5,i6,s[0]);
mux_16 mux_16_4(x4,i7,i8,s[0]);

mux_16 mux_16_5(y1,x1,x2,s[1]);
mux_16 mux_16_6(y2,x3,x4,s[1]);

mux_16 mux_16_7(o,y1,y2,s[2]);

endmodule

/* 64x1 MUX with 16-bit I/O */

module mux_16_64w(o,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11,i12,i13,i14,i15,i16,i17,i18,i19,i20,i21,i22,i23,i24,i25,i26,i27,i28,i29,i30,i31,i32,i33,i34,i35,i36,i37,i38,i39,i40,i41,i42,i43,i44,i45,i46,i47,i48,i49,i50,i51,i52,i53,i54,i55,i56,i57,i58,i59,i60,i61,i62,i63,i64,s);
input [15:0]i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11,i12,i13,i14,i15,i16,i17,i18,i19,i20,i21,i22,i23,i24,i25,i26,i27,i28,i29,i30,i31,i32,i33,i34,i35,i36,i37,i38,i39,i40,i41,i42,i43,i44,i45,i46,i47,i48,i49,i50,i51,i52,i53,i54,i55,i56,i57,i58,i59,i60,i61,i62,i63,i64;
input [5:0]s;
output [15:0]o;
wire [15:0]x1,x2,x3,x4,x5,x6,x7,x8;

mux_16_8w mux_16_8w_1(x1,i1,i2,i3,i4,i5,i6,i7,i8,s[2:0]);
mux_16_8w mux_16_8w_2(x2,i9,i10,i11,i12,i13,i14,i15,i16,s[2:0]);
mux_16_8w mux_16_8w_3(x3,i17,i18,i19,i20,i21,i22,i23,i24,s[2:0]);
mux_16_8w mux_16_8w_4(x4,i25,i26,i27,i28,i29,i30,i31,i32,s[2:0]);
mux_16_8w mux_16_8w_5(x5,i33,i34,i35,i36,i37,i38,i39,i40,s[2:0]);
mux_16_8w mux_16_8w_6(x6,i41,i42,i43,i44,i45,i46,i47,i48,s[2:0]);
mux_16_8w mux_16_8w_7(x7,i49,i50,i51,i52,i53,i54,i55,i56,s[2:0]);
mux_16_8w mux_16_8w_8(x8,i57,i58,i59,i60,i61,i62,i63,i64,s[2:0]);

mux_16_8w mux_16_8w_9(o,x1,x2,x3,x4,x5,x6,x7,x8,s[5:3]);
endmodule


module T_FF(q,t,clk);           //T-FlipFlop
input t,clk;
output q;
reg q;
initial
begin
    q=0;
end
always @(posedge clk)
begin
    if(t==1)
        q=~q; 
end
endmodule

module counter(out,clk);            //counter that counts from 0 to 63 (6-bit)
input clk;
output [5:0]out;
wire [5:0]out_;
T_FF tff_1(out_[0],1'b1,clk);
T_FF tff_2(out_[1],1'b1,out_[0]);
T_FF tff_3(out_[2],1'b1,out_[1]);
T_FF tff_4(out_[3],1'b1,out_[2]);
T_FF tff_5(out_[4],1'b1,out_[3]);
T_FF tff_6(out_[5],1'b1,out_[4]);
not(out[0],out_[0]);
not(out[1],out_[1]);
not(out[2],out_[2]);
not(out[3],out_[3]);
not(out[4],out_[4]);
not(out[5],out_[5]);
endmodule

/*Sine Wave generator  SWG(o,t)=> o=1000*sin(t*360/64)+1000  */
module sine_wave_generator(o,t);
input [5:0]t;
output [15:0]o;
reg [15:0] i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11,i12,i13,i14,i15,i16,i17,i18,i19,i20,i21,i22,i23,i24,i25,i26,i27,i28,i29,i30,i31,i32,i33,i34,i35,i36,i37,i38,i39,i40,i41,i42,i43,i44,i45,i46,i47,i48,i49,i50,i51,i52,i53,i54,i55,i56,i57,i58,i59,i60,i61,i62,i63,i64;
mux_16_64w mux_1(o,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11,i12,i13,i14,i15,i16,i17,i18,i19,i20,i21,i22,i23,i24,i25,i26,i27,i28,i29,i30,i31,i32,i33,i34,i35,i36,i37,i38,i39,i40,i41,i42,i43,i44,i45,i46,i47,i48,i49,i50,i51,i52,i53,i54,i55,i56,i57,i58,i59,i60,i61,i62,i63,i64,t);
initial
begin
i1=1000;               //1000*sin(t*360/64)+1000 values recorded in order
i2=1098;
i3=1195;
i4=1290;
i5=1383;
i6=1471;
i7=1556;
i8=1634;
i9=1707;
i10=1773;
i11=1831;
i12=1882;
i13=1924;
i14=1957;
i15=1981;
i16=1995;
i17=2000;
i18=1995;
i19=1981;
i20=1957;
i21=1924;
i22=1882;
i23=1831;
i24=1773;
i25=1707;
i26=1634;
i27=1556;
i28=1471;
i29=1383;
i30=1290;
i31=1195;
i32=1098;
i33=1000;
i34=902;
i35=805;
i36=710;
i37=617;
i38=529;
i39=444;
i40=366;
i41=293;
i42=227;
i43=169;
i44=118;
i45=76;
i46=43;
i47=19;
i48=5;
i49=0;
i50=5;
i51=19;
i52=43;
i53=76;
i54=118;
i55=169;
i56=227;
i57=293;
i58=366;
i59=444;
i60=529;
i61=617;
i62=710;
i63=805;
i64=902;
end
endmodule

module sine_wave_Pi_shift(o,t);             //SWG generating sinusoidal wave with phase diff of Pi
input [5:0]t;
output [15:0]o;
wire [5:0]t_;
wire c;
adder_6b add_1(t_,c,t,6'b100000);           //t_=t+32
sine_wave_generator SWG(o,t_);
endmodule

module adder_6b(s,c,a,b);                   //6-bit Adder
input [5:0]a,b;                             //input 6-bit Nos
output [5:0]s;                              //6-bit sum
output c;
wire c1,c2,c3,c4,c5;
half_adder HA_1(s[0],c1,a[0],b[0]);
full_adder FA_1(s[1],c2,a[1],b[1],c1);
full_adder FA_2(s[2],c3,a[2],b[2],c2);
full_adder FA_3(s[3],c4,a[3],b[3],c3);
full_adder FA_4(s[4],c5,a[4],b[4],c4);
full_adder FA_5(s[5],c,a[5],b[5],c5);
endmodule

module half_adder(s,c,i1,i2);               //Half_Adder
input i1,i2;
output s,c;
xor(s,i1,i2);
and(c,i1,i2);
endmodule

module full_adder(s,c,i1,i2,cin);           //Full_Adder
input i1,i2,cin;
output s,c;
wire s1,c1,c2;
half_adder HF_1(s1,c1,i1,i2);
half_adder HF_2(s,c2,s1,cin);
or(c,c1,c2);
endmodule



/* Gate Level Multiplicator */

module mult_16(prod,a,b);
input [15:0]a,b;
output [15:0] prod;

wire [31:0]p;                       //Contains pruduct in 32bits

wire [31:0]w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15; //To store 16 product terms
wire [31:0]s0,s1,s2,s3,s4,s5,s6,s7;
wire [31:0]x0,x1,x2,x3;
wire [31:0]y0,y1;


andgat and_0[15:0](w0[31:16],16'b0,16'b0);          //setting initial 16 bits of w0,which are not required to zero

andgat and_1[14:0](w1[31:17],15'b0,15'b0);          //setting initial 15 bits and last 1 bit of w1,which are not required to zero
andgat and_1_1(w1[0],1'b0,1'b0);

andgat and_2[13:0](w2[31:18],14'b0,14'b0);          //setting initial 14 bits and last 2 bits of w2,which are not required to zero
andgat and_2_1[1:0](w2[1:0],2'b0,2'b0);

andgat and_3[12:0](w3[31:19],13'b0,13'b0);          //setting initial 13 bits and last 3 bits of w3,which are not required to zero
andgat and_3_1[2:0](w3[2:0],3'b0,3'b0);

andgat and_4[11:0](w4[31:20],12'b0,12'b0);          //setting initial 12 bits and last 4 bits of w4,which are not required to zero
andgat and_4_1[3:0](w4[3:0],4'b0,4'b0);

andgat and_5[10:0](w5[31:21],11'b0,11'b0);          //setting initial 11 bits and last 5 bits of w5,which are not required to zero
andgat and_5_1[4:0](w5[4:0],5'b0,5'b0);

andgat and_6[9:0](w6[31:22],10'b0,10'b0);           //setting initial 10 bits and last 6 bits of w6,which are not required to zero
andgat and_6_1[5:0](w6[5:0],6'b0,6'b0);

andgat and_7[8:0](w7[31:23],9'b0,9'b0);             //setting initial 9 bits and last 7 bits of w7,which are not required to zero
andgat and_7_1[6:0](w7[6:0],7'b0,7'b0);

andgat and_8[7:0](w8[31:24],8'b0,8'b0);             //setting initial 8 bits and last 8 bits of w8,which are not required to zero
andgat and_8_1[7:0](w8[7:0],8'b0,8'b0);

andgat and_9[6:0](w9[31:25],7'b0,7'b0);             //setting initial 7 bits and last 9 bits of w9,which are not required to zero
andgat and_9_1[8:0](w9[8:0],9'b0,9'b0);

andgat and_10[5:0](w10[31:26],6'b0,6'b0);           //setting initial 6 bits and last 10 bits of w10,which are not required to zero
andgat and_10_1[9:0](w10[9:0],10'b0,10'b0);

andgat and_11[4:0](w11[31:27],5'b0,5'b0);           //setting initial 5 bits and last 11 bits of w11,which are not required to zero
andgat and_11_1[10:0](w11[10:0],11'b0,11'b0);

andgat and_12[3:0](w12[31:28],4'b0,4'b0);           //setting initial 4 bits and last 12 bits of w12,which are not required to zero
andgat and_12_1[11:0](w12[11:0],12'b0,12'b0);

andgat and_13[2:0](w13[31:29],3'b0,3'b0);           //setting initial 3 bits and last 13 bits of w13,which are not required to zero
andgat and_13_1[12:0](w13[12:0],13'b0,13'b0);

andgat and_14[1:0](w14[31:30],2'b0,2'b0);           //setting initial 2 bits and last 14 bits of w14,which are not required to zero
andgat and_14_1[13:0](w14[13:0],14'b0,14'b0);

andgat and_15(w15[31],1'b0,1'b0);                   //setting initial 1 bit and last 15 bits of w15,which are not required to zero
andgat and_15_1[14:0](w15[14:0],15'b0,15'b0);


mux_16 mux_0(w0[15:0],16'b0,a,b[0]);                //a multiplied with each b[i] and product stored in corresponding wi's
mux_16 mux_1(w1[16:1],16'b0,a,b[1]);
mux_16 mux_2(w2[17:2],16'b0,a,b[2]);
mux_16 mux_3(w3[18:3],16'b0,a,b[3]);

mux_16 mux_4(w4[19:4],16'b0,a,b[4]);
mux_16 mux_5(w5[20:5],16'b0,a,b[5]);
mux_16 mux_6(w6[21:6],16'b0,a,b[6]);
mux_16 mux_7(w7[22:7],16'b0,a,b[7]);

mux_16 mux_8(w8[23:8],16'b0,a,b[8]);
mux_16 mux_9(w9[24:9],16'b0,a,b[9]);
mux_16 mux_10(w10[25:10],16'b0,a,b[10]);
mux_16 mux_11(w11[26:11],16'b0,a,b[11]);

mux_16 mux_12(w12[27:12],16'b0,a,b[12]);
mux_16 mux_13(w13[28:13],16'b0,a,b[13]);
mux_16 mux_14(w14[29:14],16'b0,a,b[14]);
mux_16 mux_15(w15[30:15],16'b0,a,b[15]);

adder_32b add_0(s0,w0,w1);                      //all wi's are added together  to obtain the product
adder_32b add_1(s1,w2,w3);
adder_32b add_2(s2,w4,w5);
adder_32b add_3(s3,w6,w7);
adder_32b add_4(s4,w8,w9);
adder_32b add_5(s5,w10,w11);
adder_32b add_6(s6,w12,w13);
adder_32b add_7(s7,w14,w15);

adder_32b add_8(x0,s0,s1);
adder_32b add_9(x1,s2,s3);
adder_32b add_10(x2,s4,s5);
adder_32b add_11(x3,s6,s7);

adder_32b add_12(y0,x0,x1);
adder_32b add_13(y1,x2,x3);

adder_32b add_14(p,y0,y1);

andgat and_32_to_16[15:0](prod,p[15:0],16'b1111111111111111);

endmodule


module adder_4b(s,c,i1,i2);                     //4-bit Adder
input [3:0]i1,i2;
output [3:0]s;
output c;
wire c1,c2,c3;
half_adder half_adder_1(s[0],c1,i1[0],i2[0]);
full_adder full_adder_1(s[1],c2,i1[1],i2[1],c1);
full_adder full_adder_2(s[2],c3,i1[2],i2[2],c2);
full_adder full_adder_3(s[3],c,i1[3],i2[3],c3);
endmodule

module full_adder_4b(s,c,i1,i2,cin);        //4-bit Adder with Carry in
input [3:0]i1,i2;
input cin;
output [3:0]s;
output c;
wire c1,c2,c3;
full_adder full_adder_1(s[0],c1,i1[0],i2[0],cin);
full_adder full_adder_2(s[1],c2,i1[1],i2[1],c1);
full_adder full_adder_3(s[2],c3,i1[2],i2[2],c2);
full_adder full_adder_4(s[3],c,i1[3],i2[3],c3);
endmodule

module adder_16b(s,c,i1,i2);                //16-bit Adder
input [15:0]i1,i2;
output [15:0]s;
output c;
wire c1,c2,c3;
adder_4b adder_4b_1(s[3:0],c1,i1[3:0],i2[3:0]);
full_adder_4b full_adder_4b_1(s[7:4],c2,i1[7:4],i2[7:4],c1);
full_adder_4b full_adder_4b_2(s[11:8],c3,i1[11:8],i2[11:8],c2);
full_adder_4b full_adder_4b_3(s[15:12],c,i1[15:12],i2[15:12],c3);
endmodule

module adder_32b(s,i1,i2);                  //32-bit Adder
input [31:0]i1,i2;
output [31:0]s;
wire c;
wire c1,c2,c3,c4,c5,c6,c7;
adder_4b adder_4b_1(s[3:0],c1,i1[3:0],i2[3:0]);
full_adder_4b full_adder_4b_1(s[7:4],c2,i1[7:4],i2[7:4],c1);
full_adder_4b full_adder_4b_2(s[11:8],c3,i1[11:8],i2[11:8],c2);
full_adder_4b full_adder_4b_3(s[15:12],c4,i1[15:12],i2[15:12],c3);

full_adder_4b full_adder_4b_4(s[19:16],c5,i1[19:16],i2[19:16],c4);
full_adder_4b full_adder_4b_5(s[23:20],c6,i1[23:20],i2[23:20],c5);
full_adder_4b full_adder_4b_6(s[27:24],c7,i1[27:24],i2[27:24],c6);
full_adder_4b full_adder_4b_7(s[31:28],c,i1[31:28],i2[31:28],c7);
endmodule

module andgat(o,a,b);                   //andgate using nand gate
input a,b;
output o;
wire x;
nand(x,a,b);
nand(o,x,x);
endmodule
