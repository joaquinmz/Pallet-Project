# PR310G – Decisions log

Registro de decisiones del proyecto de paletizado (Joaquín y Peru). Una línea por decisión: fecha · decisión · motivo. Lo que esté como PENDIENTE aún no se ha decidido. Claude lo mantiene al día cuando tomamos o cambiamos una decisión.

## Decisiones

- 2026-10-26 · Objetivo: nota A en el proyecto · pesa 3 de 6 hp del curso.
- ≤2026-10-28 · Robot IRB 1600-10/1.45 con IRC5 y RobotWare 6.13.02 · alcance necesario ≈ 1,19 m < 1,45 m; carga máxima ventosa + 2,4 kg ≤ 10 kg (masa de la ventosa pendiente de confirmar).
- ≤2026-10-28 · Base del robot girada 135° en Z; el task frame se queda en el mundo · el límite de ±180° del eje 1 queda en −45°, en el hueco entre los palés; `wobj0` = mundo.
- ≤2026-10-28 · Layout: europalé en +X, medio palé en −Y, las dos cintas entran desde +Y, mesa junto a la cinta 2, soporte de liners bajo (500 mm) · palés y liners en el perímetro, se cambian desde fuera; el trayecto cinta 2 → mesa es el más repetido.
- ≤2026-10-28 · Herramienta estándar de ElegantTools, TCP (0, 0, 175), una válvula por copa · la caja 2 se coge con la copa de esquina Cup21 porque con la central se pisarían las cajas vecinas.
- ≤2026-10-28 · Un wobj por estación con el origen en la esquina del lado del robot, X por el lado largo e Y alejándose del robot · coordenadas positivas, un target base por estación más `Offs`.
- 2026-10-28 · Confirmación del operario con una DI por palé y `IF` en `Main` (no `WaitDI` ni `TPReadFK`) · el aviso de una línea no bloquea la otra.
- 2026-10-28 · Dos contadores para la caja 2 (`box2State` en la mesa, `blockState` en el palé) y flag `tableFull` · el bloque puede esperar en la mesa con el palé lleno.
- 2026-10-29 · MoveJ en el tránsito, MoveL solo en vertical, altura de aproximación por estación con `ApproachHeight` (tránsito a 1100 en cintas y mesa, 850 en palés, mínimo 250) · errores 50050 (fuera de alcance) y 50024/50027 (MoveL en el tránsito).
- 2026-10-29 · Pila de liners vacía: `linerStackEmpty` (aviso), `linerMissing` (la caja 2 espera) y `DI_LinersRefilled` · el robot no para hasta que de verdad falta un liner.
- 2026-10-30 · Smart components de la cinta 1 y de la ventosa, y estado guardado `Inicio` · extra 2 y demo realista.
- 2026-11-01 · Mesa llenada desde la fila lejana de la cinta (y = 130), cada fila en X descendente (sustituye al orden del 29 oct) · con la fila cercana primero, la caja transportada (base a 900) atravesaba unos 70 mm la fila ya puesta (techo a 970). Coste: al dejar las 3 últimas, las copas de la otra fila tocan 20 mm el borde de la fila puesta.
- 2026-11-01 · Ventosa con 6 `LineSensor` (uno por copa, desplazados 35 mm hacia el centro), todos con la señal `Grip` = `DO_Cup21` · engancha la caja 1, la caja 2 y el bloque 3×2; el sensor justo bajo la copa detectaba la propia ventosa.
- 2026-11-01 · Planos de los sensores de las cintas de 10 mm de alto (z 788…798) · la caja colgando de la ventosa cruzaba el plano y creaba cajas de más.
- 2026-11-04 · Luces para el operario `DO_EuroPalletFull`, `DO_HalfPalletFull` y `DO_LinerStackEmpty` (SetDO en RAPID) · aviso de palé lleno o pila vacía sin bloquear la otra línea; también habilitan el vaciado en los smart components.
- 2026-11-04 · Pulsadores del operario dentro de los smart components (`EuroPalletReplaced`, `HalfPalletReplaced`, `LinersRefilled`) con un `AND` con la señal de "lleno/vacío", que activan la DI del controlador · en RobotStudio una DI del controlador no puede ser el origen de la lógica de estación; equivale al pulsador real fuera de la valla cableado a la DI.
- 2026-11-04 · Vaciado del medio palé con `Queue_HalfPallet` (FIFO) + `Repeater` (`Count` 72) → `Delete`, sin `DeleteAll` · borra solo las 72 cajas del palé y respeta las de la mesa.
- 2026-11-04 · Liners como copias de 10 `Source` (`SC_Liners`), en `Queue_Liners` de arriba abajo; al cambiar el palé, `Repeater_Liners` (`Count` 2) borra los 2 del palé · el modelo fijo daba colisión y los liners se quedaban flotando al cambiar el palé.
- 2026-11-04 · Estado vigente `Inicio_04-11`; no cargar `Inicio_03-11` ni anteriores · los estados antiguos devuelven piezas y sensores a posiciones viejas.
- 2026-11-05 · Plan de extras: smart components (hecho) + detección de colisiones + PLr/PL; presión analógica de reserva · los smart components ya están completos y PLr/PL va unido a los requisitos 2 y 3. *Propuesta de Claude; confirmar con Peru.*
- 2026-11-05 · (Peru) `Enqueue` de `Queue_EuroPallet` y `Queue_HalfPallet` en `Source.Executed`, y europalé con `Repeater` (`Count` 12) → `Delete` en vez de `DeleteAll` · `Delete`/`DeleteAll` vacían `Back` y la primera caja después de cada cambio no entraba en la cola (se quedaba suelta en el siguiente vaciado). Detalle en `MEMORIA_PROYECTO.md` §10.4.
- 2026-11-05 · (Peru) Pulsadores del operario por interrupción: `ISignalDI` + `TRAP` que apaga `DO_…Full` en el acto y deja una bandera para `Main` (europalé, medio palé y `DI_LinersRefilled`) · RAPID perdía el pulso si llegaba en mitad de un bloque, y una 2.ª pulsación borraba cajas de más.
- 2026-11-05 · (Peru) Mensaje al operario: luz (DO) + `TPWrite` una sola vez junto a cada `SetDO …,1`, en inglés · que no se discuta si una luz es un "message"; nada de `TPReadFK` para no bloquear la otra línea.
- 2026-11-05 · Protección del cambio de palé y de la reposición de liners (alternativa C): cortina de luz en cada hueco (europalé, medio palé y liners, cada uno con su cortina) → PLC de seguridad (Pluto) → entrada de parada del IRC5, que para todo el robot al cortarse la cortina y lo mantiene parado hasta un rearme manual fuera de la valla, con vista al hueco y separado de los pulsadores de proceso · PLr = e (S2, F2, P2).
  - Fuente única: Product manual – IRC5 Panel Mounted Controller (3HAC047137-001), tabla de datos de seguridad por función: entradas de parada del IRC5 PFHd 4,29·10⁻⁸ (PL e); funciones de SafeMove2 PFHd 1,01·10⁻⁷ (PL d).
  - SF1 = Focus 5,02·10⁻⁹ + Pluto 2·10⁻⁹ + parada IRC5 4,29·10⁻⁸ = 4,99·10⁻⁸ → PL e ≥ PLr e; SafeMove2 (PL d) no llega a PLr e.
  - Para el extra 4 se usa 4,29·10⁻⁸ en vez del 5,79·10⁻⁸ de Jokab (2011), y se dice en el documento.
  - El robot sigue con la otra línea mientras el palé lleno espera; solo se para desde el corte de la cortina hasta el rearme.
  - Funciones de seguridad previstas: SF1 huecos de palé/liners (Focus), SF2 puerta de mantenimiento (Eden), SF3 parada de emergencia (Smile Tina), SF4 entrada de cajas por las cintas (Focus con muting), SF5 presencia en el hueco (ver abajo).
- 2026-11-05 · Una cortina por hueco: europalé, medio palé y liners por separado (sustituye a la idea inicial de una zona común para medio palé + liners) · coincide con la planta v2 y con el Excel de riesgos; cada operación tiene su propio pasillo, su rearme con vista al hueco y su luz de aviso.
- 2026-11-05 · Excel de riesgos: la situación de partida (columnas E–G) se valora sin protecciones (robot y cintas sin valla ni cortinas) · así se ve el efecto de cada medida y el análisis no sale verde desde el principio.
- 2026-11-05 · Excel de riesgos: alcance y supuestos en una pestaña propia (`Scope & assumptions`); el análisis incluye la célula dentro de la valla, los puestos de palé y liners, los tramos finales de las cintas con sus entradas y el puesto del operario; excluye el resto de las cintas · no se tocan las fórmulas ni los colores de la tabla. *Texto de Claude; Joaquín decide dejarlo como está (riesgo aceptado).*
- 2026-11-05 · Excel: objetivo de 15–20 filas (2–4 por modo) · pocas filas bien justificadas puntúan más que muchas; la plantilla trae 12.
- 2026-11-05 · **Propuesta** de valla y cortinas (`PR310G_datos_celula.md` §9b, planta v2): valla de 2000 mm de alto a 2450 mm del eje del robot (alcance 1850 + c = 600, ISO 13857 tabla 2, a = 2000); cortinas de 30 mm a ≈2950 mm (S ≈ 1090, ISO 13855 con T = 0,6 s supuesto); huecos como pasillos de ~500 mm con la cortina en la entrada; puerta de mantenimiento enclavada en −X; túneles con muting en las cintas · cumplir las distancias sin mover palés ni wobj. *Sustituida el mismo día por radio 1950 / valla 2550 / cortinas 3050 (ver abajo).*
- 2026-11-05 · La estación (Pack and Go guardado con la 25.2) se abre en RobotStudio 2024 (portátil de Joaquín) · reduce el riesgo de versión; falta probar el ciclo completo.
- 2026-11-05 · Excel de riesgos con 19 filas seguidas (filas 3–21; sobrantes borradas): 3 de operación normal, 5 de cambio de palés y liners, 3 de atascos, 4 de mantenimiento, 3 de programación y 1 de emergencia · cubre todos los modos que pide el enunciado. *Casi todo el texto lo ha redactado Claude a petición de Joaquín: Joaquín lo revisa y lo pasa a sus palabras antes de entregar.*
- 2026-11-05 · Regla de valoración: las medidas bajan P, no C (J = F), salvo T1, donde la velocidad reducida baja la energía del golpe (J = 4 < F = 5) · coherencia de la matriz; pregunta probable en la defensa.
- 2026-11-05 · PLr por función: SF1 cortinas de los huecos e (S2, F2, P2); SF2 puerta de mantenimiento e (S2, F2, P2; F2 porque la puerta también se usa para los atascos), que además para las cintas; parada de las cintas d (S2, F2, P1), cubierta por SF2; SF4 cortina con muting en la entrada de cajas d (S2, F1, P2); SF3 parada de emergencia d (S2, F1, P2), medida complementaria · cada PLr sale del gráfico, no "e" por defecto.
- 2026-11-05 · Mantenimiento del robot, del aire comprimido y del armario: aislamiento de energía con bloqueo y etiquetado (lockout/tagout), sin PLr · no es una función de seguridad del sistema de control.
- 2026-11-05 · Valla modelada en RobotStudio (obligatoria, requisito 3) y cortinas, puerta, paneles del operario y armario del IRC5 como geometría simple, sin lógica de señales · el resto de equipos solo hay que explicarlo, pero modelarlo ayuda en la defensa y en la detección de colisiones; la seguridad no se programa en RAPID.
- 2026-11-05 · Zona peligrosa de **1950 mm** (no 1850): valla a **2550 mm** y cortinas a **≈3050 mm** · el liner (800 × 540) va centrado en el TCP y gira con el eje 6; su media diagonal (483 mm) sobre la muñeca a 1450 mm da ≈1933 mm.
- 2026-11-05 · No se mueven los palés: los huecos quedan **abiertos a la célula** (el operario entra hasta el palé con el robot parado por SF1) · el robot tiene que alcanzar los palés, así que están dentro de la zona peligrosa; hay que corregir las filas 6 y 7 del Excel.
- 2026-11-05 · Detección de presencia en los tres huecos (alfombra de seguridad modelada) como **función aparte, SF5** (presencia en el hueco / bloqueo del rearme), PLr e · ISO 13849-1: cada función con su cadena; no cambia el PFHd de SF1. PFHd de la alfombra pendiente (fabricante). *Claude recomienda escáner láser de seguridad por el paso de la carretilla.*
- 2026-11-05 · **Carretilla elevadora** en vez de transpaleta manual; huecos ensanchados: europalé **1800 mm** (y −900…900) y medio palé **1500 mm** (x −750…750); liners sin cambio · con 1500/1100 quedaban 125 mm por lado o la carretilla no cabía. Anchos de carretilla aproximados.
- 2026-11-05 · Puerta de mantenimiento en −X (y 900…1700) · junto a la cinta 2 y la mesa (atascos); Joaquín cambia el texto de la fila 14.
- 2026-11-05 · Añadidos `EStop_Inside` (dentro, junto a la puerta) y topes de palé (`PalletStop_*`) · coherencia con las filas 10, 11 y 19 del Excel.
- 2026-11-05 · Rearme de la seguridad en el mismo puesto que el pulsador de proceso, separado y en azul · reset con vista al hueco sin duplicar puestos.
- 2026-11-05 · Luces del operario con Highlighter conectado a las DO existentes, sin tocar el RAPID · **pendiente de verificar en pantalla que existe en la 2024** (T41).
- 2026-11-05 · Valla y equipos modelados en una copia de práctica con Modelado → Sólido (Tetraedro/Box y Cilindro): 103 piezas con nombres en inglés y colores; grupo `Safety_Fence` · no hay valla ni cortinas en la librería de esa instalación. Detalle, coordenadas y pasos en `Seguridad_valla/PR310G_valla_modelado.md` (en el proyecto de Claude: `claude/PR310G_valla_modelado.md`).
- 2026-11-06 · Rama `joaquin-valla` con la copia de práctica (`Seguridad_valla/Pallet_Project_valla_practica.rspag`, guardada con la 2024 e incluyendo los paquetes de ABB) · no sustituye al `Pallet_Project.rspag` de `main` (parte de la estación de la mañana del 5 nov, sin los arreglos de Peru); la seguridad se pasa a la estación de Peru en la T37. No se fusiona la estación de práctica en `main` como entregable.

## Pendientes

- PENDIENTE · Reparto. Propuesta del 5 nov: Joaquín hace Excel de riesgos, valla y equipos, PLr/PL, calidad de código (`Main`, números mágicos, `CalibData`, inercias, masa de la ventosa), documento de extras y, si sobra tiempo, presión analógica; Peru hace Station Viewer, Pack and Go final, vídeo final, limpieza de la estación y del repo. (`TPWrite` ya lo hizo Peru.)
- PENDIENTE · T37: juntar la celda de seguridad con la estación de Peru (*Guardar como biblioteca* / *Importar biblioteca*).
- PENDIENTE · T4: copas apoyadas 20 mm sobre la fila puesta de la mesa y cajas fuera del conjunto de colisión. Peru propone dejarlo y justificarlo (5 nov); **falta que lo confirme Joaquín**.
- PENDIENTE · Tiempo de parada real del IRB 1600 (ABB 3HAC048645) para recalcular S de las cortinas (T42).
- PENDIENTE · Verificar en el PDF del manual del IRC5 (3HAC047137-001, pág. 20) el emparejamiento función ↔ PFHd (4,29·10⁻⁸ entradas de parada; 1,01·10⁻⁷ SafeMove2), deducido del texto web desordenado (T38).
- PENDIENTE · Preguntar a la profesora si acepta SafeMove2 (PL d) según ISO 10218-2; si sí, se presenta como mejora sobre la alternativa C.
- PENDIENTE · Umbral de casi colisión (50 mm salta con `LinerStand` en los 4 liners de abajo).
- PENDIENTE · Masa, centro de gravedad e inercias de la ventosa y de las cargas.
- PENDIENTE · Alfombra o escáner láser de seguridad para SF5 (con carretilla), y su PFHd.
- PENDIENTE · Altura real de la zona peligrosa (a = 2000 supuesto) con la envolvente vista de lado (T39).
- ~~PENDIENTE · ¿Añadir `TPWrite` además de las luces?~~ · resuelto: sí, hecho por Peru el 5 nov.
- ~~PENDIENTE · Dónde va el armario del IRC5~~ · resuelto: fuera de la valla, junto al puesto general (−4150…−3425, 2700…3410).

## Respuestas del profesorado

- (vacío; correo a My Legendi pendiente, preguntas en `PR310G_pendientes.md` §4)
