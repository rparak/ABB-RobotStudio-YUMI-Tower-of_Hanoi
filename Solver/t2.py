# System (Default)
import sys

def Get_Solution(n, sol_raw_data, n_tower):
    """
    # Number of rings in the tower.
    n_tower = [n, 0, 0]
    """
    final_solution = []
    for _, (r_id, p_1, p_2) in enumerate(zip(sol_raw_data['Ring_ID'], 
                                             sol_raw_data['Source'], 
                                             sol_raw_data['Destination'])):                                      
        final_solution.append([n - r_id, p_1, p_2, n_tower[0], n_tower[1], n_tower[2]])
        for i in range(0, len(n_tower)):
            if p_1 == i:
                n_tower[i] -= 1
            elif p_2 == i:
                n_tower[i] += 1

    return final_solution

def Tower_Of_Hanoi(n, source, destination, auxiliary, sol_raw_data):
    """
    Description:
        ...

    Args:
        ...
    """

    if n > 0:
        Tower_Of_Hanoi(n-1, source, auxiliary, destination, sol_raw_data)
        # Save the data for later analysis.
        sol_raw_data['Ring_ID'].append(n)
        sol_raw_data['Source'].append(source)
        sol_raw_data['Destination'].append(destination)
        Tower_Of_Hanoi(n-1, auxiliary, destination, source, sol_raw_data)

def main():
    """
    Description:
        ...
    """

    # The number of rings to solve the Hanoi Tower problem.
    n = 3
    # Tower of Hanoi: 
    #   Tower 1 (source), Tower 3 (destination), Tower 2 (auxiliary)
    source, destination, auxiliary = 0, 2, 1

    # The minimal number of moves required to solve a Tower of Hanoi.
    num_of_moves = (2 ** n) - 1

    Solution_Raw = {'Ring_ID': [], 'Source': [], 'Destination': []}
    # Solution of the problem: Standard
    Tower_Of_Hanoi(n, source, destination, auxiliary, Solution_Raw)

    Solution_Raw_Inv = {'Ring_ID': [], 'Source': [], 'Destination': []}
    # Solution of the problem: Inverse
    Tower_Of_Hanoi(n, destination, source, auxiliary, Solution_Raw_Inv)

    print('[INFO] ')
    print(f'VAR num TOH_SOL_R{n}({num_of_moves}, 6) := {Get_Solution(n, Solution_Raw, [n, 0, 0])}')
    print('[INFO] ')
    print(f'VAR num TOH_SOL_R{n}({num_of_moves}, 6) := {Get_Solution(n, Solution_Raw_Inv, [0, 0, n])}')

if __name__ == '__main__':
    sys.exit(main())