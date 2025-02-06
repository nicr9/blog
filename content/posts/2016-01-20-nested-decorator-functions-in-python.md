---
title: Nested decorator functions in Python
author: nicr9
type: post
date: 2016-01-20T23:32:58+00:00
url: /2016/01/20/nested-decorator-functions-in-python/
tags:
  - Python
---

When I was at [PyConIE last October][1] I was talking with an old friend about Python's decorator functions.

He lamented how you need to google around for tutorials any time you wanted to write a parametrised decorator because it can be so confusing. I told him that there was a way to do it by nesting decorator functions which is much simpler than implementing them using classes (which seems to be the widely known about way).

I thought I'd write up this quick blog post with some examples that will demonstrate how to do this and serve as a reference in case I forget any of this stuff myself!

## Using classes

So here's a rick rolling example using classes:

```python
class WithoutParams(object):
    def __init__(self, func):
        """
        Constructor receives target function.
        """
        self.func = func

    def __call__(self, *args, **kwargs):
        """
        Arguments intended for target function are passed to __call__.
        From here you can call the target any way you see fit.
        """
        self.func("Never gonna give you up")


class WithParams(object):
    def __init__(self, val):
        """
        Constructor takes decorator params instead of target.
        """
        self.val = val

    def __call__(self, func):
        """
        Target function is passed in here instead.
        This is where we create a wrapper function to replace the target.
        """
        def wrapped(*args, **kwargs):
            """
            Wrapper function takes the target arguments and calls target.
            """
            func(self.val)

        return wrapped

@WithoutParams
def a(text):
    print text

@WithParams("Never gonna let you down")
def b(text):
    print text

if __name__ == "__main__":
    a("hello world")
    b("foo bar")
```

## Using nested functions

And here's the corresponding example which uses nested functions:

```python
def without_params(func):
    """
    Outer function takes target function and returns a wrapped one.
    """
    def _without_params(*args, **kwargs):
        """
        Inner function takes target arguments and makes the call.
        """
        return func("Never gonna run around")

    return _without_params

def with_params(val):
    """
    If you need to take params, it's the same but wrapped in another function.
    This one takes the decorator parameters and returns a doubly wrapped function.
    """
    def _with_params(func):
        def __with_params(*args, **kwargs):
            return func(val)
        return __with_params
    return _with_params

@without_params
def a(text):
    print text

@with_params("and desert you!")
def b(text):
    print text

if __name__ == "__main__":
    a(2, 3)
    b("fizz bang")
```

## Conclusion

Class decorators are confusing because arguments and functions are sent to different places depending on the context. Nested function decorators are a neater abstraction because the base decorator is the same in both cases, if you want parameters you just wrap it in an additional function.

Hope this comes in handy!

[1]: https://python.ie/previous-pycons/pycon-2015/
