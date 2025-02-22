import os

import torch
import torch.nn as nn
import torch.nn.functional as f


class Linear_QNet(nn.Module):
    """
    Simple feed-forward (Linear) Q-Network implementation. This class creates a neural network model with one
    hidden layer. The network consists of two linear layers with a ReLU activation function in between.

    Args:
        input_size (int): The number of input features.
        hidden_size (int): The number of neurons in the hidden layer.
        output_size (int): The number of output neurons. Typically corresponds to the number of actions.
    """
    def __init__(self, input_size, hidden_size, output_size):
        super().__init__()
        self.linear1 = nn.Linear(input_size, hidden_size)
        self.linear2 = nn.Linear(hidden_size, output_size)

    def forward(self, x):
        """
         Defines the computation performed at every call.

         Args:
             x: The input tensor.
         Returns:
             The output of the network's forward pass.
         """
        x = f.relu(self.linear1(x))
        x = self.linear2(x)
        return x

    def save(self, file_name="model_ff.pth"):
        """
         Saves the current model weights to a file.

         Args:
             file_name (str): The name of the file to save to. Defaults to "model_ff.pth".
         """
        model_folder_path = "./model"
        if not os.path.exists(model_folder_path):
            os.makedirs(model_folder_path)

        file_name = os.path.join(model_folder_path, file_name)
        torch.save(self.state_dict(), file_name)

    def load(self, file_name="model_ff.pth"):
        """
        Loads the model weights from a file.

        Args:
            file_name (str): The name of the file to load from. Defaults to "model_ff.pth".
        """
        model_folder_path = "./model"
        file_name = os.path.join(model_folder_path, file_name)
        self.load_state_dict(torch.load(file_name))


class DQN_CNN(nn.Module):
    """
    Deep Q-Network (DQN) implementation. This class creates a convolutional neural network for a DQN model,
    as proposed by Minh et al. 2015. The network consists of a series of convolutional layers followed by
    a couple of fully connected layers.

    Args:
        in_channels (int): The number of input channels. Default is 4.
        num_actions (int): The number of output actions. Default is 3.
    """
    def __init__(self, in_channels=4, num_actions=3):
        super(DQN_CNN, self).__init__()

        self.conv = nn.Sequential(
            nn.Conv2d(in_channels, 32, kernel_size=8, stride=4),
            nn.ReLU(),
            nn.Conv2d(32, 64, kernel_size=4, stride=2),
            nn.ReLU(),
            nn.Conv2d(64, 64, kernel_size=3, stride=1),
            nn.ReLU()
        )

        self.fc = nn.Sequential(
            nn.Linear(7*7*64, 512),
            nn.ReLU(),
            nn.Linear(512, num_actions)
        )

    def forward(self, x):
        """
        Defines the computation performed at every call.
        Should be overridden by all subclasses.

        Args:
            x: The input tensor.
        Returns:
            The output of the network's forward pass.
        """
        x = self.conv(x)
        x = x.view(x.size(0), -1)  # flatten the tensor
        x = self.fc(x)
        return x

    @staticmethod
    def weights_init(m):
        """
        Initialize the weights of the network.
        Args:
            m: The network module to initialize.
        """
        classname = m.__class__.__name__
        if classname.find('Conv') != -1:
            m.weight.data.normal_(0.0, 0.02)
        if classname.find('Linear') != -1:
            m.weight.data.normal_(0.0, 0.02)

    def save(self, file_name="model_dqn.pth"):
        """
         Saves the current model weights to a file.

         Args:
             file_name (str): The name of the file to save to. Defaults to "model_dqn.pth".
         """
        model_folder_path = "./model"
        if not os.path.exists(model_folder_path):
            os.makedirs(model_folder_path)

        file_name = os.path.join(model_folder_path, file_name)
        torch.save(self.state_dict(), file_name)

    def load(self, file_name="model_dqn.pth"):
        """
        Loads the model weights from a file.

        Args:
            file_name (str): The name of the file to load from. Defaults to "model_dqn.pth".
        """
        model_folder_path = "./model"
        file_name = os.path.join(model_folder_path, file_name)
        self.load_state_dict(torch.load(file_name))


class DQN_CNN_SIMPLE(nn.Module):
    def __init__(self, input_shape, num_outputs):
        super(DQN_CNN_SIMPLE, self).__init__()

        # Define the layers
        self.conv1 = nn.Conv2d(input_shape[0], 32, kernel_size=3, stride=1, padding=1)
        self.pool1 = nn.MaxPool2d(kernel_size=2, stride=2)
        self.conv2 = nn.Conv2d(32, 64, kernel_size=2, stride=1, padding=1)

        self.input_shape = input_shape
        self.fc1_features = self.feature_size()  # compute the flattened feature size
        self.fc1 = nn.Linear(self.fc1_features, 256)
        self.fc2 = nn.Linear(256, num_outputs)

    def forward(self, x):
        x = nn.functional.relu(self.conv1(x))
        x = self.pool1(x)
        x = nn.functional.relu(self.conv2(x))
        x = torch.flatten(x, 1)  # flatten all dimensions except batch
        x = nn.functional.relu(self.fc1(x))
        x = self.fc2(x)
        return x

    # Function to compute the flattened feature size
    def feature_size(self):
        x = torch.zeros(1, *self.input_shape)
        x = self.pool1(self.conv1(x))
        x = self.conv2(x)
        return x.view(1, -1).size(1)

    def save(self, file_name="model_dqn.pth"):
        """
         Saves the current model weights to a file.

         Args:
             file_name (str): The name of the file to save to. Defaults to "model_dqn.pth".
         """
        model_folder_path = "./model"
        if not os.path.exists(model_folder_path):
            os.makedirs(model_folder_path)

        file_name = os.path.join(model_folder_path, file_name)
        torch.save(self.state_dict(), file_name)

    def load(self, file_name="model_dqn.pth"):
        """
        Loads the model weights from a file.

        Args:
            file_name (str): The name of the file to load from. Defaults to "model_dqn.pth".
        """
        model_folder_path = "./model"
        file_name = os.path.join(model_folder_path, file_name)
        self.load_state_dict(torch.load(file_name))
