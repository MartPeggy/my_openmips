//************************************************
//* @FilePath     : \my_OpenMIPS\mem.v
//* @Date         : 2022-04-27 21:42:44
//* @LastEditTime : 2022-07-21 11:49:35
//* @Author       : mart
//* @Tips         : CA+I 头注释 CA+P TB
//* @Description  : 访存模块
//* @Description  : MEM：Memory(访存)
//************************************************

//^序号     接口名          宽度    输入输出    作用
//^ 1       rst             1       in
//^ 2       wd_i            5       in      访存阶段的指令要写入的目的寄存器地址
//^ 3       wreg_i          1       in      访存阶段的指令是否要写入目的寄存器
//^ 4       wdata_i         32      in      访存阶段的指令要写入目的寄存器的值
//^ 5       wd_o            5       out     访存阶段的指令最终要写入的目的寄存器地址
//^ 6       wreg_o          1       out     访存阶段的指令最终是否要写入目的寄存器
//^ 7       wdata_o         32      out     访存阶段的指令最终要写入目的寄存器的值
// & 增加接口如下
//^ 1       whilo_i         1       in      访存阶段的指令是否要写入HILO寄存器
//^ 2       hi_i            32      in      访存阶段的指令要写入HI寄存器的值
//^ 3       lo_i            32      in      访存阶段的指令要写入LO寄存器的值
//^ 4       whilo_o         1       out     访存阶段的指令最终是否要写入HILO寄存器
//^ 5       hi_o            32      out     访存阶段的指令最终要写入HI寄存器的值
//^ 6       lo_o            32      out     访存阶段的指令最终要写入LO寄存器的值
// & 增加加载存储指令接口如下
//^ 1       aluop_i         8       in      访存阶段的指令要进行的运算子类型
//^ 2       mem_addr_i      32      in      加载存储指令对应的地址
//^ 3       reg2_i          32      in      存储指令要存储的数据以及LWL LWR指令要写入的值
//^ 4       mem_data_i      32      in      从RAM读取的数据
//^ 5       mem_addr_o      32      out     要访问RAM的地址
//^ 6       mem_we_o        1       out     写操作使能，1为写
//^ 7       mem_sel_o       4       out     字节选择信号
//^ 8       mem_data_o      32      out     要写入RAM的值
//^ 9       mem_ce_o        1       out     RAM 使能信号
//& 增加LLbit寄存器的接口
//^ 1       LLbit_i         i       in      LLbit寄存器的值
//^ 2       wb_LLbit_we_i   1       in      回写阶段指令是否要写LLBit
//^ 3    wb_LLbit_value_i   1       in      回写阶段要写LLbit的值
//^ 4       LLbit_we_o      1       out     访存阶段指令是否要写LLBit
//^ 5       LLbit_value_o   1       out     访存阶段要写LLbit的值

`include "defines.v"

module mem(

           input wire rst,

           // 来自执行阶段的信息
           input wire [ `RegAddrBus ] wd_i,
           input wire wreg_i,
           input wire [ `RegBus ] wdata_i,
           input wire [ `RegBus ] hi_i,
           input wire [ `RegBus ] lo_i,
           input wire whilo_i,

           input wire [ `AluOpBus ] aluop_i,
           input wire [ `RegBus ] mem_addr_i,
           input wire [ `RegBus ] reg2_i,

           // 来自memory的信息
           input wire [ `RegBus ] mem_data_i,

           // LLbit_i是LLbit寄存器的值
           input wire LLbit_i,
           // 但不一定是最新值，回写阶段可能要写LLbit，所以还要进一步判断
           input wire wb_LLbit_we_i,
           input wire wb_LLbit_value_i,

           // 送到回写阶段的信息
           output reg [ `RegAddrBus ] wd_o,
           output reg wreg_o,
           output reg [ `RegBus ] wdata_o,
           output reg [ `RegBus ] hi_o,
           output reg [ `RegBus ] lo_o,
           output reg whilo_o,

           output reg LLbit_we_o,
           output reg LLbit_value_o,

           // 送到memory的信息
           output reg [ `RegBus ] mem_addr_o,
           output wire mem_we_o,
           output reg [ 3: 0 ] mem_sel_o,
           output reg [ `RegBus ] mem_data_o,
           output reg mem_ce_o

       );

// 保存LLBit的值
reg LLbit;
wire [ `RegBus ] zero32;
reg mem_we;

// 外部存储器RAM的读写信号
assign mem_we_o = mem_we ;
assign zero32 = `ZeroWord;

// 获取最新的LLbit的值
// 若回写阶段要写LLbit，则要写入的值就是最新值
always @ ( * )
    begin
        if ( rst == `RstEnable )
            begin
                LLbit <= 1'b0;
            end
        else
            begin
                if ( wb_LLbit_we_i == 1'b1 )
                    begin
                        LLbit <= wb_LLbit_value_i;
                    end
                else
                    begin
                        LLbit <= LLbit_i;
                    end
            end
    end

always @ ( * )
    begin
        if ( rst == `RstEnable )
            begin
                wd_o <= `NOPRegAddr;
                wreg_o <= `WriteDisable;
                wdata_o <= `ZeroWord;
                hi_o <= `ZeroWord;
                lo_o <= `ZeroWord;
                whilo_o <= `WriteDisable;
                mem_addr_o <= `ZeroWord;
                mem_we <= `WriteDisable;
                mem_sel_o <= 4'b0000;
                mem_data_o <= `ZeroWord;
                mem_ce_o <= `ChipDisable;
                LLbit_we_o <= 1'b0;
                LLbit_value_o <= 1'b0;
            end
        else
            begin
                wd_o <= wd_i;
                wreg_o <= wreg_i;
                wdata_o <= wdata_i;
                hi_o <= hi_i;
                lo_o <= lo_i;
                whilo_o <= whilo_i;
                mem_we <= `WriteDisable;
                mem_addr_o <= `ZeroWord;
                mem_sel_o <= 4'b1111;
                mem_ce_o <= `ChipDisable;
                LLbit_we_o <= 1'b0;
                LLbit_value_o <= 1'b0;

                case ( aluop_i )
                    // LB 指令即从指定地址处读取一个字节，wdata_o 即为地址
                    // LB/LBU/LH/LHU/LW 逻辑类似
                    `EXE_LB_OP:
                        begin
                            mem_addr_o <= mem_addr_i;
                            mem_we <= `WriteDisable;
                            mem_ce_o <= `ChipEnable;

                            // 通过地址的后两位判断是读取数据中的4位数据中的哪一个字节
                            // 地址末尾为 0x00,0x04,0x08,...,0x4n 时，二进制的最后两位为 00
                            // 末尾为0x01,0x05,0x09,...,0x4n+1 时，二进制的最后两位为 01
                            // 同理，4n+2 对应的二进制为 10，4n+3 对应的二进制为 11
                            // 00 对应的第4位 ； 01 对应的第3位 ；10 对应的第2位 ；11 对应的第1位
                            case ( mem_addr_i[ 1: 0 ] )
                                2'b00:
                                    begin
                                        wdata_o <= { { 24{ mem_data_i[ 31 ] } }, mem_data_i[ 31: 24 ] };
                                        mem_sel_o <= 4'b1000;
                                    end

                                2'b01:
                                    begin
                                        wdata_o <= { { 24{ mem_data_i[ 23 ] } }, mem_data_i[ 23: 16 ] };
                                        mem_sel_o <= 4'b0100;
                                    end

                                2'b10:
                                    begin
                                        wdata_o <= { { 24{ mem_data_i[ 15 ] } }, mem_data_i[ 15: 8 ] };
                                        mem_sel_o <= 4'b0010;
                                    end

                                2'b11:
                                    begin
                                        wdata_o <= { { 24{ mem_data_i[ 7 ] } }, mem_data_i[ 7: 0 ] };
                                        mem_sel_o <= 4'b0001;
                                    end

                                default:
                                    begin
                                        wdata_o <= `ZeroWord;
                                    end

                            endcase
                        end

                    `EXE_LBU_OP:
                        begin
                            mem_addr_o <= mem_addr_i;
                            mem_we <= `WriteDisable;
                            mem_ce_o <= `ChipEnable;

                            case ( mem_addr_i[ 1: 0 ] )
                                2'b00:
                                    begin
                                        wdata_o <= { { 24{ 1'b0 } }, mem_data_i[ 31: 24 ] };
                                        mem_sel_o <= 4'b1000;
                                    end

                                2'b01:
                                    begin
                                        wdata_o <= { { 24{ 1'b0 } }, mem_data_i[ 23: 16 ] };
                                        mem_sel_o <= 4'b0100;
                                    end

                                2'b10:
                                    begin
                                        wdata_o <= { { 24{ 1'b0 } }, mem_data_i[ 15: 8 ] };
                                        mem_sel_o <= 4'b0010;
                                    end

                                2'b11:
                                    begin
                                        wdata_o <= { { 24{ 1'b0 } }, mem_data_i[ 7: 0 ] };
                                        mem_sel_o <= 4'b0001;
                                    end

                                default:
                                    begin
                                        wdata_o <= `ZeroWord;
                                    end

                            endcase
                        end

                    `EXE_LH_OP:
                        begin
                            mem_addr_o <= mem_addr_i;
                            mem_we <= `WriteDisable;
                            mem_ce_o <= `ChipEnable;

                            case ( mem_addr_i[ 1: 0 ] )
                                2'b00:
                                    begin
                                        wdata_o <= { { 16{ mem_data_i[ 31 ] } }, mem_data_i[ 31: 16 ] };
                                        mem_sel_o <= 4'b1100;
                                    end

                                2'b10:
                                    begin
                                        wdata_o <= { { 16{ mem_data_i[ 15 ] } }, mem_data_i[ 15: 0 ] };
                                        mem_sel_o <= 4'b0011;
                                    end

                                default:
                                    begin
                                        wdata_o <= `ZeroWord;
                                    end

                            endcase
                        end

                    `EXE_LHU_OP:
                        begin
                            mem_addr_o <= mem_addr_i;
                            mem_we <= `WriteDisable;
                            mem_ce_o <= `ChipEnable;

                            case ( mem_addr_i[ 1: 0 ] )
                                2'b00:
                                    begin
                                        wdata_o <= { { 16{ 1'b0 } }, mem_data_i[ 31: 16 ] };
                                        mem_sel_o <= 4'b1100;
                                    end

                                2'b10:
                                    begin
                                        wdata_o <= { { 16{ 1'b0 } }, mem_data_i[ 15: 0 ] };
                                        mem_sel_o <= 4'b0011;
                                    end

                                default:
                                    begin
                                        wdata_o <= `ZeroWord;
                                    end

                            endcase
                        end

                    `EXE_LW_OP:
                        begin
                            mem_addr_o <= mem_addr_i;
                            mem_we <= `WriteDisable;
                            wdata_o <= mem_data_i;
                            mem_sel_o <= 4'b1111;
                            mem_ce_o <= `ChipEnable;
                        end

                    // LWL指令用于非对齐地址的读取
                    // LWL/LWR 指令逻辑类似
                    `EXE_LWL_OP:
                        begin
                            mem_addr_o <= { mem_addr_i[ 31: 2 ], 2'b00 };
                            mem_we <= `WriteDisable;
                            mem_sel_o <= 4'b1111;
                            mem_ce_o <= `ChipEnable;

                            // LWL指令要将从RAM读出的数据与reg2_i即rt寄存器的原始值拼接
                            // 对于对齐地址，即地址末尾为00时，直接用RAM读出的数据
                            // 对于非对齐地址，末尾为01时，将读出的前三位与原寄存器的最后一位拼接后再读出
                            // 10，11同理
                            case ( mem_addr_i[ 1: 0 ] )
                                2'b00:
                                    begin
                                        wdata_o <= mem_data_i[ 31: 0 ];
                                    end

                                2'b01:
                                    begin
                                        wdata_o <= { mem_data_i[ 23: 0 ], reg2_i[ 7: 0 ] };
                                    end

                                2'b10:
                                    begin
                                        wdata_o <= { mem_data_i[ 15: 0 ], reg2_i[ 15: 0 ] };
                                    end

                                2'b11:
                                    begin
                                        wdata_o <= { mem_data_i[ 7: 0 ], reg2_i[ 23: 0 ] };
                                    end

                                default:
                                    begin
                                        wdata_o <= `ZeroWord;
                                    end

                            endcase
                        end

                    `EXE_LWR_OP:
                        begin
                            mem_addr_o <= { mem_addr_i[ 31: 2 ], 2'b00 };
                            mem_we <= `WriteDisable;
                            mem_sel_o <= 4'b1111;
                            mem_ce_o <= `ChipEnable;

                            case ( mem_addr_i[ 1: 0 ] )
                                2'b00:
                                    begin
                                        wdata_o <= { reg2_i[ 31: 8 ], mem_data_i[ 31: 24 ] };
                                    end

                                2'b01:
                                    begin
                                        wdata_o <= { reg2_i[ 31: 16 ], mem_data_i[ 31: 16 ] };
                                    end

                                2'b10:
                                    begin
                                        wdata_o <= { reg2_i[ 31: 24 ], mem_data_i[ 31: 8 ] };
                                    end

                                2'b11:
                                    begin
                                        wdata_o <= mem_data_i;
                                    end

                                default:
                                    begin
                                        wdata_o <= `ZeroWord;
                                    end

                            endcase
                        end

                    `EXE_LL_OP:
                        begin
                            mem_addr_o <= mem_addr_i;
                            mem_we <= `WriteDisable;
                            wdata_o <= mem_data_i;
                            LLbit_we_o <= 1'b1;
                            LLbit_value_o <= 1'b1;
                            mem_sel_o <= 4'b1111;
                            mem_ce_o <= `ChipEnable;
                        end

                    // SB指令将一个字节写入RAM
                    // SB/SH/SW逻辑类似
                    `EXE_SB_OP:
                        begin
                            mem_addr_o <= mem_addr_i;
                            mem_we <= `WriteEnable;
                            mem_data_o <= { reg2_i[ 7: 0 ], reg2_i[ 7: 0 ], reg2_i[ 7: 0 ], reg2_i[ 7: 0 ] };
                            mem_ce_o <= `ChipEnable;

                            case ( mem_addr_i[ 1: 0 ] )
                                2'b00:
                                    begin
                                        mem_sel_o <= 4'b1000;
                                    end

                                2'b01:
                                    begin
                                        mem_sel_o <= 4'b0100;
                                    end

                                2'b10:
                                    begin
                                        mem_sel_o <= 4'b0010;
                                    end

                                2'b11:
                                    begin
                                        mem_sel_o <= 4'b0001;
                                    end

                                default:
                                    begin
                                        mem_sel_o <= 4'b0000;
                                    end

                            endcase
                        end

                    `EXE_SH_OP:
                        begin
                            mem_addr_o <= mem_addr_i;
                            mem_we <= `WriteEnable;
                            mem_data_o <= { reg2_i[ 15: 0 ], reg2_i[ 15: 0 ] };
                            mem_ce_o <= `ChipEnable;

                            case ( mem_addr_i[ 1: 0 ] )
                                2'b00:
                                    begin
                                        mem_sel_o <= 4'b1100;
                                    end

                                2'b10:
                                    begin
                                        mem_sel_o <= 4'b0011;
                                    end

                                default:
                                    begin
                                        mem_sel_o <= 4'b0000;
                                    end

                            endcase
                        end

                    `EXE_SW_OP:
                        begin
                            mem_addr_o <= mem_addr_i;
                            mem_we <= `WriteEnable;
                            mem_data_o <= reg2_i;
                            mem_sel_o <= 4'b1111;
                            mem_ce_o <= `ChipEnable;
                        end

                    // SWL指令用于非对齐地址的写入
                    // SWL/SWR 指令逻辑类似
                    `EXE_SWL_OP:
                        begin
                            mem_addr_o <= { mem_addr_i[ 31: 2 ], 2'b00 };
                            mem_we <= `WriteEnable;
                            mem_ce_o <= `ChipEnable;

                            case ( mem_addr_i[ 1: 0 ] )
                                2'b00:
                                    begin
                                        mem_sel_o <= 4'b1111;
                                        mem_data_o <= reg2_i;
                                    end

                                2'b01:
                                    begin
                                        mem_sel_o <= 4'b0111;
                                        mem_data_o <= { zero32[ 7: 0 ], reg2_i[ 31: 8 ] };
                                    end

                                2'b10:
                                    begin
                                        mem_sel_o <= 4'b0011;
                                        mem_data_o <= { zero32[ 15: 0 ], reg2_i[ 31: 16 ] };
                                    end

                                2'b11:
                                    begin
                                        mem_sel_o <= 4'b0001;
                                        mem_data_o <= { zero32[ 23: 0 ], reg2_i[ 31: 24 ] };
                                    end

                                default:
                                    begin
                                        mem_sel_o <= 4'b0000;
                                    end

                            endcase
                        end

                    `EXE_SWR_OP:
                        begin
                            mem_addr_o <= { mem_addr_i[ 31: 2 ], 2'b00 };
                            mem_we <= `WriteEnable;
                            mem_ce_o <= `ChipEnable;

                            case ( mem_addr_i[ 1: 0 ] )
                                2'b00:
                                    begin
                                        mem_sel_o <= 4'b1000;
                                        mem_data_o <= { reg2_i[ 7: 0 ], zero32[ 23: 0 ] };
                                    end

                                2'b01:
                                    begin
                                        mem_sel_o <= 4'b1100;
                                        mem_data_o <= { reg2_i[ 15: 0 ], zero32[ 15: 0 ] };
                                    end

                                2'b10:
                                    begin
                                        mem_sel_o <= 4'b1110;
                                        mem_data_o <= { reg2_i[ 23: 0 ], zero32[ 7: 0 ] };
                                    end

                                2'b11:
                                    begin
                                        mem_sel_o <= 4'b1111;
                                        mem_data_o <= reg2_i[ 31: 0 ];
                                    end

                                default:
                                    begin
                                        mem_sel_o <= 4'b0000;
                                    end

                            endcase
                        end

                    `EXE_SC_OP:
                        begin
                            if ( LLbit == 1'b1 )
                                begin
                                    LLbit_we_o <= 1'b1;
                                    LLbit_value_o <= 1'b0;
                                    mem_addr_o <= mem_addr_i;
                                    mem_we <= `WriteEnable;
                                    mem_data_o <= reg2_i;
                                    wdata_o <= 32'b1;
                                    mem_sel_o <= 4'b1111;
                                    mem_ce_o <= `ChipEnable;
                                end
                            else
                                begin
                                    wdata_o <= 32'b0;
                                end
                        end

                    default:
                        begin
                            //什么也不做
                        end

                endcase
            end    //if
    end      //always


endmodule
