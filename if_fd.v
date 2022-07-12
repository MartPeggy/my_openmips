//************************************************
//* @FilePath     : \my_OpenMIPS\if_fd.v
//* @Date         : 2022-04-24 11:08:17
//* @LastEditTime : 2022-07-12 14:13:57
//* @Author       : mart
//* @Tips         : CA+I 头注释 CA+P TB
//* @Description  : 暂时保存取值阶段取得的指令和指令地址
//* @Description  : IF:Instruction bufF(指令缓冲) ？？？
//* @Description  : ID:Instruction Decoder(指令译码)
//* @Description  : 仅仅起缓冲作用，将取指阶段的数据传递给下一级
//* @Description  : 参与流水线暂停
//************************************************

//^序号     接口名          宽度    输入输出
//^ 1       rst             1       in
//^ 2       clk             1       in
//^ 3       if_pc           32      in
//^ 4       if_inst         32      in
//^ 5       id_pc           32      out
//^ 6       id_inst         32      out
//& 增加流水线暂停信号
//^ 1       stall           6       in

`include "defines.v"
module if_fd (
           input wire clk,
           input wire rst,

           input wire [ `InstAddrBus ] if_pc,
           input wire [ `InstBus ] if_inst,

           output reg [ `InstAddrBus ] id_pc,
           output reg [ `InstBus ] id_inst,

           input wire [ 5: 0 ] stall
       );

// stall[1]==`Stop 取指暂停
// stall[2]==`Stop 译码暂停
// stall[2]==`NoStop 译码不暂停
always @( posedge clk )
    begin
        if ( rst == `RstEnable )
            begin
                id_pc <= `ZeroWord;
                id_inst <= `ZeroWord;
            end

        // 取值暂停且当前指令的译码继续
        else if ( stall[ 1 ] == `Stop && stall[ 2 ] == `NoStop )
            begin
                id_pc <= `ZeroWord;
                id_inst <= `ZeroWord;
            end

        // 流水线无暂停
        else if ( stall[ 1 ] == `NoStop )
            begin
                id_pc <= if_pc;
                id_inst <= if_inst;
            end
    end

endmodule //if_fd
