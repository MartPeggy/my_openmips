//************************************************
//* @FilePath     : \my_OpenMIPS\defines.v
//* @Date         : 2022-04-24 09:53:09
//* @LastEditTime : 2022-07-08 08:51:03
//* @Author       : mart
//* @Tips         : CA+I 头注释 CA+P TB Ctrl+t 转到定义
//* @Description  : 一些宏定义
//************************************************

//*  全局宏定义  *//
`define RstEnable       1'b1            // 复位有效
`define RstDisable      1'b0            // 复位无效
`define ZeroWord        32'h00000000    // 32位的数值0
`define WriteEnable     1'b1            // 写使能
`define WriteDisable    1'b0            // 禁止写
`define ReadEnable      1'b1            // 读使能
`define ReadDisable     1'b0            // 禁止读

`define AluOpBus        7:0             // 译码阶段的输出 aluop_o 的宽度
`define AluSelBus       2:0             // 译码阶段的输出 alusel_o的宽度

`define InstValid       1'b0            // 指令有效
`define InstInvalid     1'b1            // 指令无效
`define True_v          1'b1            // 逻辑真
`define False_v         1'b0            // 逻辑假
`define ChipEnable      1'b1            // 芯片使能
`define ChipDisable     1'b0            // 芯片禁止

`define Stop            1'b1
`define NoStop          1'b0
`define InDelaySlot     1'b1
`define NotInDelaySlot  1'b0
`define Branch          1'b1
`define NotBranch       1'b0
`define InterruptAssert 1'b1
`define InterruptNotAssert 1'b0
`define TrapAssert      1'b1
`define TrapNotAssert   1'b0
//*   指令宏定义    *//

`define EXE_NOP             6'b000000       // NOP

`define EXE_AND             6'b100100       // AND
`define EXE_OR              6'b100101       // OR
`define EXE_XOR             6'b100110       // XOR 异或
`define EXE_NOR             6'b100111       // NOR 非或
`define EXE_ANDI            6'b001100       // ANDI 寄存器+立即数 进行与运算
`define EXE_ORI             6'b001101       // ORI
`define EXE_XORI            6'b001110       // XORI 寄存器+立即数 进行异或运算
`define EXE_LUI             6'b001111       // LUI  立即数保存到寄存器高16位

`define EXE_SLL             6'b000000       // SLL 寄存器中的值左移并把结果保存到新的寄存器中
`define EXE_SLLV            6'b000100       // SLLV 寄存器中的值左移并把结果保存到新的寄存器中，移位位数由寄存器决定
`define EXE_SRL             6'b000010       // SRL 寄存器中的值右移并把结果保存到新的寄存器中
`define EXE_SRLV            6'b000110       // SRLV 寄存器中的值右移并把结果保存到新的寄存器中，移位位数由寄存器决定
`define EXE_SRA             6'b000011       // SRA 寄存器中的值进行算术右移并把结果保存到新的寄存器中
`define EXE_SRAV            6'b000111       // SRAV 寄存器中的值进行算术右移并把结果保存到新的寄存器中，移位位数由寄存器决定

`define EXE_SYNC            6'b001111       // SYNC 这里相当于空指令
`define EXE_PREF            6'b110011       // PREF 这里相当于空指令
`define SSNOP               32'b00000000000000000000000001000000

`define EXE_REGIMM_INST     6'b000001
`define EXE_SPECIAL2_INST   6'b01110
`define EXE_SPECIAL_INST    6'b000000       // 特殊指令

//Aluop
`define EXE_AND_OP       8'b00100100
`define EXE_OR_OP        8'b00100101
`define EXE_XOR_OP       8'b00100110
`define EXE_NOR_OP       8'b00100111
`define EXE_ANDI_OP      8'b01011001
`define EXE_ORI_OP       8'b01011010
`define EXE_XORI_OP      8'b01011011
`define EXE_LUI_OP       8'b01011100
`define EXE_SLL_OP       8'b01111100
`define EXE_SLLV_OP      8'b00000100
`define EXE_SRL_OP       8'b00000010
`define EXE_SRLV_OP      8'b00000110
`define EXE_SRA_OP       8'b00000011
`define EXE_SRAV_OP      8'b00000111
`define EXE_NOP_OP       8'b00000000

//AluSel
`define EXE_RES_LOGIC   3'b001
`define EXE_RES_SHIFT   3'b010
`define EXE_RES_NOP     3'b000


//*   与ROM相关的宏指令    *//
`define InstAddrBus      31:0    // ROM的地址总线宽度
`define InstBus          31:0    // ROM的数据总线宽度
`define InstMemNum       131071  // ROM的实际大小
`define InstMemNumLog2   17      // ROM实际使用的地址线宽度

//*    与通用寄存器regfile有关的宏指令    *//
`define RegAddrBus       4:0     // RegFile的地址线宽度
`define RegBus           31:0    // RegFile的数据线宽度
`define RegWidth         32      // 通用寄存器的宽度
`define DoubleRegWidth   64      // 通用寄存器的两倍宽度
`define DoubleRegBus     63:0    // 通用寄存器的数据线宽度的两倍
`define RegNum           32      // 通用寄存器的数量
`define RegNumLog2       5       // 寻址通用寄存器使用的地址位宽
`define NOPRegAddr       5'b000000
