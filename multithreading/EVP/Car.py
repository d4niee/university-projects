# Klasse car nur zur veranschaulichung
# ein auto hat eine id → car_id

class Car:
    # konstruktor übernimmt die id
    def __init__(self, car_id):
        self.car_id = car_id

    # gibt die Id zurück
    def get_id(self):
        return self.car_id
