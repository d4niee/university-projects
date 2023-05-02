import random
import time


class Philosopher:
    def __init__(self, id, l=None, r=None):
        self.id = id        # id des philosophs
        self.left_stick = l     # linker stick
        self.right_stick = r    # rechter stick
        self.isEating = False   # status ob der philosoph aktuell am essen ist
        self.eaten = 0          # anzahl erfolgreicher essen

    # Getter und setter methoden für den chobstick
    def get_left_stick(self):
        return self.left_stick

    def get_right_stick(self):
        return self.right_stick

    def set_left_stick(self, s):
        self.left_stick = s

    def set_right_stick(self, s):
        self.right_stick = s

    def eat(self):
        # wenn man schon isst -> abbrechen
        if self.isEating:
            return
        # wenn der linke oder der rechte stick schon belegt sind -> abbrechen
        if self.left_stick.is_taken() or self.right_stick.is_taken():
            return
        # nehme linken und rechten stick
        x = self.left_stick.take(self.id)
        y = self.right_stick.take(self.id)
        # nehmen war erfolgreich
        if x is None and y is None:
            self.eaten = self.eaten + 1  # essen erfolgreich + 1
            self.isEating = True         # setze status auf "essen"
        # nehmen war nicht erfolgreich
        else:
            self.left_stick.drop(self.id)     # lasse linken stick los
            self.right_stick.drop(self.id)    # lasse rechten stick los
            self.isEating = False               # setze status auf "nicht am essen"
            return

    def think(self):
        # wenn nicht gegessen wird abbrechen
        if not self.isEating:
            return
        # lasse beide stäbchen los
        self.right_stick.drop(self.id)
        self.left_stick.drop(self.id)
        self.isEating = False   # setze status auf "nicht am essen"

    def dine(self, m):
        r = random.Random()  # random generator
        # durchlaufe den essen/denken zyklus m mal
        for i in range(m):
            # essen, kurz warten, dann denken und erneut kurz warten
            self.eat()
            time.sleep(r.randint(0, 3) * 0.01)
            self.think()
            time.sleep(r.randint(0, 3) * 0.01)
        # warte kurz vor dem print um komplikationen mit anderen
        # threads zu vermeiden
        time.sleep(r.randint(0, 5))
        print("Philosoph", self.id, "hat", self.eaten, "mal gegessen.")

