# PR310G – Pallet Project: memoria de decisiones

Resumen de lo decidido y hecho en la estación `Pallet_Project` (RobotStudio 2025, controlador IRC5 RobotWare 6.13.02), actualizado el 1 nov 2026. Coordenadas en mm, respecto al mundo de la estación salvo que se diga otra cosa.

Autores: Peru Mendivil y Joaquín Moreno (Group 2, JMPM). Repo: github.com/joaquinmz/Pallet-Project (rama `main` = Peru, `second-main` = caja 2 de Joaquín, `cambios-peru-28-10` = trabajo de Peru del 28 oct, `cambios-peru-29-10` = trabajo del 29 oct, `cambios-peru-30-10` = smart components del 30 oct, `cambios-peru-01-11` = cinta 2 del 1 nov). **La versión de trabajo actual del programa es la carpeta `PalletProgram_29-10`** (guardada desde RobotStudio); `PalletProgram_28-10` es la de ayer y `PalletProgramV1` una anterior (con una copia de esta memoria).

Vídeo de la simulación de la caja 2 (29 oct, 9:30 min, medio palé completo con los dos liners): `RobotStudio 10-29 v3 comprimido.mp4`. Los vídeos originales sin comprimir están en `.gitignore` (el v3 original pesa 126 MB, más que el límite de GitHub).

Vídeo de la simulación con smart components (1 nov, 6:51 min): `RobotStudio 11-01 comprimido.mp4`. Llega hasta el europalé lleno y la capa 1 del medio palé con su liner, no hasta el medio palé lleno. El original de 146 MB está fuera del repo.

## 1. Robot y herramienta

| Elemento | Valor | Motivo |
|---|---|---|
| Robot | IRB 1600-10/1.45 | Alcance necesario ≈ 1,19 m < 1,45 m; carga ventosa + 2,4 kg ≤ 10 kg; misma huella que la de 6 kg |
| Base del robot | En (0, 0, 0), **girada 135° en Z** | El límite ±180° del eje 1 queda en −45° del mundo (hueco entre europalé y medio palé); la cadena caja 2 y los liners no lo cruzan |
| Base de la tarea | No se movió (= mundo de la estación) | Los wobj y targets no cambian; `wobj0` ya no está alineado con la base del robot |
| Herramienta | `toolVacuum`, TCP (0, 0, 175), en el plano de los labios de las copas | Medido en RobotStudio: labios Z 644,88 − cara de montaje 469,88 |
| Copas | 6 copas Ø50 en x = −160 / 0 / +160, y = ±100 | Medido |
| Masa ventosa | 1 kg provisional | **Pendiente de estimar** |
| `Home` | `CONST jointtarget` [0, 0, 0, 0, **90**, 0] | Postura de reposo con la ventosa vertical (con el eje 5 a 30 quedaba inclinada 60° y las copas pasaban cerca de la caja 2). Se va con `MoveAbsJ` al arrancar `Main` |

## 2. Layout

| Elemento | Ocupa / posición | Notas |
|---|---|---|
| Europalé (madera, 1200×800×144) | x 600…1400, y −600…600 | Del ejercicio 3 (`EuroPalletWood.rslib`, no borrar) |
| Medio palé (Half EPAL) | x −400…400, y −1200…−600, cara superior z 144 | Lado de 800 hacia el robot |
| Cinta 1 (`ConveyorBox1`) | Entra desde +Y, eje x ≈ +340, fin y ≈ 650, superficie 768 | Caja 1 |
| Cinta 2 (`ConveyorBox2`) | Entra desde +Y, eje x ≈ −350, fin y ≈ 650 | Caja 2 |
| Mesa (`StackingTable`) | 500×600×770, x −1100…−600, y 0…600 | Junto a la cinta 2: el tramo cinta 2 → mesa (72 veces por palé) es el más corto |
| Soporte liners (`LinerStand`) | 800×540×500, x −1300…−500, y −700…−160 | Bajo, para que los bloques pasen por encima sin subir |
| Pila liners (`Liner_01`…`Liner_10`) | 10 piezas de 800×540×10, x −1300…−500, y −700…−160, z 500…600 | Sustituyen a `LinerStack` (1 nov), para coger un liner cada vez. Reposición desde fuera de la valla |

Palés y liners en el perímetro: se cambian sin entrar en la célula.

## 3. Work objects (módulo `CalibData`, TASK PERS)

Criterio: origen en la esquina del lado del robot, X por el lado largo, Y alejándose del robot, Z hacia arriba (todas las coordenadas positivas). Creados escribiendo posición + rz (sin 3 puntos), tras medir con Medir → Punto a punto.

| Wobj | uframe (posición, rz) | oframe |
|---|---|---|
| `wobjEuroPallet` | (600, 600, 144), −90° | 0 |
| `wobjHalfPallet` | (400, −600, 144), 180° | 0 |
| `wobjConveyor1` | (338,5, 670, 768), 90° | 0 |
| `wobjConveyor2` | (−353,5, 670, 768), 90° | 0 |
| `wobjTable` | (−600, 600, 770), 180° | (55, 170, 0): bloque centrado en la mesa |
| `wobjLinerStack` | (−500, −160, 500), 180° (base de la pila) | 0 |

## 4. Cargas (`CalibData`)

| loaddata | Masa | CdG respecto al TCP | Nota |
|---|---|---|---|
| `loadBox1` | 2 kg | [0, 0, 100] | |
| `loadBox2` | 0,4 kg | [−160, −100, 100] | Se coge con una sola copa de esquina |
| `loadBox2Stack` | 2,4 kg | [0, 0, 100] | Bloque 3×2 |
| `loadLiner` | 0,52 kg | [0, 0, 5] | Cartón ondulado (suposición) |

Inercias a 0 (masa puntual) hasta que el profesorado confirme si hacen falta.

## 5. Targets base (módulo `PalletProgram`, CONST)

Herramienta siempre vertical (rx = 180). Un target por estación; el resto se calcula con `Offs`.

| Target | Wobj | Posición | rx/ry/rz | Familia (offsets) |
|---|---|---|---|---|
| `PickConveyor1` | wobjConveyor1 | 249,5 / 0 / 200 | 180/0/180 | — |
| `PlaceEuroRow4` | wobjEuroPallet | 225 / 525 / 200 | 180/0/−90 | X +250 (4 cajas); capa Z +200 |
| `PlaceEuroRow2` | wobjEuroPallet | 350 / 150 / 200 | 180/0/0 | X +500 (2 cajas); capa Z +200 |
| `PickConveyor2` | wobjConveyor2 | −35,5 / −160 / 200 | 180/0/−90 | — (copa de esquina sobre la caja) |
| `PlaceTable` | wobjTable | −95 / 165 / 200 | 180/0/180 | X y Y +130 (6 cajas) |
| `PickTableStack` | wobjTable | 195 / 130 / 200 | 180/0/180 | — |
| `PlaceHalfPallet` | wobjHalfPallet | 205 / 170 / 200 | 180/0/180 | X +390, Y +260 (4 bloques); capa Z +210 |
| `PickLiner` | wobjLinerStack | 400 / 270 / 100 | 180/0/180 | Z −10 por liner cogido |
| `PlaceLiner` | wobjHalfPallet | 400 / 300 / 210 | 180/0/180 | Liner tras capa L: Z +(L−1)·210 |

Orientaciones elegidas para que la cadena de la caja 2 y los liners no giren la herramienta y para que, al alternar caja 1 / caja 2, el eje 6 casi no gire.

## 6. Secuencia (enunciado)

- **Caja 1:** cinta 1 → europalé, formación 4-2, 2 capas (12 cajas). Orden: primero la fila de 4 (lejana), luego las 2 cercanas. Con el palé lleno no se coge caja 1 hasta que el operario confirma el cambio.
- **Caja 2:** cinta 2 → mesa (bloque 3×2) → medio palé 2×2 bloques por capa, 3 capas (72 cajas), liner tras las capas 1 y 2. Con el medio palé lleno se puede terminar un bloque en la mesa, que espera.
- **Las dos cintas llenas:** alternar caja 1 / caja 2.
- Cambio de palé: lo hace el operario desde fuera de la valla; el robot sigue con el otro producto.

## 7. Señales (virtuales, sin dispositivo)

| Señal | Tipo | Uso |
|---|---|---|
| `DO_Cup11` … `DO_Cup23` | DO | Una válvula por copa (fila 1 = y +100, fila 2 = y −100; columnas x −160 / 0 / +160) |
| `DI_Box1Arrived`, `DI_Box2Arrived` | DI | Sensores de las cintas |
| `DI_EuroPalletReplaced`, `DI_HalfPalletReplaced` | DI | Confirmación del operario por palé (no bloqueante). En simulación las activan `SC_Conveyor1` y `SC_Conveyor2` (ver 10.1 y 10.5) |
| `DO_EuroPalletFull` | DO | Luz de "europalé lleno" para el operario (4 nov); también habilita el vaciado en `SC_Conveyor1` |
| `DO_HalfPalletFull` | DO | Luz de "medio palé lleno" (4 nov); también habilita el vaciado en `SC_Conveyor2` |
| `DI_LinersRefilled` | DI | Confirmación del operario: pila de liners repuesta (no bloqueante) |
| `AI_VacuumPressure` | AI 0–10 bar | Extra de presión |

En RAPID: `cupSignals{6}` enlazado con `AliasIO` en `InitSignals`; `VacuumControl` recibe un array de 6 bool (`CupsAllOn`, `CupsAllOff`, `CupsBox2On` = solo Cup21) y espera `VacuumTime` (1 s, requisito 8).

## 8. Convención de nombres (slides)

- VAR / PERS / parámetros: camelCase (`box1State`, `euroPalletFull`, `cupsState`) → pueden cambiar.
- CONST / PROC / FUNC / MODULE: PascalCase (`SafeHeight`, `VacuumTime`, `ProcessBox1`, `Box1Ready`) → fijos.
- Estados de las máquinas: `Box1Pos1…Box1Pos5`, `Box1LastPos` (`box1State`); `Box2Pos1…Box2Pos5`, `Box2LastPos` (`box2State`, mesa); `BlockPos1…BlockPos4` (`blockState`, hueco del bloque en la capa del medio palé). Capas máximas: `Box1MaxLayers` (2), `Box2MaxLayers` (3).
- Señales: prefijos `DI_`, `DO_`, `AI_`, `AO_`.
- Ojo RAPID: `NOT` tiene la prioridad más baja → poner paréntesis: `(DI_x=1) AND (NOT flag)`.
- FUNC devuelve valor y se llama con `()` dentro de expresiones; PROC es una instrucción sin paréntesis.

## 9. Estado del código (`PalletProgram_29-10/PalletProgram.mod`, 29–30 oct)

Refinado el 29 oct por la tarde (todo probado en simulación: caja 1, caja 2, alternancia y pila de liners vacía):
- Identificadores de estación: `StationConveyor1`, `StationConveyor2`, `StationTable`, `StationLinerStand`, `StationHalfPallet`, `StationEuroPallet` (= 1…6); parámetro `station` en `ApproachHeight`.
- Z de la capa calculada una vez: `layerZ` local en `ProcessBox1`; en la caja 2, `FUNC num HalfPalletLayerZ()` = `(box2Layer-1)*(Box2Height+LinerHeight)` (un liner bajo cada capa salvo la 1.ª). Se quitó `linersPlaced` (siempre valía `box2Layer-1`).
- Offsets con nombre: `EuroRow4Offset` 250, `EuroRow2Offset` 500, `Box2Offset` 130, `BlockOffsetX` = 3·130, `BlockOffsetY` = 2·130.
- Orden de llenado de la mesa (cambiado el 1 nov): fila lejana de la cinta primero (y=130, luego y=0) y X descendente (260 → 130 → 0). La caja viaja con la base a 900 y las puestas tienen el techo a 970; con la fila cercana primero, la caja atravesaba esa fila unos 70 mm. Coste: al dejar las 3 últimas, las copas de la fila contraria quedan 20 mm sobre el borde de la otra fila, a la misma altura (se tocan, no entran).
- Pila de liners vacía (9.3).

Hecho el 29 oct (detalles en 9.1 y 9.2):
- `Main` completo y probado en simulación.
- `Home` (`MoveAbsJ`), velocidades con nombre (`TransitSpeed` v1000 para el `MoveJ` de tránsito, `ApproachSpeed` v300 para bajar y subir).
- `ApproachPoint` con un quinto parámetro `approachHeight` (cuánto sube sobre el target), calculado por `FUNC num ApproachHeight(station)`.
- Arreglos de nombres: `TotalLiners`, `linersLeft`, `Box1`/`Box2`.

Hecho el 28 oct:
- Encabezado del programa, secciones comentadas, nombres según la convención.
- `ProcessBox1` (máquina de estados de 6 posiciones × 2 capas, pone `euroPalletFull`).
- `VacuumControl`, `InitSignals`, `ApproachPoint(target, wobj, cups, load)` con `GripLoad`.
- `FUNC bool Box1Ready()` y `Box2Ready()`; `Box2Ready()` ya usa `NOT tableFull`.
- `ProcessBox2`: 6 posiciones en la mesa (sin cambios). En `Box2LastPos`: si `halfPalletFull` → `tableFull:=TRUE` (el bloque espera); si no → `TransferStack`. En los dos casos vuelve a `Box2Pos1`.
- `PROC TransferStack`: coge el bloque (`CupsAllOn`, `loadBox2Stack`) y lo deja según `blockState`:
  - `BlockPos1` (0, +260), `BlockPos2` (+390, +260): fila lejana primero; `BlockPos3` (0, 0), `BlockPos4` (+390, 0).
  - Z = `HalfPalletLayerZ()`.
  - En `BlockPos4` (capa completa): si `box2Layer=Box2MaxLayers` → `halfPalletFull:=TRUE`; si la pila está vacía → `linerMissing:=TRUE` (9.3); si no → `PlaceLayerLiner` (`PickLiner` Z −(TotalLiners−linersLeft)·LinerHeight, `PlaceLiner` con la misma Z que la capa, **antes** de `Incr box2Layer`; luego `Decr linersLeft`). Vuelve a `BlockPos1`.

Variables de la caja 2:

| Variable | Qué cuenta | Se reinicia al cambiar el medio palé |
|---|---|---|
| `box2State` | Caja en la mesa (1…6) | **No** (la mesa puede tener un bloque a medias) |
| `blockState` | Hueco del bloque en la capa (1…4) | Sí (ya vuelve solo a 1) |
| `box2Layer` | Capa del medio palé (1…3) | Sí (se queda en 3) |
| `linersLeft` | Liners en la pila (empieza en `TotalLiners` = 10) | **No** (la pila no cambia con el palé; se repone con `DI_LinersRefilled`) |
| `linerStackEmpty` | Pila vacía (aviso, el robot sigue) | No (se quita al reponer) |
| `linerMissing` | Capa terminada sin liner (la caja 2 espera) | No (se quita al poner el liner) |
| `halfPalletFull` | Capa 3 completa | Sí |
| `tableFull` | Bloque completo esperando en la mesa con el palé lleno | Sí, después de `TransferStack` |

Por qué `tableFull`: con el palé lleno la caja 2 pasa por tres momentos y un solo bool no los distingue:

| Momento | `halfPalletFull` | `tableFull` | ¿Coger caja 2? |
|---|---|---|---|
| Palé con sitio | FALSE | FALSE | Sí |
| Palé lleno, mesa llenándose | TRUE | FALSE | Sí |
| Palé lleno, bloque completo en la mesa | TRUE | TRUE | No |

Resets del operario (ya escritos en `Main`):
- Europalé (`euroPalletFull AND DI_EuroPalletReplaced=1`): `box1Layer:=1`, `box1State:=Box1Pos1` (no necesario, por seguridad), `euroPalletFull:=FALSE`.
- Medio palé (`halfPalletFull AND DI_HalfPalletReplaced=1`): `box2Layer:=1`, `blockState:=BlockPos1`, `halfPalletFull:=FALSE`; luego, si `tableFull` → `TransferStack` y `tableFull:=FALSE`. **Orden importante**: contadores antes de `TransferStack`, para que el bloque vaya a capa 1, hueco 1.
- `IF` y no `WaitDI`: el robot sigue con el otro producto. Incluir el flag de palé lleno en la condición evita resets por pulsaciones accidentales y hace de detector de flanco (se ejecuta una vez aunque el botón siga pulsado). Alternativa nativa de RAPID para flancos: `ISignalDI` + `TRAP` (no hace falta aquí).

### 9.1 `Main` (hecho el 29 oct)

Orden: `InitSignals` (primero: sin `AliasIO`, `VacuumControl` falla) → `VacuumControl CupsAllOff` → `GripLoad load0` → `MoveAbsJ Home,v100,fine,toolVacuum` → `WHILE TRUE`:
1. Elección de caja: `IF Box1Ready() AND ((NOT Box2Ready()) OR lastBox=Box2)` → `ProcessBox1`; `ELSEIF Box2Ready()` → `ProcessBox2`.
2. Los dos `IF` de reset del operario.
3. `WaitTime 0.1` (sin él, sin cajas el bucle gira sin parar).

Claves:
- `CONST num Box1:=1`, `Box2:=2`; `VAR num lastBox:=Box2` → si llegan las dos a la vez empieza la caja 1. `lastBox` se actualiza al final de `ProcessBox1` / `ProcessBox2`.
- La alternancia solo se aplica si la otra caja también puede procesarse (evita el bloqueo con un palé lleno).
- `MoveAbsJ` y no `MoveJ` para Home: un `jointtarget` son los ángulos de los ejes, sin cinemática inversa ni wobj; siempre la misma postura. Sin `\NoEOffs` (no hay ejes externos).
- Antes de cada prueba tras un error: RAPID → Puntero de programa → *PP a Main* (las VAR vuelven a su valor inicial).

### 9.2 Alturas de aproximación y tránsito (29 oct)

`ApproachPoint(target, wobj, cups, load, approachHeight)`: `MoveJ` a `Offs(target,0,0,approachHeight)` (tránsito, `TransitSpeed`), `MoveL` al target (`ApproachSpeed`, `fine`), vacío + `GripLoad`, `MoveL` de vuelta arriba.

Cómo se llegó aquí:
- Con `SafeHeight` fijo de 300 sobre el target, la cinta 1 (≈ 980 mm de la base) daba **50050 Posición fuera del área de trabajo**: el punto de aproximación (z 1268) estaba fuera de alcance. Después pasó lo mismo en la mesa.
- Se probó un plano de tránsito único con `MoveL` en el tránsito para mantener la altura: la recta entre estaciones opuestas pasaba sobre la base del robot → **50024** (fallo de trayectoria de esquina) y **50027** (eje fuera de rango). Se volvió a `MoveJ`. El `MoveJ` hace un arco (reparte los ángulos, no la posición del TCP): que suba no es problema; que baje sí.
- En los palés, subir hasta 1100 suponía ~756 mm de `MoveL` por bloque con el brazo casi estirado.

Solución actual: `FUNC num ApproachHeight(num station)` con un `TEST` por estación (`StationConveyor1`…`StationEuroPallet`, = 1…6). Las alturas en mundo de cada estación son CONST (`ConveyorsHeight` 768, `TableHeight` 770, `LinerStandHeight` 500, `EuroPalletHeight` / `HalfPalletHeight` 144). `DEFAULT` deja 9E+09 a propósito: un identificador erróneo da error de alcance y para el robot.

| Estación | TCP en tránsito (mundo) | Sube sobre el target |
|---|---|---|
| Cintas 1 y 2 (techo caja 968) | `TransitHeight` 1100 | 132 |
| Mesa: dejar caja 2 y coger bloque (techo 970) | 1100 | 130 |
| Pila de liners (techo 500 + `linersLeft`·10) | 1100 | 500 con la pila llena |
| Europalé | 850 = 1100 − `PalletOffsetHeight` (250) | 506 (capa 1), 306 (capa 2) |
| Medio palé (bloques y liner) | 850, con mínimo `MinApproachHeight` 250 | 506, 296, **250** (capa 3, manda el mínimo) |

- **850** = tope de la pila de liners (600) + bloque (200) + 50: el bloque pasa por encima de los liners entre la mesa y el medio palé.
- **Mínimo 250** = caja (200) + 50: el bloque que lleva no choca con los de al lado en la misma capa. Sin él, en la capa 3 solo subía 86 mm.
- La FUNC lee `box1Layer`, `box2Layer` y `linersLeft` en el momento de la llamada: en `PlaceLayerLiner` las llamadas van **antes** de los `Incr`/`Decr`.

### 9.3 Pila de liners vacía (29 oct)

Dos flags, porque son dos situaciones distintas:
- `linerStackEmpty`: se pone en `PlaceLayerLiner` cuando `linersLeft` llega a 0. Solo es un aviso: el robot sigue y el operario tiene toda una capa (4 bloques) para reponer sin que el robot pare.
- `linerMissing`: se pone en `BlockPos4` si la capa está completa y `linerStackEmpty`. `ProcessBox2` trata `halfPalletFull OR linerMissing` igual: la mesa se sigue llenando y el bloque espera (`tableFull`). La caja 1 no se para. No se puede empezar la capa siguiente: el liner va encima de la terminada y debajo de la nueva.
- Reset en `Main`: `linerStackEmpty AND DI_LinersRefilled=1` → `linersLeft:=TotalLiners` (antes de coger el liner, la altura depende de él), `linerStackEmpty:=FALSE`; si `linerMissing` → `PlaceLayerLiner`, y si `tableFull` → `TransferStack`.
- Limitación: solo cuenta la reposición con la pila vacía (mismo criterio de flanco que los palés).
- Probado con `linersLeft:=1` temporal: reponiendo durante la capa 2 el robot no para; sin reponer, espera y sigue al activar la señal. Sin mensajes en el FlexPendant de momento (se dejan para el final).

Simulación de la caja 2 (vídeo v3): sin colisiones salvo con `LinerStack` al coger los liners: casi colisión en el 1.º (normal, las copas apoyan) y colisión a z 598,8 en el 2.º, porque el modelo de la pila es fijo (10 liners, techo 600) y el código coge cada liner 10 mm más abajo. Es un efecto de la simulación, no un fallo.

## 10. Smart components (30 oct y 1 nov)

Vídeo de la prueba de la cinta 1 con smart components: `RobotStudio 10-30_6.mp4`. El Pack and Go `Pallet_Project.rspag` del repo es del 1 nov e incluye las dos cintas, la ventosa con sus 6 sensores, los 10 liners y el estado `Inicio_01-11_v8`. El de `Descargas` del 26 oct es anterior. El código RAPID no cambió: los smart components solo sustituyen las señales que antes se activaban a mano.

### 10.1 `SC_Conveyor1` (cinta 1)

| Componente | Configuración | Para qué |
|---|---|---|
| `Box1` (plantilla, en Componentes) | Origen local movido al centro de la caja; centro en (338,5, 3390, 868) = principio de la cinta 1 (fin de la cinta medido en Y 3660, menos 250 de media caja y 20 de margen). Caja 250 × 500 × 200 | Lo que copia el `Source` |
| `Source` | `Source` = `Box1`, `Position` (338,5, 3390, 868), `Transient` ✓ | Crea cada caja. `Position` es respecto al padre (la estación), no a la plantilla |
| `Queue` | Nada manual | Lista de cajas que mueve el `LinearMover` |
| `LinearMover` | `Object` = `Queue`, `Direction` (0, −1, 0), `Speed` 250, `Reference` Global, `Execute` ✓ | Mueve las cajas hacia el robot |
| `PlaneSensor` | `Origin` (188,5, 675, 788), `Axis1` (300, 0, 0), `Axis2` (0, 0, 10), `Active` ✓ | Plano vertical en el fin de la cinta (cara delantera de la caja en Y 670). `Origin` es una esquina y cada `Axis` un lado entero: x 188,5…488,5 (centrado en la cinta) y z 788…798 (lo bastante bajo para no detectar el robot ni la caja colgando de la ventosa, ver 10.4; antes 828) |
| `LogicGate` | `NOT` | Al llevarse el robot la caja (sensor 1 → 0), pide la siguiente |
| `SimulationEvents` | Nada manual | Primera caja al pulsar *Reproducir*. Sale una sola si antes se carga el estado guardado; si no, salen dos (ver 10.5) |
| Señal `BoxArrived` | DigitalOutput | Salida del componente hacia el controlador |

Enlazamiento: `Source.Copy` → `Queue.Back`. Conexiones: `Source.Executed` → `Queue.Enqueue`; `PlaneSensor.SensorOut` → `Queue.Dequeue` (la caja se para), → `SC_Conveyor1.BoxArrived` y → `LogicGate.InputA`; `LogicGate.Output` → `Source.Execute`; `SimulationEvents.SimulationStarted` → `Source.Execute`. Lógica de estación: `SC_Conveyor1.BoxArrived` → `DI_Box1Arrived`.

Comprobado: la caja centrada en el fin de la cinta tiene el techo en (338,5, 919,5, 968) = `PickConveyor1` en mundo.

**Vaciado del europalé (3–4 nov, hecho y probado; cambiado el 5 nov: ahora `Source.Executed` → `Enqueue` y `Repeater` (`Count` 12) → `Delete` en lugar de `DeleteAll`, ver 10.4, «Vaciado del medio palé descuadrado en el 2.º borrado»):** `Queue_EuroPallet` (en `SC_Conveyor1`, nada manual) guarda las cajas que el robot se ha llevado de la cinta 1, es decir, las del europalé. Enlace `Source.Copy` → `Queue_EuroPallet.Back`; conexión `LogicGate_2 [NOT].Output` → `Queue_EuroPallet.Enqueue`, colocada **encima** de `NOT.Output` → `Source.Execute`. Las conexiones se ejecutan en el orden de la lista: así `Back` todavía es la caja que se lleva el robot y no la nueva de la cinta (con `Source.Executed` → `Enqueue` entraba también la que espera en la cinta). Comprobado por Peru: la cola llega a 12 con el palé lleno. Señal `EuroPalletReplaced` (DigitalInput de `SC_Conveyor1`) → `Queue_EuroPallet.DeleteAll`: pulsada a mano en las propiedades del componente borra las cajas y la cola vuelve a 0. Una DI del controlador (`DI_EuroPalletReplaced`) no sirve como origen en la lógica de estación: no llega al componente.

Montaje final (4 nov): RAPID pone `DO_EuroPalletFull` a 1 junto a `euroPalletFull:=TRUE` (`ProcessBox1`, `Box1LastPos`), y a 0 al aceptar el cambio de palé en `Main` y al arrancar (antes del `WHILE`), con `SetDO` (`:=` sobre una `signaldo` da error de tipo 55). Dentro de `SC_Conveyor1`: señales `EuroPalletReplaced` (DigitalInput, el pulsador del operario), `EuroPalletFull` (DigitalInput) y `EuroPalletReplacedOut` (DigitalOutput); `LogicGate [AND]` (`Delay` 0) con `EuroPalletReplaced` → `InputA`, `EuroPalletFull` → `InputB`, `Output` → `Queue_EuroPallet.DeleteAll` y `Output` → `EuroPalletReplacedOut`. Lógica de estación: `Controler.DO_EuroPalletFull` → `SC_Conveyor1.EuroPalletFull`; `SC_Conveyor1.EuroPalletReplacedOut` → `Controler.DI_EuroPalletReplaced`. Uso: pulsar `EuroPalletReplaced` en las propiedades de `SC_Conveyor1` y **volver a ponerla a 0** (si se queda a 1, el próximo palé lleno se vacía solo). Antes de tiempo no hace nada; con el palé lleno borra las 12 cajas (no la de la cinta), da un pulso a `DI_EuroPalletReplaced` y RAPID apaga `DO_EuroPalletFull`, que a su vez apaga el `AND` y la DI. Probado por Peru el 4 nov.

### 10.2 `SC_Gripper` (ventosa)

| Componente | Configuración | Para qué |
|---|---|---|
| `LS_Cup21` (antes `LineSensor_2`) | `Start` (−597,51, 689,43, 956,5), `End` (−597,51, 689,43, 924,5) con el robot en Home, `Radius` 3,31; conectado a `PalletizingVacuumTool/PalletizingVacuumTool` (sin actualizar posición) | Línea en (−160, −65) del `toolVacuum`: al lado de `Cup21`, 35 mm hacia el centro de la ventosa, de 10 mm por encima a 22 mm por debajo del plano de las copas. Cae sobre la caja 1 y la caja 2 |
| `Attacher` | `Parent` = mecanismo `PalletizingVacuumTool` (la lista no ofrece el eslabón), `Flange` = `toolVacuum` (única opción, no se puede dejar vacío), `Mount` sin marcar | Engancha la pieza que detecta el sensor |
| `Detacher` | `KeepPosition` ✓ | La suelta donde está |
| `LogicGate` | `NOT` | `Grip` 1 → 0 activa el `Detacher` |
| Señal `Grip` | DigitalInput | Entrada desde el controlador |

Enlazamientos: `LS_Cup21.SensedPart` → `Attacher.Child`; `Attacher.Child` → `Detacher.Child`. Conexiones: `Grip` → `Attacher.Execute` y → `LogicGate.InputA`; `LogicGate.Output` → `Detacher.Execute`. Lógica de estación: `DO_Cup21` → `SC_Gripper.Grip`. `DO_Cup21` es la única copa activa en todas las recogidas (`CupsAllOn` y `CupsBox2On`) y a 0 en todas las dejadas.

Sensores del bloque 3×2 (1 nov), uno por copa, cada uno sobre una caja distinta del bloque. `Length` 32, `Radius` 3,31, `Active` 1, Z de 956,5 a 924,5 con el robot en Home, conectados a la herramienta sin actualizar posición. Con una caja 1 en el aire, los 6 sensores marcan la caja (comprobado el 1 nov):

| Sensor | Posición en `toolVacuum` | X, Y en Home |
|---|---|---|
| `LS_Cup11` | (−160, +65) | −689,43, 597,51 |
| `LS_Cup12` | (0, +65) | −576,29, 484,37 |
| `LS_Cup13` | (+160, +65) | −463,15, 371,23 |
| `LS_Cup21` | (−160, −65) | −597,51, 689,43 |
| `LS_Cup22` | (0, −65) | −484,37, 576,29 |
| `LS_Cup23` | (+160, −65) | −371,23, 463,15 |

Cada uno tiene su `Attacher_CupXX` (`Parent` y `Flange` como el `Attacher`, `Mount` sin marcar) y su `Detacher_CupXX` (`KeepPosition` ✓). Enlazamientos: `LS_CupXX.SensedPart` → `Attacher_CupXX.Child`; `Attacher_CupXX.Child` → `Detacher_CupXX.Child`. Conexiones: `Grip` → `Attacher_CupXX.Execute`; `LogicGate [NOT].Output` → `Detacher_CupXX.Execute`. Todos usan la misma señal `Grip`: al coger la caja 2 solo `LS_Cup21` tiene algo debajo, así que no hace falta una señal por copa.

TCP de `toolVacuum` en Home (0, 0, 0, 0, 90, 0): (−530,33, 530,33, 946,5), RX −180 (herramienta vertical). Comprobado con la geometría del IRB 1600-1.45: brida en Z 1121,5 − 175 de herramienta; alcance horizontal 750 girado 135°.

### 10.3 Estado guardado (`Inicio_01-11_v2`)

*Simulación → ˅ bajo Restablecer → Guardar estado actual*: `Pallet_Project` incluido entero, con valores de propiedad, señales de E/S (objetos y controlador), valores de eje, visibilidad y posición/orientación/conexión; sin comportamiento físico ni valores de variable (al *Reproducir*, el PP vuelve a `Main` y las VAR a su valor inicial). Al quitar esas dos opciones, la casilla **Incluir** sale como ■ (cuadrado) y no como ✓: es lo correcto. Se guarda dentro de la estación (Ctrl+S). Cada prueba: **Parar → ˅ Restablecer → `Inicio_04-11` → Reproducir**. **`Inicio_04-11` (guardado el 4 nov a las 22:20) es el estado vigente**: incluye `SC_Liners` (10 `Source`, liners como copias), la plantilla `Liner_01` en (−900, −2000, 0), sin `Liner_02…10`, sin copias reales, robot en Home, pulsadores a 0, `Count` 72 y 2. Se guardó tras cargar `Inicio_03-11` una última vez y corregir lo que este devolvía (`Liner_01` a (0, 0, 0), copias reales `Box1_1` y `Box2_2`). Comprobado que al cargarlo no crea copias ni mueve `Liner_01`. **No volver a cargar `Inicio_03-11`**: devuelve `Liner_01` a (0, 0, 0), en la base del robot. `Inicio_03-11` (4 nov, 11:13) queda como el anterior: ventosa completa, 10 liners, planos de las cintas a 10 mm y `Queue_EuroPallet`. Es de antes del `AND` y de las señales nuevas de `SC_Conveyor1`, pero cargarlo no las borra. `Inicio_01-11_v8` (ventosa completa, 10 liners y plano de las cintas bajado a 828) queda de copia. `Inicio` (30 oct), `Inicio_01-11` y `Inicio_01-11_v2` a `_v7` están obsoletos: no cargarlos, porque guardan las propiedades y devuelven el sensor a su posición antigua (ver 10.5).

### 10.4 Errores encontrados (para no repetirlos)

- `Box1` tenía el origen de la pieza en el origen del mundo y la geometría desplazada dentro (`Cuerpo` con origen en una esquina, (214, 670, 768)): *Establecer posición* daba 0. Se arregló con *Establecer origen local*.
- `Execute` del `Source` fuera de la simulación crea una pieza normal que se queda en la estación (`Transient` solo borra las creadas durante la simulación). Las copias temporales no salen en el árbol.
- `PlaneSensor` con un 100 por defecto en la Y de `Axis2`: plano inclinado y la caja se paraba antes del fin de la cinta.
- `LineSensor`: `Start`, `End` y `Length` se recalculan entre sí. Lo importante para que no se estropeen los valores es escribir los decimales con coma (`,`) y no con punto (`.`); no hace falta escribir `Length` primero. El valor está guardado cuando `Length` cuadra y no lleva `~`.
- `LineSensor` solo detecta cuando la línea **cruza una cara** de la pieza: empezando 2 mm bajo las copas, la línea quedaba entera dentro de la caja y no detectaba nada. Por eso empieza 10 mm por encima.
- `LineSensor` justo bajo `Cup21` (1 nov): la línea empieza 10 mm por encima de los labios, dentro de la copa, y `SensedPart` marcaba `PalletizingVacuumTool` (confirmado en pausa). A veces no enganchaba y a veces no soltaba. Se apartó 35 mm hacia el centro de la ventosa (25 de radio de copa + 3,31 de radio del sensor). Bajar la Z no sirve: la línea debe empezar por encima del techo de la caja, que al coger coincide con los labios. Que el fallo fuera intermitente sigue sin explicar.
- **Caja parada a mitad de la cinta 1 (1 nov):** con el plano hasta z 938, el robot lo cruzaba al ir del europalé a la cinta 2. La señal sacaba de la `Queue` a la caja que venía de camino, y al salir del plano el `NOT` creaba otra, que atravesaba a la parada. Se vio en el vídeo hacia el segundo 84. Se arregló bajando el techo del plano a 828 en las dos cintas y Peru comprobó que ya no pasa.
- **Cajas 1 de más al llevarse la caja (3 nov):** por cada caja cogida el `Source` creaba 2 o 3 copias superpuestas (en la cinta se veía una caja más larga; los nombres saltaban `Box1_2` → `_4` → `_7`). Con el *Analizador de señales* (`PlaneSensor.SensorOut`, `NOT.Output`, `Source.Executed`) se vio que, medio segundo después de levantar la caja, `SensorOut` volvía a 1 un instante: la caja colgando de la ventosa volvía a cruzar el plano en el `MoveJ` hacia el europalé (en la cinta la base de la caja queda en ≈900, solo 72 mm sobre el techo del plano, y la aproximación del europalé está más baja). No pasaba en todas las posiciones del palé. Se arregló bajando la altura de los dos `PlaneSensor` a 10 mm (`Axis2` (0, 0, 10): z 788…798) y Peru comprobó que la cola sube de uno en uno. Los nombres siguen saltando de 2 en 2, pero no hay copias de más (la cola cuadra).
- **Simulador de E/S sin refrescar (4 nov):** durante la simulación el panel marcaba todas las señales a 0, aunque el robot cogía cajas (con la simulación parada sí salían los valores). No era el *Analizador de señales* ni el panel colgado: se arregló reiniciando RobotStudio entero.
- **Menú contextual en gris (4 nov):** clic derecho en `SC_Conveyor1` con *Editar componente*, *Cambiar nombre* y casi todo en gris, con la simulación parada. Causa: había varios objetos seleccionados a la vez en el panel *Diseño*. Solución: clic en un hueco vacío del panel, un solo clic en el componente y otra vez clic derecho. Pista: si *Cambiar nombre* sale en gris, hay más de un objeto seleccionado.
- **`LogicGate [AND]` desaparecido (4 nov):** el `AND` de `SC_Conveyor1` desapareció de *Componer* y sus 4 conexiones quedaron como `<LogicGate_3>` con un círculo rojo. No es por cargar un estado (Peru lo comprobó: cargar `Inicio_03-11` no lo borra); probablemente se borró sin querer. Si pasa, eliminar las conexiones rojas, volver a añadir el componente y sus conexiones, y Ctrl+S.
- **Copias reales al crear conexiones hacia `Source.Execute` (4 nov):** al crear o volver a crear con la simulación parada una conexión que llega a `Source.Execute` (p. ej. `LogicGate [NOT].Output` → `Source.Execute`), el `Source` puede dispararse y crear una copia real (`BoxN_xxx`, sale en el panel *Diseño*; `Transient` no la borra). Hay que mirar el panel *Diseño* y borrarla. Pasó con `Box2_314`: el robot la dejó en el primer hueco de la mesa, se quedó allí tras *Parar*, y en la prueba siguiente la 1.ª caja 2 se dejó dentro de ella; el `Detacher_Cup21` soltó `Box2_314` (lo último que detectó `LS_Cup21`) y la caja buena siguió en la ventosa hasta el europalé (mismo fallo que el del vídeo del 3 nov con el europalé). Borrada el 4 nov.
- **«Mover hacia arriba» no funcionó (4 nov)** en las conexiones de `SC_Conveyor2` (fila seleccionada, enlace activo, varios clics y la fila no se movía). Se arregló borrando y volviendo a crear `LogicGate [NOT].Output` → `Source.Execute`: las conexiones nuevas se añaden al final, así que quedó la última, debajo de la de `Queue_HalfPallet.Enqueue`.
- **Copias reales de caja 1 al cargar `Inicio_03-11` tras *Parar* (4 nov, observado dos veces):** después de parar con una caja 1 esperando en la cinta 1, cargar el estado creó `Box1_338` (13:38) y `Box1_346` (13:50), las dos reales (salen en *Diseño*). Hipótesis muy probable: al cargar el estado el `NOT` de `SC_Conveyor1` pasa de 0 a 1 fuera de la simulación y dispara `Source.Execute`; la copia sale al principio de la cinta 1, al reproducir es la primera caja que el robot lleva al primer hueco del europalé y, como es real, se queda allí al parar (así acabó `Box1_338`). En la prueba siguiente podría repetirse el fallo del `Detacher` de `Box2_314`. Solución de momento: **después de cada carga del estado, mirar en *Diseño* si hay copias reales (`Box1_xxx`, `Box2_xxx` con número) y borrarlas**; nunca las plantillas `Box1` y `Box2`. No se ha investigado el `NOT`.
- **Liners flotando tras cambiar el medio palé (4 nov, visto por Peru con 3 capas):** al pulsar `HalfPalletReplaced` se borran las 72 cajas 2, pero los 2 liners del palé (`Liner_xx`, piezas fijas) se quedan en el aire. Después el robot lleva el bloque que esperaba (`tableFull`) a la capa 1 del palé nuevo; la línea de los sensores de la ventosa cruza el liner que está a esa altura, el `Detacher` suelta el liner (lo último que detectó el sensor) en vez del bloque, y el bloque vuelve pegado a la ventosa. Mismo mecanismo que `Box2_314` (más arriba). La prueba con `Box2MaxLayers:=1` no lo detectaba porque sin liners no pasa. Solución: punto 2B (liners como copias de un `Source`, borradas al cambiar el palé).
- **Vaciado del medio palé descuadrado en el 2.º borrado (5 nov, vídeos `RobotStudio 11-5.mp4` y `RobotStudio 11-5_1.mp4`; resuelto el 5 nov, también en el europalé):** 1.er borrado bien. En el 2.º, el palé lleno (3 capas + 2 liners) se vació salvo **una caja de la capa 1** (en el suelo del palé, parte delantera), que sigue ahí en los ciclos siguientes. En el 3.er borrado volvió a fallar: al llevar el bloque de la mesa al palé nuevo, una caja se quedó en una esquina de la mesa y ahí sigue. Hipótesis: a una caja (casi seguro una del bloque que esperaba en el 1.er cambio, que acaba en la capa 1 del palé 2) le falta su entrada en `Queue_HalfPallet`. Así las 72 `Delete` se llevan 71 cajas del palé y la más antigua de la mesa, y el desfase se arrastra un ciclo tras otro. Por confirmar: con `HalfPalletFull` = 1 y la mesa llena, `NumberOfObjects` debería ser 78 (72 + 6). Prueba hecha con «Lo más rápido posible» (≈3,6x), paso de 24 ms.
  - **Medido (5 nov, ejecución de las 12:51, ≈9x):** 1.er palé lleno a ≈1272 s: `NumberOfObjects` **78**, `Front` `Box2_706`, `Back` `Box2_799` (cuadra). 2.º palé lleno a ≈2570 s: **77**, `Front` `Box2_793`, `Back` `Box2_871`. `Front` = una de las 6 cajas de la mesa del 1.er ciclo (con `Back` 799), así que el 1.er borrado respetó el bloque y la cola empezaba bien. **La entrada se pierde mientras se llena el 2.º palé**, no al principio.
  - **Qué caja es (5 nov, ≈5216 s, vista superior):** la que se queda está en la capa 1, esquina exterior de `BlockPos2` (con `wobjHalfPallet` girado 180°, `BlockPos1` = abajo a la derecha en planta, `BlockPos2` = abajo a la izquierda). Como el bloque se lleva rígido de mesa a palé con la misma orientación, esa esquina es `Box2Pos1`. O sea, es **la primera caja que se coge después del cambio de palé**: la que esperaba en el sensor de la cinta 2 mientras se borraban las 72. Los nombres lo apoyan: del 2.º ciclo se crearon `Box2_793`…`870` seguidos (`Back` 871 = la que espera), sin copias de más (así que no es el parpadeo del sensor del 3 nov), y solo hay 77 en la cola. Hipótesis: algo del cambio de palé (las 72 `Delete`, o `Repeater_Liners`) deja `Back` de `Queue_HalfPallet` sin la caja que espera, y su `Enqueue` no añade nada. Por comprobar justo después de un cambio.
  - **Confirmado (5 nov):** justo después del cambio (5219,7 s, bloque ya en el palé, caja esperando en el sensor), `Back` **vacío**, `Front` `Box2_866`, `NumberOfObjects` 5. Tras levantar la caja que esperaba (5224,8 s), `NumberOfObjects` **sigue en 5** y `Back` = `Box2_872` (la nueva que acaba de crear el `Source`). **`Queue.Delete` vacía `Back`**. Como la caja que espera ya estaba creada, `Source.Copy` no cambia y el enlace no vuelve a escribir `Back`. Su `Enqueue` (en `NOT.Output`, al levantarla) no añade nada.
  - **Arreglo propuesto:** hacer el `Enqueue` en `Source.Executed` (como la `Queue` de la cinta), no en `NOT.Output`. Así `Back` siempre está recién escrito. La cola tendría también la caja que va por la cinta (la más nueva), así que con el palé lleno y la mesa llena debería marcar 79, y las 72 `Delete` siguen siendo correctas. Hay que mirar si a `Queue_EuroPallet` (`DeleteAll`, mismo montaje en `NOT.Output`) le pasa lo mismo en el 2.º vaciado.
  - **Hecho y probado (5 nov):** en `SC_Conveyor2` se borró `LogicGate [NOT].Output` → `Queue_HalfPallet.Enqueue` y se añadió `Source.Executed` → `Queue_HalfPallet.Enqueue` (al final de la lista; aquí el orden no importa). Prueba: 1.er palé lleno con la mesa llena, **79** (`Front` `Box2_884`); después del cambio, **7** (`Back` vacío, ya da igual); al levantar la caja que esperaba, **8**; 2.º palé lleno, **79** (`Front` `Box2_969`); después del 2.º cambio, palé vacío sin cajas sueltas, bloque completo en `BlockPos1` y **8** al levantar la siguiente. **Resuelto.**
  - Falta: `Queue_EuroPallet` en el 2.º vaciado (sigue con `Enqueue` en `NOT.Output` y `DeleteAll`). Si falla, el arreglo es el mismo: `Source.Executed` de `SC_Conveyor1` → `Queue_EuroPallet.Enqueue`.
  - **Prueba de `Queue_EuroPallet` (5 nov, 15:46, con `Inicio_04-11`):** 10,7 s: 0, `Back` `Box1_52`; 13,4 s: 1 (`Front` `Box1_52`); 1.er palé lleno (380,3 s): **12** (`Front` `Box1_52`, `Back` `Box1_75`, la que espera); 2.º palé lleno (648,8 s): **12** (`Front` `Box1_158`, `Back` `Box1_181`); justo después del 2.º vaciado (681,3 s): 0 con **`Back` vacío** (`DeleteAll` vacía `Back`, igual que `Delete`); con la caja que esperaba ya levantada (688,6 s): **sigue en 0**, `Back` `Box1_197`; con la siguiente (701,0 s): 1, `Front` `Box1_197`. **Mismo fallo que en el medio palé:** la primera caja después de cada cambio no entra en la cola y se quedaría suelta en el siguiente vaciado. Pendiente de cuadrar: el 12 del 2.º palé (con el fallo deberían ser 11) y una caja 1 que ya está en el hueco 1 a 681,3 s, antes de levantar la que esperaba. En las capturas 4 y 5 no se vio la cola (se miraba `SC_Conveyor1`) y `EuroPalletReplaced` siguió a 1 de 390 a 396 s.
  - **El arreglo de la caja 2 no vale tal cual aquí:** con `Source.Executed` → `Enqueue` la caja que espera en la cinta también entra en la cola, y `DeleteAll` la borraría. Hay que cambiar también `DeleteAll` por un `Repeater` (`Count` 12) → `Queue_EuroPallet.Delete`, como en `SC_Conveyor2`.
  - **Hecho y probado (5 nov, 16:20):** en `SC_Conveyor1`, `Repeater` (`Count` 12); `LogicGate_4 [AND].Output` → `Repeater.Execute` (en lugar de `DeleteAll`); `Repeater.Output` → `Queue_EuroPallet.Delete`; borrada `LogicGate_2 [NOT].Output` → `Queue_EuroPallet.Enqueue` y añadida `Source.Executed` → `Queue_EuroPallet.Enqueue`. `NOT.Output` → `Source.Execute` no se tocó. Revisada la lista entera de conexiones (12) a partir de las capturas. Valores esperados: 1 al arrancar, 13 con el palé lleno, 1 después del cambio (la caja de la cinta sigue), 13 en el 2.º palé y palé vacío sin cajas sueltas.
  - **Prueba (5 nov, con `Inicio_04-11`, estación guardada a las 16:20):** antes de reproducir, 0 y `Front`/`Back` vacíos; 10,5 s (1.ª caja en el sensor): **1**, `Front` = `Back` = `Box1_297`; 1.er palé lleno (219,6 s): **13** (`Front` `Box1_297`, `Back` `Box1_320`, la que espera); justo después de `EuroPalletReplaced` (222,5 s): **1**, `Front` `Box1_320`, `Back` vacío, palé vacío y la caja sigue en la cinta; al levantarla (226,5 s): **2** (`Back` `Box1_323`); 2.º palé lleno (437,8 s): **13** (`Front` `Box1_320`, `Back` `Box1_345`); 2.º vaciado: sin captura, Peru lo vio bien (palé vacío). **Resuelto.** El 12 del 2.º palé en la prueba de las 15:46 quedó sin explicar; ya no importa.
  - **Pulsador perdido por RAPID (5 nov, vídeo `RobotStudio 11-5.mp4` de las 16:37, que sustituye al de la mañana; ≈1,6x, no a máxima velocidad):** europalé lleno, cola **14** (`Front` `Box1_680`, `Back` `Box1_707`; se esperaban 13, sin explicar). 1.ª pulsación a ≈1081,7 s, vuelta a 0 a ≈1083 s: el palé se vacía en el acto, pero `EuroPalletFull` sigue a 1. El robot estaba con el bloque del medio palé (`ProcessBox2`/`TransferStack`) y, cuando volvió a `Main`, la DI ya estaba a 0. 2.ª pulsación a ≈1090,9 s: como `EuroPalletFull` seguía a 1, el `AND` volvió a disparar el `Repeater` y otros 12 `Delete` se llevaron las 2 que quedaban en la cola, **incluida la caja que esperaba en la cinta** (`BoxArrived` a 0 sin que el robot la cogiera). Esta vez RAPID sí vio la DI y `EuroPalletFull` bajó a 0. Después, cola 1 (`Box1_723`, la nueva). **Causa:** RAPID solo lee `DI_EuroPalletReplaced` / `DI_HalfPalletReplaced` en `Main`, entre caja y caja, sin interrupción; el pulso se pierde si el operario lo suelta antes. No depende de la velocidad, sino de en qué parte del ciclo esté el robot. En el medio palé, una 2.ª pulsación borraría 72 más: las de la mesa. **Arreglo propuesto:** `ISignalDI` + `TRAP` que ponga a 0 `DO_…Full` en el acto (así el `AND` se cierra y una 2.ª pulsación no hace nada) y active una bandera; `Main` hace el resto (capa 1, `TransferStack` si `tableFull`). Mientras tanto: mantener el pulsador a 1 hasta ver `…Full` a 0 en el SC, y no pulsar dos veces.
  - **Arreglo con interrupción, europalé (5 nov, ≈17:00–17:20, escrito por Peru paso a paso):** en la sección de la caja 1, `VAR intnum euroReplacedInt;` y `VAR bool euroPalletReplaced:=FALSE;`. `TRAP EuroPalletReplacedTrap` (después de `Main`): `IF euroPalletFull THEN SetDO DO_EuroPalletFull,0; euroPalletReplaced:=TRUE; ENDIF` (apagar la DO en el `TRAP` cierra el `AND` del SC, así una 2.ª pulsación no borra nada). En `Main`, tras los `SetDO …,0` iniciales: `IDelete euroReplacedInt;` (evita «already connected» al volver a ejecutar), `CONNECT euroReplacedInt WITH EuroPalletReplacedTrap;`, `ISignalDI DI_EuroPalletReplaced,1,euroReplacedInt;` (sin `\Single`). El `IF` del europalé en `Main` pasa a `IF euroPalletReplaced THEN euroPalletReplaced:=FALSE; box1Layer:=1; box1State:=Box1Pos1; euroPalletFull:=FALSE; ENDIF` (sin `SetDO`, ya lo hace el `TRAP`). Errores al escribirlo: `IDelete(…)` / `ISignalDI(…)` con paréntesis y sin comas («Missing argument TriggValue»); las instrucciones van sin paréntesis y con comas, los paréntesis solo en llamadas a `FUNC`.
  - **Probado (vídeo `RobotStudio 11-5_1.mp4`, 17:21, ≈0,5x):** europalé lleno (cola 13, `Front` `Box1_779`, `Back` `Box1_802`). Pulsación breve a ≈204 s con el robot cogiendo el bloque de la mesa (`TransferStack`): palé vacío y `EuroPalletFull` a 0 en el mismo instante, `EuroPalletReplaced` ya de vuelta a 0. Cola 1 (`Front` `Box1_802`, la de la cinta). **Funciona.** En ese vídeo no se probó la 2.ª pulsación. Peru sigue con más ciclos. Módulo guardado en `PalletProgram_29-10/PalletProgram.mod` a las 17:59, con comentarios revisados (en el `TRAP`: por qué solo con el palé lleno, por qué se apaga la luz en el `TRAP` y por qué la capa 1 la pone `Main`). Pendiente: repetir lo mismo para el medio palé (`DI_HalfPalletReplaced`) y, si se quiere, para `DI_LinersRefilled`.
  - **Medio palé, mismo arreglo (5 nov, ≈18:15, escrito por Peru):** `VAR intnum halfReplacedInt;` y `VAR bool halfPalletReplaced:=FALSE;` en la sección de `TransferStack`; `TRAP HalfPalletReplacedTrap` (debajo del del europalé, misma cabecera); `IDelete`/`CONNECT`/`ISignalDI DI_HalfPalletReplaced,1,halfReplacedInt` en `Main`. El `IF` de `Main` pasa a `IF halfPalletReplaced`: bandera a FALSE, `box2Layer:=1`, `blockState:=BlockPos1`, `halfPalletFull:=FALSE` y después, si `tableFull`, `TransferStack` (el orden importa: el bloque va al hueco 1 y, mientras lo lleva, `halfPalletFull` ya es FALSE y el `TRAP` ignora otra pulsación). `halfPalletFull` no se toca en el `TRAP`: si se pulsa mientras se pone la 6.ª caja 2, `ProcessBox2` sigue poniendo `tableFull` y el bloque espera como antes. Revisado el módulo entero: sin errores de lógica. **Pendiente de probar.** Queda con el mismo problema `DI_LinersRefilled` (se lee en `Main`; si se pierde, en la simulación una 2.ª pulsación crearía otros 10 liners encima). Arreglo igual: tercera interrupción.
  - **Prueba del medio palé con interrupción (5 nov, 18:27–18:53):** 1.ª ejecución (desde 18:27:55): medio palé lleno con bloque en la mesa a 1232 s; pulsación con el robot ocupado, `HalfPalletFull` a 0 en el acto; 2.ª pulsación sin efecto; el bloque de la mesa va al hueco 1 de la capa 1 (Peru: correcto). Pero tras el borrado la cola marca **13** (`Front` `Box2_1212`, 1429,8 s) en vez de 7 y Peru vio que **quedó un bloque de 6 cajas** en el palé: había 6 entradas de más (sin explicar; el vídeo de las 18:32 se sobrescribió). 2.ª ejecución (vídeos `RobotStudio 11-5.mp4` 18:48 y `_1.mp4` 18:52, que sustituyen a los anteriores): medio palé bien en los dos ciclos (79 → 7; 79 con `Front` `Box2_1525` → 7 → 8). Europalé: 1.er lleno **13** (`Front` `Box1_1441`, `Back` `Box1_1464`), cambio a ≈1191 s con `EuroPalletFull` a 0 en el acto; a 1197 s, ya cogida `Box1_1464`, la cola marca **3** (`Front` `Box1_1464`, `Back` `Box1_1533`) en vez de 2: **entra una de más justo al coger la primera caja después del cambio**. 2.º lleno **14** (`Front` `Box1_1464`, `Back` `Box1_1553`); tras el cambio, 3 con `Front` `Box1_1551`: se borraron 12 de 14 y `Box1_1551` (la última del palé) parece quedarse en el palé. Hipótesis: el `Source` de `SC_Conveyor1` se ejecuta dos veces al levantar esa caja (el parpadeo del sensor del 3 nov) y salen dos copias superpuestas que el robot lleva juntas al mismo hueco; la cola tiene una entrada más que huecos y el `Repeater` de 12 se queda corto. Por comprobar con el analizador de señales (`PlaneSensor.SensorOut`, `Source.Executed`) y mirando el nombre de la caja que queda. A 2729,5 s (en pausa): `Queue_EuroPallet` **6**, `Front` **`Box1_1551`**, `Back` `Box1_1621`. `Box1_1551` es anterior a `Box1_1553` (la que esperaba en la cinta durante el cambio), así que no puede estar en la cinta: es la caja que se quedó en el palé, la última del 2.º palé (`Box1LastPos`, capa 2). Confirmado por la cola, sin hacer clic. **En la vista 3D no se puede hacer clic sobre las cajas del `Source`** (copias temporales de la simulación): para saber qué caja es, mirar `Front`/`Back` de la cola. **Analizador de señales (5 nov, ≈19:10, `Recording-9`, con `Inicio_04-11`, pausa a 242 s):** al levantar una caja 1, `SensorOut` baja y `Source.Executed` da un pulso; ≈0,8 s después `SensorOut` vuelve a 1 un instante, el `NOT` baja y sube y **`Source.Executed` da un 2.º pulso**: el parpadeo del 3 nov sigue ahí (los 10 mm lo redujeron, no lo quitaron). En esa prueba la cola pareció bien (2 tras el cambio: `Front` `Box1_1658`, `Back` `Box1_1662`, el nombre salta 4). Causa probable: la aproximación a los palés está a `TransitHeight-PalletOffsetHeight` = TCP 850 mundo (igual en las dos capas), y la caja se coge a TCP 1100 (base de la caja ≈900); en el `MoveJ` hacia el palé la base baja de 900 a 650 y cruza el plano (788–798) si aún está sobre el final de la cinta. Arreglo a decidir. **Se deja como algo a tener en cuenta** (5 nov, llevaba un rato sin fallar; tarea T36 en `PR310G_pendientes.md`). Ojo: RobotStudio reutiliza los nombres `RobotStudio 11-5.mp4`, `_1`… y sobrescribe vídeos; renombrarlos tras grabar.
  - **Liners, mismo arreglo (5 nov, ≈19:40, escrito por Peru):** `VAR intnum linersRefilledInt;`, `VAR bool linersRefilled:=FALSE;`; `TRAP LinersRefilledTrap` (`IF linerStackEmpty`: `SetDO DO_LinerStackEmpty,0` y bandera); tercera conexión en `Main`; el `IF` de `Main` pasa a `IF linersRefilled` (bandera a FALSE, `linersLeft:=TotalLiners`, `linerStackEmpty:=FALSE` y después, si `linerMissing`, `PlaceLayerLiner` y el bloque de la mesa). Orden de los bloques en `Main`: medio palé, europalé, liners (el orden no importa: `linerMissing` y `halfPalletFull` no pueden ser TRUE a la vez, y el europalé no mueve nada). Cabecera de los `TRAP`: «operator buttons (pallet replaced, liners refilled)». Revisado el módulo entero: bien. **Probado (5 nov, 20:00–20:13, vídeo `RobotStudio_Liners.mp4`):** 5477 s, pila vacía tras el 5.º medio palé (`LinerStackEmpty` = 1); 6399 s, capa 1 del 6.º palé sin liner y bloque esperando en la mesa; ≈6537 s, pulsación de `LinersRefilled` con el robot ocupado con cajas 1: `LinerStackEmpty` a 0 en el acto y salen los 10 liners; 2.ª pulsación en seguida: la pila no cambia a la vista (no se comprobó `Queue_Liners`); después el robot pone el liner que faltaba y lleva el bloque de la mesa. En el mismo vídeo, cambio del europalé con `EuroPalletFull` a 0 en el acto. **Funciona.** Módulo final escrito por Claude a petición de Peru (5 nov, 20:19) a partir de su versión, con las cabeceras corregidas y los bloques de `Main` en orden europalé → medio palé → liners; Pack and Go en `Pallet_Project.rspag` a las 20:23, con el mismo `PalletProgram.mod` (comprobado byte a byte). Cabeceras: el texto de las interrupciones va al final del párrafo *Structure* de la cabecera del módulo y la sección de los `TRAP` se titula `! Interrupts: operator buttons (pallet replaced, liners refilled)`.
  - En esa prueba el panel *Controler señales* no se actualizaba: con el palé lleno `DO_EuroPalletFull` salía 0, y con una caja en la ventosa las `DO_Cup` también salían 0. No sirve como prueba en esas capturas.
  - **Vídeo `RobotStudio 11-5_3.mp4` (5 nov, 12:47, ≈10 862–10 972 s, otra prueba):** al pulsar `HalfPalletReplaced` se vacía el medio palé y bajan a 0 `HalfPalletFull` (en `SC_Conveyor2`) y `DO_HalfPalletFull`. La que sigue a 1 es `DO_EuroPalletFull`, y es lo correcto: en esa prueba el europalé estaba lleno y no se vació. `DO_LinerStackEmpty` también está a 1. `HalfPalletReplaced` se queda a 1 todo el vídeo (hay que volver a ponerla a 0).
- **Ctrl+S con el editor RAPID activo no guarda la estación (4 nov):** no sale «Proyecto guardado». Hay que hacer clic en la vista 3D (u otra pestaña) y entonces Ctrl+S. Para guardar el módulo en disco: panel *Controlador* → RAPID → T_ROB1 → clic derecho en `PalletProgram` → *Guardar módulo como...* (abre ya `PalletProgram_29-10`). Los cambios del editor se cargan en el controlador con *Aplicar* (pestaña RAPID), que además verifica el programa.
- *Parar* detiene la simulación, no la tarea RAPID: el módulo sigue `[sólo lectura]` y sale *La tarea está en el estado de funcionamiento*. Para editar: pestaña `RAPID` → grupo `Probar y depurar` → **Detener**. Si *Detener* no hace nada (5 nov, 16:40, después de grabar un vídeo con la simulación en pausa): guardar la estación y *Controlador* → *Reiniciar* ▾ → **Reiniciar (Arranque en caliente)**. Conserva el programa y deja el módulo editable. *Restablecer RAPID* y *Restablecer sistema*, no.
- Conectar el `SC_Gripper` a la herramienta no arrastra su sensor: hay que conectar el propio `LineSensor` a `PalletizingVacuumTool/PalletizingVacuumTool`.
- `Attacher.Parent` se había quedado en `Detacher (SC_Gripper)`.
- Con el estado `Inicio` guardado (salida del NOT ya a 1), el NOT ya no daba flanco al arrancar y no salía la primera caja: de ahí `SimulationEvents`.
- Aviso 50024 *Fallo de trayectoria de esquina*: el último `MoveL` de `ApproachPoint` acaba en `z10` y `Main` se queda esperando caja; el robot para en el punto. No es un error; se quita con `fine` en la subida si molesta en el vídeo.
- **Casi colisión ventosa–`LinerStand` al coger los liners de abajo (5 nov): comportamiento esperado, no un fallo.** El soporte está en z 500, cada liner mide 10 mm y el umbral de casi colisión es 50 mm: al coger los 4 liners más bajos (7.º a 10.º) las copas quedan a 10–40 mm del soporte. Salió 4 veces en la prueba de reposición (10.5), ninguna colisión real.

### 10.5 `SC_Conveyor2` (cinta 2, 1 nov)

Mismo montaje que la cinta 1 (10.1). Probado el 1 nov con `Inicio_01-11_v2`: sale una sola caja en cada cinta, la caja 2 se para al final de la cinta y `Cup21` baja sobre su centro. La caja 2 todavía no se engancha (ver sección 11), así que se queda en la cinta y no sale la siguiente.

| Componente | Configuración | Para qué |
|---|---|---|
| `Box2` (plantilla, en Componentes) | Caja 130 × 130 × 200. Origen local movido al centro; pieza en (−353,5, 3575, 868), `Cuerpo` en (−418,5, 3510, 768) | Lo que copia el `Source` |
| `Source` | `Source` = `Box2`, `Position` (−353,5, 3575, 868), `Transient` ✓, `PhysicsBehavior` `Unchanged`. Y 3575 = fin de la cinta 3660 − 65 de media caja − 20 de margen | Crea cada caja |
| `Queue` | Nada manual | Lista de cajas que mueve el `LinearMover` |
| `LinearMover` | `Object` = `Queue (SC_Conveyor2)`, `Direction` (0, −1, 0), `Speed` 250, `Reference` Global, `Execute` ✓ | Mueve las cajas hacia el robot |
| `PlaneSensor` | `Origin` (−503,5, 675, 788), `Axis1` (300, 0, 0), `Axis2` (0, 0, 10), `Active` ✓ | Barrera al final de la cinta, de z 788 a 798 (antes 828, ver 10.4) |
| `LogicGate` | `NOT`, `Delay` 0 | Al llevarse el robot la caja, pide la siguiente |
| `SimulationEvents` | Nada manual | Primera caja al pulsar *Reproducir* |
| Señal `BoxArrived` | DigitalOutput | Salida del componente hacia el controlador |

Enlazamiento: `Source.Copy` → `Queue.Back`. Conexiones: `Source.Executed` → `Queue.Enqueue`; `PlaneSensor.SensorOut` → `Queue.Dequeue`, → `SC_Conveyor2.BoxArrived` y → `LogicGate.InputA`; `LogicGate.Output` → `Source.Execute`; `SimulationEvents.SimulationStarted` → `Source.Execute`. Lógica de estación: `SC_Conveyor2.BoxArrived` → `DI_Box2Arrived`.

Con la caja parada, su centro queda en (−353,5, ≈734,5): es la posición de `Cup21` calculada con `PickConveyor2` y `wobjConveyor2`.

**Vaciado del medio palé, cajas 2 (4 nov, hecho y probado):** como el del europalé (10.1), pero sin `DeleteAll`, porque en la mesa puede haber cajas (o un bloque esperando, `tableFull`) que no hay que borrar.
- `Queue_HalfPallet` (nada manual) guarda las cajas que el robot se lleva de la cinta 2. Enlace `Source.Copy` → `Queue_HalfPallet.Back`; conexión `LogicGate [NOT].Output` → `Queue_HalfPallet.Enqueue`, colocada **encima** de `NOT.Output` → `Source.Execute` (como «Mover hacia arriba» no movía la fila, se borró y se volvió a crear la de `Source.Execute`, que queda la última).
- La cola es FIFO y las cajas recorren cinta → mesa → palé en orden: las 72 más antiguas son las del palé y las de la mesa son las últimas. `Repeater` (`Count` 72; «pulsa una señal un número de veces»: con `Execute` a 1 pulsa `Output` `Count` veces) → `Queue_HalfPallet.Delete`, que borra solo la primera de la cola (`Front`).
- Señales de `SC_Conveyor2`: `HalfPalletReplaced` (DigitalInput, pulsador del operario), `HalfPalletFull` (DigitalInput), `HalfPalletReplacedOut` (DigitalOutput). `LogicGate_5 [AND]` (`Delay` 0): `HalfPalletReplaced` → `InputA`, `HalfPalletFull` → `InputB`, `Output` → `Repeater.Execute` y `Output` → `HalfPalletReplacedOut`.
- Lógica de estación: `Controler.DO_HalfPalletFull` → `SC_Conveyor2.HalfPalletFull`; `SC_Conveyor2.HalfPalletReplacedOut` → `Controler.DI_HalfPalletReplaced`.
- `DO_HalfPalletFull` creada en *Controlador* → *Configuración* → *I/O System* → *Signal* → clic derecho → *Nuevo Signal...* (Name `DO_HalfPalletFull`, Type `Digital Output`, sin dispositivo, Category vacía, Access Level `Default`, igual que `DO_EuroPalletFull`), con la tarea RAPID detenida y la estación guardada, y después *Reiniciar (Arranque en caliente)* (conserva el programa; *Restablecer sistema* y *Restablecer RAPID* no).
- RAPID (4 nov, guardado en `PalletProgram_29-10/PalletProgram.mod`): `SetDO DO_HalfPalletFull,1;` tras `halfPalletFull:=TRUE;` (`TransferStack`, `BlockPos4`); `SetDO DO_HalfPalletFull,0;` en `Main` tras `halfPalletFull:=FALSE;` y antes del `IF tableFull`, y al arrancar junto a la de `DO_EuroPalletFull`.
- Uso: pulsar `HalfPalletReplaced` en las propiedades de `SC_Conveyor2` y volver a ponerla a 0.
- **Prueba (4 nov, con `Box2MaxLayers:=1` y `Count` 24, temporal):**
  - Con 1 bloque en el palé, pulsar no hizo nada (`HalfPalletReplacedOut` y `DI_HalfPalletReplaced` siguieron a 0).
  - A los 387 s, 4 bloques en el palé y `DO_HalfPalletFull` = 1. A los 551 s, 6 cajas en la mesa (`tableFull`) y el robot parado; cola 30.
  - Al pulsar: `DO_HalfPalletFull` y `HalfPalletFull` a 0 enseguida (RAPID aceptó el cambio, así que la DI llegó), desaparecieron las 24 cajas del palé, las 6 de la mesa se quedaron y el robot llevó el bloque a la capa 1, hueco 1 del palé nuevo. A los 637 s la cola marcaba 10 = 6 en el palé + 4 nuevas en la mesa.
  - Después se volvió a `Box2MaxLayers:=3` y `Count` 72, verificado sin errores.
- **Liners (4 nov, hecho y probado con 3 capas):** los liners son copias de 10 `Source` en `SC_Liners` (detalle del montaje en la sección 11, «Fase 2/3 del 2B»), en `Queue_Liners` de arriba abajo. Al cambiar el medio palé, `SC_Conveyor2.HalfPalletReplacedOut` → `SC_Liners.PalletReplaced` → `Repeater_Liners` (`Count` 2) → `Queue_Liners.Delete`: borra los 2 más antiguos de la cola, que son siempre los del palé. Plantilla `Liner_01` en (−900, −2000, 0), fuera de la célula (origen local en la esquina del cuerpo).
- **Prueba final (4 nov, 22:21–22:27, `Inicio_04-11`, `Box2MaxLayers:=3`, `Count` 72 y 2):** al reproducir, `Queue_Liners` = 10 con `Front` = `Liner_01_3` (la de `Source_L10`, arriba). Primer liner sobre la capa 1 a ≈394 s, segundo sobre la capa 2 a ≈880 s; `HalfPalletFull` = 1 a 1103 s; a 1297 s, 6 cajas en la mesa (`tableFull`), robot esperando, `Queue_Liners` = 10 (2 en el palé + 8 en la pila). Al pulsar `HalfPalletReplaced` (y volver a 0): `HalfPalletFull` a 0, desaparecieron las 72 cajas **y los 2 liners**, las 6 de la mesa se quedaron, y el robot llevó el bloque a la capa 1, hueco 1 del palé nuevo y lo **soltó bien** (a 1380 s el bloque está en el palé y el robot ya deja cajas en la mesa). `Queue_Liners` = 8, `Front` = `Liner_01_5`. Tras *Parar* no quedaron copias reales.
- **Reposición de la pila (`LinersRefilled`, `DO_LinerStackEmpty`): probada y bien (5 nov, 00:34–00:59, ciclo completo sin atajos).** Con `Inicio_04-11` (al cargarlo salió la copia real `Box1_112`; borrada). Europalé lleno y sin vaciar; medio palé vaciado con `HalfPalletReplaced` cada vez que se llenó (≈1090, 2184, 3261, 4352 y 5500 s).
  - Pulsar `LinersRefilled` con la pila llena (≈190 s, `LinerStackEmpty` = 0) no hizo nada: `LinersRefilledOut` siguió a 0 y `Queue_Liners` siguió en 10 (mismas `Front`/`Back`).
  - Tras el 2.º liner del 5.º palé (≈5085 s): `LinerStackEmpty` = 1 y `Queue_Liners` = 2.
  - Al cambiar el 5.º palé: `Queue_Liners` = 0. Al acabar la capa 1 del 6.º palé, el robot llenó la mesa (6 cajas) y se quedó esperando (≈6250–6400 s).
  - Al pulsar `LinersRefilled` (≈6403 s): reapareció la pila, `LinerStackEmpty` a 0 enseguida, `Queue_Liners` = 10 (`Front` `Liner_01_526` = la primera creada, de `Source_L10`, arriba; `Back` `Liner_01_535`). El robot puso el liner que faltaba y después llevó el bloque que esperaba encima (mesa vacía a ≈6478 s). A ≈6716 s el 2.º liner del 6.º palé ya estaba puesto, bien apoyado.
  - Tras *Parar* (6742 s) no quedaron copias reales. Guardado 01:00.
  - 4 mensajes «Casi colisión en Conjunto de colisión_1 entre PalletizingVacuumTool y LinerStand» (00:48:22, 00:49:42, 00:52:26, 00:53:46; cada uno terminó en el mismo segundo), al coger los 4 liners más bajos (7.º a 10.º); con los de arriba no salió ninguno. Ninguna colisión real. **Esperado** (explicación en 10.4). También avisos 50024, ya explicados en 10.4.

Errores encontrados el 1 nov:

- **Cajas dobles («se dividen en dos» al llegar al sensor):** al parar la simulación, el sensor se queda en 1 y el NOT en 0. Al reproducir sin cargar el estado, el NOT pasa de 0 a 1 y `SimulationEvents` también dispara: salen dos copias superpuestas. La `Queue` saca solo una al llegar al sensor y la otra sigue de largo. Por eso hay que cargar el estado guardado antes de cada prueba.
- **Guardar el estado con el NOT en 1:** antes de guardar, comprobar `LogicGate.Output` = 1 (`Componer` → clic derecho en `LogicGate [NOT]` → *Propiedades*; no sale en el panel *Diseño*). Si está a 0, poner `PlaneSensor.Active` a 0 y otra vez a 1, y borrar la copia que aparece.
- **Mover siempre la pieza, no `Cuerpo`:** el título del cuadro lo indica: *Definir posición: Box2* mueve la pieza y *Definir posición: (Body) - Box2* el cuerpo. Se aplicó (−353,5, 3575, 868) a `Cuerpo` y la caja quedó flotando 100 mm. La altura de la base se lee en `Cuerpo` (Z 768); la pieza va en Z 868.
- **Copias reales al montar:** conectar el NOT activó el `Source` fuera de la simulación y creó `Box2_2`. Hay que borrar esas copias (`Transient` no las borra).
- **`Box1_1`** era una copia sobrante del mismo tipo y estaba en el europalé; se borró. La plantilla de la cinta 1 es `Box1`.
- **Cargar un estado antiguo devuelve `Box2` a su valor de entonces:** con el `Inicio` del 30 oct, `Box2` marcó (0, 0, 0). Se arregló volviendo a aplicar la posición, sin rehacer el origen local (`Cuerpo` volvió a marcar bien).
- **Casilla `Incluir` al guardar:** sale ■, no ✓ (ver 10.3).

## 11. Pendiente

Código:
- `cupsState`: se escribe en `VacuumControl` pero no se lee. Quitarlo o usarlo para el extra de presión.
- Mensajes al FlexPendant (pila vacía, palé lleno) y `DEFAULT` de `ApproachHeight`: al final.
- **Retocar `CalibData.mod`** (apuntado el 4 nov):
  - **Comentarios:** falta uno por cada `wobj` (dónde está su origen y hacia dónde van sus ejes). Las cabeceras de sección mezclan tabuladores y espacios. El comentario de `loadBox2` dice que la mesa se llena "rows ascending Y, each row descending X", pero desde el 1 nov se llena primero la fila lejana (y = 130), es decir, Y descendente (ver el comentario de `ProcessBox2`).
  - **Masas e inercias:** `toolVacuum` sigue con 1 kg provisional, CdG (0, 0, 1) e inercias 0. Todas las `loaddata` (`loadBox1` 2 kg, `loadBox2` 0,4 kg, `loadBox2Stack` 2,4 kg, `loadLiner` 0,52 kg) tienen las inercias a 0 (masa puntual). Calcularlas (caja maciza: Ix = m(b²+c²)/12, etc.) o justificar el 0, y confirmar las masas (correo a My Legendi).
  - **CdG:** comprobar que el de `loadBox2Stack` (0, 0, 100) está bien respecto al TCP con el que se coge el bloque en `PickTableStack`.
- Ordenar carpetas: `PalletProgram_29-10` es la versión buena; decidir qué hacer con `PalletProgram_28-10` y `PalletProgramV1`.

Simulación:
- Cinta 1, caja 1, cinta 2, caja 2 en la ventosa, bloque 3×2 y liners hechos y probados el 1 nov (10.1, 10.2, 10.5). El código de los liners no cambió: `PickLiner` ya bajaba 10 mm por liner. Ciclo completo hasta llenar los dos palés probado por Peru el 1 nov: todo bien. Falta:
  - **Cambio de palé en simulación:** europalé hecho el 4 nov (10.1); medio palé (cajas 2 y liners) hecho y probado con 3 capas el 4 nov (10.5); reposición de liners probada con el ciclo completo el 5 nov (10.5). Planteamiento original del medio palé: al activar `DI_HalfPalletReplaced` tienen que desaparecer las cajas 2 del medio palé y los liners, pero no las cajas 2 que estén en la mesa (un bloque puede estar esperando, `tableFull`).
    - **Decidido (4 nov), en curso:**
      - **Cajas 2 (opción 1A):** `Queue_HalfPallet` en `SC_Conveyor2`, llenada al coger la caja de la cinta 2, con el mismo montaje que `Queue_EuroPallet`. Al cambiar el palé, un `Repeater` (`Count` 72) da pulsos a `Queue_HalfPallet.Delete`, que borra la primera de la cola. No se usa `DeleteAll`.
      - **Por qué funciona:** la cola es FIFO y las cajas pasan cinta → mesa → palé siempre en el mismo orden. Las 72 más antiguas son las del palé; las de la mesa (0–6) son las últimas y, tras el cambio, quedan las primeras, que es justo lo que irá al palé nuevo.
      - **Descartadas:** cola al soltar el bloque en `SC_Gripper` (6 objetos a la vez y `Cup21` también suelta en la mesa) y `VolumeSensor` + `Sink` (detectaría los liners y el bloque de la ventosa).
      - **Liners (opción 2B):** pasan a ser copias de un `Source` (10 `Source`, uno por altura), creadas con `SimulationStarted` y con el pulsador `LinersRefilled` (`AND` con una `DO_LinerStackEmpty` nueva → `DI_LinersRefilled`). Entran en `Queue_Liners` de arriba abajo, el mismo orden en que los coge el robot. Al cambiar el palé, un `Repeater` (`Count` 2) → `Queue_Liners.Delete`: un medio palé lleno tiene siempre 2 liners.
      - **Por qué no se mueven los liners fijos (`Positioner`):** la pila se vacía justo al poner el 2.º liner de un palé, así que al reponer 2 de las 10 piezas siguen en el palé en uso.
      - **Plantilla del liner:** apartada fuera del alcance de la ventosa, como `Box1` y `Box2` al principio de las cintas. Si se queda en la pila, los sensores de la ventosa la detectarían y el robot cogería la plantilla en vez de una copia.
      - **Posiciones de los liners fijos (leídas el 4 nov, 16:40, antes de tocar nada; *Definir posición*, referencia Mundo, cerrado sin aplicar):** las piezas `Liner_01` y `Liner_02` tienen el origen en (0, 0, 0), orientación (0, 0, 0) (03–10 no comprobadas; mismo caso que `Box1` en 10.4: la geometría va desplazada en `Cuerpo`). Los `Cuerpo` (esquina inferior, orientación 0, 0, 0): `Liner_01` (−1300, −700, 500) = el de **abajo**; `Liner_02` 510; `Liner_03` 520; `Liner_04` 530; `Liner_05` 540; `Liner_06` 550; `Liner_07` 560; `Liner_08` 570; `Liner_09` 580; `Liner_10` (−1300, −700, 590) = el de **arriba** (el primero que coge el robot). Todos con X −1300 e Y −700.
      - **Fase 2 del 2B (4 nov, 16:44–16:53), prueba con 2 `Source`, bien:**
        - `HalfPalletReplaced` de `SC_Conveyor2` estaba a 1 (de la prueba de Peru); puesta a 0.
        - Plantilla: `Liner_01` → clic derecho → *Modificar* → *Establecer origen local* (Mundo, (−1300, −700, 500), orientación 0) → la pieza marca (−1300, −700, 500). Después *Posición* → *Fijar posición* (−900, −2000, 0): queda en el suelo, fuera de la célula (el robot nunca va allí).
        - `SC_Liners` creado (*Modelado* → *Componente inteligente*, renombrado en *Diseño*). Dentro: `Source_L10` y `Source_L09` (*Acciones* → `Source`; `Source` = `Liner_01`, `Position` (−1300, −700, 590) y (−1300, −700, 580), orientación 0, `Transient` ✓, `PhysicsBehavior` `Unchanged`), `Queue_Liners` y `SimulationEvents` (*Otros*).
        - Enlaces: `Source_L10.Copy` → `Queue_Liners.Back` y `Source_L09.Copy` → `Queue_Liners.Back`. **RobotStudio deja enlazar varios orígenes al mismo destino** y funciona: `Back` toma la última copia escrita.
        - Conexiones, en este orden: `SimulationEvents.SimulationStarted` → `Source_L10.Execute`; `Source_L10.Executed` → `Queue_Liners.Enqueue`; `Source_L10.Executed` → `Source_L09.Execute`; `Source_L09.Executed` → `Queue_Liners.Enqueue`.
        - Prueba (*Reproducir* sin cargar estado, pausa a 11,4 s): `Queue_Liners` = 2, `Front` = `Liner_01_635` = la copia de `Source_L10` (su `Copy` la marca), `Back` = `Liner_01_636`. La cadena `Executed` → `Execute` funciona en el mismo instante. Al crear las conexiones no salieron copias reales; tras *Parar* tampoco.
        - **Fase 3 en curso (4 nov, 17:15; guardado):** montados los 10 `Source` (`Source_L10` z 590 … `Source_L01` z 500, todos (−1300, −700, z), `Source` = `Liner_01`, `Transient` ✓, `Unchanged`), los 10 enlaces `Source_Lnn.Copy` → `Queue_Liners.Back` y la cadena completa: `SimulationStarted` → `L10.Execute`; para cada nn, `Lnn.Executed` → `Queue_Liners.Enqueue` y, debajo, `Lnn.Executed` → `L(nn−1).Execute`, hasta `L01.Executed` → `Enqueue`. Borrados `Liner_02`…`Liner_10` (solo queda la plantilla `Liner_01` en (−900, −2000, 0)). **Falta:** `DO_LinerStackEmpty` + RAPID, señales `LinersRefilled`/`LinerStackEmpty`/`LinersRefilledOut` + `AND` → `Source_L10.Execute`, `Repeater_Liners` (`Count` 2) → `Queue_Liners.Delete` con entrada `PalletReplaced` desde `SC_Conveyor2.HalfPalletReplacedOut`, lógica de estación, estado `Inicio_04-11` y prueba final. Sin probar todavía la cola con 10.
        - **Hecho a las 17:19:** `DO_LinerStackEmpty` creada (*I/O System* → *Signal* → *Nuevo Signal...*: `Digital Output`, sin dispositivo, Access Level `Default`) + *Reiniciar (Arranque en caliente)*; sale en *Controler señales*. RAPID (aplicado, verificado sin errores y guardado en `PalletProgram_29-10/PalletProgram.mod`, comprobado en disco): `SetDO DO_LinerStackEmpty,1;` tras `linerStackEmpty:=TRUE;` (`PlaceLayerLiner`, línea 366); `SetDO DO_LinerStackEmpty,0;` tras `linerStackEmpty:=FALSE;` en el reset de `Main` (línea 203, antes del `IF linerMissing`) y al arrancar junto a las otras dos (línea 174). 
        - **Hecho a las 22:16 (guardado):** en `SC_Liners`, señales `LinersRefilled`, `LinerStackEmpty`, `PalletReplaced` (DigitalInput) y `LinersRefilledOut` (DigitalOutput); `LogicGate [AND]` (`Delay` 0) y `Repeater_Liners` (`Count` 2). Conexiones: `LinersRefilled` → `AND.InputA`; `LinerStackEmpty` → `AND.InputB`; `AND.Output` → `LinersRefilledOut`; `AND.Output` → `Source_L10.Execute`; `PalletReplaced` → `Repeater_Liners.Execute`; `Repeater_Liners.Output` → `Queue_Liners.Delete`. Lógica de estación: `Controler.DO_LinerStackEmpty` → `SC_Liners.LinerStackEmpty`; `SC_Liners.LinersRefilledOut` → `Controler.DI_LinersRefilled`; `SC_Conveyor2.HalfPalletReplacedOut` → `SC_Liners.PalletReplaced`. No salieron copias reales.
        - **Comprobado a las 22:18:** cargar `Inicio_03-11` devolvió `Liner_01` a (0, 0, 0) (con el origen nuevo, geometría en la base del robot) y creó las copias reales `Box1_1` y `Box2_2`. Se volvió a poner `Liner_01` en (−900, −2000, 0) y se borraron las dos copias. Comprobado además: ningún `Liner_02…10` reapareció; `Count` 72 (`SC_Conveyor2`) y 2 (`Repeater_Liners`); `HalfPalletReplaced`, `EuroPalletReplaced` y `LinersRefilled` a 0; robot en Home (*Movimiento de ejes* 0, 0, 0, 0, 90, 0; TCP −530,33 / 530,33 / 946,5). Guardado `Inicio_04-11` (22:20, sin comportamiento físico ni valores de variable) y comprobado que carga limpio.
        - **Prueba final con 3 capas (22:21–22:27): bien.** Resultado en 10.5. Guardado 22:28.
      - **Comprobado en RobotStudio 2025:** existe `Repeater` (en *Señales y propiedades*) y `Queue` tiene las entradas `Enqueue`, `Dequeue`, `Clear`, `Delete` y `DeleteAll`. Según la descripción del propio componente, `Delete` «elimina el objeto Front de la cola y de la estación» (solo la primera) y `DeleteAll` «vacía la cola y elimina todos los objetos de la estación».
      - **Paso 1 (`Queue_HalfPallet`) probado y bien (4 nov, 13:54):** sin copias reales y con vista desde arriba, la cola subió de una en una al coger cada caja 2 (1…6), cada caja se quedó en la mesa (la ventosa se fue vacía), con 6 en la mesa el robot llevó el bloque al medio palé (107,9 s; mesa vacía) y con la 7.ª caja: **cola 7 = 6 en el medio palé + 1 en la mesa** (131,9 s). `Front` = `Box2_347` (la 1.ª).
      - **Paso 2a (`Repeater`) probado y bien (4 nov, 14:01):** `Repeater` en `SC_Conveyor2` (en *Señales y propiedades*; «pulsa una señal un número de veces»; `Execute` a 1 pulsa `Output` `Count` veces), conexión `Repeater.Output` → `Queue_HalfPallet.Delete`. Prueba con `Count` 6: con 6 cajas en el medio palé y 1 en la mesa (cola 7, `Front` `Box2_364`), pulsando a mano `Execute` desaparecieron las 6 del medio palé, la de la mesa se quedó y la cola pasó a 1 con `Front` = la caja de la mesa (`Box2_377`). Al *Parar*, `Execute` vuelve solo a 0. Después `Count` = 72 y guardado (14:02). Esta vez cargar `Inicio_03-11` no creó copias reales.
      - **Paso 2b hecho y probado (4 nov, 14:30): montaje final y prueba en 10.5, «Vaciado del medio palé».** Notas del montaje: en `SC_Conveyor2`, señales `HalfPalletReplaced` (DigitalInput, pulsador del operario), `HalfPalletFull` (DigitalInput) y `HalfPalletReplacedOut` (DigitalOutput); `LogicGate_5 [AND]` (`Delay` 0, ya venía así) con `HalfPalletReplaced` → `InputA`, `HalfPalletFull` → `InputB`, `Output` → `Repeater.Execute` y `Output` → `HalfPalletReplacedOut`. `DO_HalfPalletFull` creada en *Controlador* → *Configuración* → *I/O System* → *Signal* (clic derecho → *Nuevo Signal...*: Name `DO_HalfPalletFull`, Type `Digital Output`, sin dispositivo, Category vacía, Access Level `Default`, igual que `DO_EuroPalletFull`), con la tarea RAPID detenida y la estación guardada; reinicio *Reiniciar (Arranque en caliente)* (conserva el programa; I-start y P-start no). Lógica de estación: `Controler.DO_HalfPalletFull` → `SC_Conveyor2.HalfPalletFull`; `SC_Conveyor2.HalfPalletReplacedOut` → `Controler.DI_HalfPalletReplaced`.
      - **Montado el 4 nov:** `Queue_HalfPallet` en `SC_Conveyor2` (nada manual); enlace `Source.Copy` → `Queue_HalfPallet.Back`; conexiones en este orden: … `SimulationEvents.SimulationStarted` → `Source.Execute`, `LogicGate [NOT].Output` → `Queue_HalfPallet.Enqueue`, `LogicGate [NOT].Output` → `Source.Execute` (la de `Source.Execute` se borró y se volvió a crear para que quedara la última).
      - **Prueba pendiente / resultado sin explicar:** con `Inicio_03-11`, en pausa a los 148,5 s la cola marcaba 11 (`Front` `Box2_315`, `Back` `Box2_337`), pero en la vista solo se veía 1 caja 2 en la mesa y el medio palé vacío. Falta averiguar qué hay en la cola.
      - **Segunda prueba (4 nov, 13:39):** tras *Parar* y cargar `Inicio_03-11`, `NumberOfObjects` seguía mostrando 11 (`Front`/`Back` vacíos), pero al coger la 1.ª caja 2 pasó a 1 y con la 2.ª a 2: la cola cuenta de una en una y el 11 era un valor viejo en pantalla. 1.ª caja 2 = `Box2_339`, 2.ª = `Box2_345`.
      - **Caja real sobrante `Box2_314`:** está sobre la mesa (hacia x −1045, y 203) desde antes de reproducir y sale en el panel *Diseño*, así que no es temporal. Se creó casi seguro al volver a crear `NOT.Output` → `Source.Execute` fuera de la simulación (mismo efecto que en 10.5, «Copias reales al montar»). Con la vista desde arriba (47,5 s) se vio: en la mesa `Box2_314` y la 2.ª caja 2 en el hueco de al lado; la 1.ª caja 2 suelta en el europalé; medio palé vacío. Explicación en 10.4. `Box2_314` borrada el 4 nov (13:50), y también `Box1_338` y `Box1_346` (13:53). Prueba de las 7 cajas 2 repetida y bien (ver arriba).
      - Al cambiar de nombre: en la lista de *Componer* el menú del clic derecho no tiene *Cambiar nombre*; en el panel *Diseño* sí (en la pestaña RAPID el panel izquierdo es *Controlador*; *Diseño* sale en *Posición inicial*).
      - «Mover hacia arriba» en *Señales y conexiones* no movió la fila (probado 4 veces con clic, sale activo). Alternativa que funcionó: borrar y volver a crear la conexión que debe ir debajo (las nuevas se añaden al final).
  - **Reposición de liners en simulación:** montada el 4 nov (`SC_Liners`: `LinersRefilled` AND `LinerStackEmpty` → `Source_L10.Execute` y → `LinersRefilledOut` → `DI_LinersRefilled`; `DO_LinerStackEmpty` → `LinerStackEmpty`). **Probada y bien el 5 nov** con el ciclo completo (sin atajo en RAPID: menos liners desordenaría la cola respecto a lo que coge el robot). Resultado en 10.5.
  - **Vídeo final:** grabarlo entero, hasta llenar los dos palés, con la cámara más alejada (el vídeo del 1 nov termina en la capa 1 del medio palé).
- Las cajas van ya enganchadas en la cinta 1: así se ven en la presentación y la detección de colisiones comprueba también la carga.
- Conjunto de colisión: A = robot + herramienta; B = cintas, mesa, soporte y palés (las cajas y los liners no, porque se tocan a propósito). Casi colisión a 50 mm.
- Grabar el vídeo final con la cámara más alejada (en la mesa la ventosa se sale del encuadre).

Resto:
- Estimar masa y CdG de la ventosa.
- Valla, Excel de riesgos, extras (presión analógica, colisiones, PLr/PL).
- Correo a My Legendi: inercias, liner (masa/material), caja 2 con una copa, simulación de la señal analógica, alcance del Station Viewer.
- Comprobar que el Pack and Go de RobotStudio 2025 abre en la 2024.4 de las salas.

## 12. Notas para la defensa

- **Caja 2 con una sola copa:** la caja (130×130) es menor que el patrón de copas. Se coge con la copa de esquina (−160, −100) y válvula por copa; con la central, las copas laterales pisarían cajas vecinas en la mesa. La mesa se llena desde la fila lejana de la cinta y, en cada fila, en X descendente: la caja transportada no pasa sobre las ya puestas. Herramienta estándar de ElegantTools (el enunciado permite otra si se justifica).
- **Giro de la base 135°:** para que el eje 1 no cruce su límite en la cadena caja 2.
- **`wobj0`** coincide con el mundo, no con la base del robot.
- **`GripLoad`:** tras el vacío; carga correspondiente al coger, `load0` al dejar.
- **Cambio de palé en simulación (señal desde el smart component):** el operario pulsa `EuroPalletReplaced` en `SC_Conveyor1`; el componente borra las cajas del palé y activa `DI_EuroPalletReplaced` del controlador. En RobotStudio una entrada del controlador no puede ser el origen de una conexión de la lógica de estación, así que no se puede hacer al revés (pulsar la DI y que el componente borre las cajas).
  - **Equivale a la celda real:** en la celda el pulsador del operario está fuera del vallado y su cable llega a una entrada del controlador. El pulsador es quien mueve la entrada, igual que aquí el componente mueve `DI_EuroPalletReplaced`; cambiar la DI a mano en el Simulador de E/S era menos realista. Lo que en la simulación pasa a la vez (las cajas desaparecen y llega la DI) en la realidad son dos pasos: primero se retira el palé lleno y se pone uno vacío, y después el operario confirma.
  - **No es una señal de seguridad:** `DI_EuroPalletReplaced` solo informa al programa de que puede volver a empezar en la capa 1, y RAPID solo la tiene en cuenta con `euroPalletFull`. La seguridad del cambio de palé es otra cosa: la zona del palé tiene que estar protegida (cortina, escáner o puerta con enclavamiento y su PL según ISO 13849) para que el robot no entre en ella mientras hay alguien, y mientras tanto el robot sigue con el otro producto.
  - **Riesgo de proceso:** si se confirma sin haber cambiado el palé, el robot dejaría cajas encima de un palé lleno. En la simulación, pulsarlo antes de tiempo borra las cajas sin que RAPID reinicie los contadores. Mejora posible en una celda real: un sensor de palé vacío o de presencia de palé que confirme el cambio, en vez de fiarse solo del pulsador.
- **Copas en `ApproachPoint`:** el array es el estado de las copas al llegar al punto. Coger → `CupsAllOn` (o `CupsBox2On`) con carga real; dejar → `CupsAllOff` con `load0`.
- **Dos contadores por producto en la caja 2:** `box2State` (mesa) y `blockState` (palé) son independientes; así el `CASE` de la mesa no cambia y no hace falta un `CASE` de 24 estados.
- **Convención de nombres:** por la primera letra se sabe si un nombre puede cambiar (minúscula) o no (mayúscula).
- **FUNC vs PROC:** `Box1Ready()` / `Box2Ready()` son FUNC porque devuelven un bool que se evalúa en el momento de la llamada.
- **`MoveJ` en el tránsito, `MoveL` solo en vertical:** el `MoveL` entre estaciones lejanas pasa cerca de la base (singularidades, ejes al límite); el `MoveJ` hace un arco, y lo que se comprueba es que no baje sobre nada (rastreo de TCP + conjunto de colisión).
- **Alturas de aproximación:** una FUNC con una fórmula por estación, para que la regla esté en un solo sitio. Plano de 1100 en cintas y mesa, de 850 en los palés (pasar sobre los liners con el bloque) y mínimo de 250 sobre el target (no chocar con las vecinas de la capa).
- **Casi colisión con `LinerStand` al coger los últimos liners:** es esperada. El soporte está en z 500, cada liner mide 10 mm y el umbral de casi colisión del conjunto de colisión es 50 mm, así que al coger los 4 liners de abajo las copas quedan a 10–40 mm del soporte. En la prueba de reposición (5 nov, 10 liners) no hubo ninguna colisión real. Los avisos 50024 tampoco son errores (10.4).
- Seguridad: cortinas de luz en los huecos de los palés, puerta enclavada, paradas de emergencia; reposición de liners y túnel de las cintas en el Excel de riesgos.
