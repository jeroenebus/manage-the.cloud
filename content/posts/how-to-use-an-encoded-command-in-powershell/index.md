---
title: "How to use an encoded command in PowerShell?"
date: 2023-12-20T21:07:48
lastmod: 2023-12-20T21:18:01
slug: "how-to-use-an-encoded-command-in-powershell"
wpid: 751
categories: ["PowerShell"]
tags: ["Base64", "Decode", "Encode", "PowerShell"]
description: "How to encode and decode a PowerShell command with Base64, for example to store it in a scheduled task, and run it with -EncodedCommand."
---

Sometimes you want to store a PowerShell command not readable at first read. This is so called an obfuscation. It is an action to make something unreadable for humans. For example, this could be used when storing a PowerShell command in a task schedular job or something similar.

## How to encode your command?

First you must store your command in a variable, for example $PlainCommand. After that you encode that variable with the following command: 

```
[Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($string))
```

![Screenshot: After that you encode that variable with the following command](/wp-content/uploads/2023/12/image-6-1024x153.png)

## How to run the encoded command?

To run the encoded command simple, execute powershell.exe with the parameter -EncodedCommand followed by your variable.

![Screenshot: To run the encoded command simple, execute powershell.exe with the parameter -EncodedCommand…](/wp-content/uploads/2023/12/image-7.png)

## How to decode the encoded command?

To decode the encoded variable, you can use:

```
[Text.Encoding]::Utf8.GetString([Convert]::FromBase64String($EncodedCommand))
```

![Screenshot: To decode the encoded variable, you can use](/wp-content/uploads/2023/12/image-9-1024x87.png)

## Another method to encode/ decode!

A nice way to also decode and encode your command is via the Base64 Decode and Encode website:

[**Base64 Decode and Encode – Online**](https://www.base64decode.org/)

![Screenshot: Base64 Decode and Encode – Online](/wp-content/uploads/2023/12/image-10.png)

And of course, the same for encoding your command!

![Screenshot: And of course, the same for encoding your command!](/wp-content/uploads/2023/12/image-12.png)

## How to decode a PowerShell command from a running process?

Microsoft has a nice write up about how to decode running process, this because PowerShell stores running commands in also as an encoded command:

[**https://learn.microsoft.com/en-us/powershell/scripting/samples/decode-powershell-command-from-a-running-process?view=powershell-7.4**](https://learn.microsoft.com/en-us/powershell/scripting/samples/decode-powershell-command-from-a-running-process?view=powershell-7.4)

Thank for reading this short blog, hopefully it was informational and helpful when you need to encode your commands!

