import pickle

import torch
from torch import optim, nn


class QTrainerFF:
    def __init__(self, model, lr, gamma):
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.lr = lr
        self.gamma = gamma
        self.model = model
        self.optimizer = optim.Adam(model.parameters(), lr=self.lr)
        self.criterion = nn.MSELoss()

    def train_one(self, state, action, reward, next_state, done):
        """
        This method performs a single step of training for the Q-learning model in the Fast Forward mode.

        :param state: The current state of the environment. It's a tensor that represents the game state.
        :param action: The action taken by the agent in the current state. It's a tensor that represents the action.
        :param reward: The reward received by the agent after taking the action. It's a scalar value.
        :param next_state: The next state of the environment after the agent takes the action. It's a tensor that
               represents the game state.
        :param done: A boolean or a tuple of booleans indicating whether the game is finished after the agent takes
               the action.

        The method first converts the inputs to tensors and reshapes them if necessary. Then it predicts the Q-values
        for the current state using the model. It calculates the target Q-values for each action. If the game is done,
        the target Q-value for the taken action is just the received reward. Otherwise, it's the received reward plus
        the discounted maximum Q-value for the next state. The model's weights are then updated to minimize the
        difference between the predicted and target Q-values using backpropagation.
        """
        state = torch.tensor(state, dtype=torch.float).to(self.device)

        next_state = torch.tensor(next_state, dtype=torch.float).to(self.device)
        action = torch.tensor(action, dtype=torch.long).to(self.device)
        reward = torch.tensor(reward, dtype=torch.float).to(self.device)
        # (n, x)

        if len(state.shape) == 1:
            # (1, x)
            state = torch.unsqueeze(state, 0).to(self.device)
            next_state = torch.unsqueeze(next_state, 0).to(self.device)
            action = torch.unsqueeze(action, 0).to(self.device)
            reward = torch.unsqueeze(reward, 0).to(self.device)
            done = (done,)

        # 1: predicted Q values with current state
        predict = self.model(state)

        target = predict.clone()
        for idx in range(len(done)):
            q_new = reward[idx]
            if not done[idx]:
                q_new = reward[idx] + self.gamma * torch.max(self.model(next_state[idx]))

            target[idx][torch.argmax(action[idx]).item()] = q_new

        self.optimizer.zero_grad()
        loss = self.criterion(target, predict)
        loss.backward()

        self.optimizer.step()

    def save_optimizer(self, path="./storage/qtrainer_optim_ff.pkl"):
        with open(path, 'wb') as f:
            pickle.dump(self.optimizer, f)

    def load_optimizer(self, path="./storage/qtrainer_optim_ff.pkl"):
        try:
            with open(path, 'rb') as f:
                self.optimizer = pickle.load(f)
        except FileNotFoundError:
            print("optimizer file not found, creating new optimizer...")
            self.optimizer = optim.Adam(self.model.parameters(), lr=self.lr)
        except EOFError:
            print("optimizer file load failed, creating new optimizer...")
            self.optimizer = optim.Adam(self.model.parameters(), lr=self.lr)


class DQN_Trainer:
    def __init__(self, model, lr, gamma):
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.lr = lr
        self.gamma = gamma
        self.model = model
        self.optimizer = optim.Adam(model.parameters(), lr=self.lr)
        self.criterion = nn.MSELoss()

    def train_step(self, state, action, reward, next_state, done):
        """
        This method performs a single step of training for the Q-learning model.

        :param state: The current state of the environment. It's a tensor that represents the game state.
        :param action: The action taken by the agent in the current state. It's a tensor that represents the action.
        :param reward: The reward received by the agent after taking the action. It's a scalar value.
        :param next_state: The next state of the environment after the agent takes the action. It's a tensor that
               represents the game state.
        :param done: A boolean indicating whether the game is finished after the agent takes the action.

        The method first predicts the Q-values for the current state using the model. Then it calculates the
        target Q-values.
        If the game is done, the target Q-value for the taken action is just the received reward. Otherwise, it's the
        received reward plus the discounted maximum Q-value for the next state. The model's weights are then updated
        to minimize the difference between the predicted and target Q-values using backpropagation.
        """
        state = state.clone().detach().requires_grad_(True).to(self.device)
        next_state = next_state.clone().detach().requires_grad_(True).to(self.device)
        action = torch.tensor(action, dtype=torch.long).unsqueeze(0).to(self.device)
        reward = torch.tensor(reward, dtype=torch.float).unsqueeze(0).to(self.device)

        # 1: predicted Q values with current state
        predict = self.model(state)

        target = predict.clone()
        q_new = reward
        if not done:
            q_new = reward + self.gamma * torch.max(self.model(next_state))

        target[0][torch.argmax(action[0]).item()] = q_new

        self.optimizer.zero_grad()
        loss = self.criterion(target, predict)
        loss.backward()

        self.optimizer.step()

    def save_optimizer(self, path="./storage/qtrainer_optimizer_dqn.pkl"):
        with open(path, 'wb') as f:
            pickle.dump(self.optimizer, f)

    def load_optimizer(self, path="./storage/qtrainer_optimizer_dqn.pkl"):
        try:
            with open(path, 'rb') as f:
                self.optimizer = pickle.load(f)
        except FileNotFoundError:
            print("optimizer file not found, creating new optimizer...")
            self.optimizer = optim.Adam(self.model.parameters(), lr=self.lr)
        except EOFError:
            print("optimizer file load failed, creating new optimizer...")
            self.optimizer = optim.Adam(self.model.parameters(), lr=self.lr)
