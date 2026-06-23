# Escalón: mecanica-git — pre-commit, branches, backup destructivo

> **Escalón del flujo NIMBUS (v3 — carga por escalones).** Se carga solo cuando dispara su trigger; asume el **piso** cargado (principios rectores, roles del meta-sistema y reglas de comunicación del `CLAUDE.md` global). No requiere el resto del flujo.

## Cuándo carga este escalón (triggers)

- Setup de pre-commit en un proyecto nuevo, decisión de rama, o ANTES de cualquier operación git destructiva (migración, refactor grande, `rm -rf`, `git reset --hard`, `push --force`).

## Dependencias declaradas

- El backup destructivo refuerza los bloques `side-effects-management-v2.3.0` e `irreversibilidad-sobre-confianza-v2.3.0` del `CLAUDE.md` global (piso).
- `/review` es skill built-in de Claude Code (review formal antes de mergear un PR).

---

## Pre-commit checks

Cada proyecto debe tener pre-commit que corra automático antes de aceptar un commit (red de seguridad para no commitear roto).

- **Python:** `ruff` + `mypy` + `pytest` si hay tests.
- **TypeScript/JS:** `eslint` + `tsc --noEmit` + `vitest`/`jest` si hay tests.
- Configurar con `pre-commit` (Python) o `husky` (JS) o `.git/hooks/pre-commit`. Que corra solo.
- Si falla → arreglar, NO `--no-verify`.
- Check lento (>30s) → mueve a CI, deja solo rápidos en pre-commit.
- Si el proyecto no lo tiene → setup en la primera rebanada (10 min que ahorran horas).

## Estrategia de branches

**Default: trabajar directo en `main`.** Las rebanadas son chicas y se verifican antes de commit, así que `main` no se rompe.

Crear feature branch SOLO si: (a) la rebanada es experimental y puede no funcionar, (b) el cambio toca infra que rompería `main` si se queda a la mitad (migration, refactor grande), o (c) entra colaborador externo a trabajar en paralelo.

Nombre: `<tipo>/<rebanada-corta>` (`feat/auth-jwt`, `exp/agente-voz-realtime`). Cerrar con squash en `main`, borrar el branch. Si hay PR → `/review` antes de mergear.

`ESTADO.md` vive en `main`, no en feature branches. Si trabajas en feature branch, commitea código ahí pero `ESTADO.md` siempre en `main`.

## Backup antes de operaciones destructivas

Operaciones no reversibles con `git revert` requieren snapshot antes. Aplica a: migrations de DB que dropean columnas/tablas, refactors que mueven >5 archivos o renombran módulos públicos, `rm -rf` de directorios no claramente temporales, sobrescribir configs con secretos, `git reset --hard` / `clean -f` / `branch -D` / `push --force`.

Protocolo: (1) avisar a {{USER_NAME}} en 1 línea + esperar confirmación explícita — auto mode no autoriza, (2) snapshot antes (DB → dump; archivos → branch `backup/pre-<op>-YYYYMMDD`), (3) ejecutar, (4) verificar resultado antes de borrar el snapshot, (5) si algo no sale → restaurar, NO improvisar workaround.

Regla mental: **las operaciones destructivas no son rápidas. La velocidad viene de no tener que reconstruir lo destruido.**
