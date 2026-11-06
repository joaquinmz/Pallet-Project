MODULE CalibData
    ! Calibration data: work objects, tool and loads (mm, kg).
    ! Work objects are given in the world frame (wobj0 = world, not the robot base).

    !-----------------------------------------------------------------------
    ! Work objects and tool
    !-----------------------------------------------------------------------
    ! Euro pallet (1200x800): origin at the corner nearest the robot and conveyor 1, on top of the
    ! pallet (z 144). X along the long side, away from the conveyors; Y away from the robot
    TASK PERS wobjdata wobjEuroPallet:=[FALSE,TRUE,"",[[600,600,144],[0.707106781,0,0,-0.707106781]],[[0,0,0],[1,0,0,0]]];
    ! Half pallet (800x600): origin at the corner nearest the robot and the Euro pallet, on top of the
    ! pallet (z 144). X along the long side, towards the liner stand; Y away from the robot
    TASK PERS wobjdata wobjHalfPallet:=[FALSE,TRUE,"",[[400,-600,144],[0,0,0,1]],[[0,0,0],[1,0,0,0]]];
    ! Conveyor 1 (Euro pallet side): origin at the end next to the robot, centred on the belt (z 768).
    ! X along the conveyor, against the flow; Y towards conveyor 2
    TASK PERS wobjdata wobjConveyor1:=[FALSE,TRUE,"",[[338.5,670,768],[0.707106781,0,0,0.707106781]],[[0,0,0],[1,0,0,0]]];
    ! Conveyor 2 (table side): same as conveyor 1. X against the flow; Y away from conveyor 1
    TASK PERS wobjdata wobjConveyor2:=[FALSE,TRUE,"",[[-353.5,670,768],[0.707106781,0,0,0.707106781]],[[0,0,0],[1,0,0,0]]];
    ! Stacking table: origin at the corner next to the end of conveyor 2, on the table top (z 770).
    ! X away from conveyor 2; Y in the direction the boxes travel on the conveyors.
    ! oframe (55,170) centres the 3x2 block on the table
    TASK PERS wobjdata wobjTable:=[FALSE,TRUE,"",[[-600,600,770],[0,0,0,1]],[[55,170,0],[1,0,0,0]]];
    ! Liner stand: origin at the corner nearest the robot and the half pallet, on top of the stand
    ! (z 500, base of the liner stack). X along the long side (800 mm liner), away from the half pallet;
    ! Y away from the robot
    TASK PERS wobjdata wobjLinerStack:=[FALSE,TRUE,"",[[-500,-160,500],[0,0,0,1]],[[0,0,0],[1,0,0,0]]];
    ! toolVacuum: TCP on the cup faces, 175 mm from the flange, at the centre of the 6 cups
    ! Mass estimated from the measured parts in aluminium (2700 kg/m3), with the column as a tube
    ! and the grey plate hollow (5 mm walls): 4.65 kg, rounded up to 4.7 kg. CoG on the tool axis,
    ! 100 mm from the flange (tool0). Solid as drawn it would be 9.6 kg: more than the 10 kg payload
    ! of the robot together with the 2.4 kg block
    TASK PERS tooldata toolVacuum:=[TRUE,[[0,0,175],[1,0,0,0]],[4.7,[0,0,100],[1,0,0,0],0,0,0]];

    !-----------------------------------------------------------------------
    ! Load data
    !-----------------------------------------------------------------------
    ! Payloads: CoG relative to the TCP of toolVacuum; inertia set to 0 (point mass) until confirmed
    TASK PERS loaddata loadBox1:=[2,[0,0,100],[1,0,0,0],0,0,0];
    ! Box 2 is picked with one corner cup (Cup21, x=-160, y=-100 from the TCP): the CoG is under that cup
    TASK PERS loaddata loadBox2:=[0.4,[-160,-100,100],[1,0,0,0],0,0,0];
    ! 3x2 block of box 2 (390 x 260 x 200 mm, 6 x 0.4 kg)
    TASK PERS loaddata loadBox2Stack:=[2.4,[0,0,100],[1,0,0,0],0,0,0];
    ! Liner: corrugated cardboard, 0.8 x 0.54 x 0.01 m3 x 120 kg/m3 = 0.52 kg
    TASK PERS loaddata loadLiner:=[0.52,[0,0,5],[1,0,0,0],0,0,0];
ENDMODULE