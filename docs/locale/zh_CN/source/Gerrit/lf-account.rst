申请 Linux Foundation 账号
=====================================

向 Hyperledger Fabric 贡献代码需要 `Linux Foundation <https://linuxfoundation.org/>`__ 
账户，如果你没有的话，请根据下面的步骤创建一个。

创建 Linux Foundation ID
------------------------------

1. 登录 `Linux Foundation ID 网站 <https://identity.linuxfoundation.org/>`__ 。

2. 选择 ``I need to create a Linux Foundation ID`` 选项，然后填写出现的表单。

3. 等待几分钟，查看邮箱中的邮件是否有如下内容："Validate your Linux Foundation ID email"。

4. 打开收到的链接来验证你的邮箱。

5. 验证你的浏览器显示了如下信息： ``You have successfully validated your e-mail address`` 。

6. 点击 ``Sign In`` 来登录 Gerrit， 然后使用你的 Linux Foundation account ID 进行登录。

在 Gerrit 上配置 SSH
-----------------------------

Gerrit 使用 SSH 来和 Git 客户端交互。如果你已经有了 SSH 密钥对，那么你可以跳过这个部分。

下述步骤解释了如何在 Linux 环境下生成 SSH 密钥对，不同操作系统的命令有所不同，请在你的操作系统上进行相应的操作。

首先，使用如下命令创建 SSH 密钥对：

::

    ssh-keygen -t rsa -C "John Doe john.doe@example.com"

**Note:** 这会提示你输入一个密码来保护这个唯一的私钥。请对密码进行保密，不要填写空格。

生成的 SSH 密钥对可以在 ``~/.ssh/id_rsa`` 和 ``~/.ssh/id_rsa.pub`` 文件中找到。

接下来，把在 ``id_rsa`` 文件中的私钥添加到密钥库中，例如：

::

    ssh-add ~/.ssh/id_rsa

最后，将生成的密钥对的公钥添加到 Gerrit 服务端，按照如下步骤：

1. 进入 `Gerrit <https://gerrit.hyperledger.org/r/#/admin/projects/fabric>`__ 。

2. 点击右上角你的账号名。

3. 从弹出的菜单中选择 ``Settings`` 。

4. 在左侧的菜单上，点击 ``SSH Public Keys`` 。

5. 复制你的公钥的内容 ``~/.ssh/id_rsa.pub`` 点击 ``Add key`` 。

**Note:**  ``id_rsa.pub`` 文件可以在文本编辑器中打开，确保选中该文件所有的内容，复制粘贴到 Gerrit 的 ``Add SSH key`` 窗口中。

**Note:** SSH 密钥生成指南是假设你用默认命名的前提下操作的。当然也可以使用不同的命名生成多个 SSH 密钥对。参考 `ssh-keygen <https://en.wikipedia.org/wiki/Ssh-keygen>`__ 文档进行操作。一旦你生成了一个不是默认名字的密钥对，你需要配置 SSH 对 Gerrit 使用正确的密钥。在这种情况下，你需要仿照下面的模板创建 ``~/.ssh/config`` 配置文件。

::

    host gerrit.hyperledger.org
     HostName gerrit.hyperledger.org
     IdentityFile ~/.ssh/id_rsa_hyperledger_gerrit
     User <LFID>

LFID 是你的 Linux Foundation ID，IdentityFile 是你生成的公钥的名字。

**Warning:** 潜在的危险! 不要拷贝你的私钥 ``~/.ssh/id_rsa`` 仅仅使用公钥 ``~/.ssh/id_rsa.pub`` 。

检出源代码
----------------------------

一旦你设置了之前讲的 SSH，你可以通过下面的命令克隆源代码：

::

    git clone ssh://<LFID>@gerrit.hyperledger.org:29418/fabric fabric

你已经成功地在你的电脑上检出了源代码。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/

