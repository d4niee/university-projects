import threading


class Chopstick:
    def __init__(self, num, outputs=False):
        self.num = num      # nummer des stäbchens
        self.philo = None   # referenz philosoph um den namen zu printen
        self.condition = threading.Condition(threading.Lock())  # lock um exklusiven zugriff zu gewähren
        self.taken = False  # gibt an ob ein stäbchen schon genommen wurde
        self.outputs = outputs  # gibt an ob ausgaben auf der konsole geprintet werden sollen.

    def take(self, philo):
        with self.condition:
            if self.taken:      # bereits genommen -> abbruch
                return False
            while self.taken:   # solange benutzt wird -> thread warten lassen
                self.condition.wait()
            self.philo = philo
            self.taken = True
            if self.outputs:
                print("Philosoph", self.philo, "nimmt das staebchen", self.num)
            self.condition.notify()  # benachrichtige alle schlafenden threads.

    def drop(self, philo):
        with self.condition:
            while not self.taken:  # solange nicht benutzt wird -> thread warten lassen
                self.condition.wait()
            self.taken = False
            if self.outputs:
                print("Philosoph", philo, "legt das staebchen", self.num, "zurueck")
            self.condition.notify()  # benachrichtige alle schlafenden threads.

    def is_taken(self):
        return self.taken
