//************************************************
//* @FilePath     : \my_OpenMIPS\ex.v
//* @Date         : 2022-04-27 21:25:46
//* @LastEditTime : 2022-07-09 10:17:42
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

// & 增加接口如下

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
           output reg [ `RegBus ] wdata_o,

           // HILO模块
           input wire [ `RegBus ] hi_i,
           input wire [ `RegBus ] lo_i,

           // 回写阶段指令是否要写HI，LO
           input wire [ `RegBus ] wb_hi_i,
           input wire [ `RegBus ] wb_lo_i,
           input wire wb_whilo_i,

           // 访存阶段指令是否要写HI，LO
           input wire [ `RegBus ] mem_hi_i,
           input wire [ `RegBus ] mem_lo_i,
           input wire mem_whilo_i,

           // 执行阶段指令对HI，LO的写操作请求
           output reg [ `RegBus ] hi_o,
           output reg [ `RegBus ] lo_o,
           output reg whilo_o
       );

// 保存逻辑运算的结果
reg [ `RegBus ] logicout;
// 保存移位运算的结果
reg [ `RegBus ] shiftres;
// 保存移动操作的结果
reg [ `RegBus ] moveres;
// 保存HI，LO寄存器的值
reg [ `RegBus ] HI;
reg [ `RegBus ] LO;

// 解决数据相关性问题：HI，LO寄存器
always @( * )
    begin
        if ( rst == `RstEnable )
            begin
                { HI, LO } <= { `ZeroWord, `ZeroWord };
            end
        else if ( mem_whilo_i == `WriteEnable )     //  访存阶段的指令要写HI，LO寄存器
            begin
                { HI, LO } <= { mem_hi_i, mem_lo_i };
            end
        else if ( wb_whilo_i == `WriteEnable )      //  回写阶段的指令要写HI，LO寄存器
            begin
                { HI, LO } <= { wb_hi_i, wb_lo_i };
            end
        else
            begin
                { HI, LO } <= { hi_i, lo_i };
            end
    end

always @( * )
    begin
        if ( rst == `RstEnable )
            begin
                moveres <= `ZeroWord;
            end
        else
            begin
                moveres <= `ZeroWord;

                case ( aluop_i )
                    `EXE_MFHI_OP:
                        begin
                            moveres <= HI;
                        end

                    `EXE_MFLO_OP:
                        begin
                            moveres <= LO;
                        end

                    `EXE_MOVZ_OP:
                        begin
                            moveres <= reg1_i;
                        end

                    `EXE_MOVN_OP:
                        begin
                            moveres <= reg1_i;
                        end

                endcase
            end
    end


// 判断aluop_i指示的运算子类型;逻辑运算
always @( * )
    begin
        if ( rst == `RstEnable )
            begin
                logicout <= `ZeroWord;
            end
        else
            begin
                case ( aluop_i )             // 判断子类型
                    `EXE_OR_OP:              // 子类型为 OR
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

        case ( alusel_i )             // 判断类型
            `EXE_RES_LOGIC:
                begin
                    wdata_o <= logicout;
                end

            `EXE_RES_SHIFT:
                begin
                    wdata_o <= shiftres;
                end

            `EXE_RES_MOVE:
                begin
                    wdata_o <= moveres;
                end

            default :
                begin
                    wdata_o <= `ZeroWord;
                end

        endcase
    end

always @ ( * )
    begin
        if ( rst == `RstEnable )
            begin
                whilo_o <= `WriteDisable;
                hi_o <= `ZeroWord;
                lo_o <= `ZeroWord;
            end
        else if ( aluop_i == `EXE_MTHI_OP )
            begin
                whilo_o <= `WriteEnable;
                hi_o <= reg1_i;
                lo_o <= LO;
            end
        else if ( aluop_i == `EXE_MTLO_OP )
            begin
                whilo_o <= `WriteEnable;
                hi_o <= HI;
                lo_o <= reg1_i;
            end
        else
            begin
                whilo_o <= `WriteDisable;
                hi_o <= `ZeroWord;
                lo_o <= `ZeroWord;
            end
    end

endmodule //ex
