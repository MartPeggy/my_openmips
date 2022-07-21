//************************************************
//* @FilePath     : \my_OpenMIPS\ctrl.v
//* @Date         : 2022-07-10 09:49:02
//* @LastEditTime : 2022-07-21 10:08:00
//* @Author       : mart
//* @Tips         : CA+I 头注释 CA+P TB
//* @Description  : 控制流水线的暂停
//************************************************

//^序号     接口名          宽度    输入输出    作用
//^ 1       rst             1       in      复位信号
//^ 2   stallreq_from_id    1       in      译码阶段的指令请求流水线暂停
//^ 3   stallreq_from_ex    1       in      执行阶段的指令请求流水线暂停
//^ 4       stall           6       out     流水线暂停信号

`include "defines.v"
module ctrl (
           input wire rst,
           input wire stallreq_from_id,
           input wire stallreq_from_ex,
           output reg [ 5: 0 ] stall
       );
       
// stall[0]:地址PC是否保持不变，1不变
// stall[1]:取值是否暂停，1暂停
// stall[2]:译码是否暂停，1暂停
// stall[3]:执行是否暂停，1暂停
// stall[4]:访存是否暂停，1暂停
// stall[5]:回写是否暂停，1暂停

always @ ( * )
    begin
        if ( rst == `RstEnable )
            begin
                stall <= 6'b000000;
            end
        else if ( stallreq_from_ex == `Stop )
            begin
                stall <= 6'b001111;
            end
        else if ( stallreq_from_id == `Stop )
            begin
                stall <= 6'b000111;
            end
        else
            begin
                stall <= 6'b000000;
            end    //if
    end      //always

endmodule //ctrl
