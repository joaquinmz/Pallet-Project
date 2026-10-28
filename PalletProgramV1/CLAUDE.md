# CLAUDE.md – Pallet Project (PR310G, University of Skövde)

Responde en español, corto y conciso. Peru es estudiante de Ingeniería Electrónica Industrial y Automática; no se considera programador, así que explica lo de RAPID sin dar nada por sabido cuando haga falta.

## Qué es esto

Programa RAPID de una célula de paletizado ABB (IRB 1600-10/1.45, IRC5 RobotWare 6.13.02, RobotStudio 2025), proyecto de grupo de Peru Mendivil y Joaquín Moreno (Group 2, JMPM).

- `PalletProgram.mod`: programa principal (targets, máquinas de estados, `Main`).
- `CalibData.mod`: work objects, `toolVacuum` y loaddata (TASK PERS).
- `PalletProgramV1.pgf`: archivo de programa que carga RobotStudio.
- `MEMORIA_PROYECTO.md`: **léela primero**. Layout, wobj, targets, señales, decisiones, estado del código, lógica de `Main` acordada y lista de pendientes.
- `PalletProgram_antesMerge.bak`: copia de seguridad previa a fusionar la caja 2. No tocar (ignorada en git).
- **`../PalletProgram_28-10/`: versión de trabajo actual del programa** (guardada desde RobotStudio el 28 oct). Los `.mod` de esta carpeta son la versión anterior.

Repo: github.com/joaquinmz/Pallet-Project (`main` = Peru, `second-main` = caja 2 de Joaquín, `cambios-peru-28-10` = trabajo del 28 oct).

## Reglas al editar

- Convención de nombres: VAR / PERS / parámetros en camelCase; CONST / PROC / FUNC / MODULE en PascalCase; señales con prefijo `DI_`, `DO_`, `AI_`, `AO_`. Estados: `Box1Pos1…Box1LastPos`, `Box2Pos1…Box2LastPos`.
- `NOT` tiene la prioridad más baja en RAPID: usar paréntesis, `(DI_x=1) AND (NOT flag)`.
- Llamadas a PROC sin paréntesis (`VacuumControl cups;`); FUNC con `()`.
- Un target base por estación; el resto con `Offs`. Todo pick/place pasa por `ApproachPoint(target, wobj, cups, load)`.
- Mantener las secciones comentadas con `!-----` y el encabezado del módulo.
- No cambiar targets ni wobj sin que Peru lo pida: están medidos en la estación.
- Archivos solo en ASCII (sin tildes en los comentarios del código).
- Después de editar, recordar a Peru que recargue en RobotStudio (clic derecho en `T_ROB1` → *Cargar programa* → `PalletProgramV1.pgf`) y que no guarde desde RobotStudio antes, o sobrescribirá el archivo.

## Siguiente paso

Ver sección 10 de `MEMORIA_PROYECTO.md`. `TransferStack`, `tableFull` y los resets ya están hechos. Siguiente: completar `Main` (arranque, `WHILE TRUE`, elección de caja con `lastBox`, `WaitTime 0.1`).

Peru prefiere ir paso a paso: explicar primero el porqué, sin dar el código hecho salvo que lo pida; él lo escribe en RobotStudio y lo revisamos.
