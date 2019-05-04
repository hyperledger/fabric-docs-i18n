Requesting a Linux Foundation Account-申请一个Linux Foundation账号
=====================================

Contributions to the Hyperledger Fabric code base require a
`Linux Foundation <https://linuxfoundation.org/>`__
account --- follow the steps below to create one if you don't
already have one.

贡献Hyperledger Fabric的代码需要一个
`Linux Foundation <https://linuxfoundation.org/>`__ 
账户---如果你没有的话，根据下面的步骤来创建一个。

Creating a Linux Foundation ID - 创建一个Linux Foundation ID
------------------------------

1. Go to the `Linux Foundation ID
   website <https://identity.linuxfoundation.org/>`__.

1. 登录 `Linux Foundation ID 网站 <https://identity.linuxfoundation.org/>`__ 。

2. Select the option ``I need to create a Linux Foundation ID``, and fill
   out the form that appears.

2. 选择 ``I need to create a Linux Foundation ID`` 选项，然后填写出现的表单。

3. Wait a few minutes, then look for an email message with the subject line:
   "Validate your Linux Foundation ID email".

3. 等待几分钟，查看邮箱中的邮件是否有如下行：
    "Validate your Linux Foundation ID email"。

4. Open the received URL to validate your email address.

4. 打开收到的链接来验证你的邮箱。

5. Verify that your browser displays the message
   ``You have successfully validated your e-mail address``.

5. 验证你的浏览器显示来如下信息
   ``You have successfully validated your e-mail address`` 。

6. Access Gerrit by selecting ``Sign In``, and use your new
   Linux Foundation account ID to sign in.

6. 通过 ``Sign In`` 访问Gerrit， 然后使用你的
   Linux Foundation account ID进行登录。

Configuring Gerrit to Use SSH-在Gerrit上配置SSH
-----------------------------

Gerrit uses SSH to interact with your Git client. If you already have an SSH
key pair, you can skip the part of this section that explains how to generate one.

Gerrit使用SSH来和Git客户端交互。如果你已经有了SSH密钥对，那么你可以跳过解释怎么生成SSH密钥对的部分。

What follows explains how to generate an SSH key pair in a Linux environment ---
follow the equivalent steps on your OS.

下述步骤解释了如何在Linux环境下生成SSH密钥对---可以在你的操作系统上进行等价的步骤。

First, create an SSH key pair with the command:

首先，使用如下命令创建SSH密钥对：

::

    ssh-keygen -t rsa -C "John Doe john.doe@example.com"

**Note:** This will ask you for a password to protect the private key as
it generates a unique key. Please keep this password private, and DO NOT
enter a blank password.

**Note:** 这会提示你输入一个密码来保护这个唯一的私钥。请对密码进行保密，不要填写空格。

The generated SSH key pair can be found in the files ``~/.ssh/id_rsa`` and
``~/.ssh/id_rsa.pub``.

生成的SSH密钥对可以在 ``~/.ssh/id_rsa`` 和 ``~/.ssh/id_rsa.pub`` 文件中找到。

Next, add the private key in the ``id_rsa`` file to your key ring, e.g.:

接下来，把在 ``id_rsa`` 文件中的私钥添加到key ring中，例如：

::

    ssh-add ~/.ssh/id_rsa

Finally, add the public key of the generated key pair to the Gerrit server,
with the following steps:

最后，将生成的密钥对的公钥添加到Gerrit服务端，按照如下步骤：

1. Go to
   `Gerrit <https://gerrit.hyperledger.org/r/#/admin/projects/fabric>`__.

1. 进入
   `Gerrit <https://gerrit.hyperledger.org/r/#/admin/projects/fabric>`__ 。

2. Click on your account name in the upper right corner.

2. 点击右上角你的账号名。

3. From the pop-up menu, select ``Settings``.

3. 从弹出的菜单中选择 ``Settings`` 。

4. On the left side menu, click on ``SSH Public Keys``.

4. 在左侧的菜单上，点击 ``SSH Public Keys`` 。

5. Paste the contents of your public key ``~/.ssh/id_rsa.pub`` and click
   ``Add key``.

5. 复制你的公钥的内容 ``~/.ssh/id_rsa.pub`` 点击 ``Add key`` 。

**Note:** The ``id_rsa.pub`` file can be opened with any text editor.
Ensure that all the contents of the file are selected, copied and pasted
into the ``Add SSH key`` window in Gerrit.

**注意:**  ``id_rsa.pub`` 文件在文本编辑器中打开，确保该文件所有的内容都被选中，
复制粘贴到Gerrit的 ``Add SSH key`` 窗口中。

**Note:** The SSH key generation instructions operate on the assumption
that you are using the default naming. It is possible to generate
multiple SSH keys and to name the resulting files differently. See the
`ssh-keygen <https://en.wikipedia.org/wiki/Ssh-keygen>`__ documentation
for details on how to do that. Once you have generated non-default keys,
you need to configure SSH to use the correct key for Gerrit. In that
case, you need to create a ``~/.ssh/config`` file modeled after the one
below.

**Note:** SSH密钥生成指南是基于你是用默认的命名的假设前提下操作的。
当然也可以生成多个SSH迷药对，使用不同的命名。参考
`ssh-keygen <https://en.wikipedia.org/wiki/Ssh-keygen>`__ 
文档进行操作。一旦你生成了一个不是默认名字的密钥对，你需要配置SSH对Gerrit
使用正确的密钥。在这种情况下，你需要仿照下面的模型创建 ``~/.ssh/config`` 配置文件。

::

    host gerrit.hyperledger.org
     HostName gerrit.hyperledger.org
     IdentityFile ~/.ssh/id_rsa_hyperledger_gerrit
     User <LFID>

where <LFID> is your Linux Foundation ID and the value of IdentityFile is the
name of the public key file you generated.

LFID是你的Linux Foundation ID，IdentityFile是你生成的公钥的名字。

**Warning:** Potential Security Risk! Do not copy your private key
``~/.ssh/id_rsa``. Use only the public ``~/.ssh/id_rsa.pub``.

**Warning:** 潜在的危险! 不要拷贝你的私钥
``~/.ssh/id_rsa`` 仅仅使用公钥 ``~/.ssh/id_rsa.pub`` 。

Checking Out the Source Code-检出源代码
----------------------------

Once you've set up SSH as explained in the previous section, you can clone
the source code repository with the command:

一旦你设置了之前讲的SSH，你可以通过下面的命令克隆源代码：

::

    git clone ssh://<LFID>@gerrit.hyperledger.org:29418/fabric fabric

You have now successfully checked out a copy of the source code to your
local machine.

你已经成功地在你的电脑上检出了源代码。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/

