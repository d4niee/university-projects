## Install Repo

1. Clone the repo.
2. Navigate to the folder.
3. Install poetry: pip install poetry
4. Enter "poetry install" in the powershell
5. "poetry shell"

## Add new libariy
poetry add name

## Components DQN

``Agent_DQN``: This is the main class representing the DQN agent. It contains methods for storing and retrieving experiences (memory), performing actions based on the current state (get_greedy_action), training the model with stored experiences (train_long_term_memory) and performing a training step based on the current experience (train_short_term_memory). It also contains a method to perform training sessions (training) and to play the game with the trained model (play).

``DQN``: This is the class that represents the DQN model. It is a Convolutional Neural Network (CNN) consisting of three Convolutional Layers and two Fully Connected Layers. The forward method performs a forward traversal through the network. There are also methods to initialise the weights of the model (weights_init), to save the model (save) and to load a saved model (load).

``SnakeGameAI``: This is the class that represents the Snake game. It contains methods to initialise the game (init), reset the game (reset), place food (place_food), perform a move (play_step), check if a collision has occurred (is_collision), and update the user interface (_update_ui).

``DQN_Trainer``: This is the class that manages the training of the DQN model. It contains a method to perform a training step (train_step) where the weights of the model are updated to minimise the difference between the predicted and target Q values.

## Notizen

* training: evtl matrix des spielsfelds als netz input?
* mögliche reward:
Positive Belohnung (+1) für das Essen eines Apfels.
Negative Belohnung (-1) für das Sterben (z. B. Kollision mit dem Schlangenkörper oder einer Wand).
Leicht negative Belohnung (-0,01) für jede Aktion, um die KI dazu zu ermutigen, schnell zu handeln und nicht zu zögern.
