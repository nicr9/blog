---
title: Nested decorator functions in Python
author: nicr9
type: post
date: 2016-01-20T23:32:58+00:00
url: /?p=555
categories:
  - Uncategorised
tags:
  - Python

---
When I was at PyConIE last October I was talking with an old friend about Python&#8217;s decorator functions.

He lamented how you need to google around for tutorials any time you wanted to write a parametrised decorator because it can be so confusing. I told him that there was a way to do it by nesting decorator functions which is much simpler than implementing them using classes (which seems to be the widely known about way).

I thought I&#8217;d write up this quick blog post with some examples that will demonstrate how to do this and serve as a reference in case I forget any of this stuff myself!

## Using classes

So here&#8217;s a rick rolling example using classes:

<script src="https://gist.github.com/nicr9/cb79b8367bc25ee00c6d.js"></script>

## Using nested functions

And here&#8217;s the corresponding example which uses nested functions:

<script src="https://gist.github.com/nicr9/7b18c005cf27d173a55b.js"></script>

## Conclusion

In summary: class decorators are confusing because arguments and functions are sent to different places depending on the context. Nested function decorators are a neater abstraction because the base decorator is the same in both cases, if you want parameters you just wrap it in an additional function.

Hope this comes in handy!
