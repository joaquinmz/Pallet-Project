MODULE PalletProgram

    CONST robtarget PickConveyor2:=[[-35.5,-160,200],[0,-0.707106781,0.707106781,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget PlaceTable:=[[-95,165,200],[0,0,1,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget PickTableStack:=[[195,130,200],[0,0,1,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget PickLiner:=[[400,270,100],[0,0,1,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget PlaceHalfPallet:=[[205,170,200],[0,0,1,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget PlaceLiner:=[[400,300,210],[0,0,1,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget PickConveyor1:=[[249.5,0,200],[0,0,1,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget PlaceEuroRow2:=[[350,150,200],[0,1,0,0],[-2,0,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget PlaceEuroRow4:=[[225,525,200],[0,-0.707106781,0.707106781,0],[-2,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];

    CONST num SafeHeight:=300;

    VAR bool cupsState{6}:=[FALSE,FALSE,FALSE,FALSE,FALSE,FALSE];
    CONST bool CupsAllOn{6}:=[TRUE,TRUE,TRUE,TRUE,TRUE,TRUE];
    CONST bool CupsAllOff{6}:=[FALSE,FALSE,FALSE,FALSE,FALSE,FALSE];
    CONST bool CupsBox2On{6}:=[FALSE,FALSE,FALSE,TRUE,FALSE,FALSE];
    VAR signaldo cupSignals{6};

    CONST num BoxHeight:=200;

    ! BOX 1 FINITE-STATE MACHINE

    CONST num Box1Pos1:=1;
    CONST num Box1Pos2:=2;
    CONST num Box1Pos3:=3;
    CONST num Box1Pos4:=4;
    CONST num Box1Pos5:=5;
    CONST num Box1Pos6:=6;
    VAR num box1State:=1;
    VAR num box1Layer:=1;
    CONST num Box1MaxLayers:=2;
    VAR bool euroPalletFull:=FALSE;


    CONST num VacuumTime:=1;

    PROC Main()

    ENDPROC

    PROC ProcessBox1()

        ApproachPoint PickConveyor1,wobjConveyor1,CupsAllOn,loadBox1;

        TEST box1State
        CASE Box1Pos1:
            ApproachPoint Offs(PlaceEuroRow4,0,0,(box1Layer-1)*BoxHeight),wobjEuroPallet,CupsAllOff,load0;
            box1State:=Box1Pos2;
        CASE Box1Pos2:
            ApproachPoint Offs(PlaceEuroRow4,250,0,(box1Layer-1)*BoxHeight),wobjEuroPallet,CupsAllOff,load0;
            box1State:=Box1Pos3;
        CASE Box1Pos3:
            ApproachPoint Offs(PlaceEuroRow4,500,0,(box1Layer-1)*BoxHeight),wobjEuroPallet,CupsAllOff,load0;
            box1State:=Box1Pos4;
        CASE Box1Pos4:
            ApproachPoint Offs(PlaceEuroRow4,750,0,(box1Layer-1)*BoxHeight),wobjEuroPallet,CupsAllOff,load0;
            box1State:=Box1Pos5;
        CASE Box1Pos5:
            ApproachPoint Offs(PlaceEuroRow2,0,0,(box1Layer-1)*BoxHeight),wobjEuroPallet,CupsAllOff,load0;
            box1State:=Box1Pos6;
        CASE Box1Pos6:
            ApproachPoint Offs(PlaceEuroRow2,500,0,(box1Layer-1)*BoxHeight),wobjEuroPallet,CupsAllOff,load0;
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

    PROC InitSignals()
        AliasIO DO_Cup11,cupSignals{1};
        AliasIO DO_Cup12,cupSignals{2};
        AliasIO DO_Cup13,cupSignals{3};
        AliasIO DO_Cup21,cupSignals{4};
        AliasIO DO_Cup22,cupSignals{5};
        AliasIO DO_Cup23,cupSignals{6};
    ENDPROC

    PROC ApproachPoint(robtarget target,PERS wobjdata wobj,bool cups{*},PERS loaddata load)
        MoveJ Offs(target,0,0,SafeHeight),v100,z10,toolVacuum\WObj:=wobj;
        MoveL target,v100,fine,toolVacuum\WObj:=wobj;
        VacuumControl cups;
        GripLoad load;
        MoveL Offs(target,0,0,SafeHeight),v100,z10,toolVacuum\WObj:=wobj;
    ENDPROC

ENDMODULE
