import os

import flask


def hello_world(request):

    return "Hello World!"


def calculate_fibonacci(n):
    #assuming that the first fibonacci number is 1.
    if n < 1:
        return 0
    fib = [0, 1]
    for i in range(2, n+1):
        fib.append(fib[i-1] + fib[i-2])
    return sum(fib)

def return_fibonacci(request):
    request_args = request.args

    if request_args and "n" in request_args:
        n = int(request_args["n"])
    else:
        n = 1
    return f"{calculate_fibonacci(n)}"
