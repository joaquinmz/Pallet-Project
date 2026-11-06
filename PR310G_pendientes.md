# PR310G – Pendientes del proyecto de paletizado

Documento vivo: lo que falta para aprobar y para sacar la A. Claude lo actualiza cada vez que hacemos algo o cambia una decisión (ver el registro de cambios al final).

- Última revisión: **5 nov 2026**, sobre `main` (`d14f559`, Peru, 5 nov 01:59). Código de referencia: `PalletProgram_29-10/`, idéntico al que va dentro de `Pallet_Project.rspag`.
- Leyenda: ✅ hecho · 🟡 a medias · ❌ falta. Responsables: **J** = Joaquín, **P** = Peru, **J+P** = los dos.
- El reparto es una propuesta; hay que confirmarlo con Peru.

> Resumen a 5 nov:
> - **El proyecto sigue sin aprobar.** Faltan el análisis de riesgos (req. 2) y la valla con los equipos de seguridad (req. 3), y casi todo lo que queda es de seguridad y documentación.
> - Lo bueno: los **smart components ya están completos** (extra 2 ✅) y la detección de colisiones está casi lista (extra 3).
> - Para la A, cerrar el **extra 3** y **uno más** (PLr/PL o presión analógica), además de la calidad de código.
> - **Casi todo lo hecho desde el 30 oct es de Peru.** Las tareas que quedan para Joaquín son las de la sección 2.

## 0. Qué ha cambiado desde el 30 oct (trabajo de Peru, 1–5 nov)

- **Cinta 2 con smart components** (`SC_Conveyor2`), igual que la cinta 1.
- **Ventosa con 6 sensores**, uno por copa (`LS_Cup11…23` con su `Attacher` y `Detacher`). Ya engancha la caja 1, la caja 2 y el bloque 3×2.
- **Liners como copias de 10 `Source`** (`SC_Liners`) en lugar del modelo fijo `LinerStack`: desaparece la colisión del 2.º liner.
- **Vaciado de palés en simulación:**
  - Europalé: `Queue_EuroPallet` (`Enqueue` en `Source.Executed`) + `Repeater` (`Count` 12) → `Delete` (5 nov; antes `DeleteAll`).
  - Medio palé: `Queue_HalfPallet` + `Repeater` (`Count` 72), y `Repeater_Liners` (`Count` 2) para los dos liners del palé.
  - El pulsador del operario está en cada smart component; un `AND` con la señal de "palé lleno" activa la DI del controlador.
- **Reposición de liners** con `LinersRefilled` AND `LinerStackEmpty`, probada el 5 nov con 6 medios palés seguidos.
- **RAPID:** `SetDO DO_EuroPalletFull / DO_HalfPalletFull / DO_LinerStackEmpty` a 1 al llenarse o vaciarse y a 0 al resetear y al arrancar. Son tres salidas nuevas, las luces para el operario.
- **Mesa:** primero la fila lejana de la cinta (y = 130) y después la cercana, siempre con X descendente, para que la caja que lleva el robot no cruce la fila ya puesta.
- **Planos de los sensores de las cintas a 10 mm de alto** (z 788…798), para que no detecten la caja colgando de la ventosa.
- **Estado vigente: `Inicio_04-11`.** No cargar `Inicio_03-11` ni los anteriores.
- **Vídeo del 1 nov** (`RobotStudio 11-01 comprimido.mp4`): llega al europalé lleno y a la capa 1 del medio palé.
- **Sigue igual:** no hay valla, ni Excel de riesgos, ni código de presión analógica. El Pack and Go sigue guardado con RobotStudio **25.2**, siguen en la estación los restos `main`/`rBox1`/`Path_10`, y siguen en el código los fallos de calidad (`Main` con lógica, números sueltos, `cupsState`, 9E+09).

---

## 1. Estado contra el enunciado

### 1.1 Requisitos mínimos (sin los 9 no se aprueba)

| # | Requisito | Estado | Por qué / qué falta |
|---|---|---|---|
| 1 | Robot y layout para las dos cajas | ✅ | IRB 1600-10/1.45. Punto flojo: la ventosa sigue con 1 kg provisional y las inercias a 0 (T20, T32). |
| 2 | Análisis de riesgos con la plantilla Excel | ❌ | No existe (T2). |
| 3 | Valla y equipos de seguridad en RobotStudio y en la presentación | ❌ | No hay valla en la estación. Safety HT25.pdf sigue bloqueado (T3, T6). |
| 4 | Señales configuradas y usadas | ✅ | 15 señales: `DO_Cup11…23`, `DO_EuroPalletFull`, `DO_HalfPalletFull`, `DO_LinerStackEmpty`, `DI_Box1Arrived`, `DI_Box2Arrived`, `DI_EuroPalletReplaced`, `DI_HalfPalletReplaced`, `DI_LinersRefilled` y `AI_VacuumPressure` (todavía sin usar). |
| 5 | Secuencia completa, cualquier orden y alternancia | ✅ | Lógica completa y probada con los dos palés y la reposición de liners. Mensaje al operario: luz (DO) y `TPWrite` (T1, 5 nov). Los pulsadores van por interrupción (T19). |
| 6 | Sin colisiones | 🟡 | Resuelto: los liners ya son copias, así que no hay colisión con `LinerStack`. (a) Copas apoyadas 20 mm sobre la otra fila de la mesa y (b) cajas fuera del conjunto de colisión: decidido justificarlo (T4, falta confirmación de J); (c) casi colisiones esperadas con `LinerStand` al coger los 4 liners de abajo (T4). |
| 7 | Instrucciones de movimiento | ✅ | Punto flojo: `z10` en todas partes sin nombre ni justificación (T16). |
| 8 | ~1 s de vacío | ✅ | `WaitTime\InPos,VacuumTime`. |
| 9 | Nombres, legibilidad, comentarios | ✅ con fallos | Siguen `Main` con lógica, números sueltos, `cupsState` sin uso y 9E+09 (T15–T18). En `CalibData` faltan comentarios por wobj, se mezclan tabuladores y espacios, y el comentario de `loadBox2` está desactualizado (T31). |

### 1.2 Extras (2 aspectos = 1 punto; 3 aspectos = 2 puntos; uno a medias no cuenta)

| Extra | Estado | Qué falta |
|---|---|---|
| 1. Presión de vacío analógica | ❌ | Nada nuevo (T9). |
| 2. Smart components | ✅ | Cintas, ventosa, bloque, liners, vaciado de palés y reposición de liners, probados por Peru del 1 al 5 nov. Riesgo en la demo: las copias reales que aparecen al cargar el estado (T33). |
| 3. Detección de colisiones | 🟡 casi | Conjunto A = robot + herramienta; B = cintas, mesa, soporte y palés. Ciclo completo sin colisiones reales, solo casi colisiones esperadas. Falta: añadir la valla al grupo B, decidir qué hacer con las casi colisiones con `LinerStand` y enseñarlo en el vídeo y la demo (T14). |
| 4. PLr / PL | ❌ | Depende de T2 y T3 (T8). |

**Plan de extras (cambia respecto al 30 oct):** smart components ✅ + colisiones (cerrar T14) + **PLr/PL**. PLr/PL va unido a los requisitos 2 y 3, que hay que hacer de todos modos. La presión analógica queda como cuarto extra de reserva si sobra tiempo.

### 1.3 Entregables

| Entregable | Estado | Qué falta |
|---|---|---|
| Documento con los extras elegidos | ❌ | T24. |
| Pack and Go | 🟡 | El de `main` es del 5 nov (20:23, con las interrupciones y el `Repeater` de `SC_Conveyor1`) y sigue **guardado con 25.2** (T7, T26). |
| Station Viewer con una secuencia completa | ❌ | T25 (preguntar qué es "secuencia completa", T6). |
| Descripción de los equipos fuera de la célula | ❌ | T24. |
| Excel de riesgos | ❌ | T2. |

### 1.4 Requisitos personales
- [ ] Seminario de ética: asistir y participar (J y P).
- [ ] Presentación: cada uno explica toda la célula y todo el programa. Ahora también **todos los smart components**, que ha hecho Peru (ver `PR310G_practica_defensa.md`).

---

## 2. Tareas

Formato: **qué** · responsable · esfuerzo · depende de · cómo se comprueba.

### Prioridad 0 – esta semana
- [ ] **T6 Correo a My Legendi** · J · 20 min · preguntas de la sección 4. Si ya se ha enviado, apuntar la respuesta en el registro de decisiones.
- [x] **T7 Probar el Pack and Go en RobotStudio 2024.4** (✅ 6 nov: Joaquín confirma que en la 2024.4 el controlador arranca y el ciclo corre) · J+P · 30 min · sigue guardado con 25.2 · abre, el controlador arranca y el ciclo corre. Ahora es aún más importante: hay muchos smart components y rehacerlos en la 2024.4 sería muy caro. · 🟡 **Pista (6 nov):** el `.rspag` de Joaquín está guardado con **24.4.11080** y parte del Pack and Go de Peru de 25.2 (`d14f559`): lo abrió en la 2024.4 con los 54 smart components, todas sus conexiones y la lógica de estación intactas. Confirmado por Joaquín el 6 nov: el controlador arrancó y el ciclo corría.
- [x] **T35 Subir el merge de `main`** (hecho: `b08affb` está en `origin/main`, comprobado el 5 nov) · J · 5 min · el `main` local tiene el merge de `docs-joaquin` (`b08affb`) sin subir (`ahead 2`) · `git push` desde Windows; GitHub muestra `PR310G_pendientes.md` en `main`.

- [x] **T37 Juntar la celda de seguridad de Joaquín con la estación de Peru** · P · **siguiente paso (6 nov)** · Comparado el 6 nov `Pallet_Project_valla.rspag.zip` (Joaquín, guardado con 24.4) con `Pallet_Project.rspag` de `main` (5 nov, 20:23): **base de Joaquín = Pack and Go `d14f559`** (RAPID idéntico al de ese commit, sin interrupciones ni `TPWrite`). Lo que añade: 121 piezas sin lógica (`ComponentInstance`, todas con transformación identidad, geometría ya en coordenadas de mundo): grupo `Safety_Fence` (paneles, postes, pasillos y túneles de las cintas), `Door_Maintenance` + `DoorSensor_Eden_*`, 6 `EStop_*`, `OperatorStation_*`, `ResetButton_*`, cortinas `LightCurtain_*` (cinta 1 y 2, palés, liners), `Muting*`, `SafetyMat_*`, `PalletStop_*`, `Bumper_*`, `Lamp_*`, `Button_*` e `IRC5_Cabinet`. **Ningún smart component, señal ni conexión nueva**: las luces y pulsadores son solo dibujo. Igual en las dos: lógica de estación, señales de los SC, propiedades (`Count`, etc.), posiciones de cintas/mesa/palés, estados guardados (hasta `Inicio_04-11`), conjunto de colisión (la valla aún no está en B) y `EIO`/`MOC`/`SYS`/`MMC`. Lo que le falta a la de Joaquín (solo smart components, 1 componente y 5 conexiones): en `SC_Conveyor1` el `Repeater` (`Count` 12), `LogicGate_4.Output` → `Repeater.Execute` (en vez de → `Queue_EuroPallet.DeleteAll`), `Repeater.Output` → `Queue_EuroPallet.Delete`, borrar `LogicGate_2.Output` → `Queue_EuroPallet.Enqueue` y añadir `Source.Executed` → `Queue_EuroPallet.Enqueue`; en `SC_Conveyor2` borrar `LogicGate.Output` → `Queue_HalfPallet.Enqueue` y añadir `Source.Executed` → `Queue_HalfPallet.Enqueue`. **Plan cambiado:** partir de la de **Joaquín** (importar 121 piezas como biblioteca sería mucho más trabajo), rehacer esos cambios, cargar el programa de `PalletProgram_29-10/PalletProgramV1.pgf`, cargar `Inicio_04-11`, probar un ciclo con los dos cambios de palé y hacer Pack and Go. Después, valla al grupo B del conjunto de colisión (T14). **✅ Hecho el 6 nov:** `Pallet_Project_6-11.rspag` + `PalletProgram_6-11/` (comprobado en el XML: conexiones de los smart components iguales a las de Peru, `Repeater` `Count` 12, 121 piezas de seguridad, RAPID igual al de la carpeta, 12 estados). Guardado con 25.2. Queda la prueba del ciclo con los dos cambios de palé.

### Prioridad 1 – requisitos mínimos
- [ ] **T2 Excel de riesgos** (req. 2) · **J** · 4–6 h · decisión de T3.
  - Modos: operación normal, cambio de palés, reposición de liners, atascos en las cintas (y el túnel de entrada), mantenimiento y programación (T1 a 250 mm/s con dispositivo de habilitación).
  - Para cada riesgo: riesgo, medida y riesgo residual.
  - Añadir el riesgo de proceso que apunta la memoria: confirmar el cambio sin haber cambiado el palé. Medida posible: sensor de presencia de palé.
- [ ] **T3 Valla y equipos de seguridad** (req. 3) · **J** · 2–4 h · T6.
  - Valla con altura y distancia justificadas (ISO 13857; cortinas según ISO 13855, S = K·T + C), puerta enclavada, paradas de emergencia y cortinas o escáner en los accesos de los palés y de la reposición de liners.
  - **Decidir primero** cómo sigue trabajando el robot con el otro producto mientras se cambia un palé: SafeMove (zonas vigiladas) o una protección separada por lado. La memoria ya lo plantea así.
  - Al terminar, añadir la valla al grupo B del conjunto de colisión.
  - Los pulsadores del operario (`EuroPalletReplaced`, `HalfPalletReplaced`, `LinersRefilled`) y las tres luces van **fuera** de la valla: dibujarlos o describirlos.
- [x] **T1 Mensaje al operario** (req. 5) · P (con Claude) · ✅ 5 nov · `TPWrite` una sola vez junto a cada `SetDO ...,1` (europalé lleno, medio palé lleno, pila de liners vacía), en inglés y diciendo qué hacer. Probado: el del europalé sale una vez en *Controlador* → *Ventana de operador* y el robot sigue con la caja 2.
- [ ] **T4 Colisiones en la mesa** (req. 6) · J+P · 🟡 decidido por P el 5 nov, falta que lo confirme J:
  - (a) **Se queda como está y se justifica.** Al dejar las 3 cajas de la fila cercana, tres copas sin vacío se apoyan 20 mm sobre el borde de la fila lejana, sin entrar; el robot solo baja y sube en vertical (no arrastra) y las copas de fuelle absorben tolerancias. Descartado: separar las filas (haría falta 160 mm y el bloque 3×2 ya no se coge entero), coger con `Cup11` (las copas libres irían sobre la cinta 2, a la altura de la caja que espera) y llenar primero la fila cercana (habría que subir el tránsito de la caja 2 unos 120 mm, ≈1 min más por medio palé).
  - (b) **Las cajas no van en el conjunto de colisión** (se tocan a propósito: bloque 3×2, cajas pegadas en el palé, la ventosa toca la que coge; además son copias que crea el `Source` durante la simulación). Que la caja que se lleva no pase sobre las puestas lo asegura la trayectoria (fila lejana primero, X descendente; base a 900, techos a 970) y se enseña con el rastreo del TCP.
  - La prueba puntual para enseñarlo (caja estática `Box2_Test` en la fila lejana y un 2.º conjunto de colisión) se hace en la T14.

### Prioridad 2 – extras para la A
- [ ] **T14 Cerrar la detección de colisiones** (extra 3) · J+P · 1 h · T3 y T4.
  - Prueba puntual de T4: copia estática de `Box2` (`Box2_Test`) en un hueco de la fila lejana de la mesa (elegir el que tenga como vecino la última caja que se deja), 2.º conjunto de colisión (A = herramienta, B = `Box2_Test`), reproducir hasta la 6.ª caja y pausar: debe salir solo el contacto de las copas al dejar la fila cercana. Borrar `Box2_Test` y el conjunto 2 **antes** de que el robot coja el bloque (los sensores de la ventosa la engancharían). Hace falta saber dónde está el origen de la pieza `Box2` para colocarla.
  - Valla en el grupo B.
  - Decidir el umbral de casi colisión. Hoy, 50 mm hace saltar avisos con `LinerStand` al coger los 4 liners de abajo, que son esperados. Bajar el umbral para ocultarlos puede parecer trampa; mejor explicarlo.
  - Grabar un ciclo con el panel de colisiones visible.
- [ ] **T8 PLr/PL** (extra 4) · **J** · 2–3 h · T2 y T3 · para cada función de seguridad: S/F/P → PLr, diagrama de bloques, suma de PFHd (sensor + relé o PLC de seguridad + entrada de parada del robot 5,79·10⁻⁸) → PL ≥ PLr. Guía: `PR310G_EN_ISO_13849-1_Jokab.pdf`.
- [ ] **T9 Presión analógica** (extra 1, de reserva) · **J** · 3–5 h · `VacuumControl` y `SC_Gripper` (P) · presión requerida por caja como CONST (4 y 2 bar), espera a `AI_VacuumPressure` con tiempo máximo y gestión de error, y simular la subida en un smart component. Se pueden reutilizar `Expression`, `Timer` o `Counter`; no está probado. Resuelve también T18.
- [x] ~~T10 `SC_Conveyor2`~~ · hecho por P (1 nov). Joaquín debe saber rehacerlo (práctica, bloque H).
- [x] ~~T11 Caja 2 en la ventosa~~ · hecho por P (1 nov), con 6 sensores.
- [x] ~~T12 Bloque 3×2~~ · hecho por P (1 nov).
- [x] ~~T13 Liners con smart components~~ · hecho por P (4 nov), con `SC_Liners` y 10 `Source`.
- [x] ~~T5 Colisión con `LinerStack`~~ · resuelta (los liners son copias).

### Prioridad 3 – calidad de implementación y código (2 puntos)
- [ ] **T15 `Main` solo controla el flujo** · J · 45 min · sacar los tres resets del operario (con sus `SetDO`) a sus propias PROC.
- [ ] **T16 Sin números mágicos** · J · 30 min · `WaitTime 0.1`, `v100,fine` del `MoveAbsJ`, `z10` (zonas con nombre o justificadas), `VAR num box1State:=1` → `:=Box1Pos1` (lo mismo en `box2State` y `blockState`).
- [ ] **T17 `DEFAULT` de `ApproachHeight`** · J · 20 min · `ErrWrite` + `Stop` en vez de 9E+09.
- [x] **T18 `cupsState`** (✅ 6 nov: quitada, no se leía) · J · con T9 o quitarla · 5 min.
- [x] **T19 Pulsos cortos del operario** · P (con Claude) · ✅ · **confirmado el 5 nov** (vídeo de las 16:37): si el robot está en mitad de un bloque, RAPID pierde el pulso; las cajas se borran pero `DO_…Full` sigue a 1, y una 2.ª pulsación borraba 12 cajas más. Hecho con `ISignalDI` + `TRAP` (apaga la DO en el acto y deja una bandera para `Main`): europalé, medio palé y `DI_LinersRefilled` hechos y probados (5 nov, el último con 6 medios palés seguidos).
- [ ] **T36 Parpadeo del sensor de la cinta 1** · J+P · a tener en cuenta · el analizador de señales (5 nov) muestra a veces un 2.º `Source.Executed` ≈0,8 s después de levantar la caja 1: sale una copia de más y la cola del europalé puede quedar con una entrada de más (una caja sin borrar en el palé). Causa probable: el `MoveJ` hacia la aproximación del palé (TCP 850 mm) baja la caja por debajo del plano (788–798) cuando aún está sobre la cinta. Posible arreglo: aproximación a los palés a altura de tránsito o punto intermedio. Llevaba un rato sin fallar cuando se dejó.
- [x] **T31 Retocar `CalibData.mod`** (✅ 6 nov, P con Claude: cabecera, un comentario por wobj con origen y ejes comprobados en la vista 3D, solo espacios, comentario de `loadBox2` corregido) (apuntado por P el 4 nov) · J · 45 min · un comentario por wobj (dónde está el origen y hacia dónde van los ejes), solo espacios o solo tabuladores, y corregir el comentario de `loadBox2`, que dice "rows ascending Y" cuando ahora va primero la fila lejana.
- [x] **T20 Masa y centro de gravedad de la ventosa** (✅ 6 nov: 4,7 kg, CdG [0,0,100], medidas de Cowork y supuesto de piezas aligeradas; falta el diagrama de carga) (req. 1) · J · 1 h · volumen × densidad; comprobar ventosa + 2,4 kg ≤ 10 kg en el diagrama de carga.
- [x] **T32 Inercias de las `loaddata`** (✅ 6 nov: calculadas como bloques macizos, también la de la ventosa; J5 y J6 dentro de los límites del product spec; diagrama de carga solo con muñeca vertical, ver memoria) · J · 30 min · caja maciza: Ix = m(b²+c²)/12, etc., o justificar la masa puntual. Comprobar también el `cog` de `loadBox2Stack` respecto al TCP de `PickTableStack`.
- [ ] **T21 Referencia del `cog`** · J · 15 min · comprobar en el manual de RAPID si va respecto al TCP o a `tool0`.
- [ ] **T22 Limpiar la estación** · P · 15 min · siguen `main`, `rBox1` y `Path_10` en la estación (comprobado en el Pack and Go del 4 nov).
- [ ] **T23 Medidas de las cajas** (menor) · P · 10 min · reducir 1 mm el largo y el ancho, como permite el enunciado.

### Entregables, demo y cierre
- [ ] **T33 Lista de comprobación antes de la demo** · J+P · 20 min · cargar `Inicio_04-11` (nunca `Inicio_03-11`), borrar las copias reales que aparezcan en el panel *Diseño* (`Box1_xxx`, `Box2_xxx`; nunca las plantillas), poner los pulsadores a 0 y reiniciar RobotStudio si el I/O Simulator no se refresca. Ensayar la demo de 10 minutos con un **cambio de palé en directo**.
- [ ] **T24 Documento de extras y descripción de los equipos** · **J** · 1–2 h · T3 y T8 · escrito por nosotros, en inglés.
- [ ] **T25 Station Viewer** · P · 1 h.
- [ ] **T26 Pack and Go final** en la versión que abra en la sala · P · T7.
- [ ] **T27 Vídeo final** hasta llenar los dos palés, con la cámara alejada · P.
- [ ] **T28 Ordenar el repo** (`PalletProgram_29-10` como versión buena; archivar `_28-10`, `V1` y los `.mod` de la raíz) · P.
- [ ] **T29 No subir a Canvas** `CLAUDE.md`, `MEMORIA_PROYECTO.md` ni este documento.
- [ ] **T30 Práctica de la defensa** · J · ver `PR310G_practica_defensa.md` y `PR310G_preguntas_defensa.md`. Ahora incluye entender y rehacer los smart components.

---

## 3. Riesgos para la nota

1. **No aprobar:** sin el Excel (T2) y la valla (T3) es una F. Son ahora el cuello de botella y los dos son de Joaquín.
2. **Versión de RobotStudio:** el Pack and Go sigue en la 25.2. Si no abre en la 2024.4, rehacer los smart components es muy caro (T7).
3. **Demo frágil:** copias reales al cargar el estado, `Detacher` que suelta lo último que detectó, el I/O Simulator que no se refresca. Peru conoce los trucos; Joaquín también tiene que conocerlos (T33).
4. **Defensa de Joaquín:** casi todo lo hecho del 1 al 5 nov es de Peru (smart components y RAPID). La profesora pregunta a cada uno por todo. La seguridad (T2, T3, T8) y la calidad del código (T15–T17, T31, T32) son el trabajo propio que Joaquín puede defender.
5. **Seguridad coherente con la secuencia:** el robot sigue trabajando mientras se cambia un palé (T3).
6. **Carga del robot sin justificar** (T20, T21, T32).
7. **Colisiones en la mesa:** las copas tocan la otra fila y caja contra caja no se comprueba (T4).
8. **Calidad de código:** sin cambios desde el 30 oct (T15–T18, T31).
9. **Uso de IA:** los documentos de entrega, escritos por nosotros (Ouriginal); nada de CLAUDE.md ni de la memoria en Canvas.
10. **Calendario:** la presentación sigue sin fecha (módulo de las semanas 44 a 47, como tarde hacia el 20 nov).

---

## 4. Preguntas para el profesorado (correo a My Legendi, T6)

- [ ] Tabla de Safety HT25.pdf (distancia y altura de la valla).
- [ ] Fecha y sala de la presentación, y versión de RobotStudio de las salas. ¿Podemos presentar con portátil y RobotStudio 2025?
- [ ] ¿Es válido coger la caja 2 con una sola copa de la ventosa estándar?
- [ ] ¿Vale una luz (DO) como "mensaje al operario" o quiere un mensaje en el FlexPendant?
- [ ] Extra 1: ¿cómo espera que se simule la señal analógica?
- [ ] Station Viewer: ¿"una secuencia completa" es un ciclo de cada caja o los dos palés llenos?
- [ ] `loaddata`: ¿inercias o masa puntual? ¿Masa y material del liner?

---

## 5. Calendario orientativo (desde el 5 nov)

| Cuándo | Qué |
|---|---|
| Jue 5 – vie 6 nov | T35 push, T6 correo, T7 prueba en la 2024.4, T1 `TPWrite`, decidir T3, empezar T2 |
| Fin de semana 7–8 nov | T2 Excel, T8 PLr/PL, práctica (bloques A–D y H) |
| Semana del 9 nov | T3 valla en RobotStudio, T14 colisiones, T4, T15–T17, T31, T32, T20 |
| Semana del 16 nov | T24 documento, T25 Station Viewer, T26 Pack and Go final, T27 vídeo, T33 ensayo y simulacro. T9 presión si sobra tiempo. |

---

## 6. Registro de cambios

- 2026-10-30 · Documento creado tras revisar el repo (rama `cambios-peru-30-10`).
- 2026-11-05 · Revisión de `main` (`d14f559`):
  - Smart components completos (extra 2 ✅); T5 y T10–T13 cerrados; T1 casi hecho (luces DO).
  - Plan de extras cambiado a smart components + colisiones + PLr/PL.
  - Nuevas tareas T31 (`CalibData`), T32 (inercias), T33 (lista para la demo) y T35 (push del merge).
  - Calendario rehecho.
