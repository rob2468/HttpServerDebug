# 服务端接口。

## file_preview

获取文件内容。

### /api/file_preview?file_path=%@

返回指定路径的文件内容。若指向的路径为文件夹，zip压缩后返回。

#### 参数：

file_path：

使用绝对路径直接返回该路径内容；

使用相对路径必须为以下情况开头：

Documents：[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]，以该目录为根目录；

Library：[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject]，以该目录为根目录；

tmp：NSTemporaryDirectory()，以该目录为根目录。

## send_info

向app发送信息，HSD通过delegate将信息抛给宿主app，处理结果在responseData中返回。支持GET方法和POST方法。

### /api/send_info?info=%@

GET方法。向app发送字符串信息。

#### 参数：

info：

发送给app的信息，字符串类型。注意：需进行编码，不能包含URI保留字符（如?&）。

### /api/send_info

POST方法。向app发送字符串信息，信息在HTTP body中传输，支持的Content-Type为text/plain和application/x-www-form-urlencoded。
