//************************************************
//* @FilePath     : \my_OpenMIPS\LLbit_reg.v
//* @Date         : 2022-07-21 11:58:18
//* @LastEditTime : 2022-07-21 12:00:21
//* @Author       : mart
//* @Tips         : CA+I 头注释 CA+P TB
//* @Description  : 保存LLbit，用在SC、LL指令中
//************************************************

//^序号     接口名          宽度    输入输出    作用
//^ 1		clk				1		in
//^ 2		rst				1		in
//^ 3		flush			1		in		是否有异常发生
//^ 4		LLbit_i			1		in		要写到LLbit的值
//^ 5		we				1		in		写使能
//^ 6		LLbit_o			1		out 	LLBit读出的值

`include "defines.v"

module LLbit_reg(

           input wire clk,
           input wire rst,

           input wire flush,
           //写端口
           input wire LLbit_i,
           input wire we,

           //读端口1
           output reg LLbit_o

       );


always @ ( posedge clk )
    begin
        if ( rst == `RstEnable )
            begin
                LLbit_o <= 1'b0;
            end
        else if ( ( flush == 1'b1 ) )
            begin
                LLbit_o <= 1'b0;
            end
        else if ( ( we == `WriteEnable ) )
            begin
                LLbit_o <= LLbit_i;
            end
    end

endmodule
