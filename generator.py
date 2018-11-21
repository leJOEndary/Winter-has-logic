import random

INPUT_GRID =[[1,0,0],
             [0,1,0],
             [0,0,0]]


# Will be used to generate a random grid if the RANDOMIZE_GRID = True
RANDOMIZE_GRID = True
LENGTH = 4
WIDTH = 4

# Generates a random grid of size MxN (min, 4x4)
def genGrid():
    DS = False
    inventory = random.randint(1,5)

    if not RANDOMIZE_GRID:
        return (INPUT_GRID, inventory)
    else:       
        grid = []
        print("Inventory:", inventory)
        print("Generated Grid :")
        for i  in range(LENGTH):
            row = []
            for j in range(WIDTH):
                
                cell = random.randint(0,3)
                if cell == 2:
                    if DS:
                        cell=0
                    else:
                        DS = True
                if i == LENGTH-1 and j == WIDTH-1:
                    cell = 0
                row.append(cell)
            print("                  ",row)
            grid.append(row)
            
        print()
        return (grid, inventory)



def translate_Grid(grid, inv):
    kb = []
    for i, row in enumerate(grid):
        for j, cell_type in enumerate(row):
            kb.append("cell({}, {}).\n".format(i, j))

    kb.append("\n")
    num_ww = 0
    for i, row in enumerate(grid):
        for j, cell_type in enumerate(row):
            if cell_type == 1:
                kb.append("white_walker({}, {}, 1, s0).\n".format(i,j))   
                num_ww += 1           
            elif cell_type == 2:
                kb.append("dragon_stone({}, {}).\n".format(i,j))
            elif cell_type == 3:
                kb.append("obstacle({}, {}).\n".format(i,j))

    kb.append("\n")
    x = len(grid) - 1
    y = len(grid[0]) - 1
    player_init = "player({}, {}, {}, {}, {}, s0).\n".format(x, y, inv, inv, num_ww)
    kb.append(player_init)

    with open("knowledgeBase.pl", 'w') as kb_file:
        kb_file.writelines(kb)
            

grid, inv = genGrid()
translate_Grid(grid, inv)
            





