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
| `DI_EuroPalletReplaced`, `DI_HalfPalletReplaced` | DI | Confirmación del operario por palé (no bloqueante). En simulación `DI_EuroPalletReplaced` la activa `SC_Conveyor1` (ver 10.1) |
| `DO_EuroPalletFull` | DO | Luz de "europalé lleno" para el operario (4 nov); también habilita el vaciado en `SC_Conveyor1` |
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

**Vaciado del europalé (3–4 nov, hecho y probado):** `Queue_EuroPallet` (en `SC_Conveyor1`, nada manual) guarda las cajas que el robot se ha llevado de la cinta 1, es decir, las del europalé. Enlace `Source.Copy` → `Queue_EuroPallet.Back`; conexión `LogicGate_2 [NOT].Output` → `Queue_EuroPallet.Enqueue`, colocada **encima** de `NOT.Output` → `Source.Execute`. Las conexiones se ejecutan en el orden de la lista: así `Back` todavía es la caja que se lleva el robot y no la nueva de la cinta (con `Source.Executed` → `Enqueue` entraba también la que espera en la cinta). Comprobado por Peru: la cola llega a 12 con el palé lleno. Señal `EuroPalletReplaced` (DigitalInput de `SC_Conveyor1`) → `Queue_EuroPallet.DeleteAll`: pulsada a mano en las propiedades del componente borra las cajas y la cola vuelve a 0. Una DI del controlador (`DI_EuroPalletReplaced`) no sirve como origen en la lógica de estación: no llega al componente.

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

*Simulación → ˅ bajo Restablecer → Guardar estado actual*: `Pallet_Project` incluido entero, con valores de propiedad, señales de E/S (objetos y controlador), valores de eje, visibilidad y posición/orientación/conexión; sin comportamiento físico ni valores de variable (al *Reproducir*, el PP vuelve a `Main` y las VAR a su valor inicial). Al quitar esas dos opciones, la casilla **Incluir** sale como ■ (cuadrado) y no como ✓: es lo correcto. Se guarda dentro de la estación (Ctrl+S). Cada prueba: **Parar → ˅ Restablecer → `Inicio_03-11` → Reproducir**. `Inicio_03-11` (guardado el 4 nov a las 11:13) es el estado vigente: ventosa completa, 10 liners, planos de las cintas a 10 mm y `Queue_EuroPallet`. Es de antes del `AND` y de las señales nuevas de `SC_Conveyor1`, pero cargarlo no las borra. `Inicio_01-11_v8` (ventosa completa, 10 liners y plano de las cintas bajado a 828) queda de copia. `Inicio` (30 oct), `Inicio_01-11` y `Inicio_01-11_v2` a `_v7` están obsoletos: no cargarlos, porque guardan las propiedades y devuelven el sensor a su posición antigua (ver 10.5).

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
- *Parar* detiene la simulación, no la tarea RAPID: el módulo sigue `[sólo lectura]` y sale *La tarea está en el estado de funcionamiento*. Para editar: pestaña `RAPID` → grupo `Probar y depurar` → **Detener**.
- Conectar el `SC_Gripper` a la herramienta no arrastra su sensor: hay que conectar el propio `LineSensor` a `PalletizingVacuumTool/PalletizingVacuumTool`.
- `Attacher.Parent` se había quedado en `Detacher (SC_Gripper)`.
- Con el estado `Inicio` guardado (salida del NOT ya a 1), el NOT ya no daba flanco al arrancar y no salía la primera caja: de ahí `SimulationEvents`.
- Aviso 50024 *Fallo de trayectoria de esquina*: el último `MoveL` de `ApproachPoint` acaba en `z10` y `Main` se queda esperando caja; el robot para en el punto. No es un error; se quita con `fine` en la subida si molesta en el vídeo.

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
- Ordenar carpetas: `PalletProgram_29-10` es la versión buena; decidir qué hacer con `PalletProgram_28-10` y `PalletProgramV1`.

Simulación:
- Cinta 1, caja 1, cinta 2, caja 2 en la ventosa, bloque 3×2 y liners hechos y probados el 1 nov (10.1, 10.2, 10.5). El código de los liners no cambió: `PickLiner` ya bajaba 10 mm por liner. Ciclo completo hasta llenar los dos palés probado por Peru el 1 nov: todo bien. Falta:
  - **Cambio de palé en simulación:** europalé hecho el 4 nov (10.1). Falta el medio palé: al activar `DI_HalfPalletReplaced` tienen que desaparecer las cajas 2 del medio palé y los liners, pero no las cajas 2 que estén en la mesa (un bloque puede estar esperando, `tableFull`).
    - **Decidido (4 nov), en curso:**
      - **Cajas 2 (opción 1A):** `Queue_HalfPallet` en `SC_Conveyor2`, llenada al coger la caja de la cinta 2, con el mismo montaje que `Queue_EuroPallet`. Al cambiar el palé, un `Repeater` (`Count` 72) da pulsos a `Queue_HalfPallet.Delete`, que borra la primera de la cola. No se usa `DeleteAll`.
      - **Por qué funciona:** la cola es FIFO y las cajas pasan cinta → mesa → palé siempre en el mismo orden. Las 72 más antiguas son las del palé; las de la mesa (0–6) son las últimas y, tras el cambio, quedan las primeras, que es justo lo que irá al palé nuevo.
      - **Descartadas:** cola al soltar el bloque en `SC_Gripper` (6 objetos a la vez y `Cup21` también suelta en la mesa) y `VolumeSensor` + `Sink` (detectaría los liners y el bloque de la ventosa).
      - **Liners (opción 2B):** pasan a ser copias de un `Source` (10 `Source`, uno por altura), creadas con `SimulationStarted` y con el pulsador `LinersRefilled` (`AND` con una `DO_LinerStackEmpty` nueva → `DI_LinersRefilled`). Entran en `Queue_Liners` de arriba abajo, el mismo orden en que los coge el robot. Al cambiar el palé, un `Repeater` (`Count` 2) → `Queue_Liners.Delete`: un medio palé lleno tiene siempre 2 liners.
      - **Por qué no se mueven los liners fijos (`Positioner`):** la pila se vacía justo al poner el 2.º liner de un palé, así que al reponer 2 de las 10 piezas siguen en el palé en uso.
      - **Plantilla del liner:** apartada fuera del alcance de la ventosa, como `Box1` y `Box2` al principio de las cintas. Si se queda en la pila, los sensores de la ventosa la detectarían y el robot cogería la plantilla en vez de una copia.
      - **Comprobado en RobotStudio 2025:** existe `Repeater` (en *Señales y propiedades*) y `Queue` tiene las entradas `Enqueue`, `Dequeue`, `Clear`, `Delete` y `DeleteAll`.
  - **Reposición de liners en simulación:** tampoco reaparecen los liners con `DI_LinersRefilled`.
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
- Seguridad: cortinas de luz en los huecos de los palés, puerta enclavada, paradas de emergencia; reposición de liners y túnel de las cintas en el Excel de riesgos.
