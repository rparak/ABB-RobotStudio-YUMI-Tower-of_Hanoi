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
    PERS num CONST_NUM_OF_RINGS;
    ! Tower of Hanoi: Parameters
    PERS num CONST_RING_OFFSET;
    PERS num CONST_TOWER_OFFSET;
    
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
    
    ! Main waypoints (targets) for robot control
    CONST robtarget Target_INIT:=[[63.216469094,-163.494541756,161.324792507],[0.066010726,-0.842420918,-0.111214912,-0.523068661],[0,0,0,4],[-101.964427132,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget Target_GRASP:=[[457.32,-57.631690972,48.054366948],[0.5,-0.866025404,0,0],[0,-1,1,4],[-101.964427132,9E+09,9E+09,9E+09,9E+09,9E+09]];

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
        
                ! Initialize the parameters
                INIT_PARAM;
                ! Restore the environment
                RESET_ENV;
                ! Move -> Home position
                MoveJ Target_INIT,r_str.r_param.speed,fine,Servo\WObj:=wobj0;
                
                ! Initialization position near the first grasp ring.
                MoveL Offs(Target_GRASP, TOH_SOL_Standard{1, 2} * ((-1) * CONST_TOWER_OFFSET), -100.0, 200.0), r_str.r_param.speed, r_str.r_param.zone, Servo\WObj:=wobj0;
                r_str.actual_state := 1;
                
            CASE 1:
                ! Description:                                                                 !
                !  The waiting state for the second robot (arm) to finish solving the problem. !
                
                IF IN_POS_ROB_L = TRUE THEN
                    r_str.actual_state := 10;
                ENDIF 
                
            CASE 10:
                ! Description:                         !
                !  Solving the Tower of Hanoi problem. !
                
                FOR i FROM 1 TO Pow(2, CONST_NUM_OF_RINGS) - 1 DO
                    ! Path: 1-1
                    MoveL Offs(Target_GRASP, TOH_SOL_Standard{i, 2} * ((-1) * CONST_TOWER_OFFSET), 0.0, 200.0), r_str.r_param.speed, r_str.r_param.zone, Servo\WObj:=wobj0;
                    
                    ! Path: 1-2
                    MoveL Offs(Target_GRASP, TOH_SOL_Standard{i, 2} * ((-1) * CONST_TOWER_OFFSET), 0.0, 110.0 + CONST_RING_OFFSET * ((TOH_SOL_Standard{i, 4 + TOH_SOL_Standard{i, 2}}) - 1)), r_str.r_param.speed, r_str.r_param.zone, Servo\WObj:=wobj0;
                    MoveL Offs(Target_GRASP, TOH_SOL_Standard{i, 2} * ((-1) * CONST_TOWER_OFFSET), 0.0, CONST_RING_OFFSET * ((TOH_SOL_Standard{i, 4 + TOH_SOL_Standard{i, 2}}) - 1)), r_str.r_param.speed, fine, Servo\WObj:=wobj0;
                    
                    ! Signal -> Attach the object.
                    ATTACH_RING_ID TOH_SOL_Standard{i, 1} + 1; 
                    
                    ! Path: 2-1
                    MoveL Offs(Target_GRASP, TOH_SOL_Standard{i, 2} * ((-1) * CONST_TOWER_OFFSET), 0.0, 200.0), r_str.r_param.speed, r_str.r_param.zone, Servo\WObj:=wobj0;
                    MoveL Offs(Target_GRASP, TOH_SOL_Standard{i, 3} * ((-1) * CONST_TOWER_OFFSET), 0.0, 200.0), r_str.r_param.speed, r_str.r_param.zone, Servo\WObj:=wobj0;
                    MoveL Offs(Target_GRASP, TOH_SOL_Standard{i, 3} * ((-1) * CONST_TOWER_OFFSET), 0.0, 10.0 + CONST_RING_OFFSET * (TOH_SOL_Standard{i, 4 + TOH_SOL_Standard{i, 3}})), r_str.r_param.speed, r_str.r_param.zone, Servo\WObj:=wobj0;
                    MoveL Offs(Target_GRASP, TOH_SOL_Standard{i, 3} * ((-1) * CONST_TOWER_OFFSET), 0.0, CONST_RING_OFFSET * (TOH_SOL_Standard{i, 4 + TOH_SOL_Standard{i, 3}})), r_str.r_param.speed, fine, Servo\WObj:=wobj0;
                    
                    ! Signal -> Detach the object.
                    DETACH_RING_ID TOH_SOL_Standard{i, 1} + 1;
                    
                    ! Path: 2-2
                    MoveL Offs(Target_GRASP,TOH_SOL_Standard{i, 3} * ((-1) * CONST_TOWER_OFFSET), 0.0, 200.0), r_str.r_param.speed, r_str.r_param.zone, Servo\WObj:=wobj0;
                ENDFOR
                
                ! Initialization position near the last storage ring.
                MoveL Offs(Target_GRASP,TOH_SOL_Standard{Pow(2, CONST_NUM_OF_RINGS) - 1, 3} * ((-1) * CONST_TOWER_OFFSET), -100.0, 200.0), r_str.r_param.speed, r_str.r_param.zone, Servo\WObj:=wobj0;
        
                ! Change the values (the robot completed the problem).
                IN_POS_ROB_L := FALSE;
                IN_POS_ROB_R := TRUE;
                r_str.actual_state := 90;
                
            CASE 90:
                ! Description:                 !
                !  Move to a waiting position. !
                
                ! Initialization position near the first grasp ring.
                MoveL Offs(Target_GRASP, TOH_SOL_Standard{1, 2} * ((-1) * CONST_TOWER_OFFSET),-100.0, 200.0), r_str.r_param.speed, r_str.r_param.zone, Servo\WObj:=wobj0;
                r_str.actual_state := 1;
        ENDTEST     
    ENDPROC

    PROC INIT_PARAM()
        ! Description:                               !
        !   Intitialization parameters of the robot. !
        
        ! Intitialization parameters of the robot
        ! Speed
        r_str.r_param.speed := [100, 100, 100, 100];
        ! Zone
        r_str.r_param.zone  := z50;
        ! Wait time (Smart Gripper) -> [seconds]
        r_str.r_param.wait_sgT := 0.25;
    ENDPROC
    
    PROC RESET_ENV()
        ! Description:                                                   !
        !   Restore the robotic environment to the initialization state. !

        IN_POS_ROB_R := FALSE;
        IN_POS_ROB_L := TRUE;
                
        ! Detach all objects.
        PulseDO DO_SG_R_DET_ID_1;
        PulseDO DO_SG_R_DET_ID_2;
        PulseDO DO_SG_R_DET_ID_3;
        PulseDO DO_SG_R_DET_ID_4;
        PulseDO DO_SG_R_DET_ID_5;
        PulseDO DO_SG_R_DET_ID_6;
        
        ! Smart Gripper -> Release (Home Position)
        PulseDO DO_SG_R_Home;
    ENDPROC
    
    PROC ATTACH_RING_ID(num id_ring)
        ! Description:                                                            !
        !   Attach (grasp) the ring depending on the input identification number. !
        
        WaitTime r_str.r_param.wait_sgT;
        TEST id_ring
            CASE 1:
                PulseDO DO_SG_R_R_ID_1;
                WaitTime r_str.r_param.wait_sgT;
                PulseDO DO_SG_R_ATT_ID_1;
            CASE 2:
                PulseDO DO_SG_R_R_ID_2;
                WaitTime r_str.r_param.wait_sgT;
                PulseDO DO_SG_R_ATT_ID_2;
            CASE 3:
                PulseDO DO_SG_R_R_ID_3;
                WaitTime r_str.r_param.wait_sgT;
                PulseDO DO_SG_R_ATT_ID_3;
            CASE 4:
                PulseDO DO_SG_R_R_ID_4;
                WaitTime r_str.r_param.wait_sgT;
                PulseDO DO_SG_R_ATT_ID_4;
            CASE 5:
                PulseDO DO_SG_R_R_ID_5;
                WaitTime r_str.r_param.wait_sgT;
                PulseDO DO_SG_R_ATT_ID_5;
            CASE 6:
                PulseDO DO_SG_R_R_ID_6;
                WaitTime r_str.r_param.wait_sgT;
                PulseDO DO_SG_R_ATT_ID_6;
        ENDTEST
        WaitTime r_str.r_param.wait_sgT;
    ENDPROC
    
    PROC DETACH_RING_ID(num id_ring)
        ! Description:                                                              !
        !   Detach (storage) the ring depending on the input identification number. !
        
        WaitTime r_str.r_param.wait_sgT;
        PulseDO DO_SG_R_Home;
        TEST id_ring
            CASE 1:
                WaitTime r_str.r_param.wait_sgT;
                PulseDO DO_SG_R_DET_ID_1;
            CASE 2:
                WaitTime r_str.r_param.wait_sgT;
                PulseDO DO_SG_R_DET_ID_2;
            CASE 3:
                WaitTime r_str.r_param.wait_sgT;
                PulseDO DO_SG_R_DET_ID_3;
            CASE 4:
                WaitTime r_str.r_param.wait_sgT;
                PulseDO DO_SG_R_DET_ID_4;
            CASE 5:
                WaitTime r_str.r_param.wait_sgT;
                PulseDO DO_SG_R_DET_ID_5;
            CASE 6:
                WaitTime r_str.r_param.wait_sgT;
                PulseDO DO_SG_R_DET_ID_6;
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