import sys

from Buffer import GenericBuffer
from Consumer import Consumer
from Producer import Producer

buffer = GenericBuffer(4)
producers = []  # liste der producer
consumers = []  # liste der consumer


# führt alle threads der consumer und producer aus
def run():
    # starte alle producer threads
    for prod_thread in producers:
        prod_thread.start()
    # starte alle consumer threads
    for cons_thread in consumers:
        cons_thread.start()


# main - startpunkt
if __name__ == "__main__":
    count_producer = int(sys.argv[1])   # anzahl producer (arg)
    count_consumer = int(sys.argv[2])   # anzahl consumer (arg)
    # füge "count_producer producer" in die producer liste hinzu
    for i in range(count_consumer):
        consumers.append(Consumer(buffer))
    # füge "count_consumer consumer" in die consumer liste hinzu
    for i in range(count_producer):
        producers.append(Producer(buffer))

    run()     # starte die threads
