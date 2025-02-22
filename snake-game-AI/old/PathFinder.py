# Use this class to reward the agent when he reaches the apple with the best route
# and punish him for using a longer path.
class PathFinder:
    def __int__(self):
        pass

    # noinspection PyMethodMayBeStatic
    def is_valid_position(self, position, matrix):
        x, y = position
        if x < 0 or x >= len(matrix[0]) or y < 0 or y >= len(matrix):
            return False
        if matrix[y][x] == 4:
            return False
        return True

    """
    returns the shortest amount of steps needed to reach the Apple
    """

    def find_shortest_distance(self, matrix, head_position=None, apple_position=None):
        queue = []
        visited = set()
        # if None try to find thew position in the given matrix
        if apple_position is None and head_position is None:
            for y in range(len(matrix)):
                for x in range(len(matrix[y])):
                    if matrix[y][x] == 5:
                        head_position = (x, y)
                    elif matrix[y][x] == 1:
                        apple_position = (x, y)
        # add head to queue
        queue.append((head_position, 0))
        visited.add(head_position)

        while queue:
            current_position, distance = queue.pop(0)
            if current_position == apple_position:
                # target, found --> return shortest route
                return distance
            x, y = current_position
            # check parent
            for dx, dy in [(1, 0), (-1, 0), (0, 1), (0, -1)]:
                next_position = (x + dx, y + dy)
                if next_position not in visited and self.is_valid_position(next_position, matrix):
                    # Add valid parent to the queue
                    queue.append((next_position, distance + 1))
                    visited.add(next_position)
        # No path found
        return -1
