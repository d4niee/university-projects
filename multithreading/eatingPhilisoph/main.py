import sys
from threading import Thread
from Chopstick import Chopstick
from Philosopher import Philosopher


'''
diese methode erstellt eine liste mit threads in abhängigkeit der
angegebenen anzahl. 
alle threads werden gestartet.
'''
def run(p):
    threads = []
    for i in range(count_philo):
        t = Thread(target=p[i].dine, args=(count_m,))
        threads.append(t)
    print(count_philo, "Threads für", count_philo, "Philosophen erstellt")
    print("starte alle threads, starte dining...")
    for i in range(count_philo):
        threads[i].start()


if __name__ == '__main__':
    chobsticks = []     # Liste aller stäbchen
    philos = []         # liste aller philosophen
    # ! param 0 nicht beachten
    try:
        count_philo = int(sys.argv[1])  # param 1 anzahl der philosophen
        count_m = int(sys.argv[2])      # param 2 anzahl der essvorgänge
    except ValueError:
        pass

    # befülle die stäbchen u philosophenliste
    for i in range(count_philo):    # erstelle stäbchen mit id 1 - n
        chobsticks.append(Chopstick(i+1))

    for i in range(count_philo):
        philos.append(Philosopher(i+1))

    # setze die stäbhcen der philosophen
    philos[0].set_left_stick(chobsticks[0])
    philos[0].set_right_stick(chobsticks[1])
    for i in range(1, len(chobsticks)-1):
        philos[i].set_left_stick(philos[i-1].get_right_stick())
        philos[i].set_right_stick(chobsticks[i+1])
    philos[count_philo-1].set_left_stick(philos[count_philo-2].get_right_stick())
    philos[count_philo-1].set_right_stick(philos[0].get_left_stick())

    run(philos)




