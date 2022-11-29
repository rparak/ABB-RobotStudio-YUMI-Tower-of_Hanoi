MODULE Module1
    ! ## =========================================================================== ## 
    ! MIT License
    ! Copyright (c) 2022 Roman Parak
    ! Permission is hereby granted, free of charge, to any person obtaining a copy
    ! of this software and associated documentation files (the "Software"), to deal
    ! in the Software without restriction, including without limitation the rights
    ! to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    ! copies of the Software, and to permit persons to whom the Software is
    ! furnished to do so, subject to the following conditions:
    ! The above copyright notice and this permission notice shall be included in all
    ! copies or substantial portions of the Software.
    ! THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    ! IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    ! FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    ! AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    ! LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    ! OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    ! SOFTWARE.
    ! ## =========================================================================== ## 
    ! Author   : Roman Parak
    ! Email    : Roman.Parak@outlook.com
    ! Github   : https://github.com/rparak
    ! File Name: T_ROB1/Module1.mod
    ! ## =========================================================================== ##  
    
    ! Robot Parameters Structure
    RECORD robot_param
        speeddata speed;
        zonedata zone;
        num wait_sgT;
    ENDRECORD
    ! Robot Control Structure
    RECORD robot_ctrl_str
        num actual_state;
        robot_param r_param; 
    ENDRECORD
    
    ! Call Main Structure
    VAR robot_ctrl_str r_str;
    
    ! The number of rings to solve the Hanoi Tower problem.
    PERS num CONST_NUM_OF_RINGS := 3;
    ! Tower of Hanoi: Parameters
    PERS num CONST_RING_OFFSET := 20;
    PERS num CONST_TOWER_OFFSET := 91;
    
    ! Movement.
    !   TOH_SOL{i, 1}: Ring; TOH_SOL{i, 2}: Source; TOH_SOL{i, 3}: Destination
    ! Number of rings in the tower.
    !   TOH_SOL{i, 4}: Tower 1; TOH_SOL{i, 5}: Tower 2; TOH_SOL{i, 6}: Tower 3
    !   Note (CONST_NUM_OF_RINGS -> n):
    !       n(1) := TOH_SOL{1, 6}; n(2) := TOH_SOL{3, 6}; n(3) := TOH_SOL{7, 6}
    !       n(4) := TOH_SOL{15, 6}; n(5) := TOH_SOL{31, 6}; n(6) := TOH_SOL{63, 6}
    PERS num TOH_SOL_Standard{7, 6};
    PERS num TOH_SOL_Inverse{7, 6};
    
    ! Identification of the robot position.
    PERS bool IN_POS_ROB_R;
    PERS bool IN_POS_ROB_L;
    
    ! Variable that indicates switching to the calibration/home state.
    PERS bool CONST_CALIBRATION_MODE := FALSE;
    PERS bool CONST_HOME_MODE := FALSE;
    
    ! Iterator for perform movement with individual arms.
    PERS num i;
    
    ! Main waypoints (targets) for robot control
    CONST robtarget Target_INIT:=[[63.216469095,163.494541752,161.324792511],[0.506079495,-0.023222858,0.849413008,-0.147789664],[0,0,2,4],[101.964427132,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget Target_GRASP:=[[457.320066834,57.630207513,48.04989228],[-0.000000157,0,0.870355756,-0.492423455],[0,1,1,4],[101.960019593,9E+09,9E+09,9E+09,9E+09,9E+09]];

    ! Description:                             !
    !   Program Main Cycle:                    !
    !       Type        : Semistatic or Normal !
    !       TrustLeve   : No Safety or N/A     !
    !       Motion Task : N/A or YES           ! 
    PROC main()
        TEST r_str.actual_state
            CASE 0:
                ! Description:                                                                      !
                !  Initialization state to reset the environment and move the position to the home. !
                
                ! Get the solution of the mathematical problem Tower of Hanoi.
                GET_TOH_SOLUTION_Standard CONST_NUM_OF_RINGS, TOH_SOL_Standard;
                GET_TOH_SOLUTION_Inverse CONST_NUM_OF_RINGS, TOH_SOL_Inverse;
                
                ! Initialize the parameters.
                INIT_PARAM;
                ! Restore the environment.
                RESET_ENV;

                ! Move to the initialization position.
                MoveJ Target_INIT,r_str.r_param.speed,fine,Servo\WObj:=wobj0;
                
                IF CONST_CALIBRATION_MODE = TRUE THEN
                    r_str.actual_state := 100;
                ELSEIF CONST_HOME_MODE = TRUE THEN
                    r_str.actual_state := 110;
                ELSE
                    ! Initialization position near the first grasp ring.
                    MoveL Offs(Target_GRASP, TOH_SOL_Standard{1, 2} * ((-1) * CONST_TOWER_OFFSET), 100.0, CONST_RING_OFFSET * ((TOH_SOL_Standard{1, 4 + TOH_SOL_Standard{1, 2}}) - 1)), r_str.r_param.speed, r_str.r_param.zone, Servo\WObj:=wobj0;
                    r_str.actual_state := 10;
                ENDIF
                
            CASE 10: 
                ! Description:                                                                 !
                !  The waiting state for the second robot (arm) to finish solving the problem. !
                
                IF IN_POS_ROB_R = TRUE THEN
                    r_str.actual_state := 11;
                ENDIF 
                
            CASE 11:
                ! Description:                                             !
                !  Solving the Tower of Hanoi problem (Standard Solution). !
                
                ! Movement Description: 
                !   Move close to the ring to perform grasping.
                MoveL Offs(Target_GRASP, TOH_SOL_Standard{i, 2} * ((-1) * CONST_TOWER_OFFSET), 10.0, CONST_RING_OFFSET * ((TOH_SOL_Standard{i, 4 + TOH_SOL_Standard{i, 2}}) - 1)), r_str.r_param.speed, r_str.r_param.zone, Servo\WObj:=wobj0;
                MoveL Offs(Target_GRASP, TOH_SOL_Standard{i, 2} * ((-1) * CONST_TOWER_OFFSET), 0.0, CONST_RING_OFFSET * ((TOH_SOL_Standard{i, 4 + TOH_SOL_Standard{i, 2}}) - 1)), r_str.r_param.speed, fine, Servo\WObj:=wobj0;
                
                ! Signal -> Attach the object.
                ATTACH_RING_ID TOH_SOL_Standard{i, 1} + 1; 
                
                ! Movement Description: 
                !   Move with the ring from the initial state to the new (desired) state.
                MoveL Offs(Target_GRASP, TOH_SOL_Standard{i, 2} * ((-1) * CONST_TOWER_OFFSET), 0.0, 200.0), r_str.r_param.speed, r_str.r_param.zone, Servo\WObj:=wobj0;
                MoveL Offs(Target_GRASP, TOH_SOL_Standard{i, 3} * ((-1) * CONST_TOWER_OFFSET), 0.0, 200.0), r_str.r_param.speed, r_str.r_param.zone, Servo\WObj:=wobj0;
                MoveL Offs(Target_GRASP, TOH_SOL_Standard{i, 3} * ((-1) * CONST_TOWER_OFFSET), 0.0, 10.0 + CONST_RING_OFFSET * (TOH_SOL_Standard{i, 4 + TOH_SOL_Inverse{i, 3}})), r_str.r_param.speed, r_str.r_param.zone, Servo\WObj:=wobj0;
                MoveL Offs(Target_GRASP, TOH_SOL_Standard{i, 3} * ((-1) * CONST_TOWER_OFFSET), 0.0, CONST_RING_OFFSET * (TOH_SOL_Standard{i, 4 + TOH_SOL_Standard{i, 3}})), r_str.r_param.speed, fine, Servo\WObj:=wobj0;
                
                ! Signal -> Detach the object.
                DETACH_RING_ID TOH_SOL_Standard{i, 1} + 1;
                
                ! Movement Description: 
                !   Move near the tower where the ring was stored.
                MoveL Offs(Target_GRASP, TOH_SOL_Standard{i, 3} * ((-1) * CONST_TOWER_OFFSET), 100.0, CONST_RING_OFFSET * (TOH_SOL_Standard{i, 4 + TOH_SOL_Standard{i, 3}})), r_str.r_param.speed, r_str.r_param.zone, Servo\WObj:=wobj0;
             
                IF i + 2 < Pow(2, CONST_NUM_OF_RINGS) - 1 THEN
                    ! Movement Description: 
                    !   Move near the next predicted position where the ring will be grasped.
                    MoveL Offs(Target_GRASP, TOH_SOL_Standard{i + 2, 2} * ((-1) * CONST_TOWER_OFFSET), 100.0, CONST_RING_OFFSET * ((TOH_SOL_Standard{i + 2, 4 + TOH_SOL_Standard{i + 2, 2}}) - 1)), r_str.r_param.speed, r_str.r_param.zone, Servo\WObj:=wobj0;
                ENDIF
                
                i := i + 1;
                
                ! Change the values (the left hand completed the problem).
                IN_POS_ROB_R := FALSE;
                IN_POS_ROB_L := TRUE;
                r_str.actual_state := 12;
                
            CASE 12:
                ! Description:                                                  !
                !  Check if the solution for the left hand is already complete. !
                
                IF i = Pow(2, CONST_NUM_OF_RINGS) - 1 THEN
                    ! Movement Description: 
                    !   Initialization position near the first grasp ring (Inverse Solution).
                    MoveL Offs(Target_GRASP, TOH_SOL_Inverse{1, 2} * ((-1) * CONST_TOWER_OFFSET), 100.0, CONST_RING_OFFSET * ((TOH_SOL_Inverse{1, 4 + TOH_SOL_Inverse{1, 2}}) - 1)), r_str.r_param.speed, r_str.r_param.zone, Servo\WObj:=wobj0;
                    r_str.actual_state := 13;
                ELSE
                    r_str.actual_state := 10;
                ENDIF
                
            CASE 13:
                ! Description:                                                   !
                !  Check if the solution for the right hand is already complete. !

                IF i = 1 THEN
                    r_str.actual_state := 20;
                ENDIF
                
            CASE 20:
                ! Description:                                                                 !
                !  The waiting state for the second robot (arm) to finish solving the problem. !

                IF IN_POS_ROB_R = TRUE THEN
                    r_str.actual_state := 21;
                ENDIF 
                
            CASE 21:
                ! Description:                                            !
                !  Solving the Tower of Hanoi problem (Inverse Solution). !
                
                ! Movement Description: 
                !   Move close to the ring to perform grasping.
                MoveL Offs(Target_GRASP, TOH_SOL_Inverse{i, 2} * ((-1) * CONST_TOWER_OFFSET), 10.0, CONST_RING_OFFSET * ((TOH_SOL_Inverse{i, 4 + TOH_SOL_Inverse{i, 2}}) - 1)), r_str.r_param.speed, r_str.r_param.zone, Servo\WObj:=wobj0;
                MoveL Offs(Target_GRASP, TOH_SOL_Inverse{i, 2} * ((-1) * CONST_TOWER_OFFSET), 0.0, CONST_RING_OFFSET * ((TOH_SOL_Inverse{i, 4 + TOH_SOL_Inverse{i, 2}}) - 1)), r_str.r_param.speed, fine, Servo\WObj:=wobj0;
                
                ! Signal -> Attach the object.
                ATTACH_RING_ID TOH_SOL_Inverse{i, 1} + 1; 
                
                ! Movement Description: 
                !   Move with the ring from the initial state to the new (desired) state.
                MoveL Offs(Target_GRASP, TOH_SOL_Inverse{i, 2} * ((-1) * CONST_TOWER_OFFSET), 0.0, 200.0), r_str.r_param.speed, r_str.r_param.zone, Servo\WObj:=wobj0;
                MoveL Offs(Target_GRASP, TOH_SOL_Inverse{i, 3} * ((-1) * CONST_TOWER_OFFSET), 0.0, 200.0), r_str.r_param.speed, r_str.r_param.zone, Servo\WObj:=wobj0;
                MoveL Offs(Target_GRASP, TOH_SOL_Inverse{i, 3} * ((-1) * CONST_TOWER_OFFSET), 0.0, 10.0 + CONST_RING_OFFSET * (TOH_SOL_Inverse{i, 4 + TOH_SOL_Inverse{i, 3}})), r_str.r_param.speed, r_str.r_param.zone, Servo\WObj:=wobj0;
                MoveL Offs(Target_GRASP, TOH_SOL_Inverse{i, 3} * ((-1) * CONST_TOWER_OFFSET), 0.0, CONST_RING_OFFSET * (TOH_SOL_Inverse{i, 4 + TOH_SOL_Inverse{i, 3}})), r_str.r_param.speed, fine, Servo\WObj:=wobj0;
                
                ! Signal -> Detach the object.
                DETACH_RING_ID TOH_SOL_Inverse{i, 1} + 1;
                
                ! Movement Description: 
                !   Move near the tower where the ring was stored.
                MoveL Offs(Target_GRASP, TOH_SOL_Inverse{i, 3} * ((-1) * CONST_TOWER_OFFSET), 100.0, CONST_RING_OFFSET * (TOH_SOL_Inverse{i, 4 + TOH_SOL_Inverse{i, 3}})), r_str.r_param.speed, r_str.r_param.zone, Servo\WObj:=wobj0;
             
                IF i + 2 < Pow(2, CONST_NUM_OF_RINGS) THEN
                    ! Movement Description: 
                    !   Move near the next predicted position where the ring will be grasped.
                    MoveL Offs(Target_GRASP, TOH_SOL_Inverse{i + 2, 2} * ((-1) * CONST_TOWER_OFFSET), 100.0, CONST_RING_OFFSET * ((TOH_SOL_Inverse{i + 2, 4 + TOH_SOL_Inverse{i + 2, 2}}) - 1)), r_str.r_param.speed, r_str.r_param.zone, Servo\WObj:=wobj0;
                ENDIF
                
                i := i + 1;
                
                ! Change the values (the left hand completed the problem).
                IN_POS_ROB_R := FALSE;
                IN_POS_ROB_L := TRUE;
                r_str.actual_state := 22;
                
            CASE 22:
                ! Description:                                                  !
                !  Check if the solution for the left hand is already complete. !
                
                IF i = Pow(2, CONST_NUM_OF_RINGS) THEN
                    i := 1;
                    ! Movement Description: 
                    !   Initialization position near the first grasp ring (Standard Solution).
                    MoveL Offs(Target_GRASP, TOH_SOL_Standard{1, 2} * ((-1) * CONST_TOWER_OFFSET), 100.0, CONST_RING_OFFSET * ((TOH_SOL_Standard{1, 4 + TOH_SOL_Standard{1, 2}}) - 1)), r_str.r_param.speed, r_str.r_param.zone, Servo\WObj:=wobj0;
                    r_str.actual_state := 10;
                ELSE
                    r_str.actual_state := 20;
                ENDIF               
                
            CASE 100:
                ! Description:                                                               !
                !  Calibration state for setting up the robot workspace to perform the task. !
                
                ! Set an individual number of targets to calibrate the robot workspace.
                MoveL Offs(Target_GRASP, (-1) * CONST_TOWER_OFFSET, 100.0, CONST_RING_OFFSET * 3), r_str.r_param.speed, r_str.r_param.zone, Servo\WObj:=wobj0;
            
            CASE 110:
                ! Description:                                           !
                !  Home state for moving to the initialization position. !
                
                MoveAbsJ [[0,-130,30,0,40,0], [135,9E9,9E9,9E9,9E9,9E9]] \NoEOffs, r_str.r_param.speed, fine, tool0;
        ENDTEST
    ENDPROC
    
    PROC INIT_PARAM()
        ! Description:                               !
        !   Intitialization parameters of the robot. !
        
        ! Sets the iterator value to the initialization value.
        i := 1;

        ! The application starts with the right hand.
        IN_POS_ROB_R := FALSE;
        IN_POS_ROB_L := TRUE;

        ! Intitialization parameters of the robot.
        ! Speed:
        r_str.r_param.speed := [200, 200, 200, 200];
        ! Zone:
        r_str.r_param.zone  := z50;
        ! Wait time (Smart Gripper) -> [seconds]
        r_str.r_param.wait_sgT := 0.25;
    ENDPROC
    
    PROC RESET_ENV()
        ! Description:                                                   !
        !   Restore the robotic environment to the initialization state. !
          
        ! Detach all objects.
        PulseDO DO_SG_L_DET_ID_1;
        PulseDO DO_SG_L_DET_ID_2;
        PulseDO DO_SG_L_DET_ID_3;
        PulseDO DO_SG_L_DET_ID_4;
        PulseDO DO_SG_L_DET_ID_5;
        PulseDO DO_SG_L_DET_ID_6;
        
        ! Move all rings to the default position.
        PulseDO DO_RESET_ENV; 
        ! Smart Gripper -> Release (Home Position)
        PulseDO DO_SG_L_Home;
        
        ! Visibility of rings in the environment.
        SET_NUM_OF_RINGS CONST_NUM_OF_RINGS;
    ENDPROC
    
    PROC SET_NUM_OF_RINGS(num num_of_rings)
        ! Description:                                                                       !
        !   Visibility of rings in the environment. For more information, see Station Logic. !
        ! Note:                                                                              !
        ! If the variable (num_of_rings) is equal to 3, only 3 rings are displayed.          !
        
        TEST num_of_rings
            CASE 1:
                    SetDO DO_VIS_N_1, 1;
                    SetDO DO_VIS_N_2, 0;
                    SetDO DO_VIS_N_3, 0;
                    SetDO DO_VIS_N_4, 0;
                    SetDO DO_VIS_N_5, 0;
                    SetDO DO_VIS_N_6, 0;
            CASE 2:
                    SetDO DO_VIS_N_1, 1;
                    SetDO DO_VIS_N_2, 1;
                    SetDO DO_VIS_N_3, 0;
                    SetDO DO_VIS_N_4, 0;
                    SetDO DO_VIS_N_5, 0;
                    SetDO DO_VIS_N_6, 0;
            CASE 3:
                    SetDO DO_VIS_N_1, 1;
                    SetDO DO_VIS_N_2, 1;
                    SetDO DO_VIS_N_3, 1;
                    SetDO DO_VIS_N_4, 0;
                    SetDO DO_VIS_N_5, 0;
                    SetDO DO_VIS_N_6, 0;
            CASE 4:
                    SetDO DO_VIS_N_1, 1;
                    SetDO DO_VIS_N_2, 1;
                    SetDO DO_VIS_N_3, 1;
                    SetDO DO_VIS_N_4, 1;
                    SetDO DO_VIS_N_5, 0;
                    SetDO DO_VIS_N_6, 0;
            CASE 5:
                    SetDO DO_VIS_N_1, 1;
                    SetDO DO_VIS_N_2, 1;
                    SetDO DO_VIS_N_3, 1;
                    SetDO DO_VIS_N_4, 1;
                    SetDO DO_VIS_N_5, 1;
                    SetDO DO_VIS_N_6, 0;
            CASE 6:
                    SetDO DO_VIS_N_1, 1;
                    SetDO DO_VIS_N_2, 1;
                    SetDO DO_VIS_N_3, 1;
                    SetDO DO_VIS_N_4, 1;
                    SetDO DO_VIS_N_5, 1;
                    SetDO DO_VIS_N_6, 1;
        ENDTEST
    ENDPROC
    
    PROC ATTACH_RING_ID(num id_ring)
        ! Description:                                                            !
        !   Attach (grasp) the ring depending on the input identification number. !
        
        WaitTime r_str.r_param.wait_sgT;
        TEST id_ring
            CASE 1:
                PulseDO DO_SG_L_R_ID_1;
                WaitTime r_str.r_param.wait_sgT;
                PulseDO DO_SG_L_ATT_ID_1;
            CASE 2:
                PulseDO DO_SG_L_R_ID_2;
                WaitTime r_str.r_param.wait_sgT;
                PulseDO DO_SG_L_ATT_ID_2;
            CASE 3:
                PulseDO DO_SG_L_R_ID_3;
                WaitTime r_str.r_param.wait_sgT;
                PulseDO DO_SG_L_ATT_ID_3;
            CASE 4:
                PulseDO DO_SG_L_R_ID_4;
                WaitTime r_str.r_param.wait_sgT;
                PulseDO DO_SG_L_ATT_ID_4;
            CASE 5:
                PulseDO DO_SG_L_R_ID_5;
                WaitTime r_str.r_param.wait_sgT;
                PulseDO DO_SG_L_ATT_ID_5;
            CASE 6:
                PulseDO DO_SG_L_R_ID_6;
                WaitTime r_str.r_param.wait_sgT;
                PulseDO DO_SG_L_ATT_ID_6;
        ENDTEST
        WaitTime r_str.r_param.wait_sgT;
    ENDPROC
    
    PROC DETACH_RING_ID(num id_ring)
        ! Description:                                                              !
        !   Detach (storage) the ring depending on the input identification number. !
        
        WaitTime r_str.r_param.wait_sgT;
        PulseDO DO_SG_L_Home;
        TEST id_ring
            CASE 1:
                WaitTime r_str.r_param.wait_sgT;
                PulseDO DO_SG_L_DET_ID_1;
            CASE 2:
                WaitTime r_str.r_param.wait_sgT;
                PulseDO DO_SG_L_DET_ID_2;
            CASE 3:
                WaitTime r_str.r_param.wait_sgT;
                PulseDO DO_SG_L_DET_ID_3;
            CASE 4:
                WaitTime r_str.r_param.wait_sgT;
                PulseDO DO_SG_L_DET_ID_4;
            CASE 5:
                WaitTime r_str.r_param.wait_sgT;
                PulseDO DO_SG_L_DET_ID_5;
            CASE 6:
                WaitTime r_str.r_param.wait_sgT;
                PulseDO DO_SG_L_DET_ID_6;
        ENDTEST 
        WaitTime r_str.r_param.wait_sgT;
    ENDPROC
    
    PROC Path_Init()
        ! Description:                                  !
        !   Auxiliary targets created in Paths&Targets. !
        
        MoveL Target_INIT,v1000,z100,Servo\WObj:=wobj0;
        MoveL Target_GRASP,v1000,z100,Servo\WObj:=wobj0;
    ENDPROC
ENDMODULE