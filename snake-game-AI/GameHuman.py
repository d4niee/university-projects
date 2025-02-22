import os
import random
from collections import namedtuple
from enum import Enum

import pygame

pygame.init()
font = pygame.font.Font("resources/arial.ttf", 25)


class Direction(Enum):
    RIGHT = 1
    LEFT = 2
    UP = 3
    DOWN = 4


class Colors(Enum):
    TEXT_COLOR = (56, 74, 12)
    FRUIT_COLOR = (200, 0, 0)
    SNAKE_COLOR = (0, 72, 186)
    BACKGROUND_COLOR_LIGHT = (175, 215, 70)
    BACKGROUND_COLOR_DARK = (165, 205, 60)


Point = namedtuple("Point", "x, y")


class SnakeGame:
    def __init__(self, width=800, height=800, block_size=20, speed=10):
        self.frame_iteration = 0
        self.width = width
        self.height = height
        self.block_size = block_size
        self.speed = speed
        self.allow_through_walls = False
        self.field_matrix = [
            [0 for _ in range(self.width // self.block_size)] for _ in range(self.height // self.block_size)
        ]

        # init display
        self.display = pygame.display.set_mode((self.width, self.width))
        pygame.display.set_caption("Snake")
        self.clock = pygame.time.Clock()

        # init game state
        self.direction = Direction.RIGHT

        self.head = Point(self.width / 2, self.height / 2)
        self.snake = [
            self.head,
            Point(self.head.x - self.block_size, self.head.y),
            Point(self.head.x - (2 * self.block_size), self.head.y),
        ]

        self.score = 0
        self.food = None
        self._place_food_random()

    def _place_food_random(self):
        position_x = random.randint(0, (self.width - self.block_size) // self.block_size) * self.block_size
        position_y = random.randint(0, (self.height - self.block_size) // self.block_size) * self.block_size
        self.food = Point(position_x, position_y)
        if self.food in self.snake:
            self._place_food_random()

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

    def print_matrix_console(self, cls=True):
        if cls:
            os.system("cls" if os.name == "nt" else "clear")
        for row in self.field_matrix:
            for cell in row:
                print(cell, end=" ")
            print()
        print()

    def play_step(self):
        # 1. collect user input
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                quit()
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_LEFT:
                    if self.direction != Direction.RIGHT:
                        self.direction = Direction.LEFT
                elif event.key == pygame.K_RIGHT:
                    if self.direction != Direction.LEFT:
                        self.direction = Direction.RIGHT
                elif event.key == pygame.K_UP:
                    if self.direction != Direction.DOWN:
                        self.direction = Direction.UP
                elif event.key == pygame.K_DOWN:
                    if self.direction != Direction.UP:
                        self.direction = Direction.DOWN

        # 2. move
        self._move(self.direction)

        if self.allow_through_walls:
            # if walls are open: mirror the snake on the other side.
            if self.head.x >= self.width:
                self.head = Point(0, self.head.y)
            elif self.head.x < 0:
                self.head = Point(self.width - self.block_size, self.head.y)
            elif self.head.y >= self.height:
                self.head = Point(self.head.x, 0)
            elif self.head.y < 0:
                self.head = Point(self.head.x, self.height - self.block_size)

        self.snake.insert(0, self.head)

        # 3. check if game over
        game_over = False
        if self._is_collision():
            game_over = True
            self.reset()
            return game_over, self.score

        # 4. place new food or just move
        if self.head == self.food:
            self.score += 1
            self._place_food_random()
        else:
            self.snake.pop()

        # 5. update ui and clock
        self._update_ui()
        self.clock.tick(self.speed)
        # 6. return game over and score
        return game_over, self.score

    def set_allow_through_walls(self, allow_through_walls):
        self.allow_through_walls = allow_through_walls

    def _is_collision(self):
        if not self.allow_through_walls:
            if (
                self.head.x > self.width - self.block_size
                or self.head.x < 0
                or self.head.y > self.height - self.block_size
                or self.head.y < 0
            ):
                return True
        # check collision with itself
        if self.head in self.snake[1:]:
            return True

        return False

    def _fill_background(self):
        num_blocks_x = self.display.get_width() // self.block_size
        num_blocks_y = self.display.get_height() // self.block_size
        for x in range(num_blocks_x):
            for y in range(num_blocks_y):
                if (x + y) % 2 == 0:
                    color = Colors.BACKGROUND_COLOR_LIGHT.value
                else:
                    color = Colors.BACKGROUND_COLOR_DARK.value
                rect = pygame.Rect(x * self.block_size, y * self.block_size, self.block_size, self.block_size)
                pygame.draw.rect(self.display, color, rect)

    def _update_ui(self):
        self._fill_background()
        self.draw_snake()
        self.draw_fruit()
        self.draw_score()
        pygame.display.flip()

    def draw_snake(self):
        # draw the snake
        for pt in self.snake:
            pygame.draw.rect(
                self.display, Colors.SNAKE_COLOR.value, pygame.Rect(pt.x, pt.y, self.block_size, self.block_size)
            )

    def draw_fruit(self):
        # draw the fruit
        pygame.draw.rect(
            self.display,
            Colors.FRUIT_COLOR.value,
            pygame.Rect(self.food.x, self.food.y, self.block_size, self.block_size),
        )
        # self.display.blit(apple, pygame.Rect(self.food.x, self.food.y, self.block_size, self.block_size))

    def draw_score(self):
        # draw the score
        text = font.render(str(self.score), True, Colors.TEXT_COLOR.value)
        self.display.blit(text, [0, 0])

    def _move(self, direction):
        x = self.head.x
        y = self.head.y
        if direction == Direction.RIGHT:
            x += self.block_size
        elif direction == Direction.LEFT:
            x -= self.block_size
        elif direction == Direction.DOWN:
            y += self.block_size
        elif direction == Direction.UP:
            y -= self.block_size

        self.head = Point(x, y)
        self.set_field_matrix()

    def reset(self):
        # init game state
        self.direction = Direction.RIGHT

        # Reset the Snake
        self.head = Point(self.width / 2, self.height / 2)
        self.snake = [
            self.head,
            Point(self.head.x - self.block_size, self.head.y),
            Point(self.head.x - (2 * self.block_size), self.head.y),
        ]
        # Reset score and fruit (place new fruit)
        self.score = 0
        self.food = None
        self._place_food_random()
        self.frame_iteration = 0


if __name__ == "__main__":
    game = SnakeGame(speed=10, block_size=20)
    game.set_allow_through_walls(True)  # Allowing walls
    # game loop
    while True:
        game.play_step()
        # game.print_matrix_console()
