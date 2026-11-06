# PR310G – Pallet Project: memoria de decisiones

Resumen de lo decidido y hecho en la estación `Pallet_Project` (RobotStudio 2025, controlador IRC5 RobotWare 6.13.02), actualizado el 29 oct 2026 (mediodía). Coordenadas en mm, respecto al mundo de la estación salvo que se diga otra cosa.

Autores: Peru Mendivil y Joaquín Moreno (Group 2, JMPM). Repo: github.com/joaquinmz/Pallet-Project (rama `main` = Peru, `second-main` = caja 2 de Joaquín, `cambios-peru-28-10` = trabajo de Peru del 28 oct, `cambios-peru-29-10` = trabajo del 29 oct). **La versión de trabajo actual del programa es la carpeta `PalletProgram_29-10`** (guardada desde RobotStudio); `PalletProgram_28-10` es la de ayer y `PalletProgramV1` una anterior (con una copia de esta memoria).

Vídeo de la simulación de la caja 2 (29 oct, 9:30 min, medio palé completo con los dos liners): `RobotStudio 10-29 v3 comprimido.mp4`. Los vídeos originales sin comprimir están en `.gitignore` (el v3 original pesa 126 MB, más que el límite de GitHub).

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
| Pila liners (`LinerStack`) | 10 liners, z 500…600 | Reposición desde fuera de la valla |

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
| `DI_EuroPalletReplaced`, `DI_HalfPalletReplaced` | DI | Confirmación del operario por palé (no bloqueante) |
| `AI_VacuumPressure` | AI 0–10 bar | Extra de presión |

En RAPID: `cupSignals{6}` enlazado con `AliasIO` en `InitSignals`; `VacuumControl` recibe un array de 6 bool (`CupsAllOn`, `CupsAllOff`, `CupsBox2On` = solo Cup21) y espera `VacuumTime` (1 s, requisito 8).

## 8. Convención de nombres (slides)

- VAR / PERS / parámetros: camelCase (`box1State`, `euroPalletFull`, `cupsState`) → pueden cambiar.
- CONST / PROC / FUNC / MODULE: PascalCase (`SafeHeight`, `VacuumTime`, `ProcessBox1`, `Box1Ready`) → fijos.
- Estados de las máquinas: `Box1Pos1…Box1Pos5`, `Box1LastPos` (`box1State`); `Box2Pos1…Box2Pos5`, `Box2LastPos` (`box2State`, mesa); `BlockPos1…BlockPos4` (`blockState`, hueco del bloque en la capa del medio palé). Capas máximas: `Box1MaxLayers` (2), `Box2MaxLayers` (3).
- Señales: prefijos `DI_`, `DO_`, `AI_`, `AO_`.
- Ojo RAPID: `NOT` tiene la prioridad más baja → poner paréntesis: `(DI_x=1) AND (NOT flag)`.
- FUNC devuelve valor y se llama con `()` dentro de expresiones; PROC es una instrucción sin paréntesis.

## 9. Estado del código (`PalletProgram_29-10/PalletProgram.mod`, 29 oct)

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
  - Z = `(box2Layer-1)*Box2Height + linersPlaced*LinerHeight`.
  - En `BlockPos4` (capa completa): si `box2Layer=Box2MaxLayers` → `halfPalletFull:=TRUE`; si no → liner (`PickLiner` Z −(TotalLiners−linersLeft)·LinerHeight, `PlaceLiner` con la misma Z que la capa) **antes** de `Incr box2Layer`; `Incr linersPlaced`, `Decr linersLeft`. Vuelve a `BlockPos1`.

Variables de la caja 2:

| Variable | Qué cuenta | Se reinicia al cambiar el medio palé |
|---|---|---|
| `box2State` | Caja en la mesa (1…6) | **No** (la mesa puede tener un bloque a medias) |
| `blockState` | Hueco del bloque en la capa (1…4) | Sí (ya vuelve solo a 1) |
| `box2Layer` | Capa del medio palé (1…3) | Sí (se queda en 3) |
| `linersPlaced` | Liners en este palé | Sí (si no, el palé nuevo sale 20 mm más alto) |
| `linersLeft` | Liners en la pila (empieza en `TotalLiners` = 10) | **No** (la pila no cambia con el palé) |
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
- Medio palé (`halfPalletFull AND DI_HalfPalletReplaced=1`): `box2Layer:=1`, `linersPlaced:=0`, `blockState:=BlockPos1`, `halfPalletFull:=FALSE`; luego, si `tableFull` → `TransferStack` y `tableFull:=FALSE`. **Orden importante**: contadores antes de `TransferStack`, para que el bloque vaya a capa 1, hueco 1.
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

Solución actual: `FUNC num ApproachHeight(num target)` con un `TEST` por estación. Los identificadores de estación son `Conveyor1SafeHeight`…`EuroPalletSafeHeight` (= 1…6, nombre pendiente de cambiar). Las alturas en mundo de cada estación son CONST (`ConveyorsHeight` 768, `TableHeight` 770, `LinerStandHeight` 500, `EuroPalletHeight` / `HalfPalletHeight` 144). `DEFAULT` deja 9E+09 a propósito: un identificador erróneo da error de alcance y para el robot.

| Estación | TCP en tránsito (mundo) | Sube sobre el target |
|---|---|---|
| Cintas 1 y 2 (techo caja 968) | `TransitHeight` 1100 | 132 |
| Mesa: dejar caja 2 y coger bloque (techo 970) | 1100 | 130 |
| Pila de liners (techo 500 + `linersLeft`·10) | 1100 | 500 con la pila llena |
| Europalé | 850 = 1100 − `PalletOffsetHeight` (250) | 506 (capa 1), 306 (capa 2) |
| Medio palé (bloques y liner) | 850, con mínimo `MinApproachHeight` 250 | 506, 296, **250** (capa 3, manda el mínimo) |

- **850** = tope de la pila de liners (600) + bloque (200) + 50: el bloque pasa por encima de los liners entre la mesa y el medio palé.
- **Mínimo 250** = caja (200) + 50: el bloque que lleva no choca con los de al lado en la misma capa. Sin él, en la capa 3 solo subía 86 mm.
- La FUNC lee `box1Layer`, `box2Layer`, `linersPlaced` y `linersLeft` en el momento de la llamada: en `TransferStack` las llamadas van **antes** de los `Incr`/`Decr`.

Simulación de la caja 2 (vídeo v3): sin colisiones salvo con `LinerStack` al coger los liners: casi colisión en el 1.º (normal, las copas apoyan) y colisión a z 598,8 en el 2.º, porque el modelo de la pila es fijo (10 liners, techo 600) y el código coge cada liner 10 mm más abajo. Es un efecto de la simulación, no un fallo.

## 10. Pendiente

Código:
- **Mesa:** con el TCP a 1100, la caja 2 que lleva el robot tiene la base a 900 y las cajas ya puestas el techo a 970. Al llegar a un hueco puede chocar con las vecinas (no se ve en la simulación porque las cajas no van enganchadas). Opciones: bajar la mesa, cambiar el orden de llenado para no pasar sobre vecinas, o subir el tránsito (a +300 ya no llegaba).
- **Probar con la versión de hoy el ciclo de la caja 1 y la alternancia** de las dos cajas (el vídeo v3 es solo de la caja 2).
- Renombrar los identificadores de estación (`Conveyor1SafeHeight`… → p. ej. `StationConveyor1`; parámetro `target` de `ApproachHeight` → `station`). Hay un comentario `! Changename` en el código.
- Fecha del encabezado del módulo: sigue en 2026-10-28.
- Pila de liners vacía (`linersLeft=0`): ahora nada detiene al robot. Aviso al operario / señal de reposición.
- Opcional: quitar `linersPlaced` (siempre vale `box2Layer-1`).
- Comprobar orden de llenado de la mesa (memoria: Y ascendente, X descendente; el código empieza por Y=130).
- Ordenar carpetas: `PalletProgram_29-10` es la versión buena; decidir qué hacer con `PalletProgram_28-10` y `PalletProgramV1`.

Simulación:
- Enganchar las cajas, el bloque y el liner a la herramienta (lógica de estación, *Attacher/Detacher*): así se ven en la presentación y la detección de colisiones comprueba también la carga.
- Conjunto de colisión: A = robot + herramienta; B = cintas, mesa, soporte y pila de liners, palés (las cajas no, porque se tocan a propósito). Casi colisión a 50 mm.
- Grabar el vídeo final con la cámara más alejada (en la mesa la ventosa se sale del encuadre).

Resto:
- Estimar masa y CdG de la ventosa.
- Valla, Excel de riesgos, extras (presión analógica, colisiones, PLr/PL).
- Correo a My Legendi: inercias, liner (masa/material), caja 2 con una copa, simulación de la señal analógica, alcance del Station Viewer.
- Comprobar que el Pack and Go de RobotStudio 2025 abre en la 2024.4 de las salas.

## 11. Notas para la defensa

- **Caja 2 con una sola copa:** la caja (130×130) es menor que el patrón de copas. Se coge con la copa de esquina (−160, −100) y válvula por copa; con la central, las copas laterales pisarían cajas vecinas en la mesa. La mesa se llena por filas en Y ascendente y, en cada fila, X descendente. Herramienta estándar de ElegantTools (el enunciado permite otra si se justifica).
- **Giro de la base 135°:** para que el eje 1 no cruce su límite en la cadena caja 2.
- **`wobj0`** coincide con el mundo, no con la base del robot.
- **`GripLoad`:** tras el vacío; carga correspondiente al coger, `load0` al dejar.
- **Copas en `ApproachPoint`:** el array es el estado de las copas al llegar al punto. Coger → `CupsAllOn` (o `CupsBox2On`) con carga real; dejar → `CupsAllOff` con `load0`.
- **Dos contadores por producto en la caja 2:** `box2State` (mesa) y `blockState` (palé) son independientes; así el `CASE` de la mesa no cambia y no hace falta un `CASE` de 24 estados.
- **Convención de nombres:** por la primera letra se sabe si un nombre puede cambiar (minúscula) o no (mayúscula).
- **FUNC vs PROC:** `Box1Ready()` / `Box2Ready()` son FUNC porque devuelven un bool que se evalúa en el momento de la llamada.
- **`MoveJ` en el tránsito, `MoveL` solo en vertical:** el `MoveL` entre estaciones lejanas pasa cerca de la base (singularidades, ejes al límite); el `MoveJ` hace un arco, y lo que se comprueba es que no baje sobre nada (rastreo de TCP + conjunto de colisión).
- **Alturas de aproximación:** una FUNC con una fórmula por estación, para que la regla esté en un solo sitio. Plano de 1100 en cintas y mesa, de 850 en los palés (pasar sobre los liners con el bloque) y mínimo de 250 sobre el target (no chocar con las vecinas de la capa).
- **Colisión con `LinerStack` al coger el 2.º liner:** el modelo de la pila es fijo; en la realidad ese liner ya no estaría.
- Seguridad: cortinas de luz en los huecos de los palés, puerta enclavada, paradas de emergencia; reposición de liners y túnel de las cintas en el Excel de riesgos.
