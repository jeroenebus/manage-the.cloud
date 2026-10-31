---
title: "Set a Microsoft Intune application requirement PowerShell script"
date: 2023-05-08T21:38:47
lastmod: 2023-06-15T07:33:37
slug: "set-a-microsoft-intune-application-requirement-powershell-script"
categories: ["Autopilot", "Microsoft Intune"]
tags: ["0x81036502", "Autopilot", "Manage-The.Cloud", "Microsoft Intune", "PowerShell"]
description: "Stop an Intune app from installing on the wrong devices by using a PowerShell requirement script, for example to target only HP hardware."
---

Did you ever faced the fact that an Intune application is being installed on devices that you rather not want to have that certain application? For example, an application that is needed for a specific vendor e.g. all HP devices and not have to be installed on device from other vendors or virtual machines.

Consider the following:

- Application is assigned required.

- New Autopilot enrollment (so there is no hardware inventory).

- Device has been wiped (hardware inventory is being deleted).

When targeting an application with a required assignment to devices and in the Enrollment Status Page the following settings are enabled the Autopilot enrollment will fail with the 0x81036502 error.

- Block device use until all apps and profiles are installed.

- Block device use until required apps are installed if they are assigned to the user/device.

![Screenshot: Block device use until required apps are installed if they are assigned to the user/device](/wp-content/uploads/2023/05/image-7.png)

Well, let’s create an application PowerShell script requirement for this!

In your browser go to [**https://intune.microsoft.com**](https://intune.microsoft.com) and select **Apps**.

![Screenshot: In your browser go to https://intune.microsoft.com and select Apps](/wp-content/uploads/2023/05/image-3.png)

On the following page go to **Windows**.

![Screenshot: On the following page go to Windows](/wp-content/uploads/2023/05/image-9.png)

Choose the application where you want to set a requirement script on.

![Screenshot: Choose the application where you want to set a requirement script on](/wp-content/uploads/2023/05/image.png)

Select **Properties** followed by **Edit**.

![Screenshot: Select Properties followed by Edit](/wp-content/uploads/2023/05/image-5.png)

In the **Edit application** section, choose **+ Add**.

![Screenshot: In the Edit application section, choose + Add](/wp-content/uploads/2023/05/image-1.png)

In the Requirement type, choose **Script**.

![Screenshot: In the Requirement type, choose Script](/wp-content/uploads/2023/05/image-4.png)

Fill in the required fields like:

- Requirement type:

- Script name:

- Output data type:

- Operator

- Value

Upload the script that can be found on my [**GitHub**](https://github.com/jeroenebus/powershell-snippets/blob/1c7368aa5d121ecf9836ce1e5dfb290237b64245/Check-Device.ps1) and choose **OK**.

![Screenshot: Upload the script that can be found on my GitHub and choose OK](/wp-content/uploads/2023/05/image-6.png)

The application will no longer be installed on other devices that in this case HP devices. E.g. on devices from other brands or virtual machines.

