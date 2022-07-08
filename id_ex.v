//************************************************
//* @FilePath     : \my_OpenMIPS\id_ex.v
//* @Date         : 2022-04-27 21:20:29
//* @LastEditTime : 2022-07-05 13:37:24
//* @Author       : mart
//* @Tips         : CA+I 头注释 CA+P TB
//* @Description  : 将译码阶段译出的指令信息传递到执行模块
//* @Description  : EX：execute 执行
//************************************************

//^ 序号   接口名   宽度   输入输出 
//^ 1       rst     1       in      
//^ 2       clk     1       in
//^ 3   id_alusel   3       in      
//^ 4   id_aluop    8       in
//^ 5   id_reg1     32      in
//^ 6   id_reg2     32      in
//^ 7   id_wd       5       in
//^ 8   id_wreg     1       im
//^ 9   ex_alusel   3       out
//^ 10  ex_aluop    8       out
//^ 11  ex_reg1     32      out
//^ 12  ex_reg2     32      out
//^ 13  ex_wd       5       out
//^ 14  ex_wreg     1       out


`include "defines.v"
module id_ex (
           input wire clk,
           input wire rst,

           //从译码阶段传递的信息
           input wire [ `AluOpBus   ] id_aluop,
           input wire [ `AluSelBus  ] id_alusel,
           input wire [ `RegBus     ] id_reg1,
           input wire [ `RegBus     ] id_reg2,
           input wire [ `RegAddrBus ] id_wd,
           input wire                 id_wreg,

           //传递到执行阶段的信息
           output reg [ `AluOpBus   ] ex_aluop,
           output reg [ `AluSelBus  ] ex_alusel,
           output reg [ `RegBus     ] ex_reg1,
           output reg [ `RegBus     ] ex_reg2,
           output reg [ `RegAddrBus ] ex_wd,
           output reg                 ex_wreg
       );

always @ ( posedge clk )
    begin
        if ( rst == `RstEnable )
            begin
                ex_aluop  <= `EXE_NOP_OP;
                ex_alusel <= `EXE_RES_NOP;
                ex_reg1   <= `ZeroWord;
                ex_reg2   <= `ZeroWord;
                ex_wd     <= 4'b0000;
                ex_wreg   <= `WriteDisable;
            end
        else
            begin
                ex_aluop  <= id_aluop;
                ex_alusel <= id_alusel;
                ex_reg1   <= id_reg1;
                ex_reg2   <= id_reg2;
                ex_wd     <= id_wd;
                ex_wreg   <= id_wreg;
            end
    end
endmodule //id_ex
