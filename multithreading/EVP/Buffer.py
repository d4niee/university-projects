import threading


class BufferFullException(Exception):
    pass


class BufferEmptyException(Exception):
    pass


class GenericBuffer:

    def __init__(self, max_size):
        self.buffer = []
        self.max_size = max_size
        self.mutex = threading.Condition(threading.Lock())

    def push(self, e):
        if self.full():
            raise BufferFullException("Buffer schon voll!")
        self.buffer.append(e)

    def pop(self):
        if self.empty():
            raise BufferEmptyException("Buffer ist leer!")
        return self.buffer.pop(0)

    def full(self):
        return len(self.buffer) == self.max_size

    def empty(self):
        return len(self.buffer) == 0

    def get_mutex(self):
        return self.mutex

    def print_buffer(self):
        print("[", end="")
        for i in self.buffer:
            print(i.get_id(), end=",")
        print("]", end="")
        print()
