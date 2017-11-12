# 服务端接口。

## file_preview

获取文件内容。

### /file_preview?file_path=%@

返回指定路径的文件内容。若指向的路径为文件夹，zip压缩后返回。

#### 参数：

file_path：

使用绝对路径直接返回该路径内容；

使用相对路径必须为以下情况开头：

Documents：[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]，以该目录为根目录；

Library：[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject]，以该目录为根目录；

tmp：NSTemporaryDirectory()，以该目录为根目录。
