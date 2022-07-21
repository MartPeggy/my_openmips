//************************************************
//* @FilePath     : \my_OpenMIPS\LLbit_reg.v
//* @Date         : 2022-07-21 11:58:18
//* @LastEditTime : 2022-07-21 12:00:21
//* @Author       : mart
//* @Tips         : CA+I ͷע�� CA+P TB
//* @Description  : ����LLbit������SC��LLָ����
//************************************************

//^���     �ӿ���          ���    �������    ����
//^ 1		clk				1		in
//^ 2		rst				1		in
//^ 3		flush			1		in		�Ƿ����쳣����
//^ 4		LLbit_i			1		in		Ҫд��LLbit��ֵ
//^ 5		we				1		in		дʹ��
//^ 6		LLbit_o			1		out 	LLBit������ֵ

`include "defines.v"

module LLbit_reg(

           input wire clk,
           input wire rst,

           input wire flush,
           //д�˿�
           input wire LLbit_i,
           input wire we,

           //���˿�1
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
