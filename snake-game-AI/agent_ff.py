import random
from collections import deque

import numpy
import torch
import pickle

from matplotlib import pyplot as plt

from GameAI import Direction, Point, SnakeGameAI, PlayType
from QTrainer import QTrainerFF
from helper import clean_operation, plot_game_epsilon
from net import Linear_QNet

# No fixed parameters, try around
LEARNING_RATE = 0.001
MEMORY = 100_000  # Max memory of the deque
BATCH_SIZE = 1000
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print("[INFO] training with", device)


class Agent_FF:
    def __init__(self, args):
        self.args = args
        self.memory = deque(maxlen=MEMORY)
        self.games_played = 0
        self.gamma = 0.9  # discount rate
        self.discount = 0  # Indicates the importance of future rewards to the current state. Between 0 and 1

        # exploration
        self.epsilon = 1  # Epsilon for the epsilon-greedy approach
        self.epsilon_decay = 0.999  # Decay rate for epsilon
        self.epsilon_min = 0.01  # Minimum value for epsilon
        self.epsilon_history = []

        self.model = Linear_QNet(11, 256, 3)

        self.trainer = QTrainerFF(self.model, lr=LEARNING_RATE, gamma=self.gamma)

    def get_state(self, game):
        head = game.snake[0]  # Head of the snake
        # Create points around the head to see if the path is clear
        point_left = Point(head.x - 20, head.y)
        point_right = Point(head.x + 20, head.y)
        point_up = Point(head.x, head.y - 20)
        point_down = Point(head.x, head.y + 20)

        dir_left = game.direction == Direction.LEFT
        dir_right = game.direction == Direction.RIGHT
        dir_up = game.direction == Direction.UP
        dir_down = game.direction == Direction.DOWN

        food_left = game.food.x < game.head.x if game.food else False  # food left
        food_right = game.food.x > game.head.x if game.food else False  # food right
        food_up = game.food.y < game.head.y if game.food else False  # food up
        food_down = game.food.y > game.head.y if game.food else False  # food down

        state = [
            # Danger straight
            (dir_right and game.is_collision(point_right)[0])
            or (dir_left and game.is_collision(point_left)[0])
            or (dir_up and game.is_collision(point_up)[0])
            or (dir_down and game.is_collision(point_down)[0]),
            # Danger right
            (dir_up and game.is_collision(point_right)[0])
            or (dir_down and game.is_collision(point_left)[0])
            or (dir_left and game.is_collision(point_up)[0])
            or (dir_right and game.is_collision(point_down)[0]),
            # Danger left
            (dir_down and game.is_collision(point_right)[0])
            or (dir_up and game.is_collision(point_left)[0])
            or (dir_right and game.is_collision(point_up)[0])
            or (dir_left and game.is_collision(point_down)[0]),
            # Move direction
            dir_left,
            dir_right,
            dir_up,
            dir_down,
            # Food location
            food_left,
            food_right,
            food_up,
            food_down,
        ]

        return numpy.array(state, dtype=int)

    def storage(self, state, action, reward, next_state, finished):
        self.memory.append((state, action, reward, next_state, finished))  # Stores the step in the deque

    def train_short_term_memory(self, state, action, reward, next_state, finished):
        self.trainer.train_one(state, action, reward, next_state, finished)

    def train_long_term_memory(self):
        # Checks if the memory is bigger than the batch size
        if len(self.memory) > BATCH_SIZE:
            train_sample = random.sample(self.memory, BATCH_SIZE)
        else:
            train_sample = self.memory

        states, actions, rewards, next_states, finished = zip(*train_sample)
        self.trainer.train_one(states, actions, rewards, next_states, finished)

    def get_action(self, state):
        # Epsilon-greedy approach
        if random.uniform(0, 1) < self.epsilon:
            # Take random action
            move = random.randint(0, 2)
            final_move = [0, 0, 0]
            final_move[move] = 1
        else:
            # Take action based on learned Q-values (exploitation)
            state0 = torch.tensor(state, dtype=torch.float)
            prediction = self.model(state0)
            move = torch.argmax(prediction).item()
            final_move = [0, 0, 0]
            final_move[move] = 1

        # Decay epsilon to gradually shift from exploration to exploitation
        if self.epsilon > self.epsilon_min:
            self.epsilon *= self.epsilon_decay
        self.epsilon_history.append(self.epsilon)
        return final_move

    def save_storage_memory(self, path="./storage/memory_ff.pkl"):
        with open(path, 'wb') as f:
            pickle.dump({'memory': self.memory, 'epsilon': self.epsilon}, f)

    def load_storage_memory(self, path="./storage/memory_ff.pkl"):
        try:
            with open(path, 'rb') as f:
                data = pickle.load(f)
                self.memory = data['memory']
                self.epsilon = data['epsilon']
        except FileNotFoundError:
            print("memory file not found, creating new memory...")
            self.memory = deque(maxlen=MEMORY)
        except EOFError:
            print("memory file load failed, creating new memory...")
            self.memory = deque(maxlen=MEMORY)

    def training(self):
        clean = self.args
        plot_scores = []
        plot_mean_scores = []

        total_score = 0
        record = 0
        game = SnakeGameAI(speed=1000, width=640, height=480)

        if clean:
            clean_operation()

        # loading states
        try:
            self.model.load()
        except FileNotFoundError:
            print("model not found, skipping ...")

        self.load_storage_memory()
        self.trainer.load_optimizer()

        while True:
            # The old state of the game
            state_old = self.get_state(game)

            # Get the next move from get_action
            final_move = self.get_action(state_old)

            # Performs the next move
            reward, finished, score = game.play_step(final_move)
            state_new = self.get_state(game)

            self.train_short_term_memory(state_old, final_move, reward, state_new, finished)

            self.storage(state_old, final_move, reward, state_new, finished)

            self.trainer.save_optimizer()

            if finished:
                self.save_storage_memory()
                game.reset()
                self.games_played += 1
                self.train_long_term_memory()
                if score > record:
                    record = score
                    self.model.save()

                plot_scores.append(score)
                total_score += score
                mean_score = total_score / self.games_played
                plot_mean_scores.append(mean_score)
                plot_game_epsilon(plot_scores, plot_mean_scores, self.epsilon_history)
                print("Game", self.games_played, "Score", score, "Record:", record, "AVG:", mean_score,
                      "epsilon:", self.epsilon)

    # play game without learning
    def play(self):
        game = SnakeGameAI(speed=10, width=640, height=480, play_type=PlayType.PLAYING)
        # loading states
        try:
            self.model.load()
        except FileNotFoundError:
            print("model not found, skipping ...")
        self.load_storage_memory()
        self.trainer.load_optimizer()

        while True:
            state_old = self.get_state(game)
            final_move = self.get_action(state_old)
            finished = game.play_step(final_move)[1]
            print("performed action:", final_move)
            if finished:
                game.reset()
