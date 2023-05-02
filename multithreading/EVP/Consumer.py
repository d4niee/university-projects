import random
import threading
import time


class Consumer(threading.Thread):
    def __init__(self, buffer):
        super().__init__()
        self.buffer = buffer

    # Thread spezifische methode
    # wird endlos ausgeführt bis zum interrupt
    def run(self):
        while True:
            time.sleep(random.random())  # warte random zeit
            self.buffer.get_mutex().acquire()   # exklusiver zugriff
            full = False
            if self.buffer.full:
                full = True
            # wenn buffer leer warten (thread schlafen legen)
            if self.buffer.empty():
                print("Buffer ist leer, Consumer wartet...")
                self.buffer.get_mutex().wait()
            # buffer nicht leer → auto ausparken
            else:
                car = self.buffer.pop()
                print("Auto Ausgeparkt", car.get_id(), ", Bufferinhalt:", end=" ")
                self.buffer.print_buffer()
            # wenn der buffer voll war -> producer aufwecken
            if full:
                self.buffer.get_mutex().notify()
                self.buffer.get_mutex().release()
