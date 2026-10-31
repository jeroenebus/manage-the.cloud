---
title: "Windows Remote Management (WinRM) on Azure AD joined devices"
date: 2023-06-02T16:33:04
lastmod: 2023-06-16T07:31:31
slug: "windows-remote-management-winrm-on-azure-ad-joined-devices"
wpid: 292
categories: ["Azure AD", "Microsoft Intune", "PowerShell", "Windows LAPS", "Windows Remote Management"]
tags: ["Azure AD", "Certificates", "HTTP", "HTTPS", "PowerShell", "Windows Remote Management", "WinRM"]
description: "Get Windows Remote Management (WinRM) working on Azure AD joined devices, so you can connect remotely with PowerShell on cloud-only endpoints."
---

First, I would like to thank [**Anthony J. Fontanez**](https://twitter.com/ajf8729) for his wonderful post: **[Remotely Managing Windows Endpoints Part II: Azure AD Joined Hosts](https://anthonyfontanez.com/index.php/2022/11/04/remotely-managing-windows-endpoints-part-ii-azure-ad-joined-hosts/)**. This post (and also me struggling on how to get WinRM working on Azure AD joined devices) inspired me for writing this blogpost.

Let me start explaining what I was trying to achieve, what my pitfalls were and how I managed to achieve what I intended to achieve. It all started with a question from the customer I was working on. They recently migrated from all Windows 10 domain joined devices managed with Configuration Manager to Windows 11 Azure AD joined co-managed with Microsoft Intune.

For their day-to-day support, they would like to have the possibility to do some administrative tasks on devices by remotely connecting with an interactive session via PowerShell on the devices. Normally this would be quite easy with configuring WinRM for Domain Joined devices. But with Azure AD joined devices this is a little bit different.

Anthony did cover a nice piece of the entire process (so I’m not going to write the same stuff about that), so make sure reading the blogpost as is mentioned before continuing. Everything about enabling WinRM, configuring the WinRM HTTPS listener, DNS registration, configuration of DHCP/DNS, certificate deployment, opening Firewall rules etc.

This is the part where I going to jump in, because the blogpost ends with the conclusion that authentication via Azure AD is not going to work over HTTPS. This post is going to be about why this is not going to work, what I encountered and what the other possibilities are.

## Azure AD joined? WinRM? What is this all about?

**What is an Azure AD joined device?** 

This is device that is connected to and managed by Azure Active Directory (Azure AD). 

Azure AD is Microsoft’s cloud-based identity and access management service. It acts as a central hub for managing user accounts, security policies, and access to various resources. It allows organizations to control access to applications, devices, and data in a secure manner.

A device that is “Azure AD joined” means it has been connected to Azure AD and is recognized as a trusted device within the organization’s Azure AD environment.

Brooks Peppin also wrote a nice blogpost about everything you need to know about Azure AD Join!

[**A Beginners Guide to Azure AD Join – Everything you Need to Know – Brooks Peppin’s Blog**](https://brookspeppin.com/2023/04/26/a-beginners-guide-to-azure-ad-join/)

**What is Windows Remote Management (WinRM)?**

WinRM stands for Windows Remote Management. It’s a Microsoft technology that allows you to remotely manage and control Windows computers over a network. Think of it as a way to interact with a computer without being physically present in front of it.

## Next steps

Okay, and what now? What are the scenario’s that I have tested, what to choose?

- WinRM over HTTPS with Azure AD Credentials

- WinRM over HTTPS with a local account

- WinRM over HTTP with an Azure AD account

- WinRM over HTTPS with a LAPS for Windows (Intune managed) account

## WinRM over HTTPS with Azure AD credentials

Well, if you have read Antony’s blog you will probably know the outcome of this one. But let me guide you through this step-by-step. First of all, the preparations for WinRM have been taken.

- Windows Remote Management (WinRM) service is started on client/server side.

- Domain Firewall port (5986 – TCP) has been opened on the receiving side.

- Client certificate (Server Authentication) has been deployed from the receiving to the connecting side.

- Trusted hosts have been set on the connecting side.

- HTTPS listener on the WinRM client (receiving) side have been set.

- Administrator account added to the local administrators group on the receiving side.

If you would like to read a comprehensive guide about how to achieve above steps, please let me know and maybe I can create a step-by-step guide for this!

Now everything is set, let’s connect to the receiving computer with Azure AD credentials with the -UseSSL parameter.

Of course, this is failing, with the **Access is denied** error message:

![Screenshot: Of course, this is failing, with the Access is denied error message](/wp-content/uploads/2023/06/image-14-1024x252.png)

Failed? But why?

In short, this is because Microsoft just didn’t have the code in place for Azure AD authentication over HTTPS in WinRM. They do have the code in place for Azure AD authentication when connection over HTTP. 

What’s the difference then? Well, the statement of Microsoft about this is that when you set up a WinRM connection the authentication flow itself is secure. And once the connection is made the traffic that is being send over WinRM is encrypted by itself, so there is no need for implementation over HTTPS. Well, that does make sense I guess…

Let me explain a little bit more about how I did come to this conclusion together with engineers of Microsoft. 

## The Microsoft cases…

To understand this problem, we decided to open a case at Microsoft for this. They assigned me a really helpful engineer that guided us through the entire process. This process of meant that we must collect a lot of the I think well known [**TroubleShootingScript toolset (TSSv2)**](https://learn.microsoft.com/en-us/troubleshoot/windows-client/windows-troubleshooters/introduction-to-troubleshootingscript-toolset-tssv2) trace files. And in these trace files they found something interesting.  

In the trace for the HTTP connection, you can see that the connection first is being set-up via Kerberos, after failing to connect via Kerberos the next phase starts. Connection via the PKU2U protocol (I will explain this later on). This eventually succeeds so we are connected successfully over HTTP with WinRM to the remote computer.

![Screenshot: This eventually succeeds so we are connected successfully over HTTP with WinRM to the remote…](/wp-content/uploads/2023/06/image-18-1024x230.png)

Next, we can see in the trace for the HTTPs connection that the connection is being set-up via Kerberos. This connection process fails and after that it stops. What Microsoft explained to us is that simply the PKU2U code isn’t in place in WinRM for HTTPS, only for HTTP. That should be the reason for failing.

![Screenshot: That should be the reason for failing](/wp-content/uploads/2023/06/image-17-1024x159.png)

### PKU2U

What is it and why is it used? PKU2U is a peer-to-peer authentication protocol. it allows authentication to successfully complete between the two (or more) devices that have established a peer relationship through the use of online IDs. 

When devices are configured to accept authentication requests by using online IDs, such as Microsoft account, negoexts.dll calls the PKU2U SSP on the device that’s used to sign in. The PKU2U SSP obtains a local certificate and exchanges the policy between the peer devices. When it’s validated on the peer device, the certificate within the metadata is sent to the logon peer for validation. It associates the user’s certificate to a security token, and then the sign-in process completes.

This disablement of the PKU2U protocol would disallow the online identities to authenticate to domain-joined computers from Windows 7 up to Windows 10, Version 1607. This policy is enabled by default in Windows 10, Version 1607, and later.

[**Windows PKU2U Elevation of Privilege Vulnerability (CVE-2021-25195, Critical) – The things that are better left unspoken (dirteam.com)**](https://dirteam.com/sander/2021/02/10/windows-pku2u-elevation-of-privilege-vulnerability-cve-2021-25195-critical/)

[**Network security Allow PKU2U authentication requests to this computer to use online identities – Windows Security | Microsoft Learn**](https://learn.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/network-security-allow-pku2u-authentication-requests-to-this-computer-to-use-online-identities)

## WinRM over HTTPS with a local account

So, what’s next? Now we are going to connect to the remote computer with a local account (of course that is a member of Administrators or Remote Management Users). What do you think? SUCCEED! Secretly I already knew that from Anthony’s blog. But hey, this is kind of a first step.

![Screenshot: But hey, this is kind of a first step](/wp-content/uploads/2023/06/image-13-1024x196.png)

Although this is a safe approach, in a large environment you don’t want to connect to every remote computer with a local account (account provisioning? password policy?). So, we going to take a look at what’s next. 

## WinRM over HTTP with an Azure AD account

Next in line is to set up the remote session with an Azure AD account over HTTP. In this case the Azure AD user also has to be a member of the Administrators or the Remote Management Users group on the computer we are connecting to. This can be done with Endpoint security | Account protection in Microsoft Intune. Know we can see this one also succeeds, hell yes! But is it safe?

![Screenshot: But is it safe?](/wp-content/uploads/2023/06/image-15-1024x203.png)

Well, you have read about PKU2U in the chapter above. Setting up the connection via HTTP with an Azure AD (online identity) is secure as Microsoft says. And after setting up the initial connection the traffic that travels over WinRM is encrypted, so yes this can be considered as safe. 

## WinRM over HTTPS with a Windows LAPS (via Intune) account

Now the final test! We are going to connect to the remote computer via HTTPS with a local account on the remote computer that of course is again in the Administrators or Remote Management Users group. But the main difference now is that the account is managed by Windows LAPS. So, the connection succeeds just like the normal local account over HTTPS. But because this is managed by Windows LAPS (password is being rotated when used, and rotated after a certain amount of time this is even more secure and manageable!

![Screenshot: But because this is managed by Windows LAPS (password is being rotated when used, and rotated after…](/wp-content/uploads/2023/06/image-16-1024x197.png)

I already have written a blogpost about how to get started with Windows LAPS via Microsoft Intune that you can find here: **[How to: Getting started with Windows LAPS via Intune – Manage The Cloud Jeroen Ebus (manage-the.cloud)](/2023/05/26/how-to-getting-started-with-windows-laps-via-intune)**. Hopefully, it can help you with setting everything up!

## Summary

So, we learned that there are two ways to connect on a secure way via WinRM. Via HTTP with an Azure AD account and via HTTPS with a local account (managed by Windows LAPS). Both are considered as safe but they both have their pros and cons. So, it is up to you to decide what you want to use in your environment.

Thanks for reading, and please let me know in the comments what you think of this approach!

