MODULE PalletProgram

    !***********************************************************************
    ! Industrial Robotics and Offline Programming G1F - University of Skovde
    ! Offline programming project: Pallet Project - Group 2 (JMPM)
    ! Authors: Peru Mendivil and Joaquin Moreno
    ! Robot :   ABB IRB 1600-10/1.45, IRC5 RobotWare 6.13.02 (RobotStudio 2025)
    ! Tool  :   toolVacuum, vacuum gripper with 6 cups (one valve per cup)
    ! Date:    2026-10-28
    !
    ! The robot palletizes two products coming on two conveyors.
    ! Box 1 goes from conveyor 1 to the Euro pallet: 4-2 pattern,
    ! 2 layers (12 boxes). Box 2 goes from conveyor 2 to the stacking
    ! table, where a 3x2 block is formed. The block is then moved to the
    ! half pallet: 2x2 blocks per layer, 3 layers (72 boxes), with a liner
    ! after layers 1 and 2. When both conveyors have a box, the robot
    ! alternates box 1 and box 2. A full pallet is replaced by the operator
    ! from outside the fence, and the robot keeps working with the other
    ! product. With the half pallet full, one block can still be finished
    ! on the table, and it waits there.
    !
    ! Structure: Main is a state machine (grafcet). It initialises the
    ! signals and then decides each cycle which box to handle, from the
    ! conveyor sensors, the full-pallet flags and the last box handled.
    ! Each product has its own routine with a finite-state machine for
    ! the place positions. Every place position is calculated with Offs
    ! from one base target per station. ApproachPoint does every
    ! pick/place: approach, vacuum on/off and GripLoad. Work objects,
    ! tool and loads are in the module CalibData.
    !
    ! Naming: VAR, PERS and parameters in camelCase (can change);
    ! CONST, PROC, FUNC and MODULE in PascalCase (fixed).
    !***********************************************************************

    !-----------------------------------------------------------------------
    ! Base targets
    !-----------------------------------------------------------------------
    CONST robtarget PickConveyor2:=[[-35.5,-160,200],[0,-0.707106781,0.707106781,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget PlaceTable:=[[-95,165,200],[0,0,1,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget PickTableStack:=[[195,130,200],[0,0,1,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget PickLiner:=[[400,270,100],[0,0,1,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget PlaceHalfPallet:=[[205,170,200],[0,0,1,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget PlaceLiner:=[[400,300,210],[0,0,1,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget PickConveyor1:=[[249.5,0,200],[0,0,1,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget PlaceEuroRow2:=[[350,150,200],[0,1,0,0],[-2,0,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget PlaceEuroRow4:=[[225,525,200],[0,-0.707106781,0.707106781,0],[-2,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];

    !-----------------------------------------------------------------------
    ! Parameters and variables
    !-----------------------------------------------------------------------
    CONST num SafeHeight:=300;
    CONST num Box1Height:=200;
    CONST num Box2Height:=200;
    CONST num TotalLiners:=10;
    VAR num linersLeft:=totalLiners;
    CONST num LinerHeight:=10;

    CONST num VacuumTime:=1;
    VAR bool cupsState{6}:=[FALSE,FALSE,FALSE,FALSE,FALSE,FALSE];
    CONST bool CupsAllOn{6}:=[TRUE,TRUE,TRUE,TRUE,TRUE,TRUE];
    CONST bool CupsAllOff{6}:=[FALSE,FALSE,FALSE,FALSE,FALSE,FALSE];
    CONST bool CupsBox2On{6}:=[FALSE,FALSE,FALSE,TRUE,FALSE,FALSE];
    VAR signaldo cupSignals{6};

    !-----------------------------------------------------------------------
    ! Box 1 state machine parameters and variables
    !-----------------------------------------------------------------------
    CONST num Box1Pos1:=1;
    CONST num Box1Pos2:=2;
    CONST num Box1Pos3:=3;
    CONST num Box1Pos4:=4;
    CONST num Box1Pos5:=5;
    CONST num Box1LastPos:=6;
    CONST num Box1MaxLayers:=2;

    VAR num box1State:=1;
    VAR num box1Layer:=1;
    VAR bool euroPalletFull:=FALSE;

    !-----------------------------------------------------------------------
    ! Box 2 state machine parameters and variables
    !-----------------------------------------------------------------------
    CONST num Box2Pos1:=1;
    CONST num Box2Pos2:=2;
    CONST num Box2Pos3:=3;
    CONST num Box2Pos4:=4;
    CONST num Box2Pos5:=5;
    CONST num Box2LastPos:=6;
    CONST num Box2MaxLayers:=3;

    VAR num box2State:=1;
    VAR bool halfPalletFull:=FALSE;
    VAR bool tableFull:=FALSE;
    VAR num linersPlaced:=0;

    ! Parameters and variables for TransferStack
    VAR num blockState:=1;
    VAR num box2Layer:=1;

    CONST num BlockPos1:=1;
    CONST num BlockPos2:=2;
    CONST num BlockPos3:=3;
    CONST num BlockPos4:=4;


    PROC Main()

        IF halfPalletFull AND DI_HalfPalletReplaced=1 THEN
            box2Layer:=1;
            linersPlaced:=0;
            blockState:=BlockPos1;
            halfPalletFull:=FALSE;
            IF tableFull THEN
                TransferStack;
                tableFull:=FALSE;
            ENDIF
        ENDIF

        IF euroPalletFull AND DI_EuroPalletReplaced=1 THEN
            box1Layer:=1;
            !Not necessary but safe
            box1State:=Box1Pos1;
            euroPalletFull:=FALSE;
        ENDIF
    ENDPROC

    FUNC bool Box1Ready()
        ! Box 1 waiting on conveyor 1 and room on the Euro pallet
        RETURN (DI_Box1Arrived=1) AND (NOT euroPalletFull);
    ENDFUNC

    FUNC bool Box2Ready()
        ! Box 2 waiting on conveyor 2 and room on the table
        RETURN (DI_Box2Arrived=1) AND (NOT tableFull);
    ENDFUNC

    !-----------------------------------------------------------------------
    ! Box 1 state machine
    !-----------------------------------------------------------------------
    PROC ProcessBox1()

        ApproachPoint PickConveyor1,wobjConveyor1,CupsAllOn,loadBox1;

        TEST box1State
        CASE Box1Pos1:
            ApproachPoint Offs(PlaceEuroRow4,0,0,(box1Layer-1)*Box1Height),wobjEuroPallet,CupsAllOff,load0;
            box1State:=Box1Pos2;
        CASE Box1Pos2:
            ApproachPoint Offs(PlaceEuroRow4,250,0,(box1Layer-1)*Box1Height),wobjEuroPallet,CupsAllOff,load0;
            box1State:=Box1Pos3;
        CASE Box1Pos3:
            ApproachPoint Offs(PlaceEuroRow4,500,0,(box1Layer-1)*Box1Height),wobjEuroPallet,CupsAllOff,load0;
            box1State:=Box1Pos4;
        CASE Box1Pos4:
            ApproachPoint Offs(PlaceEuroRow4,750,0,(box1Layer-1)*Box1Height),wobjEuroPallet,CupsAllOff,load0;
            box1State:=Box1Pos5;
        CASE Box1Pos5:
            ApproachPoint Offs(PlaceEuroRow2,0,0,(box1Layer-1)*Box1Height),wobjEuroPallet,CupsAllOff,load0;
            box1State:=Box1LastPos;
        CASE Box1LastPos:
            ApproachPoint Offs(PlaceEuroRow2,500,0,(box1Layer-1)*Box1Height),wobjEuroPallet,CupsAllOff,load0;
            IF box1Layer=Box1MaxLayers THEN
                euroPalletFull:=TRUE;
            ELSE
                Incr box1Layer;
            ENDIF
            box1State:=Box1Pos1;
        DEFAULT:
            box1State:=Box1Pos1;
        ENDTEST

    ENDPROC

    !-----------------------------------------------------------------------
    ! Box 2 state machine
    !-----------------------------------------------------------------------
    PROC ProcessBox2()

        ApproachPoint PickConveyor2,wobjConveyor2,CupsBox2On,loadBox2;

        TEST box2State
        CASE Box2Pos1:
            ApproachPoint Offs(PlaceTable,260,130,0),wobjTable,CupsAllOff,load0;
            box2State:=Box2Pos2;
        CASE Box2Pos2:
            ApproachPoint Offs(PlaceTable,130,130,0),wobjTable,CupsAllOff,load0;
            box2State:=Box2Pos3;
        CASE Box2Pos3:
            ApproachPoint Offs(PlaceTable,0,130,0),wobjTable,CupsAllOff,load0;
            box2State:=Box2Pos4;
        CASE Box2Pos4:
            ApproachPoint Offs(PlaceTable,260,0,0),wobjTable,CupsAllOff,load0;
            box2State:=Box2Pos5;
        CASE Box2Pos5:
            ApproachPoint Offs(PlaceTable,130,0,0),wobjTable,CupsAllOff,load0;
            box2State:=Box2LastPos;
        CASE Box2LastPos:
            ApproachPoint Offs(PlaceTable,0,0,0),wobjTable,CupsAllOff,load0;
            IF halfPalletFull THEN
                tableFull:=TRUE;
            ELSE
                TransferStack;
            ENDIF
            box2State:=Box2Pos1;
        DEFAULT:
            box2State:=Box2Pos1;
        ENDTEST

    ENDPROC

    !-----------------------------------------------------------------------
    ! Controll of every cups vacuum
    !-----------------------------------------------------------------------
    PROC VacuumControl(bool cups{*})
        cupsState:=cups;

        FOR i FROM 1 TO Dim(cups,1) DO
            IF cups{i} THEN
                SetDO cupSignals{i},1;
            ELSE
                SetDO cupSignals{i},0;
            ENDIF
        ENDFOR

        WaitTime\InPos,VacuumTime;
    ENDPROC

    !-----------------------------------------------------------------------
    ! Assignment of logical cup signals with physical signals
    !-----------------------------------------------------------------------
    PROC InitSignals()
        AliasIO DO_Cup11,cupSignals{1};
        AliasIO DO_Cup12,cupSignals{2};
        AliasIO DO_Cup13,cupSignals{3};
        AliasIO DO_Cup21,cupSignals{4};
        AliasIO DO_Cup22,cupSignals{5};
        AliasIO DO_Cup23,cupSignals{6};
    ENDPROC

    !-----------------------------------------------------------------------
    ! Process for box 2 configuration on half pallet
    !-----------------------------------------------------------------------
    PROC TransferStack()

        !Pick all 6 boxes 2
        ApproachPoint Offs(PickTableStack,0,0,0),wobjTable,CupsAllOn,loadBox2Stack;

        !Place group of boxes
        TEST blockState
        CASE BlockPos1:
            ApproachPoint Offs(PlaceHalfPallet,0,130*2,(box2Layer-1)*Box2Height+linersPlaced*LinerHeight),wobjHalfPallet,CupsAllOff,load0;
            blockState:=BlockPos2;
        CASE BlockPos2:
            ApproachPoint Offs(PlaceHalfPallet,130*3,130*2,(box2Layer-1)*Box2Height+linersPlaced*LinerHeight),wobjHalfPallet,CupsAllOff,load0;
            blockState:=BlockPos3;
        CASE BlockPos3:
            ApproachPoint Offs(PlaceHalfPallet,0,0,(box2Layer-1)*Box2Height+linersPlaced*LinerHeight),wobjHalfPallet,CupsAllOff,load0;
            blockState:=BlockPos4;
        CASE BlockPos4:
            ApproachPoint Offs(PlaceHalfPallet,130*3,0,(box2Layer-1)*Box2Height+linersPlaced*LinerHeight),wobjHalfPallet,CupsAllOff,load0;
            IF box2Layer=Box2MaxLayers THEN
                halfPalletFull:=TRUE;
            ELSE
                ApproachPoint Offs(PickLiner,0,0,-(TotalLiners-linersLeft)*LinerHeight),wobjLinerStack,CupsAllOn,loadLiner;
                ApproachPoint Offs(PlaceLiner,0,0,(box2Layer-1)*Box2Height+linersPlaced*LinerHeight),wobjHalfPallet,CupsAllOff,load0;
                Incr box2Layer;
                Incr linersPlaced;
                Decr LinersLeft;
            ENDIF
            blockState:=BlockPos1;
        DEFAULT:
            blockState:=BlockPos1;
        ENDTEST
    ENDPROC

    !-----------------------------------------------------------------------
    ! Approach for every point
    !-----------------------------------------------------------------------
    PROC ApproachPoint(robtarget target,PERS wobjdata wobj,bool cups{*},PERS loaddata load)
        MoveJ Offs(target,0,0,SafeHeight),v100,z10,toolVacuum\WObj:=wobj;
        MoveL target,v100,fine,toolVacuum\WObj:=wobj;
        VacuumControl cups;
        GripLoad load;
        MoveL Offs(target,0,0,SafeHeight),v100,z10,toolVacuum\WObj:=wobj;
    ENDPROC

ENDMODULE
