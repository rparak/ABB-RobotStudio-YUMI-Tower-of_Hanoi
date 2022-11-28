# ABB RobotStudio - Solving the Tower of Hanoi problem with the Collaborative Robot YuMi (IRB 14000)

## Requirements:

**Software:**
```bash
ABB RobotStudio 2022.3 (64-bit)
```

**RobotWare:**
```bash
Version 6.13.03
```

| Software/Package      | Link                                                                                  |
| --------------------- | ------------------------------------------------------------------------------------- |
| ABB RobotStudio       | https://new.abb.com/products/robotics/robotstudio/downloads                           |

## Project Description:
The project demonstrates the mathematical problem of the Tower of Hanoi, which is solved by the collaborative robot YuMi (IRB 14000). To solve the problem, we use a Python script to generate the data with additional dependencies and ABB RobotStudio to process the data and generate the trajectory. 

The program uses both arms (T_ROB_L/R) to move the rings (1 to 6) between the three towers using special fingers that were created on a 3D printer.

**Generate data to solve the math problem Tower in Hanoi with additional dependencies:**
```bash
Windows:
    $ py -3.6 toh_solver.py
Linux:
    $ python3 toh_solver.py

# The number of rings to solve the Hanoi Tower problem.
n = 3

# Display the result in the console.
[INFO] Solution of the mathematical problem Tower of Hanoi for 3 rings.
[INFO] Number of moves: 7
[INFO] Standard (T_ROB_R): From Tower 1 to Tower 3.
VAR num TOH_SOL(7, 6);
OUTPUT := [[2, 0, 2, 3, 0, 0], [1, 0, 1, 2, 0, 1], [2, 2, 1, 1, 1, 1], [0, 0, 2, 1, 2, 0], [2, 1, 0, 0, 2, 1], [1, 1, 2, 1, 1, 1], [2, 0, 2, 1, 0, 2]]
[INFO] Inverse (T_ROB_L): From Tower 3 to Tower 1.
VAR num TOH_SOL(7, 6);
OUTPUT := [[2, 2, 0, 0, 0, 3], [1, 2, 1, 1, 0, 2], [2, 0, 1, 1, 1, 1], [0, 2, 0, 0, 2, 1], [2, 1, 2, 1, 2, 0], [1, 1, 0, 1, 1, 1], [2, 2, 0, 2, 0, 1]]
```

The project was created in collaboration with student Lukas Stanek within the [VRM (Programming for Robots and Manipulators)](https://github.com/rparak/Programming-for-robots-and-manipulators-VRM) university course.

The project was realized at the Institute of Automation and Computer Science, Brno University of Technology, Faculty of Mechanical Engineering (NETME Centre - Cybernetics and Robotics Division).

**Unpacking a station (/Final/Solution_YuMi.rspag):**
1. On the File tab, click Open and then browse to the folder and select the Pack&Go file, the Unpack & Work wizard opens.
2. In the Welcome to the Unpack & Work Wizard page, click Next.
3. In the Select package page, click Browse and then select the Pack & Go file to unpack and the Target folder. Click Next.
4. In the Library handling page select the target library. Two options are available, Load files from local PC or Load files from Pack & Go. Click the option to select the location for loading the required files, and click Next.
5. In the Virtual Controller page, select the RobotWare version and then click Locations to access the RobotWare Add-in and Media pool folders. Optionally, select the check box to automatically restore backup. Click Next.
6. In the Ready to unpack page, review the information and then click Finish.

<p align="center">
  <img src="https://github.com/rparak/ABB-RobotStudio-YUMI-Tower-of_Hanoi/blob/main/images/RS_R_ID_1.png" width="225" height="300">
  <img src="https://github.com/rparak/ABB-RobotStudio-YUMI-Tower-of_Hanoi/blob/main/images/RS_R_ID_2.png" width="225" height="300">
  <img src="https://github.com/rparak/ABB-RobotStudio-YUMI-Tower-of_Hanoi/blob/main/images/RS_R_ID_3.png" width="225" height="300">
  <img src="https://github.com/rparak/ABB-RobotStudio-YUMI-Tower-of_Hanoi/blob/main/images/RS_R_ID_4.png" width="225" height="300">
  <img src="https://github.com/rparak/ABB-RobotStudio-YUMI-Tower-of_Hanoi/blob/main/images/RS_R_ID_5.png" width="225" height="300">
  <img src="https://github.com/rparak/ABB-RobotStudio-YUMI-Tower-of_Hanoi/blob/main/images/RS_R_ID_6.png" width="225" height="300">
</p>

## Project Hierarchy:

**Repositary [/ABB-RobotStudio-YUMI-Tower-of_Hanoi/]:**

```bash
[ Template (.rspag)                            ] /Template/
[ Main Program (.rspag) (Simulation)           ] /Final
[ Example of the resulting application         ] /Exe_file/
[ Rapid codes (.mod) - Right/Left Arm          ] /Rapid/Simulation and /Real
[ CAD files of individual parts of the project ] /Project_Materials/.sat/
[ Python Solver of TOH problem                 ] /Solver/toh_solver.py/
```

## Application:

<p align="center">
  <img src="https://github.com/rparak/ABB-RobotStudio-YUMI-Tower-of_Hanoi/blob/main/images/RS_Simulation_Workspace.png" width="700" height="450">
</p>

## Result:

Youtube: ....

## Contact Info:
Roman.Parak@outlook.com

## Citation (BibTex)
```bash
@misc{RomanParak_ABB_RS_TOH,
  author = {Roman Parak, Lukas Stanek},
  title = {Solving the Tower of Hanoi problem with the Collaborative Robot YuMi (IRB 14000)},
  year = {2022},
  publisher = {GitHub},
  journal = {GitHub repository},
  howpublished = {\url{https://github.com/rparak/ABB-RobotStudio-YUMI-Tower-of_Hanoi}}
}
```

## License
[MIT](https://choosealicense.com/licenses/mit/)
