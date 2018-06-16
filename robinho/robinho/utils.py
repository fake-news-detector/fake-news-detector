import os
import psutil


def current_ram():
    process = psutil.Process(os.getpid())
    ram = process.memory_info().rss / 1000000

    return str(int(ram)) + " MB"
