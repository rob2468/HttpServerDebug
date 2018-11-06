# 服务端接口规范

## 一、请求

存在两种请求方式：GET 和 POST

## 二、响应

response data 为 json 格式。

```
{
    "errno": "0",
    "data": xxx
}
```

|字段|类型|说明|
|----|----|----|
|errno|int|错误码，成功0，错误-1|
|data|any|业务数据|

## 三、API 列表

### 1. file_preview

描述：获取文件内容。

request，GET 方法

```
/api/file_preview?file_path=%@
```

|参数|说明|
|----|----|
|file_path|使用绝对路径直接返回该路径内容。<br>使用相对路径必须为以下情况开头：<br>Documents：[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]，以该目录为根目录；<br>Library：[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject]，以该目录为根目录；<br>tmp：NSTemporaryDirectory()，以该目录为根目录。|

response

返回指定路径的文件内容。若指向的路径为文件夹，zip压缩后返回。

### 2. send_info

描述：向 App 发送信息，HSD 通过 delegate 将信息抛给宿主 App，处理结果在 responseData 中返回。支持 GET 方法和 POST 方法。

request，GET 方法

```
/api/send_info?info=%@
```

|参数|说明|
|----|----|
|info|发送给 App 的信息，字符串类型。注意：需进行编码，不能包含URI保留字符（如?&）。|

request，POST 方法

```
/api/send_info
```

向 App 发送字符串信息，信息在 HTTP body 中传输，支持的 Content-Type 为 text/plain 和 application/x-www-form-urlencoded。

### 3. file_explorer

描述：获取文件信息，或修改文件。

request，GET 方法

```
/api/file_explorer?file_path=xxx&action=delete
```

|参数|说明|
|----|----|
|file_path|文件或文件夹完整路径|
|action|字段不存在或为空：对于文件，请求文件属性；对于文件夹，请求文件夹内内容信息。<br>delete：删除文件或文件夹。|
