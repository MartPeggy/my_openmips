# my_OpenMIPS

实现一个自己的CPU，采用MIPS32架构

## Contents

- [MIPS32简介](#MIPS32简介)
- [使用的工具](#使用的工具)
- [参考书目](#参考书目)
- [预期目标](#预期目标)
- [模块划分](#模块划分)
- [可用指令](#可用指令)
- [贡献者](#贡献者)
- [License](#license)
- 

## MIPS32简介

#### 指令寻址方式

1. **立即数寻址**：16位二进制立即数
2. **寄存器寻址**：操作数放在寄存器中
3. **基址寻址**：有效地址分为两部分，基地址放在寄存器中，偏移部分为一个立即数
4. **PC相对寻址**：下一条指令的PC值加上16位偏移量地址左移两位的值
5. **伪直接寻址**：指令中的26位偏置地址左移两位并替换掉PC的后28位

### 指令类型

1. **算术指令**：两个操作数的算术运算，加减乘除
2. **逻辑运算**：两个操作数的逻辑运算和移位运算
3. **数据传送**：数据存储器的读写或将立即数传输到一个寄存器
4. **条件转移**：先进行逻辑判断，再根据条件是否满足进行特定操作（跳转或赋值）
5. **无条件转移**：跳转到目标地址

### 指令格式

*op——**操作码**； rs——**源操作数**； rt——**源/目的操作数**； rd——**目的操作数**； shamt——**移位的位数**； funct——**功能码**； imm——**立即数**； address——**转移的目的地址***

- **R类型：全为寄存器操作数**

  - |   31 ~ 26    | 25 ~ 21 | 20 ~ 16 | 15 ~ 11 | 10 ~ 6 | 5 ~ 0 |
    | :----------: | :-----: | :-----: | :-----: | :----: | :---: |
    | op（000000） |   rs    |   rt    |   rd    | shamt  | funct |

- **I类型：含立即数操作数**
  - | 31 ~ 26 | 25 ~ 21 | 20 ~ 16 | 15 ~ 0 |
    | :-----: | :-----: | :-----: | :----: |
    |   op    |   rs    |   rt    |  imm   |

- **J类型：含转移地址**

    - | 31 ~ 26 | 25 ~ 0  |
      | :-----: | :-----: |
      |   op    | address |

### 五大阶段

1. **取值（IF）：从指令寄存器中取出32位指令并将PC+=4**
2. **译码（ID）：读取操作数和相应字段**
3. **执行（EX）：算术、移位、逻辑、比较、加载/存储**
4. **访存（MEM）：对存储器的读写（仅加载/存储指令用到）**
5. **回写（WB）：指令执行结果写回到寄存器**

## 使用的工具

- **[VSCODE](https://code.visualstudio.com/)**
- vscode useful extensions
  - **[Batch Runner](https://marketplace.visualstudio.com/items?itemName=NilsSoderman.batch-runner)**
  - **[Chinese (Simplified) (简体中文) Language Pack for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=MS-CEINTL.vscode-language-pack-zh-hans)**
  - **[Code alignment](https://marketplace.visualstudio.com/items?itemName=cpmcgrath.codealignment-vscode)**
  - **[Colorful Comments](https://marketplace.visualstudio.com/items?itemName=ParthR2031.colorful-comments)**
  - **[Comment Translate](https://marketplace.visualstudio.com/items?itemName=intellsmi.comment-translate)**
  - **[ctagsxs](https://marketplace.visualstudio.com/items?itemName=jtanx.ctagsx)**
  - **[Error Lens](https://marketplace.visualstudio.com/items?itemName=usernamehw.errorlens)**
  - **[filesize](https://marketplace.visualstudio.com/items?itemName=mkxml.vscode-filesize)**
  - **[koroFileHeader](https://marketplace.visualstudio.com/items?itemName=OBKoro1.korofileheader)**
  - **[Material Product Icons](https://marketplace.visualstudio.com/items?itemName=PKief.material-product-icons)**
  - **[MIPS Support](https://marketplace.visualstudio.com/items?itemName=kdarkhan.mips)**
  - **[One Dark Pro](https://marketplace.visualstudio.com/items?itemName=zhuangtongfa.Material-theme)**
  - **[Project Manager](https://marketplace.visualstudio.com/items?itemName=alefragnani.project-manager)**
  - **[Rainbow End](https://marketplace.visualstudio.com/items?itemName=jduponchelle.rainbow-end)**
  - **[TCL](https://marketplace.visualstudio.com/items?itemName=rashwell.tcl)**
  - **[Verilog Highlight](https://marketplace.visualstudio.com/items?itemName=tzylee.verilog-highlight)**
  - **[Verilog Snippet](https://marketplace.visualstudio.com/items?itemName=czh.czh-verilog-snippet)**
  - **[Verilog_Testbench](https://marketplace.visualstudio.com/items?itemName=Truecrab.verilog-testbench-instance)**
  - **[verilog-formatter](https://marketplace.visualstudio.com/items?itemName=IsaacT.verilog-formatter)**
  - **[Verilog-HDL/SystemVerilog/Bluespec SystemVerilog](https://marketplace.visualstudio.com/items?itemName=mshr-h.VerilogHDL)**
  - **[vscode-icons](https://marketplace.visualstudio.com/items?itemName=vscode-icons-team.vscode-icons)**
- **[ctags](https://github.com/universal-ctags/ctags)**
  - 可执行文件 [ctags-2022-07-13_p5.9.20220710.0-8-g7b5c7ef-x64.zip](https://github.com/universal-ctags/ctags-win32/releases/download/2022-07-13%2Fp5.9.20220710.0-8-g7b5c7ef/ctags-2022-07-13_p5.9.20220710.0-8-g7b5c7ef-x64.zip)
- [**Istyle**](http://code.google.com/p/istyle-verilog-formatter) 
  - 可执行文件 [iStyle_windows_x86_64.zip](https://github.com/0qinghao/istyle-verilog-formatter/releases/download/v1.21_x86_64/iStyle_windows_x86_64.zip)
- [**iverilog(Icarus Verilog)**](https://github.com/steveicarus/iverilog) 
  - 可执行文件 [iverilog-v12-20220611-x64_setup.exe](http://bleyer.org/icarus/iverilog-v12-20220611-x64_setup.exe)
- [**Modelsim**](http://www.modelsim.com/) 

## 参考书目

1. 雷思磊著. 自己动手写CPU. 北京：电子工业出版社, 2014.09.  978-7-121-23950-2
2. （英）斯威特曼（Sweetman，D.）著. MIPS体系结构透视 第2版. 北京：机械工业出版社, 2007.02.  978-7-121-23950-2			 				 	

## 预期目标

- [ ] 实现预期的指令
- [ ] 通过时序分析，在FPGA开发板上实现预期功能
- [ ] 完备代码注释，完整分析芯片架构

## 模块划分

- [取指 pc_reg](./pc_reg.v)
- [译码 id](./id.v)
- [执行 ex](./ex.v)
- [访存 mem](./mem.v)
- [回写 wb](./mem_wb.v)
- ......

## 可用指令

|  指令名  |    31 ~ 26     | 25 ~ 21 | 20 ~ 16 | 15 ~ 11 | 10 ~ 6 |    5 ~ 0    |
| :------: | :------------: | :-----: | :-----: | :-----: | :----: | :---------: |
| **ORI**  |  ORI *001101*  |   rs    |   rt    |   imm   |  imm   |     imm     |
| **AND**  | SPECIAL 000000 |   rs    |   rt    |   rd    | 00000  | AND 100100  |
|  **OR**  |    SPECIAL     |   rs    |   rt    |   rd    | 00000  |  OR 100101  |
| **XOR**  |    SPECIAL     |   rs    |   rt    |   rd    | 00000  | XOR 100110  |
| **NOR**  |    SPECIAL     |   rs    |   rt    |   rd    | 00000  | NOR 100111  |
| **ANDI** |  ANDI 001100   |   rs    |   rt    |   imm   |  imm   |     imm     |
| **XORI** |  XORI 001110   |   rs    |   rt    |   imm   |  imm   |     imm     |
| **LUI**  |   LUI 001111   |  00000  |   rt    |   imm   |  imm   |     imm     |
| **SLL**  |    SPECIAL     |  00000  |   rt    |   rd    |   sa   | SLL 000000  |
| **SRL**  |    SPECIAL     |  00000  |   rt    |   rd    |   sa   | SRL 000010  |
| **SRA**  |    SPECIAL     |  00000  |   rt    |   rd    |   sa   | SRA 000011  |
| **SLLV** |    SPECIAL     |   rs    |   rt    |   rd    | 00000  | SLLV 000100 |
| **SRLV** |    SPECIAL     |   rs    |   rt    |   rd    | 00000  | SRLV 000110 |
| **SRAV** |    SPECIAL     |   rs    |   rt    |   rd    | 00000  | SRAV 000111 |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
## 贡献者

- MartPeggy


## License

[MIT © Richard McRichface.](./LICENCE)
