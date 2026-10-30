# PR310G – Pendientes del proyecto de paletizado

Documento vivo: lo que falta para aprobar y para sacar la A. Claude lo actualiza cada vez que hacemos algo o cambia una decisión (ver el registro de cambios al final).

- Última revisión: **30 oct 2026**, sobre el repo `Pallet-Project`, rama `cambios-peru-30-10`. Código de referencia: `PalletProgram_29-10/` (es el mismo que va dentro de `Pallet_Project.rspag`).
- Leyenda: ✅ hecho · 🟡 a medias · ❌ falta. Responsables: **J** = Joaquín, **P** = Peru, **J+P** = los dos.
- El reparto es una **propuesta del 30 oct**; hay que confirmarlo con Peru.

> Resumen: **hoy el proyecto no aprueba.** Faltan dos requisitos mínimos enteros (análisis de riesgos y valla) y otro a medias (mensaje al operario). No hay ningún extra terminado, y para la A hacen falta 3 extras cerrados más la máxima nota de calidad de código.

---

## 1. Estado contra el enunciado

### 1.1 Requisitos mínimos (sin los 9 no se aprueba)

| # | Requisito | Estado | Por qué / qué falta |
|---|---|---|---|
| 1 | Robot y layout para las dos cajas | ✅ | IRB 1600-10/1.45 con los palés en el perímetro. Punto flojo: la ventosa tiene una masa provisional de 1 kg, así que no está demostrado que la carga quede por debajo de 10 kg (T20). |
| 2 | Análisis de riesgos con la plantilla Excel | ❌ | No existe (T2). |
| 3 | Valla y layout de seguridad en RobotStudio, más los equipos explicados en la presentación | ❌ | No hay valla en la estación. La tabla de Safety HT25.pdf está bloqueada (T3, T6). |
| 4 | Señales configuradas y usadas (vacío y sensores de las cintas) | ✅ | 12 señales en EIO.cfg: `DO_Cup11…23`, `DI_Box1Arrived`, `DI_Box2Arrived`, `DI_EuroPalletReplaced`, `DI_HalfPalletReplaced`, `DI_LinersRefilled` y `AI_VacuumPressure`. |
| 5 | Programa con toda la secuencia, cualquier orden de llegada y alternancia | 🟡 | La lógica está completa y probada en simulación, pero **falta el mensaje al operario** que el enunciado pide para los dos palés (T1). |
| 6 | Sin colisiones en todo el proceso | 🟡 | La caja que lleva el robot puede chocar con las vecinas en la mesa (sin comprobar, T4). En el vídeo, colisión con `LinerStack` al coger el segundo liner (T5). |
| 7 | Instrucciones de movimiento adecuadas | ✅ | MoveJ en tránsito, MoveL en vertical, `fine` al coger y dejar, velocidades con nombre. Punto flojo: `z10` en todas partes sin nombre ni justificación (T16). |
| 8 | ~1 s de vacío antes del siguiente movimiento | ✅ | `WaitTime\InPos,VacuumTime` con `VacuumTime` = 1 s. |
| 9 | Nombres, legibilidad, indentación y comentarios | ✅ con fallos | `Main` contiene lógica, hay números sueltos, `cupsState` no se usa y el `DEFAULT` usa 9E+09 (T15–T18). |

### 1.2 Extras (2 aspectos = 1 punto; 3 aspectos = 2 puntos; uno a medias no cuenta)

| Extra | Estado | Qué falta |
|---|---|---|
| 1. Presión de vacío con señal analógica (caja 1: 4 bar, caja 2: 2 bar, ~4 bar/s) | ❌ | La AI está configurada pero el código no la usa y nada simula la subida de presión (T9). |
| 2. Mover objetos con smart components | 🟡 | Hechos `SC_Conveyor1` y `SC_Gripper` (caja 1). Faltan la cinta 2, la caja 2 en la ventosa, el bloque 3×2 y los liners (T10–T13). |
| 3. Detección de colisiones de RobotStudio | 🟡 | Existe "Conjunto de colisión_1". Falta dejar un ciclo limpio y grabarlo (T5, T14). |
| 4. PLr de la estación y PL de la solución | ❌ | Depende de T2 y T3 (T8). |

Propuesta: cerrar **colisiones, PLr/PL y presión analógica** como los tres extras y dejar los smart components como reserva.

### 1.3 Entregables (una entrega por grupo)

| Entregable | Estado | Qué falta |
|---|---|---|
| Documento con los extras que queremos que se evalúen | ❌ | T24. |
| Pack and Go (.rspag) de toda la célula | 🟡 | Existe uno intermedio del 30 oct, **guardado con RobotStudio 25.2** (T7, T26). |
| Station Viewer que ejecuta una secuencia completa | ❌ | T25. Hay que preguntar qué cuenta como "secuencia completa" (T6). |
| Descripción de los equipos que no están en la célula | ❌ | T24. |
| Excel de riesgos con riesgos identificados y soluciones | ❌ | T2. |

### 1.4 Requisitos personales
- [ ] Seminario de ética: asistir y participar activamente (J y P, P/F).
- [ ] Presentación oral (P/F): cada uno tiene que explicar toda la célula y todo el programa (ver `PR310G_practica_defensa.md`).

---

## 2. Tareas

Formato: **qué** · responsable · esfuerzo · depende de · cómo se comprueba que está hecha.

### Prioridad 0 – hoy o mañana
- [ ] **T6 Correo a My Legendi** · J · 20 min · nada · respuesta guardada en el registro de decisiones. Preguntas en la sección 4.
- [ ] **T7 Probar el Pack and Go en RobotStudio 2024.4** (ordenador de la sala o 2024.4 instalada en el portátil) · J+P · 30 min · nada · la estación abre, el controlador arranca y el programa corre. Si falla: rehacer la estación en la 2024.4 o pedir permiso para presentar con el portátil.

### Prioridad 1 – requisitos mínimos (sin esto no se aprueba)
- [ ] **T1 Mensaje al operario** (req. 5) · J · 1,5 h · toca `PalletProgram.mod` (pedir rama o coordinar con P) · al llenarse el europalé, el medio palé o vaciarse la pila de liners aparece un mensaje **una sola vez** y se enciende una salida (`DO_EuroPalletFull`, `DO_HalfPalletFull`, `DO_LinersEmpty`, que serían lámparas fuera de la valla). La salida se apaga en el reset correspondiente. Nada de `TPReadFK`, porque bloquea la otra línea.
- [ ] **T2 Excel de riesgos** (req. 2) · J · 4–6 h · layout definitivo y decisión de T3 · cubre operación normal, cambio de palés, atascos en las cintas (y el túnel de entrada), reposición de liners, mantenimiento y programación (T1 a 250 mm/s con dispositivo de habilitación), con riesgo, medida y riesgo residual.
- [ ] **T3 Valla y equipos de seguridad** (req. 3) · J · 2–4 h · T6 (tabla de Safety HT25) · valla en la estación con alturas y distancias justificadas (ISO 13857 para alcanzar por encima de la valla; ISO 13855 para la distancia de la cortina, S = K·T + C), puerta enclavada, paradas de emergencia y cortinas en los accesos de los palés. **Hay que decidir antes:** con una cortina normal, cambiar un palé para el robot entero y el "sigue con el otro producto" deja de ser cierto. Opciones: SafeMove (zonas vigiladas: el robot no entra en la zona del palé mientras la cortina está interrumpida) o una protección separada por cada lado. Al terminar, añadir la valla al grupo B del conjunto de colisión.
- [ ] **T4 Posible choque en la mesa** (req. 6) · J+P · 1–3 h · wobj y targets de P (CLAUDE.md: no se cambian sin acordarlo) · con el TCP a 1100 mm, la base de la caja que lleva el robot queda a 900 mm y el techo de las cajas puestas a 970 mm. Comprobarlo con 6 cajas estáticas en la mesa, una caja 2 enganchada a mano bajo Cup21 y el conjunto de colisión. Si choca: bajar la mesa a unos 650 mm (`TableHeight`, Z de `wobjTable` y modelo) y revisar el alcance.
- [ ] **T5 Colisión con `LinerStack`** (req. 6 y extra 3) · P (con T13) · 1–2 h · el modelo de la pila es fijo (10 liners) · ciclo de caja 2 sin colisiones. Lo más limpio son 10 liners sueltos y coger el de arriba.

### Prioridad 2 – extras para la A
- [ ] **T8 PLr/PL** (extra 4) · J · 2–3 h · T2 y T3 · para cada función de seguridad (puerta enclavada, parada de emergencia, cortina): S/F/P → PLr, diagrama de bloques, suma de PFHd (sensor + relé o PLC de seguridad + entrada de parada del robot 5,79·10⁻⁸) → PL ≥ PLr. Guía: `PR310G_EN_ISO_13849-1_Jokab.pdf`.
- [ ] **T9 Presión analógica** (extra 1) · J · 3–5 h · `VacuumControl` y el smart component de la ventosa de P · presión requerida por caja como CONST (4 y 2 bar), espera a `AI_VacuumPressure` con tiempo máximo y gestión de error. Simular la subida en un smart component (idea: `StopWatch` + `Expression` ≈ 4·t, sin probar) o como diga el profesorado. Con esto `cupsState` se usa o desaparece (T18).
- [ ] **T10 `SC_Conveyor2`** (extra 2) · J · 2–3 h · receta del apartado 10.1 de la memoria. Construirlo en una estación aparte y guardarlo como librería (.rslib), o editar la estación por turnos con P (las estaciones no se fusionan) · `DI_Box2Arrived` activado por el smart component.
- [ ] **T11 Caja 2 en la ventosa** (extra 2) · P · 1–2 h · `SC_Gripper` · segundo `LineSensor` bajo Cup21 con la misma señal `Grip`.
- [ ] **T12 Bloque 3×2 en la ventosa** (extra 2) · P · 2–3 h · T11 · decidir cómo: varios sensores, `SenseMultiple` o agrupar las cajas.
- [ ] **T13 Liners con smart components** (extra 2) · P · 1–2 h · resuelve también T5.
- [ ] **T14 Detección de colisiones** (extra 3) · J+P · 1–2 h · T4, T5 y la valla · grupo A = robot + herramienta; grupo B = cintas, mesa, soporte y pila de liners, palés y valla; casi colisión a 50 mm; ciclo completo limpio y grabado.

### Prioridad 3 – calidad de implementación y código (2 puntos)
- [ ] **T15 `Main` solo controla el flujo** · J · 45 min · sacar los tres resets del operario a sus propias PROC.
- [ ] **T16 Sin números mágicos** · J · 30 min · `WaitTime 0.1`, `v100,fine` del `MoveAbsJ`, `z10` (zonas con nombre o justificadas), y `VAR num box1State:=1` → `:=Box1Pos1` (lo mismo en `box2State` y `blockState`).
- [ ] **T17 `DEFAULT` de `ApproachHeight`** · J · 20 min · `ErrWrite` + `Stop` en vez de forzar un error de alcance con 9E+09.
- [ ] **T18 `cupsState`** · J · con T9 · usarla o quitarla.
- [ ] **T19 Pulsos cortos del operario** (opcional) · J · 1 h · ahora las DI solo se leen entre ciclos y un pulso de 0,5 s se pierde. Arreglo: `ISignalDI` + `TRAP` que guarde un flag, o señal memorizada. Si no se hace, hay que saber explicar la limitación.
- [ ] **T20 Masa y centro de gravedad de la ventosa** (req. 1) · J · 1 h · estimar desde la geometría (volumen × densidad), corregir `toolVacuum` y comprobar ventosa + bloque ≤ 10 kg en el diagrama de carga del IRB 1600.
- [ ] **T21 Sistema de referencia del `cog` de las `loaddata`** · J · 15 min · comprobar en el manual de RAPID (`loaddata`) si va respecto al TCP o a `tool0`. Ahora `loadBox1` usa [0,0,100], que solo es correcto respecto al TCP.
- [ ] **T22 Limpiar la estación** · P · 15 min · en la estación quedan procedimientos o trayectorias antiguos (`main`, `rBox1`, `Path_10`). RAPID no distingue mayúsculas, así que un `main` sincronizado chocaría con `Main`.
- [ ] **T23 Medidas de las cajas** (menor) · P · 10 min · el enunciado permite reducir 1 mm el largo y el ancho para que no se toquen; `Box1` es 250×500.

### Entregables y cierre
- [ ] **T24 Documento de extras y descripción de los equipos** · J · 1–2 h · T3 y T8 · escrito por nosotros, en inglés.
- [ ] **T25 Station Viewer** · P · 1 h · con todo lo demás terminado.
- [ ] **T26 Pack and Go final** en la versión que abra en la sala · P · 30 min · T7.
- [ ] **T27 Vídeo final** con la cámara más alejada (en la mesa la ventosa se sale del encuadre) · P.
- [ ] **T28 Ordenar el repo**: dejar `PalletProgram_29-10` como la versión buena y archivar `PalletProgram_28-10`, `PalletProgramV1` y los `.mod` de la raíz · P.
- [ ] **T29 No subir a Canvas** `CLAUDE.md` ni `MEMORIA_PROYECTO.md`. Los documentos de entrega, escritos por nosotros (Ouriginal).
- [ ] **T30 Práctica de la defensa** · J · ver `PR310G_practica_defensa.md` y `PR310G_preguntas_defensa.md`.

---

## 3. Riesgos para la nota

1. **No aprobar:** sin T1, T2 y T3 el proyecto es una F, por bien que funcione el robot.
2. **Versión de RobotStudio:** la estación se guardó con la 25.2 y las salas tienen la 2024.4. En general, una versión antigua no abre estaciones de una más nueva (T7).
3. **Colisiones en la demo:** la mesa (T4) y `LinerStack` (T5). Decir "es un efecto de la simulación" no sirve si la profesora lo ve en rojo.
4. **Seguridad incoherente con la secuencia:** cortina de luz frente a "el robot sigue con el otro producto" (T3).
5. **Pulsos del operario que se pierden** (T19).
6. **Carga del robot sin justificar:** la ventosa a 1 kg (T20) y la referencia del `cog` (T21).
7. **Ningún extra terminado:** hoy la nota máxima sería una E. Mejor 3 extras cerrados que 4 a medias.
8. **Calidad de código:** `Main` con lógica, números sueltos, variable sin uso, `DEFAULT` con 9E+09, ninguna gestión de errores. Además, en los `DEFAULT` de los `TEST`, la caja ya cogida se quedaría en la ventosa (caso al que no se llega, pero se puede preguntar).
9. **Defensa individual:** el layout, los wobj y los targets se hicieron con ayuda de Claude y el código lo ha llevado sobre todo Peru. La profesora pregunta a cada uno por todo, y el curso considera trampa el material creado con IA. Joaquín tiene que poder rehacerlo y explicarlo él solo (T30).
10. **Calendario:** examen de cinemática el 3 nov. La fecha de la presentación no está publicada (módulo de las semanas 44 a 47, como tarde hacia el 20 nov).

---

## 4. Preguntas para el profesorado (correo a My Legendi, T6)

- [ ] Tabla de Safety HT25.pdf (distancia y altura de la valla): está bloqueada en Canvas.
- [ ] Fecha y sala de la presentación, y versión de RobotStudio de las salas. ¿Podemos presentar con nuestro portátil y RobotStudio 2025?
- [ ] ¿Es válido coger la caja 2 con una sola copa de la ventosa estándar, con una válvula por copa?
- [ ] Extra 1: ¿cómo espera que se simule la señal analógica de presión (smart component, I/O Simulator, otra forma)?
- [ ] Station Viewer: ¿"una secuencia completa" es un ciclo de cada caja o los dos palés completos (72 cajas 2)?
- [ ] `loaddata`: ¿hace falta poner inercias o basta con masa puntual? ¿Qué masa y material damos al liner?

---

## 5. Calendario orientativo

| Cuándo | Qué |
|---|---|
| Vie 30 oct | T6 correo, T1 mensaje al operario, empezar T2 |
| Sáb 31 oct – lun 2 nov | Sobre todo cinemática; si sobra tiempo, T2 y practicar los bloques A–D |
| Mar 3 nov | Examen de cinemática |
| Semana del 3 nov | T3, T4, T8, T9, T10, T15–T17, T20 |
| Semana del 9 nov | T14, T24, T25, T26 y simulacro de la defensa |

---

## 6. Registro de cambios

- 2026-10-30 · Documento creado tras revisar el repo (rama `cambios-peru-30-10`), `MEMORIA_PROYECTO.md`, `CLAUDE.md`, el código de `PalletProgram_29-10`, el Pack and Go y el git log.
