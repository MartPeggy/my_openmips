//************************************************
//* @FilePath     : \my_OpenMIPS\hilo_reg.v
//* @Date         : 2022-07-09 09:07:22
//* @LastEditTime : 2022-07-09 09:44:59
//* @Author       : mart
//* @Tips         : CA+I 头注释 CA+P TB
//* @Description  : HI、LO寄存器模块
//* @Description  : 在乘法、除法运算中起效果，保存高低位或商余数
//************************************************

//^序号    接口名   宽度   输入输出      作用
//^ 1      clk      1       in
//^ 2      rst      1       in
//^ 3      we       1       in      寄存器写使能
//^ 4    hi_i       32      in      写入hi寄存器的值
//^ 5    lo_i       32      in      写入lo寄存器的值
//^ 6    hi_o       32      in      hi寄存器输出的值
//^ 7    lo_o       32      in      lo寄存器输出的值

`include "defines.v"
module hilo_reg (
           input wire clk,
           input wire rst,

           input wire we,
           input wire [ `RegBus ] hi_i,
           input wire [ `RegBus ] lo_i,

           output reg [ `RegBus ] hi_o,
           output reg [ `RegBus ] lo_o
       );
always @( posedge clk )
    begin
        if ( rst == `RstEnable )
            begin
                hi_o <= `ZeroWord;
                lo_o <= `ZeroWord;
            end
        else if ( we == `WriteEnable )
            begin
                hi_o <= hi_i;
                lo_o <= lo_i;
            end

    end

endmodule //hilo_reg
