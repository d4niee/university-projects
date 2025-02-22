import argparse

from agent_dqn import Agent_DQN
from agent_ff import Agent_FF


def parse_arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument("--clean", "-c", action="store_true", help="Perform clean operation")
    args = parser.parse_args()
    return args.clean


if __name__ == "__main__":
    agent_dqn = Agent_DQN(parse_arguments())
    agent_FF = Agent_FF(parse_arguments())
    agent_FF.training()
    # agent_dqn.training()
