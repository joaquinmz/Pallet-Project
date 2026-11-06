MODULE CalibData
    TASK PERS wobjdata wobjEuroPallet:=[FALSE,TRUE,"",[[600,600,144],[0.707106781,0,0,-0.707106781]],[[0,0,0],[1,0,0,0]]];
    TASK PERS wobjdata wobjHalfPallet:=[FALSE,TRUE,"",[[400,-600,144],[0,0,0,1]],[[0,0,0],[1,0,0,0]]];
    TASK PERS wobjdata wobjConveyor1:=[FALSE,TRUE,"",[[338.5,670,768],[0.707106781,0,0,0.707106781]],[[0,0,0],[1,0,0,0]]];
    TASK PERS wobjdata wobjConveyor2:=[FALSE,TRUE,"",[[-353.5,670,768],[0.707106781,0,0,0.707106781]],[[0,0,0],[1,0,0,0]]];
    TASK PERS wobjdata wobjTable:=[FALSE,TRUE,"",[[-600,600,770],[0,0,0,1]],[[55,170,0],[1,0,0,0]]];
    TASK PERS wobjdata wobjLinerStack:=[FALSE,TRUE,"",[[-500,-160,500],[0,0,0,1]],[[0,0,0],[1,0,0,0]]];
    TASK PERS tooldata toolVacuum:=[TRUE,[[0,0,175],[1,0,0,0]],[1,[0,0,1],[1,0,0,0],0,0,0]];
    ! toolVacuum: mass and CoG are provisional (1 kg), to be estimated

    ! Payloads: CoG relative to the TCP of toolVacuum; inertia set to 0 (point mass) until confirmed
    TASK PERS loaddata loadBox1:=[2,[0,0,100],[1,0,0,0],0,0,0];
    ! Box 2 is picked with one corner cup (x=-160, y=-100); on the table fill rows ascending Y, each row descending X
    TASK PERS loaddata loadBox2:=[0.4,[-160,-100,100],[1,0,0,0],0,0,0];
    ! 3x2 stack of box 2 (390 x 260 x 200 mm, 6 x 0.4 kg)
    TASK PERS loaddata loadBox2Stack:=[2.4,[0,0,100],[1,0,0,0],0,0,0];
    ! Liner: corrugated cardboard, 0.8 x 0.54 x 0.01 m3 x 120 kg/m3 = 0.52 kg
    TASK PERS loaddata loadLiner:=[0.52,[0,0,5],[1,0,0,0],0,0,0];
ENDMODULE
