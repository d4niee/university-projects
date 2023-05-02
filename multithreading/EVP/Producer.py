import random
import threading
import time

from Car import Car


# Producer erbt von Thread
class Producer(threading.Thread):
    # konstruktor übernimmt den buffer
    def __init__(self, buffer):
        super().__init__()
        self.buffer = buffer

    # Thread spezifische methode
    # wird endlos ausgeführt bis zum interrupt
    def run(self):
        while True:
            time.sleep(random.random()) # warte random zeit vor dem prüfen
            self.buffer.get_mutex().acquire()   # gewähre exklusiven zugriff
            empty = False   # zwischenvariable ob der buffer leer war
            # wenn der buffer vor der entnahme leer war
            if self.buffer.empty:
                empty = True
            # wenn der buffer voll ist -> thread warten lassen
            if self.buffer.full():
                print("Buffer ist voll,  Producer wartet...")
                self.buffer.get_mutex().wait()
            # wenn nicht, auto in den buffer pushen
            else:
                car = Car(random.Random().randint(100, 999))
                self.buffer.push(car)
                print("Auto eingeparkt", car.get_id(), ", Bufferinhalt:", end=" ")
                self.buffer.print_buffer()
            # wenn vor dem pushen leer -> consumer aufwecken
            if empty:
                self.buffer.get_mutex().notify_all()
                self.buffer.get_mutex().release()
