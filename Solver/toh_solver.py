"""
## =========================================================================== ## 
MIT License
Copyright (c) 2022 Roman Parak
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
## =========================================================================== ## 
Author   : Roman Parak
Email    : Roman.Parak@outlook.com
Github   : https://github.com/rparak
File Name: toh_solver.py
## =========================================================================== ## 
"""

# System (Default)
import sys

def Get_Solution(n, sol_raw_data, n_tower):
    """
    Description:
        Get the final solution with additional dependencies.

    Args:
        (1) n [int]: Number of rings.
        (2) sol_raw_data []:
        (3) n_tower [Vector<int> 1x3]: Number of rings in each tower.

    Returns:
        (1) parameter [Tuple(int, .., int) 1x6]: Solution of the problem with additional dependencies.
                                                 Note:
                                                    # Movement.
                                                    parameter[0,..,2]: [Ring, Source, Destination]
                                                    # Number of rings in the tower.
                                                    parameter[3,..,5]: [len(Tower 1), len(Tower 2), len(Tower 2)]
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
        Get the solution of the mathematical problem Tower of Hanoi.

        Note:
            To get the result, we use a recursive function call.

    Args:
        (1) n [int]: Number of rings.
        (2) source [int]: The tower where we start.
        (2) destination [int]: The tower where we end.
        (2) auxiliary [int]: Auxiliary tower.
        (3) sol_raw_data [Tuple(int, .., int) 1x3]: Solution of the problem for {n} rings.
                                                    Note:
                                                        Iteration: (Ring_ID) Source -> Destination
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
        A simple script to generate a solution to the Hanoi tower problem for the ABB Yumi 
        collaborative robotic arm.

        Add result to the individual script in ABB RobotStudio program.
            1\ T_ROB_R: Standard Solution
            2\ T_ROB_L: Inverse Solution
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

    # Show the solution to the problem.
    print(f'[INFO] Solution of the mathematical problem Tower of Hanoi for {n} rings.')
    print(f'[INFO] Number of moves: {num_of_moves}')
    print('[INFO] Standard (T_ROB_R): From Tower 1 to Tower 3.')
    print(f'VAR num TOH_SOL({num_of_moves}, 6);')
    print(f'OUTPUT := {Get_Solution(n, Solution_Raw, [n, 0, 0])}')
    print('[INFO] Inverse (T_ROB_L): From Tower 3 to Tower 1.')
    print(f'VAR num TOH_SOL({num_of_moves}, 6);')
    print(f'OUTPUT := {Get_Solution(n, Solution_Raw_Inv, [0, 0, n])}')

if __name__ == '__main__':
    sys.exit(main())