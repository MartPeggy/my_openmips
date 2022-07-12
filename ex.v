//************************************************
//* @FilePath     : \my_OpenMIPS\ex.v
//* @Date         : 2022-04-27 21:25:46
//* @LastEditTime : 2022-07-12 13:53:55
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
//^ 1   hi_i        32      in      HILO模块给出的HI寄存器的值
//^ 2   lo_i        32      in      HILO模块给出的LO寄存器的值
//^ 3  mem_whilo_i  1       in      访存阶段的指令是否要写HILO寄存器
//^ 4  mem_hi_i     32      in      访存阶段指令要写入HI寄存器的值
//^ 5  mem_lo_i     32      in      访存阶段指令要写入LO寄存器的值
//^ 6  wb_whilo_i   1       in      回写阶段的指令是否要写HILO寄存器
//^ 7  wb_hi_i      32      in      回写阶段指令要写入HI寄存器的值
//^ 8  wb_lo_i      32      in      回写阶段指令要写入LO寄存器的值
//^ 9  whilo_o      1      out      执行阶段的指令是否要写入HILO寄存器
//^ 10  hi_o        32     out      执行阶段的指令要写入HI寄存器的值
//^ 11  lo_o        32     out      执行阶段的指令要写入LO寄存器的值
//& 流水线暂停增加接口如下
//^ 1   stall       1      output   发出流水线暂停信号
//& 多周期指令：增加如下接口
//^ 1  hilo_temp_i  64      in      第一个执行周期的乘法结果
//^ 2  cnt_i        2       in      记录执行阶段的第几个时钟周期
//^ 3  hilo_temp_o  64      out     第一个执行周期的乘法结果
//^ 4  cnt_o        2       out     下一个时钟周期处于第几个时钟周期


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
           output reg whilo_o,

           // 流水线暂停
           output reg stallreq,

           // 多周期执行
           input wire [ `DoubleRegBus ] hilo_temp_i,
           input wire [ 1: 0 ] cnt_i,
           output reg [ `DoubleRegBus ] hilo_temp_o,
           output reg [ 1: 0 ] cnt_o
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

// 保存溢出结果
wire ov_sum;
// reg1等于reg2
wire reg1_eq_reg2;
// reg1小于reg2
wire reg1_lt_reg2;
// 算术运算结果
reg [ `RegBus ] arithmeticres;
// 保存reg2的补码
wire [ `RegBus ] reg2_i_mux;
// 保存reg1的反码
wire [ `RegBus ] reg1_i_not;
// 保存加法结果
wire [ `RegBus ] result_sum;
// 乘法运算中的被乘数
wire [ `RegBus ] opdata1_mult;
// 乘法运算中的乘数
wire [ `RegBus ] opdata2_mult;
// 临时保存乘法结果
wire [ `DoubleRegBus ] hilo_temp;
// 保存乘法结果
reg [ `DoubleRegBus ] mulres;
// 临时保存多周期乘法运算结果
reg [ `DoubleRegBus ] hilo_temp1;
// 指令是否请求流水线暂停
reg stallreq_for_madd_msub;


// 解决数据相关性问题：HI，LO寄存器
always @( * )
    begin
        if ( rst == `RstEnable )
            begin
                { HI, LO } <= { `ZeroWord, `ZeroWord };
            end
        else if ( mem_whilo_i == `WriteEnable )                                  //  访存阶段的指令要写HI，LO寄存器
            begin
                { HI, LO } <= { mem_hi_i, mem_lo_i };
            end
        else if ( wb_whilo_i == `WriteEnable )                                   //  回写阶段的指令要写HI，LO寄存器
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
                case ( aluop_i )                                       // 判断子类型
                    `EXE_OR_OP:                                       // 子类型为 OR
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

//**** 算术运算 ****//

// 对于减法运算或有符号数比较运算，reg2_i_mux为reg2_i的补码，其他情况下就等于原数
assign reg2_i_mux = ( ( aluop_i == `EXE_SUB_OP ) || ( aluop_i == `EXE_SUBU_OP ) ||
                      ( aluop_i == `EXE_SLT_OP ) )
       ? ( ~reg2_i ) + 1 : reg2_i;

// 对于加法运算，sum=reg1+reg2，不需要进行额外的操作
// 对于减法运算，reg2为原数的补码，sum=reg1+reg2即为减法结果
// 对于有符号数比较运算，与减法运算相同，则可以通过判断结果是否小于0判断大小
assign result_sum = reg1_i + reg2_i_mux;

// 对于溢出的计算：在加法和减法指令执行时会产生溢出
// 当两个正数相加为负数，则溢出；两个负数相加为正数，则溢出
assign ov_sum = ( ( !reg1_i[ 31 ] && !reg2_i_mux[ 31 ] ) && result_sum[ 31 ] ) ||
       ( ( reg1_i[ 31 ] && reg2_i_mux[ 31 ] ) && ( !result_sum[ 31 ] ) );

// 对于比较的计算：a)对于有符号数比较，负数 < 正数，正数 - 正数 < 0,负数 - 负数 < 0
// b)对于无符号数比较，直接用 > < 运算符比较
assign reg1_lt_reg2 = ( ( aluop_i == `EXE_SLT_OP ) ) ?
       ( ( reg1_i[ 31 ] && !reg2_i[ 31 ] ) || ( !reg1_i[ 31 ] && !reg2_i[ 31 ] ) && ( result_sum[ 31 ] )
         || ( reg1_i[ 31 ] && reg2_i[ 31 ] && result_sum[ 31 ] ) ) : ( reg1_i < reg2_i );

// 对于反码的运算：逐位取反
assign reg1_i_not = ~reg1_i;


// 根据不同的算术类型，给 arithmeticres 赋值
// 涉及加法、比较、减法、计数四种运算
always @( * )
    begin
        if ( rst == `RstEnable )
            begin
                arithmeticres <= `ZeroWord;
            end
        else
            begin
                case ( aluop_i )
                    `EXE_SLT_OP, `EXE_SLTU_OP:
                        begin
                            arithmeticres <= reg1_lt_reg2; // 比较运算
                        end

                    `EXE_ADD_OP, `EXE_ADDU_OP, `EXE_ADDI_OP, `EXE_ADDIU_OP:
                        begin
                            arithmeticres <= result_sum;  // 加法运算
                        end

                    `EXE_SUB_OP, `EXE_SUBU_OP:
                        begin
                            arithmeticres <= result_sum;  // 减法运算
                        end

                    `EXE_CLZ_OP:
                        begin
                            arithmeticres <= ( reg1_i[ 31 ] ? 0 : reg1_i[ 30 ] ? 1 : reg1_i[ 29 ] ? 2 : reg1_i[ 28 ] ? 3 : reg1_i[ 27 ] ? 4 :
                                               reg1_i[ 26 ] ? 5 : reg1_i[ 25 ] ? 6 : reg1_i[ 24 ] ? 7 : reg1_i[ 23 ] ? 8 : reg1_i[ 22 ] ? 9 :
                                               reg1_i[ 21 ] ? 10 : reg1_i[ 20 ] ? 11 : reg1_i[ 19 ] ? 12 : reg1_i[ 18 ] ? 13 : reg1_i[ 17 ] ? 14 :
                                               reg1_i[ 16 ] ? 15 : reg1_i[ 15 ] ? 16 : reg1_i[ 14 ] ? 17 : reg1_i[ 13 ] ? 18 : reg1_i[ 12 ] ? 19 :
                                               reg1_i[ 11 ] ? 20 : reg1_i[ 10 ] ? 21 : reg1_i[ 9 ] ? 22 : reg1_i[ 8 ] ? 23 : reg1_i[ 7 ] ? 24 :
                                               reg1_i[ 6 ] ? 25 : reg1_i[ 5 ] ? 26 : reg1_i[ 4 ] ? 27 : reg1_i[ 3 ] ? 28 : reg1_i[ 2 ] ? 29 :
                                               reg1_i[ 1 ] ? 30 : reg1_i[ 0 ] ? 31 : 32 ) ;
                        end

                    `EXE_CLO_OP:
                        begin
                            arithmeticres <= ( reg1_i_not[ 31 ] ? 0 : reg1_i_not[ 30 ] ? 1 : reg1_i_not[ 29 ] ? 2 :
                                               reg1_i_not[ 28 ] ? 3 : reg1_i_not[ 27 ] ? 4 : reg1_i_not[ 26 ] ? 5 :
                                               reg1_i_not[ 25 ] ? 6 : reg1_i_not[ 24 ] ? 7 : reg1_i_not[ 23 ] ? 8 :
                                               reg1_i_not[ 22 ] ? 9 : reg1_i_not[ 21 ] ? 10 : reg1_i_not[ 20 ] ? 11 :
                                               reg1_i_not[ 19 ] ? 12 : reg1_i_not[ 18 ] ? 13 : reg1_i_not[ 17 ] ? 14 :
                                               reg1_i_not[ 16 ] ? 15 : reg1_i_not[ 15 ] ? 16 : reg1_i_not[ 14 ] ? 17 :
                                               reg1_i_not[ 13 ] ? 18 : reg1_i_not[ 12 ] ? 19 : reg1_i_not[ 11 ] ? 20 :
                                               reg1_i_not[ 10 ] ? 21 : reg1_i_not[ 9 ] ? 22 : reg1_i_not[ 8 ] ? 23 :
                                               reg1_i_not[ 7 ] ? 24 : reg1_i_not[ 6 ] ? 25 : reg1_i_not[ 5 ] ? 26 :
                                               reg1_i_not[ 4 ] ? 27 : reg1_i_not[ 3 ] ? 28 : reg1_i_not[ 2 ] ? 29 :
                                               reg1_i_not[ 1 ] ? 30 : reg1_i_not[ 0 ] ? 31 : 32 ) ;
                        end

                endcase
            end
    end

// 对于乘法的被乘数，当为有符号数乘法且被乘数为负数，取补码参与运算
// 乘累加指令也适用于此处的判断
assign opdata1_mult =
       ( ( ( aluop_i == `EXE_MUL_OP ) || ( aluop_i == `EXE_MULT_OP ) ||
           ( aluop_i == `EXE_MADD_OP ) || ( aluop_i == `EXE_MSUB_OP ) )
         && ( reg1_i[ 31 ] == 1'b1 ) ) ?
       ( ~reg1_i + 1 ) : reg1_i;

// 对于乘法的乘数，当为有符号数乘法且乘数为负数时，取补码参与运算
// 乘累加指令也适用于此处的判断
assign opdata2_mult =
       ( ( ( aluop_i == `EXE_MUL_OP ) || ( aluop_i == `EXE_MULT_OP ) ||
           ( aluop_i == `EXE_MADD_OP ) || ( aluop_i == `EXE_MSUB_OP ) )
         && ( reg2_i[ 31 ] == 1'b1 ) ) ?
       ( ~reg2_i + 1 ) : reg2_i;

// 这里的结果对于有符号数乘法来说并不准确，需要进一步修正
// 有符号数一正一负则需要对结果取补码，若都为正或都为负则不需要修正
// 利用异或运算 ^ 实现一正一负的判断
// 无符号数计算则没有差错
// 乘累加指令也适用于此处的判断
assign hilo_temp = opdata1_mult * opdata2_mult;
always @( * )
    begin
        if ( rst == `RstEnable )
            begin
                mulres <= { `ZeroWord, `ZeroWord };
            end
        else if ( ( aluop_i == `EXE_MULT_OP ) || ( aluop_i == `EXE_MUL_OP ) ||
                  ( aluop_i == `EXE_MADD_OP ) || ( aluop_i == `EXE_MSUB_OP ) )
            begin
                if ( reg1_i[ 31 ] ^ reg2_i[ 31 ] == 1'b1 )
                    begin
                        mulres <= ~hilo_temp + 1;
                    end
                else
                    begin
                        mulres <= hilo_temp;
                    end
            end
        else
            begin
                mulres <= hilo_temp;
            end
    end

// 写入寄存器的数据处理
// 根据alusel_i 指示的运算类型，选择运算结果作为最终结果
// 这里对于数据的溢出不写入寄存器，利用ov_sum判断
always @ ( * )
    begin
        wd_o <= wd_i;

        if ( ( ( aluop_i == `EXE_ADD_OP ) || ( aluop_i == `EXE_ADDI_OP ) ||
                ( aluop_i == `EXE_SUB_OP ) ) && ( ov_sum == 1'b1 ) )
            begin
                wreg_o <= `WriteDisable;
            end
        else
            begin
                wreg_o <= wreg_i;
            end

        case ( alusel_i )
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

            `EXE_RES_ARITHMETIC:
                begin
                    wdata_o <= arithmeticres;
                end

            `EXE_RES_MUL:
                begin
                    wdata_o <= mulres[ 31: 0 ];
                end

            default :
                begin
                    wdata_o <= `ZeroWord;
                end

        endcase
    end

// 确定写入HILO寄存器的值
// 增加乘累加和乘累减指令
always @( * )
    begin
        if ( rst == `RstEnable )
            begin
                whilo_o <= `WriteDisable;
                hi_o <= `ZeroWord;
                lo_o <= `ZeroWord;
            end
        else if ( ( aluop_i == `EXE_MULT_OP ) || ( aluop_i == `EXE_MULTU_OP ) )
            begin
                whilo_o <= `WriteEnable;
                hi_o <= mulres[ 63: 32 ];
                lo_o <= mulres[ 31: 0 ];
            end
        else if ( ( aluop_i == `EXE_MADD_OP ) || ( aluop_i == `EXE_MADDU_OP ) )
            begin
                whilo_o <= `WriteEnable;
                hi_o <= hilo_temp1[ 63: 32 ];
                lo_o <= hilo_temp1[ 31: 0 ];
            end
        else if ( ( aluop_i == `EXE_MSUB_OP ) || ( aluop_i == `EXE_MSUBU_OP ) )
            begin
                whilo_o <= `WriteEnable;
                hi_o <= hilo_temp1[ 63: 32 ];
                lo_o <= hilo_temp1[ 31: 0 ];
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

// 乘累加，乘累减
always @( * )
    begin
        if ( rst == `RstEnable )
            begin
                hilo_temp_o <= { `ZeroWord, `ZeroWord };
                cnt_o <= 2'b00;
                stallreq_for_madd_msub <= `NoStop;
            end
        else
            begin
                case ( aluop_i )
                    `EXE_MADD_OP, `EXE_MADDU_OP:
                        begin
                            // 第一个时钟周期
                            if ( cnt_i == 2'b00 )
                                begin
                                    hilo_temp_o <= mulres;
                                    cnt_o <= 2'b01;
                                    hilo_temp1 <= { `ZeroWord, `ZeroWord };
                                    stallreq_for_madd_msub <= `Stop;
                                end

                            // 第二个时钟周期
                            else if ( cnt_i == 2'b01 )
                                begin
                                    hilo_temp_o <= { `ZeroWord, `ZeroWord };
                                    cnt_o <= 2'b10;
                                    hilo_temp1 <= hilo_temp_i + { HI, LO };
                                    stallreq_for_madd_msub <= `NoStop;
                                end
                        end

                    `EXE_MSUB_OP, `EXE_MSUBU_OP:
                        begin
                            if ( cnt_i == 2'b00 )
                                begin
                                    hilo_temp_o <= ~mulres + 1 ;
                                    cnt_o <= 2'b01;
                                    stallreq_for_madd_msub <= `Stop;
                                end
                            else if ( cnt_i == 2'b01 )
                                begin
                                    hilo_temp_o <= { `ZeroWord, `ZeroWord };
                                    cnt_o <= 2'b10;
                                    hilo_temp1 <= hilo_temp_i + { HI, LO };
                                    stallreq_for_madd_msub <= `NoStop;
                                end
                        end

                    default :
                        begin
                            hilo_temp_o <= { `ZeroWord, `ZeroWord };
                            cnt_o <= 2'b00;
                            stallreq_for_madd_msub <= `NoStop;
                        end

                endcase
            end
    end

// 将流水线暂停信号传递下去
always @ ( * )
    begin
        stallreq = stallreq_for_madd_msub;
    end



endmodule //ex
