---
title: "How to: Getting started with Windows LAPS via Intune"
date: 2023-05-26T19:23:32
lastmod: 2023-06-16T07:25:56
slug: "how-to-getting-started-with-windows-laps-via-intune"
wpid: 221
categories: ["Azure AD", "Microsoft Entra", "Microsoft Intune", "Windows LAPS"]
tags: ["Account Protection", "Azure AD", "Local Administrator", "Microsoft Entra", "Microsoft Intune", "Remediation", "Windows LAPS"]
description: "Step-by-step guide to Windows LAPS on Azure AD joined devices with Intune: enable it, create a local admin account, set the policy and view the password."
---

In this blogpost I will help you to get started with Windows LAPS via Intune. Windows LAPS is a feature that automatically manages and backs up the password of a local administrator account on your (in this case) Azure Active Directory-joined devices.

Windows LAPS is a long-awaited solution for AAD joined devices because the advice is to disable the default administrator account and then this could be the only backdoor to your AAD joined devices when you got locked out somehow. [**Why You Should Disable the Administrator Account | ITPro Today: IT News, How-Tos, Trends, Case Studies, Career Tips, More**](https://www.itprotoday.com/strategy/why-you-should-disable-administrator-account)

### Update: 07-06-2023

Today I learned it’s even easier to create a local admin account directly via Endpoint security | Account protection. See the **[Create local user account – Endpoint security | Account protection](#account-protection)** chapter for the latest update!

## Local users on a client before starting

This is how the local users look like on a device before following the guide below. Please note that the screenshot is taking on a Windows Sandbox. Therefore, the local administrator account is not disabled!

![Screenshot: Therefore, the local administrator account is not disabled!](/wp-content/uploads/2023/05/image-24-1024x293.png)

## Enabling Windows Laps

To get started with Windows LAPS first we must enable it through the Azure AD or Microsoft Entra Admin portal. In the Azure Active Directory blade on the left, you must choose:

- Devices –> All devices.

- Device settings.

- Set the slider for Enabling Azure AD Local Administrator Password Solution (LAPS) to **Yes**.

- Save.

![Screenshot: Save](/wp-content/uploads/2023/05/image-2-1024x876.png)

## Create a local user account

This is the part where it gets interesting. Since the Windows LAPS solution doesn’t create an administrator account for you, is this something that you want to do by yourself. There are a few ways to get there. 

- Via a configuration profile. A nice guide to follow for achieving this is: [**Create a local user account on Windows 10 with Microsoft Intune | Peter Klapwijk – In The Cloud 24-7 (inthecloud247.com)**](https://www.inthecloud247.com/create-a-local-user-account-on-windows-10-with-microsoft-intune/)

- Through a PowerShell script. The following post will help you with creating a local administrator: **[How to Create a New Local User with PowerShell — LazyAdmin](https://lazyadmin.nl/powershell/create-local-user/).**

- Via a Proactive Remediation, this is the way that this post will cover. I have chosen for this way because I don’t want to have a plain text password in my Intune environment. Also, if the local account is not there anymore for any reason it will be recreated again.

- **[Update 07-06-2023: Create the local admin account via Endpoint security | Account protection](#account-protection)!**

### Proactive remediation

Keep in mind: this option will set a random password on your local administrator. So, before the LAPS configuration kicks in there is a brief period that there is a local administrator with a password that you don’t know.

Also, I highly advise to add a managed Azure Active Directory group with Azure AD accounts that get also local administrator permissions on the Azure AD joined devices.

So, let’s get started with the actual creation of the local administrator account via Proactive Remediation!

First, go to **Reports** in your Microsoft Intune environment.

![Screenshot: First, go to Reports in your Microsoft Intune environment](/wp-content/uploads/2023/05/image-19-664x1024.png)

In the **Endpoint analytics** section, go to **Proactive remediations** and **Create script package**.

![Screenshot: In the Endpoint analytics section, go to Proactive remediations and Create script package](/wp-content/uploads/2023/05/image-20-1024x565.png)

- Give the script an obvious but clear name, guided with a brief description.

- Fill in who the publisher is of the script.

![Screenshot: Fill in who the publisher is of the script](/wp-content/uploads/2023/05/image-21-1024x717.png)

You can grab a copy of the detection and remediation script on my [**Github**](https://github.com/jeroenebus/remediations/tree/main/Create_Local_Admin).

- Upload the detection script.

- Upload the remediation script.

- Switch the toggle for running the script in a 64-bit PowerShell to **Yes**.

- Save the script.

![Screenshot: Save the script](/wp-content/uploads/2023/05/image-23-1007x1024.png)

- Target the script to a specific device group or to all your Intune managed devices.

- Create a schedule for how often the remediation should run. My advice is once in the 8 hours, this represents a typical working day.

- Click **Apply**.

- Choose now for **Next**.

![Screenshot: Choose now for Next](/wp-content/uploads/2023/05/image-22-1024x859.png)

The creation of the local administrator account is now starting for your targeted devices.

### Update 07-06-23: Endpoint security | Account protection

When creating the local administrator account via this way, the local account is directly member of the local administrators, and you don’t have to worry about an account without a password or a password you don’t know about because it’s randomly generated.

- Go to **Endpoint security** in the Microsoft Intune tenant.

- Select the **Account protection** blade.

- Choose **Create Policy**.

- Select the platform you want to target it to.

- Choose **Local user group membership**.

- **Create**.

![Screenshot: Create](/wp-content/uploads/2023/05/image-11-1024x673.png)

Give the policy a proper name and description and click **Next**.

![Screenshot: Give the policy a proper name and description and click Next](/wp-content/uploads/2023/06/image-9-1024x515.png)

In the following screen select **Manual** and click on **Add user(s)**, followed by filling in a name for the local admin account. Click on **OK** and **Next** to continue.

![Screenshot: Click on OK and Next to continue](/wp-content/uploads/2023/06/image-10-1024x316.png)

After assigning the policy to a group the local admin account will be created on your devices. Because adding the account via this way the account will automatically be added to the local administrators group, so this will mean you can skip the next chapter!

## Make the local user a user with administrator privileges

Now that we created a Proactive Remediation for creating a local administrator account on the AAD joined devices it’s time to add this account to the local administrators group.

- Go to **Endpoint security** in the Microsoft Intune tenant.

- Select the **Account protection** blade.

- Choose **Create Policy**.

- Select the platform you want to target it to.

- Choose **Local user group membership**.

- **Create**.

![Screenshot: Create](/wp-content/uploads/2023/05/image-11-1024x673.png)

7. Give the policy an obvious but clear name, guided with a brief description.  
8. Choose **Next**.

![Screenshot: Choose Next](/wp-content/uploads/2023/05/image-12-1024x548.png)

To add the local user account to the local administrator group you will have to follow the next steps.

- At the **User selection type** part choose **Manual**.

- Click on **Select users/groups**.

- Type the name of your local user that must be added to the local administrators group.

- Click on **OK**.

![Screenshot: Click on OK](/wp-content/uploads/2023/05/image-13-1024x358.png)

## Configure the Local Admin Password Solution (Windows LAPS)

Now it’s time to configure the Windows LAPS solution!

Also, in the Account Protection section we are going to create a new policy.

- Select the platform you want to target it to.

- Choose **Local admin password solution (Windows LAPS)**.

- Click on **Create**.

![Screenshot: Click on Create](/wp-content/uploads/2023/05/image-14-1024x432.png)

4. Give the policy an obvious but clear name, guided with a brief description.  
5. Choose for **Next**.

![Screenshot: Choose for Next](/wp-content/uploads/2023/05/image-15-1024x678.png)

This is the part where you can define the requirements for when the password must be rotated, how many and what kind of characters the password should look like etc.

- Since this guide helps you thought the configuration for Azure AD joined devices you are going to choose **Backup the password to Azure AD only**.

- Toggle the switch to configured if you want to rotate the password after a certain number of days.

- Choose how many days that must be.

- Switch the toggle if you have created an own local administrator account.

- Give the account name of the local administrator account where the password must be rotated of.

- Choose your password complexity.

- Switch the toggle if you want to set a password length.

- Specify what the length must be.

- What action should occur when the password is being used? I want to reset the password and log off the local administrator if the grace period is expired.

- Switch the toggle when you want to use a delay for the action when the password is used.

- Specify how many hours the delay should take.

![Screenshot: Specify how many hours the delay should take](/wp-content/uploads/2023/05/image-18-852x1024.png)

## After the configuration of Windows LAPS

This is how the local users look like on a device after following the guide above. Again, please note that the screenshot is taking on a Windows Sandbox. Therefore, the local administrator account is not disabled!

![Screenshot: Therefore, the local administrator account is not disabled!](/wp-content/uploads/2023/05/image-25-1024x257.png)

## How to view the local administrator password?

So, now we successfully configured Windows LAPS there is a change you would use it. There are a few ways to view to current local administrator password.

### Microsoft Entra

In Microsoft Entra go to the **All devices** section and select the device where you want to rotate the password on.

![Screenshot: In Microsoft Entra go to the All devices section and select the device where you want to rotate the…](/wp-content/uploads/2023/06/image.png)

On the device screen on the left click on **Local administrator password recovery** followed by **Show local administrator password** and click on the **Show** button. When you show the password but not going to use it, the password will not be rotated!

![Screenshot: When you show the password but not going to use it, the password will not be rotated!](/wp-content/uploads/2023/06/image-2-1024x232.png)

### Microsoft Intune

Another way is to view the password through Microsoft Intune. Go to the **Devices** blade, followed by **All devices** and choose the device where you want to view the local administrator password from.

![Screenshot: Go to the Devices blade, followed by All devices and choose the device where you want to view the…](/wp-content/uploads/2023/06/image-3.png)

On the device screen on the left click on **Local admin password** followed by **Show local administrator password** and click on the **Show** button. When you show the password but not going to use it, the password will not be rotated!

![Screenshot: When you show the password but not going to use it, the password will not be rotated!](/wp-content/uploads/2023/06/image-8-1024x423.png)

## How to rotate the local administrator password manually?

We successfully configured Windows LAPS and the password on the devices rotates 24 hours after using it. But there is also a way to rotate the password manually. For example, if the password is used and you want to directly rotate it. This can be done through the Microsoft Intune portal.

Go to the **Devices** blade, followed by **All devices** and choose the device where you want to rotate the local administrator password for.

![Screenshot: Go to the Devices blade, followed by All devices and choose the device where you want to rotate the…](/wp-content/uploads/2023/06/image-3.png)

In the **Overview** blade click on the three dots in the upper right corner and select **Rotate local admin password**.

![Screenshot: In the Overview blade click on the three dots in the upper right corner and select Rotate local…](/wp-content/uploads/2023/06/image-7-1024x474.png)

That’s all! The local administrator password on the device will be rotated when the device is connected.

## Summary

What did this guide help you with?

- Creating a local user account.

- Adding the local user account to the local administrators group.

- Enabling Windows LAPS thought the Microsoft Entra portal.

- Configuring the Windows LAPS solution.

- Understanding the concept of Proactive Remediation.

- Understanding the need of a backdoor on your Azure AD joined devices.

- Viewing the local administrator password for a specific device.

- Rotating the local administrator password manually for a specific device.

Hopefully, you enjoyed reading this blog and it helped you to configure Windows LAPS.

Thanks for reading!

