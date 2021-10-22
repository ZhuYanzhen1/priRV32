# priRV32

&nbsp;&nbsp;&nbsp;&nbsp;![Version](https://img.shields.io/badge/Version-1.0.1-brightgreen.svg)&nbsp;&nbsp;![Build](https://img.shields.io/badge/Build-Passed-success.svg)&nbsp;&nbsp;![License](https://img.shields.io/badge/License-AGPL-blue.svg)

&nbsp;&nbsp;&nbsp;&nbsp;priRV32是一个能够实现RV32IM和RV机器模式的内核，这个内核目前还在开发过程中。

***

### 前言

&nbsp;&nbsp;&nbsp;&nbsp;第一次听到RISC-V这个词大概是2018年，当时觉得它也就是和MIPS这些CPU架构没什么区别，因此也就不以为然了。直到19年年底，RISC-V这个词开始频繁地出现在微信和其他网站上，此时我再也不能无动于衷了，于是开始在网上搜索有关它的资料，开始知道有国内的一些RISC-V论坛，也有一些大佬独立完成了RISC-V SoC的设计如tinyriscv、picorv32等，我也买来了基于RISC-V内核的单片机GD32VF103来玩，照着数据手册写了例程跑，当时没有感到和其它单片机有什么区别。<br>
&nbsp;&nbsp;&nbsp;&nbsp;后来大一下班学期由于疫情的原因在家学习，看到在淘宝上已经有相关的书籍卖了。从那之后一个“从零开始写RISC-V处理器”的想法开始不断地出现在我的脑海里。当时由于没有接触过计算机底层的知识（只看过ARM Cortex-M3内核权威指南），所以没怎么看懂。大二一整年都在补计算机相关的知识，有计算机系统结构、计算机组成原理、数据结构、Linux内核等等。现在大三转到集成电路后，开设有计算机系统结构的课程，所以借此机会想把一个简单的RV内核实现出来。<br>
&nbsp;&nbsp;&nbsp;&nbsp;设计之初我打算使用完全开源的FPGA开发工具链（综合yosys、布线nextpnr、时序分析icetime、打包icepack、烧录iceprog），由于这套工具链支持的FPGA芯片在国内难以买到而且资料很少，所以最后不得已地还是使用了在国内容易买到的Cyclone IV系列芯片EP4CE10F17C8N并使用Quartus Lite Edition进行开发。<br>
&nbsp;&nbsp;&nbsp;&nbsp;由于这是我设计的第一个RV32内核，考虑到自己水平很低，所以这个内核只打算实现RV32IM指令集架构，内核主频为36MHz，对标当前的8051及ARM Cortex-M0内核。结合功能来看，给这个内核起名为priRV32，寓意为“初级的RV32内核”。由于第一次写较为大型的项目，在语言规范以及实现上面有许多稚嫩和不足之处还请广大开发者海涵。

***

### 目录结构

+ core：priRV32内核有关的源码文件，主要包括了取指译码单元和执行写回单元。
+ fpga：基于Quartus Lite Edition集成开发环境的FPGA项目文件。
+ periph：一些简单外设接口的源码文件。
  + uart：UART串口外设的源码文件。
+ tb：内核及外设的测试脚本文件。

***

### 许可证

源代码根据[AGPL-3.0许可证](https://github.com/ZhuYanzhen1/priRV32/blob/main/LICENSE)发布。

**组织：AcmeTech <br>
作者：朱彦臻<br>
维护人：朱彦臻, 2208213223@qq.com**

&nbsp;&nbsp;&nbsp;&nbsp;该产品已经在Windows 10、Ubuntu 18.04和20.04下进行了测试。这是一个学习型代码，希望它经常更改，并且不承认任何特定用途的适用性。