import random
from collections import deque

import numpy as np
import torch
import pickle

from GameAI import SnakeGameAI, PlayType
from QTrainer import DQN_Trainer
from helper import clean_operation, plot_game_epsilon
from net import DQN_CNN_SIMPLE

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print("[INFO] training with", device)


class Agent_DQN:
    def __init__(self, args, max_memory=5000, lr=0.001, batch_size=32):
        self.args = args
        self.max_memory = max_memory
        self.lr = lr
        self.batch_size = batch_size
        self.memory = deque(maxlen=max_memory)
        self.priority = deque(maxlen=max_memory)
        self.count_mem = 0
        self.games_played = 0
        self.gamma = 0.9  # discount rate
        self.epoch = 1  # Add epoch variable
        self.total_actions = 0

        # exploration exploitation problem
        self.epsilon = 1  # Epsilon for the epsilon-greedy approach
        self.epsilon_decay = 0.9999  # Decay rate for epsilon
        self.epsilon_min = 0.01  # Minimum value for epsilon
        self.epsilon_history = []

        self.model = DQN_CNN_SIMPLE((4, 10, 10), 3)
        self.trainer = DQN_Trainer(self.model, self.lr, self.gamma)

        self.game = SnakeGameAI(speed=2000, width=800, height=800, delay=1, block_size=80, buffer=1)
        # at the beginning 4 times the starting frame
        self.frame_queue = deque(maxlen=4)  # Queue to store the last 4 frames

    def get_state(self):
        """
        Gets the current state of the game. The state is a tensor of the last 4 frames stacked together.
        :return: Stacked tensor of the last 4 frames
        """
        game_state_np = np.array(self.game.get_game_state())
        game_state_np = np.expand_dims(game_state_np, axis=0)
        game_state_np = np.expand_dims(game_state_np, axis=0)
        game_state_torch = torch.from_numpy(game_state_np)
        game_state_torch = game_state_torch.float()
        # first frame
        if self.game.frame_iteration == 0:
            for _ in range(4):
                self.frame_queue.append(game_state_torch)  # Add the current frame to the queue
        else:
            self.frame_queue.append(game_state_torch)  # Add the current frame to the queue
        stacked_state = torch.cat(list(self.frame_queue), dim=1)  # Stack the frames along the channel dimension
        return stacked_state

    def storage(self, state, action, reward, next_state, finished):
        """
        stores state, action, reward, next_state and finished state to the memory of the agent
        implements Prioritized Experience Replay (PER)
        :param state:
        :param action:
        :param reward:
        :param next_state:
        :param finished:
        :return:
        """
        self.count_mem += 1
        self.memory.append((state, action, reward, next_state, finished))
        error = abs(reward + self.gamma * torch.max(self.model(next_state)) - torch.max(self.model(state)))
        self.priority.append(error)

    # TODO FIX
    def train_short_term_memory(self, state, action, reward, next_state, done):
        """
        Train the Snake for short term. Is called after every move of the snake
        :param state:
        :param action:
        :param reward:
        :param next_state:
        :param done:
        :return:
        """
        self.trainer.train_step(state, action, reward, next_state, done)

    def train_long_term_memory(self, batch):
        """
        Trains the snake for long term. Is called after every epoch
        * enough memory is available (mem >= batch size)
        The selection is made taking into account the priorities of the experiences.
        Experiences with higher priorities have a higher probability of being selected.
        :return:
        """
        self.epoch += 1  # Increase epoch counter
        for state, action, reward, next_state, done in batch:
            self.trainer.train_step(state, action, reward, next_state, done)
        self.count_mem = 0

    def decay_epsilon(self):
        if self.epsilon > self.epsilon_min:
            self.epsilon *= self.epsilon_decay
        self.epsilon_history.append(self.epsilon)

    def get_greedy_action(self, state):
        """
        return a greedy action with epsilon.
        Every Game Iteration the 'greedy' random actions will get smaller
        :param state: predict
        :return: calculated action
        """
        self.total_actions += 1
        # Epsilon-greedy approach
        if random.uniform(0, 1) < self.epsilon:
            # Take random action
            move = random.randint(0, 2)
            final_move = [0, 0, 0]
            final_move[move] = 1
        else:
            # Take action based on learned Q-values (exploitation)
            state0 = state.clone().detach().requires_grad_(True)
            prediction = self.model(state0)
            move = torch.argmax(prediction).item()
            final_move = [0, 0, 0]
            final_move[move] = 1

        # Decay epsilon to gradually shift from exploration to exploitation
        self.decay_epsilon()

        return final_move

    def save_storage_memory(self, path="./storage/memory_dqn.pkl"):
        with open(path, 'wb') as f:
            pickle.dump({'memory': self.memory, 'epsilon': self.epsilon, 'epoch': self.epoch,
                         'games_played': self.games_played, 'priority': self.priority, 'total_actions':
                        self.total_actions}, f)

    def load_storage_memory(self, path="./storage/memory_dqn.pkl"):
        try:
            with open(path, 'rb') as f:
                data = pickle.load(f)
                self.memory = data['memory']
                self.epsilon = data['epsilon']
                self.epoch = data['epoch']
                self.games_played = data['games_played'] + 1
                self.priority = data['priority']
                self.total_actions = data['total_actions']
        except FileNotFoundError:
            print("memory file not found, creating new memory...")
            self.memory = deque(maxlen=self.max_memory)
        except EOFError:
            print("memory file load failed, creating new memory...")
            self.memory = deque(maxlen=self.max_memory)

    def training(self, iterations=20000):
        """
        The Snake will be trained with epoch.
        Every epoch the Snake will train its long term Memory with a given random sample batch
        of the Memory (see definitions Batch Size + Memory).
        Every normal Iteration the snake will train its short term Memory. In this step the Snake trains
        a single batch and appends the results to the memory
        :return:
        """
        iteration_count = 0
        clean = self.args
        plot_scores = []
        plot_mean_scores = []

        total_score = 0
        record = 0

        if clean:
            clean_operation()

        # loading states
        try:
            self.model.load()
        except FileNotFoundError:
            print("model not found, skipping ...")

        self.load_storage_memory()
        self.trainer.load_optimizer()

        while self.total_actions <= iterations:
            # The old state of the game
            state_old = self.get_state()
            # Get the next move from get_action
            final_move = self.get_greedy_action(state_old)
            # Performs the next move
            reward, finished, score = self.game.play_step(final_move)
            state_new = self.get_state()

            self.storage(state_old, final_move, reward, state_new, finished)
            self.train_short_term_memory(state_old, final_move, reward, state_new, finished)
            self.trainer.save_optimizer()

            if finished:
                self.game.reset()
                self.games_played += 1

                # Update the Q-network using QTrainer
                # Long Term Training (Epoch / Generation)
                if self.count_mem >= self.batch_size:
                    self.save_storage_memory()
                    batch = random.choices(self.memory, weights=self.priority, k=self.batch_size)
                    self.train_long_term_memory(batch)

                if score > record:
                    record = score
                    self.model.save()

                plot_scores.append(score)
                total_score += score
                mean_score = total_score / self.games_played
                plot_mean_scores.append(mean_score)
                plot_game_epsilon(plot_scores, plot_mean_scores, self.epsilon_history)
                print("Game", self.games_played, "Finished: Score", score, "Record:", record,
                      "AVG: {:.2f}".format(mean_score),
                      "epsilon: {:.2f}".format(self.epsilon), "reward:", reward, "epoch:", self.epoch,
                      "performed actions:", self.total_actions)
                iteration_count += 1

    def play(self):
        """
        Loads the Model and the training states but only plays the game without
        changing the model or other states.
        :return:
        """

        self.game.speed = 10
        self.game.play_type = PlayType.PLAYING

        # loading states
        try:
            self.model.load()
        except FileNotFoundError:
            print("model not found, skipping ...")
        self.load_storage_memory()
        self.trainer.load_optimizer()

        while True:
            state_old = self.get_state()
            final_move = self.get_greedy_action(state_old)
            finished = self.game.play_step(final_move)[1]
            if finished:
                self.game.reset()
