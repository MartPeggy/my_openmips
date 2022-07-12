//************************************************
//* @FilePath     : \my_OpenMIPS\id.v
//* @Date         : 2022-04-24 14:06:57
//* @LastEditTime : 2022-07-12 15:38:04
//* @Author       : mart
//* @Tips         : CA+I 头注释 CA+P TB
//* @Description  : 对指令进行译码，得到最终运算的类型和操作数
//* @Description  : ID:Instruction Decoder(指令译码)
//************************************************

//^序号     接口名          宽度    输入输出    作用
//^ 1       rst             1       in      复位信号
//^ 2       pc_i            32      in      译码阶段的指令对应的地址
//^ 3       inst_i          32      in      译码阶段的指令
//^ 4       reg1_data_i     32      in      从regfile第一个读端口读出的信号
//^ 5       reg2_data_i     32      in      从regfile第二个读端口读出的信号
//^ 6       reg1_read_o     1       out     regfile第一个读端口的使能
//^ 7       reg2_read_o     1       out     regfile第二个读端口的使能
//^ 8       reg1_addr_o     5       out     regfile第一个读端口的地址信号
//^ 9       reg2_addr_o     5       out     regfile第二个读端口的地址信号
//^ 10      aluop_o         8       out     译码阶段的指令要进行的运算的子类型
//^ 11      alusel_o        3       out     译码阶段的指令要进行的运算的类型
//^ 12      reg1_o          32      out     译码阶段的指令要进行的运算的源操作数1
//^ 13      reg2_o          32      out     译码阶段的指令要进行的运算的源操作数2
//^ 14      wd_o            5       out     译码阶段的指令要写入的目的寄存器地址
//^ 15      wreg_o          1       out     译码阶段的指令是否有要写入的目的寄存器
//& 为解决数据相关问题，增加以下接口
//^ 1       ex_wreg_i       1       in      处于执行阶段的指令是否要写目的寄存器
//^ 2       ex_wd_i         5       in      处于执行阶段的指令要写目的寄存器地址
//^ 3       ex_wdata_i      32      in      处于执行阶段的指令要写入目的寄存器的数据
//^ 4       mem_wreg_i      1       in      处于访存阶段的指令是否要写目的寄存器
//^ 5       mem_wd_i        5       in      处于访存阶段的指令要写目的寄存器地址
//^ 6       mem_wdata_i     32      in      处于访存阶段的指令要写入目的寄存器的数据
//& 增加流水线暂停信号
//^ 1       stall           1       out

// ALU: Arithmetic and Logic Unit 网络算术逻辑单元
// ALUOP: ALU operation ALU操作数
// ALUSEL: ALU selector ALU选择器

`include "defines.v"
module id (
           input wire rst,
           input wire [ `InstAddrBus ] pc_i,
           input wire [ `InstBus ] inst_i,

           input wire [ `RegBus ] reg1_data_i,              // 从reg1中读出的输出
           input wire [ `RegBus ] reg2_data_i,              // 从reg2中读出的输出

           output reg reg1_read_o,                          // 输出到reg1读使能信号
           output reg reg2_read_o,                          // 输出到reg2读使能信号
           output reg [ `RegAddrBus ] reg1_addr_o ,         // reg1中的读地址信号
           output reg [ `RegAddrBus ] reg2_addr_o,          // reg2中的读地址信号

           output reg [ `AluOpBus ] aluop_o,
           output reg [ `AluSelBus ] alusel_o,
           output reg [ `RegBus ] reg1_o,
           output reg [ `RegBus ] reg2_o,
           output reg [ `RegAddrBus ] wd_o,
           output reg wreg_o,

           input wire ex_wreg_i ,                    // 处于执行阶段的指令的运算结果
           input wire [ `RegBus ] ex_wdata_i,
           input wire [ `RegAddrBus ] ex_wd_i,

           input wire mem_wreg_i,                    // 处于访存阶段的指令的运算结果
           input wire [ `RegBus ] mem_wdata_i,
           input wire [ `RegAddrBus ] mem_wd_i,

           output wire stallreg
       );

// 取得指令的指令码，功能码
wire [ 5: 0 ] op = inst_i[ 31: 26 ];
wire [ 4: 0 ] op2 = inst_i[ 10: 6 ];
wire [ 5: 0 ] op3 = inst_i[ 5: 0 ];
wire [ 4: 0 ] op4 = inst_i[ 20: 16 ];

// 取得指令所需要的立即数
reg [ `RegBus ] imm;

// 指示指令是否有效
reg instvalid;

// 流水线暂停信号设定为Nostop
assign stallreq = `NoStop;

//********对指令译码*********//
always @( * )
    begin
        if ( rst == `RstEnable )                     //初始化各个连线，该置零的置零
            begin
                aluop_o <= `EXE_NOP_OP;       // 运算类型设置为None
                alusel_o <= `EXE_RES_NOP;      // 运算类型设置为None
                wd_o <= 4'b0;
                wreg_o <= `WriteDisable;     // 不写入寄存器
                reg1_read_o <= 1'b0;              // 读使能关闭
                reg2_read_o <= 1'b0;
                reg1_addr_o <= 4'b0;              // 读地址指令
                reg2_addr_o <= 4'b0;
                imm <= `ZeroWord;         // 立即数置零
            end
        else
            begin   // 非复位状态，默认信号
                aluop_o <= `EXE_NOP_OP;
                alusel_o <= `EXE_RES_NOP;
                wd_o <= inst_i[ 15: 11 ];  // 要写入的寄存器
                wreg_o <= `WriteDisable;     // 关闭写使能
                instvalid <= `InstInvalid;      // 设置指令无效
                reg1_read_o <= 1'b0;              // 关闭读使能
                reg2_read_o <= 1'b0;              // 关闭读使能
                reg1_addr_o <= inst_i[ 25: 21 ];  // Regfile读端口1读取寄存器地址
                reg2_addr_o <= inst_i[ 20: 16 ];  // Regfile读端口2读取寄存器地址
                imm <= `ZeroWord;

                // 利用case判断指令类型
                case ( op )                 // op:inst[31-26]
                    `EXE_SPECIAL_INST:
                        begin
                            case ( op2 )                   // op2:inst[10-6]
                                5'b00000:
                                    case ( op3 )                   // op3:inst[5-0]
                                        `EXE_OR:                   // 6'b100101
                                            begin
                                                wreg_o <= `WriteEnable;
                                                aluop_o <= `EXE_OR_OP;
                                                alusel_o <= `EXE_RES_LOGIC;
                                                reg1_read_o <= 1'b1;
                                                reg2_read_o <= 1'b1;
                                                instvalid <= `InstValid;
                                            end

                                        `EXE_XOR:                   // 6'b100110
                                            begin
                                                wreg_o <= `WriteEnable;
                                                aluop_o <= `EXE_XOR_OP;
                                                alusel_o <= `EXE_RES_LOGIC;
                                                reg1_read_o <= 1'b1;
                                                reg2_read_o <= 1'b1;
                                                instvalid <= `InstValid;
                                            end

                                        `EXE_NOR:                   // 6'b100111
                                            begin
                                                wreg_o <= `WriteEnable;
                                                aluop_o <= `EXE_NOR_OP;
                                                alusel_o <= `EXE_RES_LOGIC;
                                                reg1_read_o <= 1'b1;
                                                reg2_read_o <= 1'b1;
                                                instvalid <= `InstValid;
                                            end

                                        `EXE_AND:                   // 6'b100100
                                            begin
                                                wreg_o <= `WriteEnable;
                                                aluop_o <= `EXE_AND_OP;
                                                alusel_o <= `EXE_RES_LOGIC;
                                                reg1_read_o <= 1'b1;
                                                reg2_read_o <= 1'b1;
                                                instvalid <= `InstValid;
                                            end

                                        `EXE_SLLV:
                                            begin
                                                wreg_o <= `WriteEnable;
                                                aluop_o <= `EXE_SLL_OP;
                                                alusel_o <= `EXE_RES_SHIFT;
                                                reg1_read_o <= 1'b1;
                                                reg2_read_o <= 1'b1;
                                                instvalid <= `InstValid;
                                            end

                                        `EXE_SRLV:
                                            begin
                                                wreg_o <= `WriteEnable;
                                                aluop_o <= `EXE_SRL_OP;
                                                alusel_o <= `EXE_RES_SHIFT;
                                                reg1_read_o <= 1'b1;
                                                reg2_read_o <= 1'b1;
                                                instvalid <= `InstValid;
                                            end

                                        `EXE_SRAV:
                                            begin
                                                wreg_o <= `WriteEnable;
                                                aluop_o <= `EXE_SRA_OP;
                                                alusel_o <= `EXE_RES_SHIFT;
                                                reg1_read_o <= 1'b1;
                                                reg2_read_o <= 1'b1;
                                                instvalid <= `InstValid;
                                            end

                                        `EXE_SYNC:
                                            begin
                                                wreg_o <= `WriteDisable;
                                                aluop_o <= `EXE_NOP_OP;
                                                alusel_o <= `EXE_RES_NOP;
                                                reg1_read_o <= 1'b0;
                                                reg2_read_o <= 1'b1;
                                                instvalid <= `InstValid;
                                            end

                                        `EXE_MFHI:
                                            begin
                                                wreg_o <= `WriteEnable;
                                                aluop_o <= `EXE_MFHI_OP;
                                                alusel_o <= `EXE_RES_MOVE;
                                                reg1_read_o <= 1'b0;
                                                reg2_read_o <= 1'b0;
                                                instvalid <= `InstValid;
                                            end

                                        `EXE_MFLO:
                                            begin
                                                wreg_o <= `WriteEnable;
                                                wreg_o <= `WriteEnable;
                                                aluop_o <= `EXE_MFLO_OP;
                                                alusel_o <= `EXE_RES_MOVE;
                                                reg1_read_o <= 1'b0;
                                                reg2_read_o <= 1'b0;
                                                instvalid <= `InstValid;
                                            end

                                        `EXE_MTHI:
                                            begin
                                                wreg_o <= `WriteDisable;
                                                aluop_o <= `EXE_MTHI_OP;
                                                reg1_read_o <= 1'b1;
                                                reg2_read_o <= 1'b0;
                                                instvalid <= `InstValid;
                                            end

                                        `EXE_MTLO:
                                            begin
                                                wreg_o <= `WriteDisable;
                                                aluop_o <= `EXE_MTLO_OP;
                                                reg1_read_o <= 1'b1;
                                                reg2_read_o <= 1'b0;
                                                instvalid <= `InstValid;
                                            end

                                        `EXE_MOVN:
                                            begin
                                                aluop_o <= `EXE_MOVN_OP;
                                                alusel_o <= `EXE_RES_MOVE;
                                                reg1_read_o <= 1'b1;
                                                reg2_read_o <= 1'b1;
                                                instvalid <= `InstValid;

                                                if ( reg2_o != `ZeroWord )
                                                    begin
                                                        wreg_o <= `WriteEnable;
                                                    end
                                                else
                                                    begin
                                                        wreg_o <= `WriteDisable;
                                                    end
                                            end

                                        `EXE_MOVZ:
                                            begin
                                                aluop_o <= `EXE_MOVZ_OP;
                                                alusel_o <= `EXE_RES_MOVE;
                                                reg1_read_o <= 1'b1;
                                                reg2_read_o <= 1'b1;
                                                instvalid <= `InstValid;

                                                if ( reg2_o == `ZeroWord )
                                                    begin
                                                        wreg_o <= `WriteEnable;
                                                    end
                                                else
                                                    begin
                                                        wreg_o <= `WriteDisable;
                                                    end
                                            end

                                        `EXE_ADD:
                                            begin
                                                wreg_o <= `WriteEnable;
                                                aluop_o <= `EXE_ADD_OP;
                                                alusel_o <= `EXE_RES_ARITHMETIC;
                                                reg1_read_o <= 1'b1;
                                                reg2_read_o <= 1'b1;
                                                instvalid <= `InstValid;
                                            end

                                        `EXE_ADDU:
                                            begin
                                                wreg_o <= `WriteEnable;
                                                aluop_o <= `EXE_ADDU_OP;
                                                alusel_o <= `EXE_RES_ARITHMETIC;
                                                reg1_read_o <= 1'b1;
                                                reg2_read_o <= 1'b1;
                                                instvalid <= `InstValid;
                                            end

                                        `EXE_SUB:
                                            begin
                                                wreg_o <= `WriteEnable;
                                                aluop_o <= `EXE_SUB_OP;
                                                alusel_o <= `EXE_RES_ARITHMETIC;
                                                reg1_read_o <= 1'b1;
                                                reg2_read_o <= 1'b1;
                                                instvalid <= `InstValid;
                                            end

                                        `EXE_SUBU:
                                            begin
                                                wreg_o <= `WriteEnable;
                                                aluop_o <= `EXE_SUBU_OP;
                                                alusel_o <= `EXE_RES_ARITHMETIC;
                                                reg1_read_o <= 1'b1;
                                                reg2_read_o <= 1'b1;
                                                instvalid <= `InstValid;
                                            end

                                        `EXE_SLT:
                                            begin
                                                wreg_o <= `WriteEnable;
                                                aluop_o <= `EXE_SLT_OP;
                                                alusel_o <= `EXE_RES_ARITHMETIC;
                                                reg1_read_o <= 1'b1;
                                                reg2_read_o <= 1'b1;
                                                instvalid <= `InstValid;
                                            end

                                        `EXE_SLTU:
                                            begin
                                                wreg_o <= `WriteEnable;
                                                aluop_o <= `EXE_SLTU_OP;
                                                alusel_o <= `EXE_RES_ARITHMETIC;
                                                reg1_read_o <= 1'b1;
                                                reg2_read_o <= 1'b1;
                                                instvalid <= `InstValid;
                                            end

                                        `EXE_MULT:
                                            begin
                                                wreg_o <= `WriteEnable;
                                                aluop_o <= `EXE_MULT_OP;
                                                reg1_read_o <= 1'b1;
                                                reg2_read_o <= 1'b1;
                                                instvalid <= `InstValid;
                                            end

                                        `EXE_MULTU:
                                            begin
                                                wreg_o <= `WriteEnable;
                                                aluop_o <= `EXE_MULTU_OP;
                                                reg1_read_o <= 1'b1;
                                                reg2_read_o <= 1'b1;
                                                instvalid <= `InstValid;
                                            end

                                        `EXE_DIV:
                                            begin
                                                wreg_o <= `WriteDisable;
                                                aluop_o <= `EXE_DIV_OP;
                                                reg1_read_o <= 1'b1;
                                                reg2_read_o <= 1'b1;
                                                instvalid <= `InstValid;
                                            end

                                        `EXE_DIVU:
                                            begin
                                                wreg_o <= `WriteDisable;
                                                aluop_o <= `EXE_DIVU_OP;
                                                reg1_read_o <= 1'b1;
                                                reg2_read_o <= 1'b1;
                                                instvalid <= `InstValid;
                                            end

                                        default :
                                            begin
                                            end

                                    endcase
                                default :
                                    begin
                                    end

                            endcase
                        end

                    `EXE_SPECIAL2_INST:
                        begin
                            case ( op3 )
                                `EXE_CLZ:
                                    begin
                                        wreg_o <= `WriteEnable;
                                        aluop_o <= `EXE_CLZ_OP;
                                        alusel_o <= `EXE_RES_ARITHMETIC;
                                        reg1_read_o <= 1'b1;
                                        reg2_read_o <= 1'b0;
                                        instvalid <= `InstValid;
                                    end

                                `EXE_CLO:
                                    begin
                                        wreg_o <= `WriteEnable;
                                        aluop_o <= `EXE_CLO_OP;
                                        alusel_o <= `EXE_RES_ARITHMETIC;
                                        reg1_read_o <= 1'b1;
                                        reg2_read_o <= 1'b0;
                                        instvalid <= `InstValid;
                                    end

                                `EXE_MUL:
                                    begin
                                        wreg_o <= `WriteEnable;
                                        aluop_o <= `EXE_MUL_OP;
                                        alusel_o <= `EXE_RES_MUL;
                                        reg1_read_o <= 1'b1;
                                        reg2_read_o <= 1'b1;
                                        instvalid <= `InstValid;
                                    end

                                `EXE_MADD:
                                    begin
                                        wreg_o <= `WriteDisable;
                                        aluop_o <= `EXE_MADD_OP;
                                        alusel_o <= `EXE_RES_MUL;
                                        reg1_read_o <= 1'b1;
                                        reg2_read_o <= 1'b1;
                                        instvalid <= `InstValid;
                                    end

                                `EXE_MADDU:
                                    begin
                                        wreg_o <= `WriteDisable;
                                        aluop_o <= `EXE_MADDU_OP;
                                        alusel_o <= `EXE_RES_MUL;
                                        reg1_read_o <= 1'b1;
                                        reg2_read_o <= 1'b1;
                                        instvalid <= `InstValid;
                                    end

                                `EXE_MSUB:
                                    begin
                                        wreg_o <= `WriteDisable;
                                        aluop_o <= `EXE_MSUB_OP;
                                        alusel_o <= `EXE_RES_MUL;
                                        reg1_read_o <= 1'b1;
                                        reg2_read_o <= 1'b1;
                                        instvalid <= `InstValid;
                                    end

                                `EXE_MSUBU:
                                    begin
                                        wreg_o <= `WriteDisable;
                                        aluop_o <= `EXE_MSUBU_OP;
                                        alusel_o <= `EXE_RES_MUL;
                                        reg1_read_o <= 1'b1;
                                        reg2_read_o <= 1'b1;
                                        instvalid <= `InstValid;
                                    end

                            endcase
                        end

                    `EXE_ORI:            // ORI：6‘b001101
                        begin
                            wreg_o <= `WriteEnable;                     // 写使能打开
                            aluop_o <= `EXE_OR_OP;                      // 该指令所属的子类型是 “OR” 运算
                            alusel_o <= `EXE_RES_LOGIC;                 // 运算类型为 "LOGIC"
                            reg1_read_o <= 1'b1;                        // 读使能开启，对应的 rs 地址已经写入 reg1_addr_o ,即指令的 25~21
                            reg2_read_o <= 1'b0;                        // 关闭2的读使能，ORI指令不需要读这个端口
                            imm <= { 16'h0, inst_i[ 15: 0 ] };          // 立即数拼接，立即数对应指令的 15~0 ，再通过填充0满足32位
                            wd_o <= inst_i[ 20: 16 ];                   // 要写入的寄存器，对应指令的 rt ，20~16
                            instvalid <= `InstValid;                    // 写使能打开
                        end

                    `EXE_ANDI:           // ANDI：6‘b001100
                        begin
                            wreg_o <= `WriteEnable;
                            aluop_o <= `EXE_AND_OP;                  // 该指令所属的子类型是 “AND” 运算
                            alusel_o <= `EXE_RES_LOGIC;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b0;
                            imm <= { 16'h0, inst_i[ 15: 0 ] };
                            wd_o <= inst_i[ 20: 16 ];
                            instvalid <= `InstValid;
                        end

                    `EXE_XORI:
                        begin
                            wreg_o <= `WriteEnable;
                            aluop_o <= `EXE_XOR_OP;                  // 该指令所属的子类型是 “XORI” 运算
                            alusel_o <= `EXE_RES_LOGIC;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b0;
                            imm <= { 16'h0, inst_i[ 15: 0 ] };
                            wd_o <= inst_i[ 20: 16 ];
                            instvalid <= `InstValid;
                        end

                    `EXE_LUI:
                        begin
                            wreg_o <= `WriteEnable;
                            aluop_o <= `EXE_OR_OP;
                            alusel_o <= `EXE_RES_LOGIC;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b0;
                            imm <= { inst_i[ 15: 0 ], 16'h0 };
                            wd_o <= inst_i[ 20: 16 ];
                            instvalid <= `InstValid;
                        end

                    `EXE_PREF:
                        begin
                            wreg_o <= `WriteDisable;
                            aluop_o <= `EXE_NOR_OP;
                            alusel_o <= `EXE_RES_NOP;
                            reg1_read_o <= 1'b0;
                            reg2_read_o <= 1'b0;
                            instvalid <= `InstValid;
                        end

                    `EXE_ADDI:
                        begin
                            wreg_o <= `WriteEnable;
                            aluop_o <= `EXE_ADDI_OP;
                            alusel_o <= `EXE_RES_ARITHMETIC;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b0;
                            imm <= { { 16{ inst_i[ 15 ] } }, inst_i[ 15: 0 ] };
                            wd_o <= inst_i[ 20: 16 ];
                            instvalid <= `InstValid;
                        end

                    `EXE_ADDIU:
                        begin
                            wreg_o <= `WriteEnable;
                            aluop_o <= `EXE_ADDIU_OP;
                            alusel_o <= `EXE_RES_ARITHMETIC;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b0;
                            imm <= { { 16{ inst_i[ 15 ] } }, inst_i[ 15: 0 ] };
                            wd_o <= inst_i[ 20: 16 ];
                            instvalid <= `InstValid;
                        end

                    `EXE_SLTI:
                        begin
                            wreg_o <= `WriteEnable;
                            aluop_o <= `EXE_SLT_OP;
                            alusel_o <= `EXE_RES_ARITHMETIC;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b0;
                            imm <= { { 16{ inst_i[ 15 ] } }, inst_i[ 15: 0 ] };
                            wd_o <= inst_i[ 20: 16 ];
                            instvalid <= `InstValid;
                        end

                    `EXE_SLTIU:
                        begin
                            wreg_o <= `WriteEnable;
                            aluop_o <= `EXE_SLTU_OP;
                            alusel_o <= `EXE_RES_ARITHMETIC;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b0;
                            imm <= { { 16{ inst_i[ 15 ] } }, inst_i[ 15: 0 ] };
                            wd_o <= inst_i[ 20: 16 ];
                            instvalid <= `InstValid;
                        end

                    default :
                        begin
                        end

                endcase // endcase op
                if ( inst_i[ 31: 21 ] == 11'b00000000000 )
                    begin
                        if ( op3 == `EXE_SLL )
                            begin
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_SLL_OP;
                                alusel_o <= `EXE_RES_SHIFT;
                                reg1_read_o <= 1'b0;
                                reg2_read_o <= 1'b1;
                                imm[ 4: 0 ] <= inst_i[ 10: 6 ];
                                wd_o <= inst_i[ 15: 11 ];
                                instvalid <= `InstValid;
                            end
                        else if ( op3 == `EXE_SRL )
                            begin
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_SRL_OP;
                                alusel_o <= `EXE_RES_SHIFT;
                                reg1_read_o <= 1'b0;
                                reg2_read_o <= 1'b1;
                                imm[ 4: 0 ] <= inst_i[ 10: 6 ];
                                wd_o <= inst_i[ 15: 11 ];
                                instvalid <= `InstValid;
                            end
                        else if ( op3 == `EXE_SRA )
                            begin
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_SRA_OP;
                                alusel_o <= `EXE_RES_SHIFT;
                                reg1_read_o <= 1'b0;
                                reg2_read_o <= 1'b1;
                                imm[ 4: 0 ] <= inst_i[ 10: 6 ];
                                wd_o <= inst_i[ 15: 11 ];
                                instvalid <= `InstValid;
                            end
                    end
            end

    end

// 在case中得到的一系列信息中有要读的寄存器的地址和读使能情况
// 这里来读取寄存器得到其余的信息，包括操作数1和2
// 真正送到下一级流水线不包括地址，仅仅将这里取得的操作数送下去
always @( * )
    begin
        if ( rst == `RstEnable )
            begin
                reg1_o <= `ZeroWord;
            end
        else if (
            ( reg1_read_o == 1'b1 ) && ( ex_wreg_i == 1'b1 ) && ( ex_wd_i == reg1_addr_o )
        )                   // 若要读取的数据就是执行阶段要写入的数据，则把执行结果直接输出
            begin
                reg1_o <= ex_wdata_i;
            end
        else if (
            ( reg1_read_o == 1'b1 ) && ( mem_wreg_i == 1'b1 ) && ( mem_wd_i == reg1_addr_o )
        )                   // 若要读取的数据就是访存阶段要写入的数据，则把访存结果直接输出
            begin
                reg1_o <= mem_wdata_i;
            end
        else if ( reg1_read_o == 1'b1 )       // 若reg1读端口使能，将读出的数据作为源操作数1
            begin
                reg1_o <= reg1_data_i;
            end
        else if ( reg1_read_o == 1'b0 )       // 若使能关闭，则使用立即数作为源操作数1
            begin
                reg1_o <= imm;
            end
        else
            begin
                reg1_o <= `ZeroWord;
            end
    end

always @( * )
    begin
        if ( rst == `RstEnable )
            begin
                reg2_o <= `ZeroWord;
            end
        else if (
            ( reg2_read_o == 1'b1 ) && ( ex_wreg_i == 1'b1 ) && ( ex_wd_i == reg2_addr_o )
        )
            begin
                reg2_o <= ex_wdata_i;
            end
        else if (
            ( reg2_read_o == 1'b1 ) && ( mem_wreg_i == 1'b1 ) && ( mem_wd_i == reg2_addr_o )
        )
            begin
                reg2_o <= mem_wdata_i;
            end
        else if ( reg2_read_o == 1'b1 )
            begin
                reg2_o <= reg2_data_i;
            end
        else if ( reg2_read_o == 1'b0 )
            begin
                reg2_o <= imm;
            end
        else
            begin
                reg2_o <= `ZeroWord;
            end
    end

endmodule //id
