import random
from collections import namedtuple
from enum import Enum

import cv2
import numpy as np
import pygame
import torch

pygame.init()
font = pygame.font.Font("resources/arial.ttf", 25)


# font = pygame.font.SysFont('arial', 25)


class Direction(Enum):
    RIGHT = 1
    LEFT = 2
    UP = 3
    DOWN = 4


class PlayType(Enum):
    TRAINING = 1
    PLAYING = 2


Point = namedtuple("Point", "x, y")

# rgb colors
TEXT_COLOR = (0, 0, 0)
FRUIT_COLOR = (231, 71, 29)
SNAKE_COLOR = (78, 124, 246)
BACKGROUND_COLOR_LIGHT = (170, 215, 81)
BACKGROUND_COLOR_DARK = (162, 209, 73)


class SnakeGameAI:
    def __init__(self, width=640, height=480, block_size=20, speed=2000,
                 delay=0, play_type=PlayType.PLAYING, buffer=1):
        self.frame_iteration = 0
        self.food = None
        self.delay = delay
        self.food_eaten = False
        self.frame_count = 0
        self.current_distance_to_food = np.inf,
        self.prev_distance_to_food = np.inf
        self.score = 0
        self.play_type = play_type
        self.snake = None
        self.head = Point(width / 2, height / 2)
        self.direction = Direction.RIGHT
        self.width = width
        self.buffer = buffer
        self.last_actions = []
        self.height = height
        self.block_size = block_size
        self.speed = speed
        self.field_matrix = [
            [0 for _ in range(self.width // self.block_size)] for _ in range(self.height // self.block_size)
        ]
        # init display
        self.display = pygame.display.set_mode((self.width, self.height))
        pygame.display.set_caption("Snake")
        self.clock = pygame.time.Clock()
        self.reset()

    def reset(self):
        # init game state
        self.direction = Direction.RIGHT

        self.head = Point(self.width / 2, self.height / 2)
        self.snake = [
            self.head,
            Point(self.head.x - self.block_size, self.head.y),
        ]

        self.score = 0
        self.food = None
        self._place_food()
        self.frame_iteration = 0

    def _place_food(self):
        position_x = random.randint(self.buffer,
                                    (self.width - self.block_size) // self.block_size - self.buffer) * self.block_size
        position_y = random.randint(self.buffer,
                                    (self.height - self.block_size) // self.block_size - self.buffer) * self.block_size
        self.food = Point(position_x, position_y)
        if self.food in self.snake:
            self._place_food()
    '''
    OLD IMPLEMENTATION
        def get_image_data(self, resize=84):
            surface = pygame.surfarray.array3d(pygame.display.get_surface())
            image = cv2.cvtColor(cv2.resize(surface, (resize, resize)), cv2.COLOR_BGR2GRAY)
            return cv2.rotate(image, cv2.ROTATE_90_COUNTERCLOCKWISE)
    
        def get_image_data_as_tensor(self, resize=84):
            return torch.from_numpy(self.get_image_data(resize)) \
                .float().unsqueeze(0).unsqueeze(0)
        '''
    def get_game_state(self):
        """
        This method returns the current state of the game as a 2D matrix.
        The snake is represented by the number 1, the food by the number 2, and empty blocks by the number 0.
        """
        game_state = [[0 for _ in range(self.width // self.block_size)] for _ in range(self.height // self.block_size)]

        # Mark the snake's position in the matrix
        for point in self.snake:
            x = int(point.x) // self.block_size
            y = int(point.y) // self.block_size
            if y < len(game_state) and x < len(game_state[0]):
                game_state[y][x] = 255

        # Mark the food's position in the matrix
        if self.food is not None:
            x = int(self.food.x) // self.block_size
            y = int(self.food.y) // self.block_size
            if y < len(game_state) and x < len(game_state[0]):
                game_state[y][x] = 128

        return game_state

    def play_step(self, action):
        self.frame_iteration += 1

        # 1. collect user input
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                quit()

        # 2. move
        self._move(action)  # update the head
        self.snake.insert(0, self.head)

        # 3. check if game over
        game_over = False
        collision, self_collision = self.is_collision()
        if collision or self_collision or self.frame_iteration > 100 * len(self.snake):
            game_over = True
            reward = -1
            return reward, game_over, self.score

        # 4. place new food or just move
        if self.head == self.food:
            self.score += 1
            reward = 2  # positive reward for eating the food
            self.food = None  # Set food to None when eaten
            self.frame_iteration = 0
        else:
            self.snake.pop()
            reward = -0.1  # default reward when just moving around

        if self.food is None and self.frame_count >= self.delay:
            self._place_food()
            self.frame_count = 0
        else:
            self.frame_count += 1

        # 5. update ui and clock
        self._update_ui()
        self.clock.tick(self.speed)
        # 6. return game over and score
        return reward, game_over, self.score

    """
    return True, True --> collision and collision with itself
    return True, False --> collision and collision with a wall
    return False, False --> no collision
    """

    def get_food_matrix_position(self):
        return Point(self.food.x // self.block_size, self.food.y // self.block_size)

    def get_head_matrix_position(self):
        return Point(self.snake[0].x // self.block_size, self.snake[0].y // self.block_size)

    def get_body_matrix_position(self):
        point_list = []
        # exclude head
        for part in self.snake[1:]:
            point_list.append(Point(part.x // self.block_size, part.y // self.block_size))
        return point_list

    """
    0: every field in the game is 0
    1: The apple
    5: Snake Head
    4: Snake Body parts
    """

    def set_field_matrix(self):
        # first - clear the whole matrix and fill every value with 0
        self.field_matrix = [
            [0 for _ in range(self.width // self.block_size)] for _ in range(self.height // self.block_size)
        ]
        for row in range(self.width // self.block_size):
            for cell in range(self.height // self.block_size):
                if row == self.get_food_matrix_position().x and cell == self.get_food_matrix_position().y:
                    # Apple
                    self.field_matrix[cell][row] = 1
                if row == self.get_head_matrix_position().x and cell == self.get_head_matrix_position().y:
                    # Snake HEAD
                    self.field_matrix[cell][row] = 5
        for i in self.get_body_matrix_position():
            # Snake BODY Part
            self.field_matrix[int(i.y)][int(i.x)] = 4

    def get_field_matrix(self):
        return self.field_matrix

    def is_collision(self, pt=None):
        if pt is None:
            pt = self.head
        # hits boundary
        if pt.x > self.width - self.block_size or pt.x < 0 or pt.y > self.height - self.block_size or pt.y < 0:
            return True, False
        # hits itself
        if pt in self.snake[1:]:
            return True, True
        return False, False

    def _fill_background(self):
        num_blocks_x = self.display.get_width() // self.block_size
        num_blocks_y = self.display.get_height() // self.block_size
        for x in range(num_blocks_x):
            for y in range(num_blocks_y):
                if (x + y) % 2 == 0:
                    color = BACKGROUND_COLOR_DARK
                else:
                    color = BACKGROUND_COLOR_LIGHT
                rect = pygame.Rect(x * self.block_size, y * self.block_size, self.block_size, self.block_size)
                pygame.draw.rect(self.display, color, rect)

    def _update_ui(self):
        self._fill_background()
        self.draw_snake()
        self.draw_fruit()
        if self.play_type == PlayType.PLAYING:
            self.draw_score()
        pygame.display.flip()

    def draw_snake(self):
        # draw the snake
        for pt in self.snake:
            pygame.draw.rect(self.display, SNAKE_COLOR, pygame.Rect(pt.x, pt.y, self.block_size, self.block_size))

    def draw_fruit(self):
        if self.food is not None:
            # draw the fruit
            pygame.draw.rect(
                self.display, FRUIT_COLOR, pygame.Rect(self.food.x, self.food.y, self.block_size, self.block_size)
            )
        # self.display.blit(apple, pygame.Rect(self.food.x, self.food.y, self.block_size, self.block_size))

    def draw_score(self):
        # draw the score
        text = font.render(str(self.score), True, TEXT_COLOR)
        self.display.blit(text, [0, 0])

    def _move(self, action):
        # [straight, right, left]
        # Add current action to the last actions
        self.last_actions.append(action)
        if len(self.last_actions) > 4:
            self.last_actions.pop(0)  # remove the oldest action if more than four actions are stored

        clock_wise = [Direction.RIGHT, Direction.DOWN, Direction.LEFT, Direction.UP]
        idx = clock_wise.index(self.direction)

        if np.array_equal(action, [1, 0, 0]):
            new_dir = clock_wise[idx]  # no change
        elif np.array_equal(action, [0, 1, 0]):
            next_idx = (idx + 1) % 4
            new_dir = clock_wise[next_idx]  # right turn r -> d -> l -> u
        else:  # [0, 0, 1]
            next_idx = (idx - 1) % 4
            new_dir = clock_wise[next_idx]  # left turn r -> u -> l -> d

        self.direction = new_dir

        x = self.head.x
        y = self.head.y
        if self.direction == Direction.RIGHT:
            x += self.block_size
        elif self.direction == Direction.LEFT:
            x -= self.block_size
        elif self.direction == Direction.DOWN:
            y += self.block_size
        elif self.direction == Direction.UP:
            y -= self.block_size

        self.head = Point(x, y)
