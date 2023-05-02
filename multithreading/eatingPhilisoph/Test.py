from Chopstick import Chopstick
from Philosopher import Philosopher


def test_chopstick():
    c = Chopstick(1, True)
    p = Philosopher(100, c)
    c.take(p.id)
    print(c.taken)
    c.drop(p.id)
    print(c.taken)


def test_philosopher():
    c1 = Chopstick(1, True)
    c2 = Chopstick(2, True)
    p = Philosopher(200, c1, c2)
    p.think()
    p.eat()
    p.think()
    print(p.eaten)


test_chopstick()
test_philosopher()
