### 背书策略

**本节内容所面向的读者包括**：架构师，应用程序和智能合约开发人员

背书策略定义了要背书一项交易使其生效所需要的最小组织集合。要想对一项交易背书，组织的背书节点需要运行与该交易有关的智能合约，并对结果签名。当排序服务将交易发送给提交节点，节点们将各自检查该交易的背书是否满足背书策略。如果不满足的话，交易被撤销，不会对世界状态产生影响。

背书策略从以下两种不同的维度来发挥作用：既可以被设置为整个命名空间，也可被设置为单个状态键。它们是使用诸如 `AND` 和 `OR` 这样的逻辑表述来构成的。例如，在 PaperNet 中可以这样来用： MagnetoCorp 将一篇论文卖给 DigiBank，其背书策略可被设定为  `AND(MagnetoCorp.peer, DigiBank.peer)`，这就要求任何对该论文做出的改动需被 MagnetoCorp 和 DigiBank 同时背书。



<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
