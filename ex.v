//************************************************
//* @FilePath     : \my_OpenMIPS\ex.v
//* @Date         : 2022-04-27 21:25:46
//* @LastEditTime : 2022-07-08 09:18:39
//* @Author       : mart
//* @Tips         : CA+I 头注释 CA+P TB
//* @Description  : 执行模块
//* @Description  : Execute(执行)
//************************************************

//^序号    接口名   宽度   输入输出      作用
//^ 1      rst      1       in      复位信号
//^ 2    alusel_i   3       in      执行阶段要执行的运算的类型
//^ 3    aluop_i    8       in      执行阶段要进行的运算的子类型
//^ 4    reg1_i     32      in      参与运算的源操作数1
//^ 5    reg2_i     32      in      参与运算的源操作数2
//^ 6    wd_i       5       in      指令执行要写入的寄存器地址
//^ 7    wreg_i     1       in      是否要写入寄存器
//^ 8    wd_o       5       out     执行阶段的指令最终要写入的目的寄存器的地址
//^ 9    wreg_o     1       out     执行阶段的指令最终是否要写入的目的寄存器
//^ 10   wdata_o    32      out     执行阶段的指令最终要写入的目的寄存器的值

`include "defines.v"
module ex (
           input wire rst,
           // 送到执行阶段的信息
           // 信息都来自于上一级的id_ex模块
           input wire [ `AluOpBus ] aluop_i,
           input wire [ `AluSelBus ] alusel_i,
           input wire [ `RegBus ] reg1_i,
           input wire [ `RegBus ] reg2_i,
           input wire [ `RegAddrBus ] wd_i,
           input wire wreg_i,

           // 执行的结果
           output reg [ `RegAddrBus ] wd_o,
           output reg wreg_o,
           output reg [ `RegBus ] wdata_o
       );
// 保存逻辑运算的结果
reg [ `RegBus ] logicout;
// 保存移位运算的结果
reg [ `RegBus ] shiftres;

// 判断aluop_i指示的运算子类型;逻辑运算
always @( * )
    begin
        if ( rst == `RstEnable )
            begin
                logicout <= `ZeroWord;
            end
        else
            begin
                case ( aluop_i )    // 判断子类型
                    `EXE_OR_OP:     // 子类型为 OR
                        begin
                            logicout <= reg1_i | reg2_i;
                        end

                    `EXE_AND_OP:
                        begin
                            logicout <= reg1_i & reg2_i;
                        end

                    `EXE_NOR_OP:
                        begin
                            logicout <= ~( reg1_i | reg2_i );
                        end

                    `EXE_XOR_OP:
                        begin
                            logicout <= reg1_i ^ reg2_i;
                        end

                    default :
                        begin
                            logicout <= `ZeroWord;
                        end

                endcase
            end
    end

always @( * )
    begin
        if ( rst == `RstEnable )
            begin
                shiftres <= `ZeroWord;
            end
        else
            begin
                case ( aluop_i )
                    `EXE_SLL_OP:
                        begin
                            shiftres <= reg2_i << reg1_i[ 4: 0 ];
                        end

                    `EXE_SRL_OP:
                        begin
                            shiftres <= reg2_i >> reg1_i[ 4: 0 ];
                        end

                    `EXE_SRA_OP:
                        begin
                            shiftres <= ( { 32{ reg2_i[ 31 ] } } << ( 6'd32 - { 1'b0, reg1_i[ 4: 0 ] } ) )
                            | reg2_i >> reg1_i[ 4: 0 ];
                        end

                    default:
                        begin
                            shiftres <= `ZeroWord;
                        end

                endcase
            end
    end

// 根据alusel_o 指示的运算类型，选择运算结果作为最终结果
// 目前仅有逻辑运算结果
always @( * )
    begin
        // 均直接来自于译码阶段，不需要更改
        wd_o <= wd_i;
        wreg_o <= wreg_i;

        case ( alusel_i )    // 判断类型
            `EXE_RES_LOGIC:
                begin
                    wdata_o <= logicout;
                end

            `EXE_RES_SHIFT:
                begin
                    wdata_o <= shiftres;
                end

            default :
                begin
                    wdata_o <= `ZeroWord;
                end

        endcase
    end

endmodule //ex
