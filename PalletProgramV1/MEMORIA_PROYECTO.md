# PR310G – Pallet Project: memoria de decisiones

Resumen de lo decidido y hecho en la estación `Pallet_Project` (RobotStudio 2025, controlador IRC5 RobotWare 6.13.02), actualizado el 28 oct 2026 (noche). Coordenadas en mm, respecto al mundo de la estación salvo que se diga otra cosa.

Autores: Peru Mendivil y Joaquín Moreno (Group 2, JMPM). Repo: github.com/joaquinmz/Pallet-Project (rama `main` = Peru, `second-main` = caja 2 de Joaquín, `cambios-peru-28-10` = trabajo de Peru del 28 oct). **La versión de trabajo actual del programa es la carpeta `PalletProgram_28-10`** (guardada desde RobotStudio); `PalletProgramV1` tiene la versión anterior y esta memoria.

## 1. Robot y herramienta

| Elemento | Valor | Motivo |
|---|---|---|
| Robot | IRB 1600-10/1.45 | Alcance necesario ≈ 1,19 m < 1,45 m; carga ventosa + 2,4 kg ≤ 10 kg; misma huella que la de 6 kg |
| Base del robot | En (0, 0, 0), **girada 135° en Z** | El límite ±180° del eje 1 queda en −45° del mundo (hueco entre europalé y medio palé); la cadena caja 2 y los liners no lo cruzan |
| Base de la tarea | No se movió (= mundo de la estación) | Los wobj y targets no cambian; `wobj0` ya no está alineado con la base del robot |
| Herramienta | `toolVacuum`, TCP (0, 0, 175), en el plano de los labios de las copas | Medido en RobotStudio: labios Z 644,88 − cara de montaje 469,88 |
| Copas | 6 copas Ø50 en x = −160 / 0 / +160, y = ±100 | Medido |
| Masa ventosa | 1 kg provisional | **Pendiente de estimar** |

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

## 9. Estado del código (`PalletProgram_28-10/PalletProgram.mod`, 28 oct noche)

Hecho:
- Encabezado del programa, secciones comentadas, nombres según la convención.
- `ProcessBox1` (máquina de estados de 6 posiciones × 2 capas, pone `euroPalletFull`).
- `VacuumControl`, `InitSignals`, `ApproachPoint(target, wobj, cups, load)` con `GripLoad`.
- `FUNC bool Box1Ready()` y `Box2Ready()`; `Box2Ready()` ya usa `NOT tableFull`.
- `ProcessBox2`: 6 posiciones en la mesa (sin cambios). En `Box2LastPos`: si `halfPalletFull` → `tableFull:=TRUE` (el bloque espera); si no → `TransferStack`. En los dos casos vuelve a `Box2Pos1`.
- `PROC TransferStack`: coge el bloque (`CupsAllOn`, `loadBox2Stack`) y lo deja según `blockState`:
  - `BlockPos1` (0, +260), `BlockPos2` (+390, +260): fila lejana primero; `BlockPos3` (0, 0), `BlockPos4` (+390, 0).
  - Z = `(box2Layer-1)*Box2Height + linersPlaced*LinerHeight`.
  - En `BlockPos4` (capa completa): si `box2Layer=Box2MaxLayers` → `halfPalletFull:=TRUE`; si no → liner (`PickLiner` Z −(TotalLiners−linersLeft)·LinerHeight, `PlaceLiner` con la misma Z que la capa) **antes** de `Incr box2Layer`; `Incr linersPlaced`, `Decr linersLeft`. Vuelve a `BlockPos1`.
- `Main`: solo los dos `IF` de reset del operario (falta el resto, ver abajo).

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

`Main` completo (lógica acordada, falta escribir arranque, bucle y elección de caja):

```
PROC Main()
    InitSignals;                 ! primero: sin AliasIO, VacuumControl falla
    VacuumControl CupsAllOff;
    GripLoad load0;
    ! MoveAbsJ Home (pendiente)
    WHILE TRUE DO
        IF Box1Ready() AND ((NOT Box2Ready()) OR lastBox=2) THEN
            ProcessBox1;  lastBox:=1;
        ELSEIF Box2Ready() THEN
            ProcessBox2;  lastBox:=2;
        ENDIF
        ! los dos IF de reset (ya escritos)
        WaitTime 0.1;            ! evita que el bucle gire sin parar si no hay cajas
    ENDWHILE
ENDPROC
```

Claves:
- `lastBox` (VAR num := 2, sin declarar todavía): si llegan las dos a la vez empieza la caja 1.
- La alternancia solo se aplica si la otra caja también puede procesarse (evita el bloqueo con un palé lleno).

## 10. Pendiente

Código:
- `Main`: arranque, `WHILE TRUE`, elección de caja con `lastBox` (declararla), resets dentro del bucle, `WaitTime 0.1`.
- Mayúsculas: `totalLiners` → `TotalLiners` (declaración de `linersLeft`); `Decr LinersLeft` → `linersLeft`. Compila igual (RAPID no distingue mayúsculas), pero no sigue la convención.
- Pila de liners vacía (`linersLeft=0`): ahora nada detiene al robot. Aviso al operario / señal de reposición.
- Opcional: quitar `linersPlaced` (siempre vale `box2Layer-1`).
- Comprobar orden de llenado de la mesa (memoria: Y ascendente, X descendente; el código empieza por Y=130).
- Altura de tránsito: `SafeHeight` es relativa al target; comprobar que el bloque no choca con la pila de liners (tope z 600) en el trayecto mesa → medio palé.
- `Home` como `CONST jointtarget` con `MoveAbsJ`; velocidades como constantes con nombre.
- Ordenar carpetas: `PalletProgram_28-10` es la versión buena; decidir si `PalletProgramV1` se borra o se sustituye.

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
- Seguridad: cortinas de luz en los huecos de los palés, puerta enclavada, paradas de emergencia; reposición de liners y túnel de las cintas en el Excel de riesgos.
