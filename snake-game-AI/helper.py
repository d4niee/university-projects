import os

import matplotlib.pyplot as plt
from IPython import display

plt.ion()


def plot_game(scores, mean_scores):
    display.clear_output(wait=True)
    display.display(plt.gcf())
    plt.clf()
    plt.title("Training...")
    plt.xlabel("Number of Games")
    plt.ylabel("Score")
    plt.plot(scores)
    plt.plot(mean_scores)
    plt.ylim(ymin=0)
    plt.text(len(scores) - 1, scores[-1], str(scores[-1]))
    plt.text(len(mean_scores) - 1, mean_scores[-1], str(mean_scores[-1]))
    plt.show(block=False)
    plt.pause(0.1)


def plot_hyper_values(epsilon):
    display.clear_output(wait=True)
    display.display(plt.gcf())
    plt.clf()
    plt.title("Hyper Parameters")
    plt.xlabel("Number of Games")
    plt.ylabel("Value")
    plt.ylim(ymin=0)
    plt.plot(epsilon)
    plt.show(block=False)
    plt.pause(0.1)


def plot_game_epsilon(plot_scores, plot_mean_scores, epsilon_history):
    plt.figure(figsize=(12, 6))

    plt.subplot(1, 2, 1)
    plt.plot(plot_scores)
    plt.plot(plot_mean_scores)
    plt.title('Scores over time')
    plt.xlabel('Game')
    plt.ylabel('Score')

    plt.subplot(1, 2, 2)
    plt.plot(epsilon_history)
    plt.title('Epsilon over time')
    plt.xlabel('Iteration')
    plt.ylabel('Epsilon')

    plt.show()


def plot_avg_scores(avg_scores):
    plt.plot(avg_scores)
    plt.ylabel('Average Score')
    plt.xlabel('Epoch (Generation)')
    plt.show()


def clean_operation():
    storage_path = './storage/'
    for filename in os.listdir(storage_path):
        file_path = os.path.join(storage_path, filename)
        if os.path.isfile(file_path):
            os.remove(file_path)
    model_path = './model/'
    for filename in os.listdir(model_path):
        file_path = os.path.join(model_path, filename)
        if os.path.isfile(file_path):
            os.remove(file_path)
