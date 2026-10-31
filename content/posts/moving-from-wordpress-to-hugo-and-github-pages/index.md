---
title: "Moving from WordPress to Hugo and GitHub Pages with GitHub Copilot"
date: 2026-10-31T14:00:00+01:00
slug: "moving-from-wordpress-to-hugo-and-github-pages"
categories: ["General"]
tags: ["GitHub Copilot", "GitHub Pages", "Hugo", "Markdown", "Static website", "WordPress"]
description: "How I moved this blog from WordPress to a static Hugo site on GitHub Pages with the help of GitHub Copilot: export, theme, SEO, redirects, RSS and publishing new posts."
draft: true
---

In this blogpost I will tell you how I moved my blog from WordPress to a static website, hosted on GitHub. Not because WordPress is bad, but because I wanted a website that is fast, secure by default, free of plugin updates and that I can write in Markdown, just like the guides I write for my work.

I got inspired by two other bloggers who did the same. [**My move from WordPress to Git and Markdown (Hugo, Blowfish and Cloudflare) | Michael Morten Sonne**](https://blog.sonnes.cloud/my-move-from-wordpress-to-git-and-md/) and [**From WordPress to Hugo on Cloudflare | JanBakker.tech**](https://janbakker.tech/from-wordpress-to-hugo-on-cloudflare/). Thanks guys!

The big difference is that I did the biggest part of this together with GitHub Copilot. So, this post is also a bit of an experiment: how far can you get when you describe what you want and let an AI assistant do the heavy lifting?

## Why a static website?

A static website is just a folder with HTML, CSS and images. There is no database and no PHP, so there is nothing to hack and nothing to patch. My list of reasons:

- No more WordPress, plugin and theme updates.

- Every post is a Markdown file in Git, so I have a full history and a backup for free.

- Hosting on GitHub Pages is free and fast.

- Writing a new post is the same as writing documentation: a text file, a few screenshots and a `git push`.

## Export the content from WordPress

First thing to do is getting everything out of WordPress. I asked Copilot to read the posts, pages and images from my existing site and convert them to Hugo Markdown. For every post this resulted in a folder with an `index.md` and the screenshots next to it (a so called page bundle).

Keep in mind: an export is never perfect. After the conversion I let Copilot audit all 13 posts for broken formatting, missing images, wrong headings and code blocks that lost their formatting. Those are the things you only notice when you compare the old and the new post side by side.

## Choosing a theme

Like the guys above I started with the Hugo theme **Blowfish**, which is a good-looking theme out of the box. After that I tried a modern restyle of it, and in the end I asked Copilot to build a brand new theme from scratch, with new branding, based on the type of content I write about.

That last one is what you are looking at right now. A few things that I wanted:

- A dark and a light theme that follows your system setting, with a toggle.

- No cookies, no trackers and no third-party requests. The fonts are hosted on the site itself.

- A good looking home page, topic pages that are easy to browse and an About page.

- Search (press **Ctrl+K**), a table of contents on every post, copy buttons on code blocks and clickable screenshots.

- The header with **Manage The Cloud** and **Jeroen Ebus** on two separate lines, so it is readable on every screen size.

The logo went through a few versions as well. The first one was an “M with a dot” that I didn’t like, the second one was too round, so the current logo is a sharp, geometric **M**. Just tell the assistant what you don’t like and it will try again. 😉

## Keep your search engine ranking

This is the part that is easy to forget and the part that can hurt the most. All links to your old website that are out there on the internet should keep working. This is what I checked:

- **Post URLs.** I kept the same permalink format as WordPress (`/year/month/day/slug/`), so all post links are unchanged.

- **Old archive URLs.** WordPress has `/category/...`, `/tag/...` and `/author/...` pages. Hugo uses other URLs for these, so I created redirects for all of them. In total that were 24 categories and 56 tags. Keep in mind that GitHub Pages can’t do real server-side redirects, so these are small redirect pages. If you put Cloudflare in front of your site, you can use real 301 redirects.

- **Images.** Posts and external websites can link directly to an image under `/wp-content/uploads/`. I restored the original images on the same paths. Only the resized versions (like `image-11-300x197.png`) are not there anymore.

- **RSS feed.** The old feed on `/feed/` still works. I also kept the original WordPress item IDs as `guid`, otherwise every reader would show all your posts as new again. And the feed still contains the full post, like before.

- **Sitemap and robots.txt.** Hugo generates the sitemap, and `robots.txt` points to it.

I compared the sitemaps and the feed of the live WordPress site with the new build to be sure that nothing was missed.

## Alt text, descriptions and share cards

WordPress didn’t export the alt text of my screenshots, so around 187 images had an empty alt text. That is bad for accessibility and for image search. Copilot filled them in, based on the captions and the text around the image.

I also added a one-line description to every post, and a default share image. Now a link to one of my posts on LinkedIn or X shows a nice card, and the search results show a real description instead of the first lines of the post.

Also the privacy policy got a rewrite. Because the site has no cookies and no trackers, there is no cookie banner needed.

## Writing a new post

This was the most important requirement for me: writing a new post should be easy. The site now has a template for it. In the folder of the website:

```powershell
hugo new content posts/my-new-post
```

This creates a folder with an `index.md` and draft front matter. Fill in the title, category, tags and a one-line description, drop your screenshots in the same folder and write the post in Markdown. Preview it locally with:

```powershell
hugo server -D
```

When you are happy, change `draft: true` to `draft: false`, commit and push. Everything else is automatic: the reading time, the table of contents, the topic pages, the counts on the home page, search, the sitemap and the RSS feed.

## Publishing on GitHub Pages

<!-- TODO: fill in after the site is live: repository name, GitHub Pages settings, DNS records for manage-the.cloud, and whether you use Cloudflare. -->

The website is published by a GitHub Actions workflow. Every push to the `main` branch builds the site with Hugo and publishes it on GitHub Pages. For the custom domain `manage-the.cloud` you only have to point your DNS to GitHub and add a `CNAME` file to the repository.

## What I learned

Some tips if you want to do the same:

- Describe what you want, not how to do it. “Make the header two lines on every screen size” works better than telling the assistant which CSS to change.

- Always check the result in the browser. I looked at the site on desktop and mobile after every change.

- Let the assistant check its own work: broken links, missing images, empty alt text and redirects can all be checked with a script.

- Don’t trust everything it writes. For example, the PowerShell snippet on my home page used a Microsoft Graph permission that wasn’t enough for the command that was shown. I noticed that, and it was fixed. As an IT pro you should still review what AI generates!

## Conclusion

Moving from WordPress to Hugo and GitHub Pages is not as hard as I thought, especially with GitHub Copilot doing the repetitive work. The result is a fast website without cookies, where every post is a Markdown file in Git and publishing a new post is a `git push`.

I hope that this post helps you to make the move as well, and if you have any questions, feel free to reach out!

Thanks for reading!
