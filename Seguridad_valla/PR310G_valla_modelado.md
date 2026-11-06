# PR310G – Valla y equipos de seguridad modelados en RobotStudio (práctica, 5 nov 2026)

Modelado por Claude en la **copia de práctica** (`Practica\Pallet_Project_practica`) con RobotStudio 2024 en español. Copia de seguridad previa: `Practica\Pallet_Project_practica_BACKUP_2026-11-05_antes_valla`. La estación de `main` no se ha tocado. **Joaquín tiene que saber rehacerlo a mano** (el curso considera trampa el material hecho con IA).

**Dónde está (6 nov):** rama `joaquin-valla`, carpeta `Seguridad_valla/`:
- `Pallet_Project_valla_practica.rspag`: Pack and Go de la copia de práctica, guardado con RobotStudio 2024 e incluyendo los paquetes de distribución de ABB.
- Capturas: `PR310G_valla_vista_3D_RobotStudio.jpg`, `PR310G_valla_planta_RobotStudio.jpg` y `PR310G_valla_vista_lateral_RobotStudio.jpg`.

**Ojo:** la copia de práctica parte de la estación del 5 nov por la mañana. No tiene los cambios de Peru de esa tarde (interrupciones, `Repeater` de `SC_Conveyor1`, `Enqueue` en `Source.Executed`). No sustituye al `Pallet_Project.rspag` de `main`: la seguridad se pasa a la estación de Peru en la **T37** (*Guardar como biblioteca* → *Importar biblioteca*; las piezas están en coordenadas de mundo).

## 0. Estado

| Bloque | Estado |
|---|---|
| Valla (24 paneles, 20 postes, túneles, puerta) | ✅ creado, nombres en inglés, colores (malla gris 40 % opacidad, postes amarillos) |
| Cortinas (10 columnas), muting (4 sensores + 2 lámparas), bumpers, alfombras, topes | ✅ |
| Puerta + Eden + puesto de puerta + `EStop_Inside` | ✅ |
| Puestos del operario (4), luces, pulsadores, rearmes, setas, armario IRC5 | ✅ |
| Grupo `Safety_Fence` (todas las `Fence_*`) | ✅ |
| Subgrupos LightCurtains, Door, OperatorStations y grupo raíz Safety | ❌ pendiente (pasos en §2.6) |
| Comprobación con Measure | ❌ pendiente (las cotas salen por construcción de las coordenadas; hay que enseñarlo con Measure) |
| Conjunto de colisión (grupo B) + ciclo completo (extra 3) | ❌ pendiente |
| Envolvente vista de lado (a = 2000) | ❌ pendiente (solo hay captura de alzado con el robot en Home) |
| Luces con Highlighter | ❌ no verificado en pantalla; no prometer hasta comprobarlo |
| Señales de advertencia | ❌ opcional, no hecho |

Incidencia durante el trabajo: con el diálogo de cilindro abierto, el clic derecho cayó sobre la raíz de la estación y "↑ + Intro" ejecutó **Cerrar estación** (guardando antes). No se perdió nada salvo el nombre de una pieza; se reabrió y se corrigió.

## 1. Medidas base (decisiones del 5 nov)

- Radio de la zona peligrosa: **1950 mm** (la media diagonal del liner, 483 mm, sobre la muñeca a 1450 mm da ≈1933 mm).
- Valla: **2000 mm** de alto, cara interior a **2550 mm** del eje 1 (1950 + c = 600, ISO 13857 tabla 2, a = b = 2000; a = 2000 sigue siendo **supuesto**).
- Cortinas de 30 mm a **3050 mm** (S ≈ 1090 mm, ISO 13855, T = 0,6 s **supuesto**): 3050 − 1950 = 1100 ≥ 1090.
- Huecos: europalé **y −900…900** (1800 mm) y medio palé **x −750…750** (1500 mm), ensanchados para **carretilla elevadora**; liners y −800…−60 (sin cambio). Pasillos de 500 mm (2550 → 3050).
- Cintas `Conveyor Guide 400` (librería ABB): bastidor medido ≈470 mm (≈600 con los pies); separación entre cintas ≈225 mm.

## 2. Pasos en RobotStudio (para repetir en la estación real)

Menús en español (tu portátil) / inglés (salas, 2024.4).

### 2.1 Preparación
1. Copia la carpeta de la estación antes de empezar (o *Simulación → Guardar estado* / *Simulation → Save State*).
2. Abre la estación. Clic derecho en la vista → **Orientación → Arriba** (*View → Top*) para trabajar en planta.

### 2.2 Crear cada pieza
3. **Modelado → Sólido → Tetraedro** (*Modeling → Solid → Box*). En español la caja aparece traducida como "Tetraedro".
4. Referencia **Mundo**. Escribe **Punto de esquina** (x, y, z), deja la orientación a 0 y escribe **Longitud** (X), **Anchura** (Y) y **Altura** (Z). Pulsa **Crear**. El diálogo se queda abierto para la siguiente.
5. Para cilindros: **Modelado → Sólido → Cilindro** (*Cylinder*): **Punto central de la base**, **Radio**, **Altura** → **Crear**.
6. Renombrar: en el panel **Diseño** (*Layout*) escribe "Pieza" en **Buscar** para ver solo la pieza nueva → clic derecho → **Cambiar nombre** (*Rename*). F2 no funciona en ese árbol.
7. Coordenadas exactas: tabla de §3 (todas en mm, esquina mínima de la caja).

### 2.3 Colores
8. En **Buscar** escribe el prefijo (p. ej. `Fence_`), clic en el primer elemento y **Mayús+Fin** para seleccionar todos.
9. Clic derecho → **Modificar → Apariencia de gráficos…** (*Modify → Graphic Appearance*). **Opacidad (%)** (40 para la malla, 50 para la puerta, 100 para el resto) y **Color simple** → color → **Aceptar**.
10. Orden: `Fence_` gris 40 % → `Fence_Post` amarillo 100 % → `LightCurtain`, `Bumper`, `EStopBase`, `PalletStop` amarillo → `EStop_` rojo → `Button_` verde → `ResetButton` azul → `Lamp_` naranja → `MutingLamp` blanco → `MutingSensor` negro → `SafetyMat` oliva → `Door_Maint` azul acero 50 % → `DoorSensor` rojo.

### 2.4 Agrupar
11. Filtra `Fence_`, selecciona todos → clic derecho → **Agrupar** (*Group*) → renombra el grupo `Safety_Fence`.
12. **Ojo:** al cambiar el filtro se pierde la selección. Para los demás subgrupos, quita el filtro (el árbol ya es corto) y usa Ctrl+clic, o arrastra las piezas al grupo.

### 2.5 Guardar
13. **Ctrl+S** al terminar cada bloque (valla, pasillos, cortinas, puerta, puestos).

### 2.6 Lo que falta (hazlo tú, cuenta para la nota)
14. Subgrupos `LightCurtains` (LightCurtain_*, MutingSensor_*, MutingLamp_*, Bumper_*, SafetyMat_*), `Door` (Door_Maintenance, DoorSensor_*, OperatorStation_Door, ResetButton_Door, EStop/EStopBase_Door, EStopPost/EStop/EStopBase_Inside) y `OperatorStations` (resto + IRC5_Cabinet). Después, los cuatro dentro de `Safety`.
15. **Modelado → Medir → Punto a punto** (*Modeling → Measure → Point to Point*): mide eje del robot (0,0) → cara interior de la valla (2550), → cortina del europalé (3050), → cortina de un túnel (3110). Haz captura.
16. Conjunto de colisión: en **Diseño** despliega `Conjunto de colisión_1` → arrastra `Safety_Fence`, las `LightCurtain_*` y `Door_Maintenance` a **Objetos B** (*ObjectsB*). Ejecuta un ciclo completo (**Simulación → Reproducir**) y mira la ventana de salida. Si salta casi colisión, apunta pieza y punto.
17. Envolvente: clic derecho en el robot → **Mostrar envolvente de trabajo** → **Herramienta activa** + **Contorno 2D**, vista de frente. Comprueba la altura máxima del TCP frente a a = 2000 (la caja/liner añade unos 200–480 mm). Si supera 2000, a pasa a la fila 2200/2400 de la tabla 2 y hay que revisar c.
18. Luces: **Modelado → Componente inteligente** → **Añadir componente** → busca *Highlighter* (comprueba que existe en la 2024). Propiedades: Objeto = `Lamp_EuroPalletFull`, color naranja intenso. En **Simulación → Lógica de estación**, conecta `DO_EuroPalletFull` del controlador a la entrada `Active` del Highlighter. Repite para las otras dos luces. No toca el RAPID.

## 3. Tabla de equipos (posición = esquina mínima en mm; para cilindros, centro de la base)

| Objeto(s) | Posición (x, y, z) | Medidas | Función | SF |
|---|---|---|---|---|
| `Fence_Panel_E1/E2` | (2550, −2550, 0) / (2550, 900, 0) | 20 × 1650 × 2000 | Valla +X | Resguardo fijo |
| `Fence_Panel_S1/S2` | (−2550, −2570, 0) / (750, −2570, 0) | 1800 × 20 × 2000 | Valla −Y | Resguardo fijo |
| `Fence_Panel_W1/W2/W3` | (−2570, −2550 / −60 / 1700, 0) | 20 × 1750 / 960 / 850 × 2000 | Valla −X | Resguardo fijo |
| `Fence_Panel_N1/N2/N3` | (−2550 / −88,5 / 603,5, 2550, 0) | 1931,5 / 162 / 1946,5 × 20 × 2000 | Valla +Y | Resguardo fijo |
| `Fence_Corridor_Euro_1/2` | (2550, −920 / 900, 0) | 500 × 20 × 2000 | Pasillo europalé | Resguardo fijo |
| `Fence_Corridor_Half_1/2` | (−770 / 750, −3050, 0) | 20 × 500 × 2000 | Pasillo medio palé | Resguardo fijo |
| `Fence_Corridor_Liner_1/2` | (−3050, −820 / −60, 0) | 500 × 20 × 2000 | Pasillo liners | Resguardo fijo |
| `Fence_Tunnel_Conv1_1/2`, `Conv2_1/2` | x 53,5 / 603,5 / −638,5 / −88,5; y 2550 | 20 × 500 × 2000 | Paredes de túnel | Resguardo fijo |
| `Fence_Tunnel_Conv1/2_Low`, `_Top` | (73,5 / −618,5, 3050, 0 y 1020) | 530 × 20 × 700 / 980 | Frente del túnel; abertura 530 × 320 (z 700…1020) | Resguardo fijo |
| `Fence_Post_01…20` | esquinas, bordes de huecos y frentes de túnel | 60 × 60 × 2000 | Postes | — |
| `Door_Maintenance` | (−2570, 900, 0) | 20 × 800 × 2000 | Puerta | SF2 |
| `DoorSensor_Eden_Actuator/Sensor` | (−2600, 1650, 1000) / (−2640, 1710, 1000) | 30 × 40 × 60 | Enclavamiento sin contacto | SF2 |
| `OperatorStation_Door` + `ResetButton_Door` + `EStop_Door` | (−3000, 1750, 0); rearme (−2900, 1850, 1100) | 300 × 300 × 1100 | Rearme de la puerta y seta | SF2 / SF3 |
| `EStopPost_Inside` + `EStop_Inside` | (−2530, 1750, 0) | 100 × 100 × 1100 | Seta dentro, junto a la puerta | SF3 |
| `LightCurtain_EuroPallet_Emitter/Receiver` | (3050, −900 / 850, 0) | 50 × 50 × 2000 | Cortina europalé | SF1 |
| `LightCurtain_HalfPallet_*` | (−750 / 700, −3100, 0) | 50 × 50 × 2000 | Cortina medio palé | SF1 |
| `LightCurtain_LinerBay_*` | (−3100, −800 / −110, 0) | 50 × 50 × 2000 | Cortina liners | SF1 |
| `LightCurtain_Conv1_*` | (23,5 / 603,5, 3110, 650) | 50 × 50 × 450 | Cortina túnel cinta 1 | SF4 |
| `LightCurtain_Conv2_*` | (−668,5 / −88,5, 3110, 650) | 50 × 50 × 450 | Cortina túnel cinta 2 | SF4 |
| `MutingSensor_Conv1_A/B` | (628,5, 3235 / 3535, 0) | 30 × 30 × 900 | Muting (separación 300 < caja 1) | SF4 |
| `MutingSensor_Conv2_A/B` | (−673,5, 3235 / 3335, 0) | 30 × 30 × 900 | Muting (separación 100 < caja 2) | SF4 |
| `MutingLamp_Conv1/2` | (338,5 / −353,5, 3100, 1060) | Ø60 × 100 | Lámpara de muting | SF4 |
| `Bumper_EuroPallet_1/2` | (3175, ∓875, 0) | Ø114 × 1000 | Protege columnas | (fila 10) |
| `Bumper_HalfPallet_1/2` | (∓725, −3175, 0) | Ø114 × 1000 | Protege columnas | (fila 10) |
| `SafetyMat_EuroPallet` | (1400, −900, 0) | 1650 × 1800 × 15 | Presencia en hueco | SF5 (nueva) |
| `SafetyMat_HalfPallet` | (−750, −3050, 0) | 1500 × 1850 × 15 | Presencia en hueco | SF5 |
| `SafetyMat_LinerBay` | (−3050, −800, 0) | 1750 × 740 × 15 | Presencia en hueco | SF5 |
| `PalletStop_Euro_1/2` | (560, −450 / 350, 0) | 40 × 100 × 80 | Tope del palé | — |
| `PalletStop_Half_1/2` | (−350 / 250, −600, 0) | 100 × 40 × 80 | Tope del palé | — |
| `OperatorStation_EuroPallet` + `Lamp_EuroPalletFull`, `Button_EuroPalletReplaced`, `ResetButton_EuroPallet`, `EStop(Base)_EuroPallet` | (3300, 1250, 0) | 400 × 300 × 1100 | Puesto europalé | Luz y pulsador: proceso · rearme SF1 · seta SF3 |
| `OperatorStation_HalfPallet` (+ `Lamp_HalfPalletFull`, `Button_HalfPalletReplaced`, …) | (1200, −3650, 0) | Ídem | Puesto medio palé | Ídem |
| `OperatorStation_LinerBay` (+ `Lamp_LinerStackEmpty`, `Button_LinersRefilled`, …) | (−3700, −1700, 0) | Ídem | Puesto liners | Ídem |
| `OperatorStation_General` + `EStop_General` | (−3350, 2900, 0) | Ídem | Puesto general | SF3 |
| `IRC5_Cabinet` | (−4150, 2700, 0) | 725 × 710 × 970 (supuesto) | Armario fuera de la valla | LOTO (fila 17) |

## 4. Respuestas a las preguntas del 5 nov

**Alfombra de seguridad y PFHd de SF1.** No se suma al PFHd de SF1. En ISO 13849-1 cada función de seguridad tiene su propia cadena, y la alfombra hace otra cosa: detecta a una persona que ya ha pasado la cortina e impide el rearme (y para el robot si alguien pisa). Trátala como **SF5 "detección de presencia en el hueco / bloqueo del rearme"**: alfombra + Pluto + entrada de parada del IRC5. PLr con el mismo gráfico (S2, F2, P2 → e). **El PFHd de la alfombra no está en los documentos** (no lo invento): hay que sacarlo del fabricante. Si la alfombra solo llega a PL d, SF5 no alcanza PLr e: dilo en la defensa o usa otro sensor.

**Crítica importante: alfombra + carretilla.** Una alfombra de seguridad no está pensada para el paso de carretillas (se daña y además la carretilla la activa). Con la decisión de usar carretilla, lo coherente es un **escáner láser de seguridad** que vigile el suelo del hueco. Lo he modelado como alfombra porque lo pediste; propongo cambiarlo a escáner (mismo sitio, misma SF5).

**Anchos de hueco con carretilla.**
- Europalé (1200 de ancho en la dirección de entrada): 1500 → 1450 libres entre columnas, solo 125 mm por lado. Insuficiente. **Modelado a 1800** (1700 libres, 250 por lado).
- Medio palé: 1100 → 1050 libres. Una carretilla contrapesada pequeña mide ≈1000–1100 de ancho y entra hasta 1,65 m dentro de la célula, así que no cabe. **Modelado a 1500** (1400 libres).
- El EPAL acepta horquillas por los cuatro lados, así que con carretilla deja de importar que el palé mire al hueco por su lado largo.
- Delante de cada hueco hace falta espacio de maniobra (≈3–4 m): el puesto del europalé está en y 1250…1550 y el del medio palé en x 1200…1600, fuera de la trayectoria de entrada pero cerca. Los bumpers protegen las columnas.
- Valores de ancho de carretilla: **aproximados, no están en los documentos**.

## 5. Diferencias con el Excel y con `PR310G_datos_celula.md`: qué cambiar

Excel `PR310G_Group2_Risk_Assessment.xlsx`, pestaña *Risk Assessment* (fila Excel = nº de riesgo + 2). El texto lo redactas tú.

| Fila Excel (riesgo) | Columna | Cambio |
|---|---|---|
| 5 (3, valla) | H | 1850 → **1950 mm** de zona peligrosa; valla a **2550 mm** |
| 5 (3) | L | Añadir que 1950 sale del liner (media diagonal 483 mm); a = 2000 sigue siendo supuesto |
| 6 (4, europalé) | C | "pallet jack" → **forklift** |
| 6 (4) | H | Quitar "never has to walk through the robot's working area". Poner que el hueco está abierto a la célula, el robot entero para (SF1) y la alfombra/escáner detecta presencia (SF5). Hueco de 1800 mm. |
| 6 (4) | L | Cortina a 3050 mm; añadir SF5 |
| 7 (5, persona dentro al rearmar) | H | Quitar "short dead-end corridor" y "Optional: a safety mat". La alfombra/escáner deja de ser opcional. Rearme azul en el mismo puesto que el pulsador de proceso, separado. |
| 7 (5) | L | SF1 + **SF5** (PLr e; PFHd de la alfombra pendiente del fabricante) |
| 8 (6, medio palé) | C, H | Forklift; hueco de 1500 mm; añadir SF5 |
| 9 (7, liners) | H, L | Añadir SF5 |
| 10 (8, transpaleta) | B, C, D, H, L | Reescribir para **carretilla**: huecos de 1800/1500, topes en el suelo (modelados), bumpers, zona de maniobra; señalización de tráfico de carretillas |
| 13 (11, túneles) | H | La abertura es de 530 × 320 mm (bastidor de la cinta + caja + margen), no "solo la caja"; el túnel mide 500 mm |
| 14 (12, puerta) | H | Lo cambias tú (la puerta queda en −X, junto a la mesa y la cinta 2) |
| 21 (19, emergencia) | H | Añadir la seta **dentro** junto a la puerta (`EStop_Inside`) |
| Pestaña *Scope & assumptions* | — | Transpaleta manual → carretilla; zona peligrosa de 1950 mm |

`PR310G_datos_celula.md`:
- §1 "Usar ~1,8–1,9 m" → **1,95 m**, con el liner como caso que manda.
- §9b: alcance 1850 → **1950**; valla 2450 → **2550**; cortina 2950 → **3050**; añadir los huecos (europalé y ±900, medio palé x ±750, liners y −800…−60), túneles (530 × 320) y alfombras/SF5. Alternativa de valla de 2200: recalcular con 1950 (2350).
- §5: ancho del bastidor de las cintas ≈470 mm (medido en pantalla, ±20 mm).
