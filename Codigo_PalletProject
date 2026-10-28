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

    VAR num nSafeHeight:=300;

    VAR bool CupsState{6}:=[FALSE,FALSE,FALSE,FALSE,FALSE,FALSE];
    CONST bool CupsALL_ON{6}:=[TRUE,TRUE,TRUE,TRUE,TRUE,TRUE];
    CONST bool CupsALL_OFF{6}:=[FALSE,FALSE,FALSE,FALSE,FALSE,FALSE];
    CONST bool CupBox2_ON{6}:=[FALSE,FALSE,FALSE,TRUE,FALSE,FALSE];
    VAR signaldo cupSignals{6};
    
    VAR num BoxHeight := 200;

    ! BOX 1 FINITE-STATE MACHINE

    CONST num Box1:=1;
    CONST num Box2:=2;
    CONST num Box3:=3;
    CONST num Box4:=4;
    CONST num Box5:=5;
    CONST num LastBox:=6;
    VAR num Box1FSM_STATE:=1;
    VAR num Box1Layers := 1;
    VAR bool fEuroPalletFull := false;


    CONST num VACUUM_TIME:=1;

    PROC main()

    ENDPROC
    
    PROC rBox2()
        ApproachPoint PickConveyor2, wobjConveyor2, CupsALL_On;
        
        TEST Box2FSM_STATE
        
        CASE 
        
        
    ENDPROC

    PROC rBox1()

        ApproachPoint PickConveyor1,wobjConveyor1,CupsALL_ON;

        TEST Box1FSM_STATE
        CASE Box1:
            ApproachPoint Offs(PlaceEuroRow4,0,0,(Box1Layers-1)*BoxHeight),wobjEuroPallet,CupsALL_OFF;
            Box1FSM_STATE:=Box2;
        CASE Box2:
            ApproachPoint Offs(PlaceEuroRow4,250,0,(Box1Layers-1)*BoxHeight),wobjEuroPallet,CupsALL_OFF;
            Box1FSM_STATE:=Box3;
        CASE Box3:
            ApproachPoint Offs(PlaceEuroRow4,500,0,(Box1Layers-1)*BoxHeight),wobjEuroPallet,CupsALL_OFF;
            Box1FSM_STATE:=Box4;
        CASE Box4:
            ApproachPoint Offs(PlaceEuroRow4,750,0,(Box1Layers-1)*BoxHeight),wobjEuroPallet,CupsALL_OFF;
            Box1FSM_STATE:=Box5;
        CASE Box5:
            ApproachPoint Offs(PlaceEuroRow2,0,0,(Box1Layers-1)*BoxHeight),wobjEuroPallet,CupsALL_OFF;
            Box1FSM_STATE:=LastBox;
        CASE LastBox:
            ApproachPoint Offs(PlaceEuroRow2,500,0,(Box1Layers-1)*BoxHeight),wobjEuroPallet,CupsALL_OFF;
            IF Box1Layers = 2 THEN
                feuroPalletFull := TRUE;
            ELSE
                Incr Box1Layers;
            ENDIF
        DEFAULT:
            Box1FSM_STATE:=Box1;
        ENDTEST
        
    ENDPROC

    PROC VacuumControl(bool cups{*})
        CupsState:=cups;

        FOR i FROM 1 TO Dim(cups,1) DO
            IF cups{i} THEN
                SetDO cupSignals{i},1;
            ELSE
                SetDO cupSignals{i},0;
            ENDIF
        ENDFOR

        WaitTime\InPos,VACUUM_TIME;
    ENDPROC

    PROC InitSignals()
        AliasIO DO_Cup11,cupSignals{1};
        AliasIO DO_Cup12,cupSignals{2};
        AliasIO DO_Cup13,cupSignals{3};
        AliasIO DO_Cup21,cupSignals{4};
        AliasIO DO_Cup22,cupSignals{5};
        AliasIO DO_Cup23,cupSignals{6};
    ENDPROC

    PROC ApproachPoint(robtarget target,PERS wobjdata wobj,bool cups{*})
        MoveJ Offs(target,0,0,nSafeHeight),v100,z10,toolVacuum\WObj:=Wobj;
        MoveL target,v100,fine,toolVacuum\WObj:=Wobj;
        VacuumControl(cups);
        MoveL Offs(target,0,0,nSafeHeight),v100,z10,toolVacuum\WObj:=Wobj;
    ENDPROC

ENDMODULE