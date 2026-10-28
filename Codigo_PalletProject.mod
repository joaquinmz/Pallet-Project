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

    VAR num nSafeHeight:=100;

    VAR bool CupsState{6}:=[FALSE,FALSE,FALSE,FALSE,FALSE,FALSE];
    CONST bool CupsALL_ON{6}:=[TRUE,TRUE,TRUE,TRUE,TRUE,TRUE];
    CONST bool CupsALL_OFF{6}:=[FALSE,FALSE,FALSE,FALSE,FALSE,FALSE];
    CONST bool CupBox2_ON{6}:=[FALSE,FALSE,FALSE,TRUE,FALSE,FALSE];
    VAR signaldo cupSignals{6};
    
    Const num Box1Height := 200;
    Const num Box2Height := 200;
    Const num LinerHeight := 10;
    VAR num nLiner := 0;

    ! BOX 1 FINITE-STATE MACHINE
    
    ! State variables for Box 1
    CONST num Box11:=1;
    CONST num Box12:=2;
    CONST num Box13:=3;
    CONST num Box14:=4;
    CONST num Box15:=5;
    CONST num LastBox1:=6;
    
    ! States variables for Box 2
    CONST num Box21:=1;
    CONST num Box22:=2;
    CONST num Box23:=3;
    CONST num Box24:=4;
    CONST num Box25:=5;
    CONST num LastBox2:=6;
    
    
    VAR num Box1FSM_STATE:=1;
    VAR num Box2FSM_STATE := 1;
    VAR num Box1Layers := 1;
    VAR num Box2Layers := 1;
    VAR bool fHalfPalletFull := false;
    VAR bool fEuroPalletFull := false;
    

    CONST num VACUUM_TIME:=1;

    PROC main()
    
        FOR I FROM 1 TO 100 DO
            rBox2;
        ENDFOR
       
    ENDPROC
    
    PROC rBox2()
        ApproachPoint PickConveyor2, wobjConveyor2, CupBox2_ON;
        
        TEST Box2FSM_STATE
        CASE Box21:
            ApproachPoint Offs(PlaceTable,260,130,0),wobjTable,CupsALL_OFF;
            Box2FSM_STATE:=Box22;
        CASE Box22:
            ApproachPoint Offs(PlaceTable,130,130,0),wobjTable,CupsALL_OFF;
            Box2FSM_STATE:=Box23;
        CASE Box23:
            ApproachPoint Offs(PlaceTable,0,130,0),wobjTable,CupsALL_OFF;
            Box2FSM_STATE:=Box24;
        CASE Box24:
            ApproachPoint Offs(PlaceTable,260,0,0),wobjTable,CupsALL_OFF;
            Box2FSM_STATE:=Box25;
        CASE Box25:
            ApproachPoint Offs(PlaceTable,130,0,0),wobjTable,CupsALL_OFF;
            Box2FSM_STATE:=LastBox2;
        CASE LastBox2:
            ApproachPoint Offs(PlaceTable,0,0,0),wobjTable,CupsALL_OFF; 
            IF Box2Layers = 3 THEN
                feuroPalletFull := TRUE;
            ELSE
                ApproachPoint Offs(PickTableStack,0,0,0),wobjTable,CupsALL_OFF;
                ApproachPoint Offs(PlaceHalfPallet,0,0,(Box2Layers-1)*Box2Height + nLiner*LinerHeight),wobjHalfPallet,CupsALL_OFF;
                Incr Box2Layers;
                ApproachPoint Offs(PickLiner,0,0,0),wobjLinerStack,CupsALL_OFF;
                ApproachPoint Offs(PlaceLiner,0,0,(Box2Layers-1)*Box2Height + nLiner*LinerHeight),wobjHalfPallet,CupsALL_OFF; 
                Incr nLiner;
            ENDIF
        DEFAULT:

        ENDTEST 
        
        
    ENDPROC

    PROC rBox1()

        ApproachPoint PickConveyor1,wobjConveyor1,CupsALL_ON;

        TEST Box1FSM_STATE
        CASE Box11:
            ApproachPoint Offs(PlaceEuroRow4,0,0,(Box1Layers-1)*Box1Height),wobjEuroPallet,CupsALL_OFF;
            Box1FSM_STATE:=Box12;
        CASE Box12:
            ApproachPoint Offs(PlaceEuroRow4,250,0,(Box1Layers-1)*Box1Height),wobjEuroPallet,CupsALL_OFF;
            Box1FSM_STATE:=Box13;
        CASE Box13:
            ApproachPoint Offs(PlaceEuroRow4,500,0,(Box1Layers-1)*Box1Height),wobjEuroPallet,CupsALL_OFF;
            Box1FSM_STATE:=Box14;
        CASE Box14:
            ApproachPoint Offs(PlaceEuroRow4,750,0,(Box1Layers-1)*Box1Height),wobjEuroPallet,CupsALL_OFF;
            Box1FSM_STATE:=Box15;
        CASE Box15:
            ApproachPoint Offs(PlaceEuroRow2,0,0,(Box1Layers-1)*Box1Height),wobjEuroPallet,CupsALL_OFF;
            Box1FSM_STATE:=LastBox1;
        CASE LastBox1:
            ApproachPoint Offs(PlaceEuroRow2,500,0,(Box1Layers-1)*Box1Height),wobjEuroPallet,CupsALL_OFF;
            IF Box1Layers = 2 THEN
                feuroPalletFull := TRUE;
            ELSE
                Incr Box1Layers;
            ENDIF
        DEFAULT:
            Box1FSM_STATE:=Box11;
        ENDTEST
        
    ENDPROC

    PROC VacuumControl(bool cups{*})
        CupsState:=cups;

        FOR i FROM 1 TO Dim(cups,1) DO
            IF cups{i} THEN
               ! SetDO cupSignals{i},1;
            ELSE
                !SetDO cupSignals{i},0;
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
        MoveL Offs(target,0,0,nSafeHeight),v1000,z10,toolVacuum\WObj:=Wobj;
        MoveL target,v100,fine,toolVacuum\WObj:=Wobj;
        VacuumControl(cups);
        MoveL Offs(target,0,0,nSafeHeight),v100,z10,toolVacuum\WObj:=Wobj;
    ENDPROC

ENDMODULE