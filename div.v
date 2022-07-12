//************************************************
//* @FilePath     : \my_OpenMIPS\div.v
//* @Date         : 2022-07-12 14:29:12
//* @LastEditTime : 2022-07-12 16:26:54
//* @Author       : mart
//* @Tips         : CA+I 头注释 CA+P TB
//* @Description  : 除法模块
//************************************************

//^序号     接口名          宽度    输入输出    作用
//^ 1       clk             1       in
//^ 2       rst             1       in
//^ 3       signed_div_i    1       in      是否为有符号除法
//^ 4       opdata1_i       32      in      被除数
//^ 5       opdata2_i       32      in      除数
//^ 6       start_i         1       in      是否开始运算
//^ 7       annul_i         1       in      是否取消除法运算，1取消
//^ 8       result_o        64      out     运算结果
//^ 9       ready_o         1       out     运算结束标志

`include "defines.v"
module div (
           input wire clk,
           input wire rst,

           input wire signed_div_i ,
           input wire [ 31: 0 ] opdata1_i,
           input wire [ 31: 0 ] opdata2_i,
           input wire start_i,
           input wire annul_i,

           output reg [ 63: 0 ] result_o,
           output reg ready_o
       );

wire [ 32: 0 ] div_temp;
// 记录试商法进行的轮数
reg [ 5: 0 ] cnt;
// 记录除法过程中的数据
reg [ 64: 0 ] dividend;
// 状态机变量
reg [ 1: 0 ] state;
reg [ 31: 0 ] divisor;
reg [ 31: 0 ] temp_op1;
reg [ 31: 0 ] temp_op2;

assign div_temp = { 1'b0, dividend[ 63: 32 ] } - { 1'b0, divisor };

always @( posedge clk )
    begin
        if ( rst == `RstEnable )
            begin
                state <= `DivFree;
                ready_o <= `DivResultNotReady;
                result_o <= { `ZeroWord, `ZeroWord };
            end
        else
            begin
                // 状态机
                case ( state )
                    /*
                    state==`DivFree：
                      a) 处于 divstart 且 不取消除法运算
                        a1) 除数为0，进入 `DivByZero 状态
                        a2) 除数不为0，进入`DivOn 状态，判断是否需要取补码
                      b) 取消除法运算，变量赋0                
                    */
                    `DivFree:
                        begin
                            if ( start_i == `DivStart && annul_i == 1'b0 )
                                begin
                                    if ( opdata2_i == `ZeroWord )
                                        begin
                                            state <= `DivByZero;
                                        end
                                    else
                                        begin
                                            state <= `DivOn;
                                            cnt <= 6'b000000;

                                            if ( signed_div_i == 1'b1 && opdata1_i[ 31 ] == 1'b1 )
                                                begin
                                                    temp_op1 = ~opdata1_i + 1;
                                                end
                                            else
                                                begin
                                                    temp_op1 = opdata1_i;
                                                end

                                            if ( signed_div_i == 1'b1 && opdata2_i[ 31 ] == 1'b1 )
                                                begin
                                                    temp_op2 = ~opdata2_i + 1;
                                                end
                                            else
                                                begin
                                                    temp_op2 = opdata2_i;
                                                end

                                            dividend <= { `ZeroWord, `ZeroWord };
                                            dividend[ 32: 1 ] <= temp_op1;
                                            divisor <= temp_op2;
                                        end

                                end
                            else
                                begin
                                    ready_o <= `DivResultNotReady;
                                    result_o <= { `ZeroWord, `ZeroWord };
                                end
                        end

                    /*
                    state==`DivByZero：
                        赋0值，结束运算
                    */
                    `DivByZero:
                        begin
                            dividend <= { `ZeroWord, `ZeroWord };
                            state <= `DivEnd;
                        end

                    /*
                    state==`DivOn:
                        a) 取消除法运算，变量赋0
                            a1) 除法次数不为32，继续执行试商法
                                a11) 执行结果为负数，此次迭代结果为0
                                a12) 执行结果不为负，此次迭代结果为1
                            a2) 除法次数为32，试商法结束
                                a21) 有符号整数除法 且 一正一负，结果取补码

                    */
                    `DivOn:
                        begin
                            if ( annul_i == 1'b0 )
                                begin
                                    if ( cnt != 6'b100000 )
                                        begin
                                            if ( div_temp[ 32 ] == 1'b1 )
                                                begin
                                                    dividend <= { dividend[ 63: 0 ] , 1'b0 };
                                                end
                                            else
                                                begin
                                                    dividend <= { div_temp[ 31: 0 ] , dividend[ 31: 0 ] , 1'b1 };
                                                end

                                            cnt <= cnt + 1;
                                        end
                                    else
                                        begin
                                            if ( ( signed_div_i == 1'b1 ) && ( ( opdata1_i[ 31 ] ^ opdata2_i[ 31 ] ) == 1'b1 ) )
                                                begin
                                                    dividend[ 31: 0 ] <= ( ~dividend[ 31: 0 ] + 1 );
                                                end

                                            if ( ( signed_div_i == 1'b1 ) && ( ( opdata1_i[ 31 ] ^ dividend[ 64 ] ) == 1'b1 ) )
                                                begin
                                                    dividend[ 64: 33 ] <= ( ~dividend[ 64: 33 ] + 1 );
                                                end

                                            state <= `DivEnd;
                                            cnt <= 6'b000000;
                                        end
                                end
                            else
                                begin
                                    state <= `DivFree;
                                end
                        end

                    /*
                    state==`DivEnd:
                    输出运算结果，高32位存储余数，低32位存储商，当ex模块送来DivStop信号，返回DivFree状态
                    */
                    `DivEnd:
                        begin
                            result_o <= { dividend[ 64: 33 ], dividend[ 31: 0 ] };
                            ready_o <= `DivResultReady;

                            if ( start_i == `DivStop )
                                begin
                                    state <= `DivFree;
                                    ready_o <= `DivResultNotReady;
                                    result_o <= { `ZeroWord, `ZeroWord };
                                end
                        end

                endcase
            end
    end

endmodule //div
