# PR310G – Pendientes del proyecto de paletizado

Documento vivo: lo que falta para aprobar y para sacar la A. Claude lo actualiza cada vez que hacemos algo o cambia una decisión (ver el registro de cambios al final).

- Última revisión: **6 nov 2026**, sobre `main` (`f16301b`, Peru, 5 nov) + rama `joaquin-valla`. Código de referencia: `PalletProgram_29-10/` (con interrupciones y `TPWrite`).
- Leyenda: ✅ hecho · 🟡 a medias · ❌ falta. Responsables: **J** = Joaquín, **P** = Peru, **J+P** = los dos.
- El reparto es una propuesta; hay que confirmarlo con Peru.
- Este fichero fusiona la versión del repo (cambios de Peru del 5 nov) con la del proyecto de Claude (Excel, decisión C y valla). **Numeración:** la T36 es la de Peru (parpadeo del sensor); el tiempo de parada del robot pasa a **T42**.

> Resumen a 6 nov:
> - **Todavía no aprueba**, pero los requisitos 2 y 3 están cerca:
>   - Excel de riesgos completo (19 filas, fuera del repo). Falta que Joaquín lo revise, lo pase a sus palabras y aplique los cambios de la valla (lista en `Seguridad_valla/PR310G_valla_modelado.md` §5).
>   - **Valla y equipos modelados en una copia de práctica** (rama `joaquin-valla`, `Seguridad_valla/Pallet_Project_valla_practica.rspag`): radio 1950 → valla 2550, cortinas 3050, huecos para carretilla, alfombras SF5. Falta llevarlo a la estación de Peru (**T37**) y que Joaquín lo sepa rehacer.
> - Peru cerró el 5 nov: `TPWrite` (T1), interrupciones de los pulsadores (T19) y la decisión de T4 (falta que la confirme Joaquín).
> - **Falta:** T37, Measure, conjunto de colisión + ciclo (extra 3), envolvente (a = 2000), Highlighter y el extra 4.

## 0. Qué ha cambiado

**6 nov (Joaquín + Claude):** rama `joaquin-valla` con la copia de práctica de la valla (Pack and Go guardado con la 2024 e incluyendo los paquetes de ABB), el documento de la valla, tres capturas, este fichero fusionado y `PR310G_decisions_log.md`.

**5 nov, noche (Joaquín + Claude, RobotStudio 2024):** modelada en `Practica\Pallet_Project_practica` toda la seguridad (103 piezas). Decisiones: radio 1950, carretilla con huecos de 1800/1500, SF5 (alfombra; se recomienda escáner), `EStop_Inside`, topes de palé, rearme azul en el mismo puesto. No hay valla ni cortinas en la librería de esa instalación; la caja en español se llama "Tetraedro".

**5 nov, tarde (Peru, en `main`):** `TPWrite` junto a cada luz (T1); interrupciones `ISignalDI` + `TRAP` para europalé, medio palé y liners (T19); `Queue_EuroPallet` y `Queue_HalfPallet` con `Enqueue` en `Source.Executed` y `Repeater` → `Delete`; Pack and Go de las 20:23; decisión de T4; T36 (parpadeo del sensor) y T37 (juntar la seguridad de Joaquín).

**5 nov (Joaquín + Claude):** Excel `PR310G_Group2_Risk_Assessment.xlsx` con 19 filas y PLr por función; decisión C con PLr e; `Scope & assumptions`; `PR310G_datos_celula.md`; plantas v1 y v2; la estación abre en la 2024.

**1–5 nov (Peru):** cinta 2, ventosa con 6 sensores, liners como copias, vaciado de palés, reposición de liners, luces `DO_…Full` / `DO_LinerStackEmpty`, nuevo orden de la mesa y estado `Inicio_04-11`.

---

## 1. Estado contra el enunciado

### 1.1 Requisitos mínimos

| # | Requisito | Estado | Por qué / qué falta |
|---|---|---|---|
| 1 | Robot y layout | ✅ | Punto flojo: masa de la ventosa provisional e inercias a 0 (T20, T32). |
| 2 | Análisis de riesgos (Excel) | 🟡 casi | 19 filas. Falta revisión de Joaquín, pasarlo a sus palabras y **aplicar los cambios de la valla** (T2). |
| 3 | Valla y equipos de seguridad | 🟡 | **Modelado en la copia de práctica** (rama `joaquin-valla`). Falta pasarlo a la estación de Peru (T37), Measure y confirmar T (T42) y a (T39). |
| 4 | Señales | ✅ | 15 señales. |
| 5 | Secuencia completa | ✅ | Mensaje al operario: luz (DO) y `TPWrite` (T1). Pulsadores por interrupción (T19). |
| 6 | Sin colisiones | 🟡 | T4 decidida por P (justificar copas y cajas fuera del conjunto), falta que la confirme J; casi colisiones con `LinerStand`; falta comprobar contra la valla (T14). |
| 7 | Movimiento | ✅ con matiz | `z10` sin nombre y todo a `v100` (T16). |
| 8 | ~1 s de vacío | ✅ | |
| 9 | Nombres y legibilidad | ✅ con fallos | T15–T18, T31. |

### 1.2 Extras

| Extra | Estado | Qué falta |
|---|---|---|
| 1. Presión analógica | ❌ | De reserva (T9). |
| 2. Smart components | ✅ | Riesgo en la demo: copias reales (T33). |
| 3. Detección de colisiones | 🟡 | Añadir la valla, las cortinas y la puerta al grupo B (después de T37), umbral de casi colisión, ciclo completo y grabarlo (T14). |
| 4. PLr / PL | 🟡 | PL de SF1 hecho. Faltan PL de SF2–SF5 (SF5 nueva: alfombra/escáner, PFHd del fabricante) y diagramas de bloques (T8). |

### 1.3 Entregables

| Entregable | Estado | Qué falta |
|---|---|---|
| Documento de extras | ❌ | T24 |
| Pack and Go | 🟡 | El de `main` es del 5 nov (20:23) y sigue guardado con 25.2 (T7, T26). Falta juntar la seguridad (T37). |
| Station Viewer | ❌ | T25 |
| Descripción de equipos | ❌ | T24 (base: tabla de `Seguridad_valla/PR310G_valla_modelado.md` §3, en palabras propias) |
| Excel de riesgos | 🟡 casi | T2 |

### 1.4 Requisitos personales
- [ ] Seminario de ética (J y P).
- [ ] Presentación: cada uno explica toda la célula, el programa, los smart components y la seguridad.

---

## 2. Tareas

### Prioridad 0
- [ ] **T37 Juntar la celda de seguridad de Joaquín con la estación de Peru** · J+P · **siguiente paso** · la valla está en `Seguridad_valla/Pallet_Project_valla_practica.rspag` (rama `joaquin-valla`), hecha sobre la estación del 5 nov por la mañana; RobotStudio no fusiona estaciones. 1) Comparar los dos `Station/Pallet_Project.rsstnx` (XML dentro del `.rspag`): objetos de seguridad y posiciones, smart components (a la de práctica le faltan el `Repeater` de `SC_Conveyor1` y los `Enqueue` en `Source.Executed`), señales, lógica de estación y conjunto de colisión. 2) Plan probable: partir de la estación de Peru e importar la celda de seguridad (en la de práctica seleccionar las 103 piezas → *Guardar como biblioteca*; en la de Peru *Importar biblioteca*; las piezas se crearon en coordenadas de mundo, así que deberían caer en su sitio, comprobarlo). 3) Añadir la valla al grupo B. **No fusionar la estación de práctica en `main` como entregable:** la modeló Claude; Joaquín tiene que saber rehacerla.
- [ ] **T6 Correo a My Legendi** · J · 20 min · preguntas de la sección 4.
- [ ] **T7 Probar el Pack and Go en RobotStudio 2024.4** · J+P · 30 min · el de `main` sigue guardado con 25.2; la copia de práctica ya abre y se guarda en la 2024.
- [x] ~~T35 Subir el merge de `main`~~ · hecho (`b08affb`).

### Prioridad 1 – requisitos mínimos
- [ ] **T2 Excel de riesgos** · **J** · casi hecho.
  - [x] Plantilla, `Scope & assumptions`, 19 filas, PLr por función.
  - [ ] Revisión de Joaquín (sección 3) y **pasar a sus palabras**.
  - [ ] **Cambios de la valla** (filas 5, 6, 7, 8, 9, 10, 13, 14, 21 y `Scope & assumptions`): lista exacta en `PR310G_valla_modelado.md` §5. Incluye carretilla y SF5.
  - [ ] Añadir el riesgo de proceso de la memoria: confirmar el cambio sin haber cambiado el palé (sensor de presencia de palé).
  - [ ] Comprobar supuestos: a = 2000, T = 0,6 s, PL d de ISO 10218-1, descarga del IRC5, una copa para la caja 2.
- [ ] **T3 Valla y equipos** · **J**.
  - [x] Decisión C (cortina por hueco → Pluto → parada del IRC5, rearme manual fuera), PLr e.
  - [x] Radio 1950 → valla 2550, cortinas 3050; huecos de 1800 / 1500 / 740.
  - [x] Modelado en la copia de práctica (103 piezas, nombres, colores, grupo `Safety_Fence`), Pack and Go en la rama `joaquin-valla`.
  - [ ] Subgrupos `LightCurtains`, `Door`, `OperatorStations` y raíz `Safety` (pasos en `PR310G_valla_modelado.md` §2.6).
  - [ ] Medir con **Modelado → Medir → Punto a punto** y hacer capturas.
  - [ ] Joaquín tiene que saber rehacerlo a mano (defensa y uso de IA).
  - [ ] **T42** Tiempo de parada real del IRB 1600 (ABB 3HAC048645) para recalcular S (T = 0,6 s supuesto).
  - [ ] **T39** Envolvente vista de lado: altura máxima del TCP con carga frente a a = 2000.
  - [ ] **T40** Actualizar `PR310G_datos_celula.md` §1, §5 y §9b (lista en `PR310G_valla_modelado.md` §5).
- [x] **T1 Mensaje al operario** · P (con Claude) · ✅ 5 nov · `TPWrite` una sola vez junto a cada `SetDO …,1`, en inglés y diciendo qué hacer.
- [ ] **T4 Colisiones en la mesa** · J+P · 🟡 decidido por P el 5 nov, **falta que lo confirme J**:
  - (a) Se queda como está y se justifica: al dejar las 3 cajas de la fila cercana, tres copas sin vacío se apoyan 20 mm sobre el borde de la fila lejana, sin entrar; el robot solo baja y sube en vertical. Descartado: separar las filas, coger con `Cup11` y llenar primero la fila cercana.
  - (b) Las cajas no van en el conjunto de colisión (se tocan a propósito y son copias del `Source`); la trayectoria asegura que la caja que se lleva no pase sobre las puestas.
  - La prueba puntual (`Box2_Test` y un 2.º conjunto de colisión) se hace en la T14.

### Prioridad 2 – extras
- [ ] **T14 Detección de colisiones** · J+P · 1 h · después de T37 · añadir `Safety_Fence`, `LightCurtain_*` y `Door_Maintenance` a los objetos B; prueba puntual de T4 con `Box2_Test` (borrarla antes de que el robot coja el bloque); umbral de casi colisión (50 mm salta con `LinerStand` en los 4 liners de abajo: explicarlo, no esconderlo); grabar un ciclo con el panel de colisiones visible.
- [ ] **T8 PLr/PL** · **J** · 2 h.
  - [x] SF1: PLr e; PL e = 5,02·10⁻⁹ + 2·10⁻⁹ + 4,29·10⁻⁸ = 4,99·10⁻⁸.
  - [x] PLr de SF2 e, SF3 d, SF4 d, cintas d.
  - [ ] PL de SF2, SF3, SF4 y **SF5** (PFHd de la alfombra o del escáner del fabricante, no inventarlo).
  - [ ] Diagramas de bloques; **T38** verificar en el manual del IRC5 (3HAC047137-001, pág. 20) el emparejamiento de los PFHd (4,29·10⁻⁸ en vez del 5,79·10⁻⁸ de Jokab).
- [ ] **T41 Luces con Highlighter** · J · 30 min · verificar en pantalla que existe en la 2024 y conectar las 3 DO en *Lógica de estación*, sin tocar RAPID.
- [ ] **T9 Presión analógica** (reserva) · J · 3–5 h · CONST de 4 y 2 bar, espera a `AI_VacuumPressure` con tiempo máximo y gestión de error, subida simulada en un smart component. Resuelve también T18.
- [x] ~~T5, T10–T13~~ · hechas (Peru).

### Prioridad 3 – calidad de código
- [ ] **T15** `Main` solo controla el flujo · J · 45 min
- [ ] **T16** Sin números mágicos · J · 30 min (`WaitTime 0.1`, `v100,fine` del `MoveAbsJ`, `z10` y velocidades con nombre; ahora todo a `v100`)
- [ ] **T17** `DEFAULT` de `ApproachHeight` con `ErrWrite` + `Stop` · J · 20 min
- [ ] **T18** `cupsState` · J · 5 min
- [x] **T19 Pulsos cortos del operario** · P (con Claude) · ✅ 5 nov · `ISignalDI` + `TRAP` para europalé, medio palé y `DI_LinersRefilled`, probados.
- [ ] **T36 Parpadeo del sensor de la cinta 1** (de Peru) · J+P · a veces un 2.º `Source.Executed` ≈0,8 s después de levantar la caja 1 (copia de más). Causa probable: el `MoveJ` hacia la aproximación del palé baja la caja por debajo del plano (788–798) cuando aún está sobre la cinta. Posible arreglo: aproximación a altura de tránsito o punto intermedio.
- [ ] **T31** Retocar `CalibData.mod` · J · 45 min
- [ ] **T20** Masa y centro de gravedad de la ventosa · J · 1 h
- [ ] **T32** Inercias de las `loaddata` · J · 30 min
- [ ] **T21** Referencia del `cog` · J · 15 min
- [ ] **T22** Limpiar `main`, `rBox1` y `Path_10` de la estación · P · 15 min
- [ ] **T23** Medidas de las cajas −1 mm · P · 10 min

### Entregables, demo y cierre
- [ ] **T33** Lista de comprobación de la demo · J+P · cargar `Inicio_04-11`, borrar copias reales, pulsadores a 0, ensayar con un cambio de palé en directo.
- [ ] **T24** Documento de extras y descripción de equipos (en inglés, escrito por nosotros) · J
- [ ] **T25** Station Viewer · P
- [ ] **T26** Pack and Go final en la versión que abra en la sala · P
- [ ] **T27** Vídeo final · P
- [ ] **T28** Ordenar el repo · P
- [ ] **T29** No subir a Canvas `CLAUDE.md`, `MEMORIA_PROYECTO.md` ni los documentos de Claude
- [ ] **T30** Práctica de la defensa · J (bloques L y M; añadir valla 1950/2550/3050, SF5, carretilla, interrupciones de Peru)

---

## 3. Riesgos para la nota

1. **Uso de IA (el más grave):** el texto del Excel y la valla de la copia de práctica los ha hecho Claude. Hay que pasar el texto a palabras propias y que Joaquín sepa rehacer la valla y explicar cada pieza.
2. **Juntar estaciones (T37):** si se hace mal, se pierden los arreglos de Peru en los smart components. Partir de la estación de Peru.
3. **Coherencia Excel ↔ estación:** el Excel aún dice transpaleta, 1850/2450, "dead-end corridor" y alfombra opcional.
4. **Defender cada distancia:** 1950 (liner), 2550 (c = 600), 3050 (S = 1090 con T supuesto), anchos de hueco para carretilla, por qué SF5 es otra función.
5. **Supuestos sin verificar:** T = 0,6 s (T42), a = 2000 (T39), PFHd de la alfombra/escáner, anchos de carretilla, PFHd del IRC5 (T38).
6. **Alfombra + carretilla:** combinación poco creíble; tener el escáner como respuesta.
7. **Versión y demo frágil** (T7, T33). El Pack and Go de `main` sigue en 25.2.
8. **Defensa de Joaquín:** casi todo el RAPID y los smart components del 1 al 5 nov son de Peru; la profesora pregunta a cada uno por todo.
9. **Carga del robot, colisiones en la mesa, calidad de código** (T20, T21, T32, T4, T15–T18, T31).
10. **Calendario:** presentación sin fecha, como tarde hacia el 20 nov.

## 4. Preguntas para el profesorado (correo a My Legendi, T6)

- [ ] Tabla de Safety HT25.pdf (altura y distancia de la valla). Usamos ISO 13857, tabla 2.
- [ ] Fecha y sala de la presentación; versión de RobotStudio de las salas.
- [ ] ¿Vale coger la caja 2 con una sola copa?
- [ ] ¿Vale una luz (DO) + `TPWrite` como "mensaje al operario"?
- [ ] ¿Acepta SafeMove2 (PL d) según ISO 10218-2, o hay que llegar a PL e?
- [ ] Columna N de la plantilla de riesgos (OK/NOK sin cabecera): ¿hay que usarla?
- [ ] Extra 1: ¿cómo simular la señal analógica?
- [ ] Station Viewer: ¿qué es "una secuencia completa"?
- [ ] `loaddata`: ¿inercias o masa puntual? ¿Masa del liner?

## 5. Calendario orientativo

| Cuándo | Qué |
|---|---|
| Vie 6 nov | T37 (juntar estaciones), T2 (revisión + cambios de la valla), T6 correo, confirmar T4 |
| Fin de semana 7–8 nov | T14, T39, T41, T8 (SF2–SF5), subgrupos y Measure |
| Semana del 9 nov | T7, T15–T17, T31, T32, T20, T36 |
| Semana del 16 nov | T24, T25, T26, T27, T33 ensayo y simulacro |

## 6. Registro de cambios

- 2026-10-30 · Creado.
- 2026-11-05 (mañana) · Revisión de `main` (`d14f559`); plan de extras; T31–T35.
- 2026-11-05 (tarde, proyecto de Claude) · Decisión C; distancias; Excel empezado; 2024.
- 2026-11-05 (tarde, Peru en `main`) · T1 y T19 hechas; T4 decidida; T36 (parpadeo) y T37 (juntar la seguridad).
- 2026-11-05 (noche) · Excel completo; una cortina por hueco; valla y equipos modelados en la copia de práctica; radio 1950, carretilla, SF5, `EStop_Inside`, topes; nuevas T39, T40, T41.
- 2026-11-06 · Fusión de las dos versiones del documento; tiempo de parada renumerado a T42; rama `joaquin-valla` con la copia de práctica.
