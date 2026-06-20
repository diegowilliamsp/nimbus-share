# NIMBUS

Un flujo de trabajo para **Claude Code** que lo hace trabajar mejor en tus proyectos: lo guía para preguntar antes de asumir, ir por pasos pequeños y verificables, y nunca saltarse el proceso cuando importa.

NIMBUS no es un programa que corres: es un conjunto de instrucciones que Claude Code lee, organizadas para cargar **solo lo que cada tarea necesita** (no un manual gigante), y con un **candado** que de ley te declara qué va a hacer y qué tan a fondo, antes de empezar.

## Cómo funciona (en corto)

- **Escalones:** cada sub-protocolo (empezar proyecto, evaluar una herramienta, revisar seguridad, etc.) es un archivo aparte. Claude carga solo el que tu tarea pide.
- **Router:** una tabla que mapea "lo que dices" → "qué escalón cargar". Un *hook* la entrega en cada turno.
- **Candado:** antes de cualquier trabajo de proyecto, Claude declara *"voy a usar el escalón X, con este esfuerzo, ¿de acuerdo?"* y tú apruebas o ajustas. No depende de que Claude se acuerde — lo fuerza el hook.

## Instalar

Requisitos: macOS o Linux, [Claude Code](https://claude.com/claude-code), y `bash`. (`jq` es opcional; si lo tienes, el registro del hook es automático.)

```bash
git clone <este-repo> nimbus
cd nimbus
bash install.sh
```

El instalador es **idempotente** (lo puedes correr varias veces) y **no destructivo** (hace backup de `~/.claude/` antes de tocar nada y nunca pisa tu `CLAUDE.md`). Te preguntará tu nombre para que NIMBUS te hable por él.

## Personalizar (onboarding)

Después de instalar, abre Claude Code y di:

```
configura NIMBUS
```

(o usa la skill `/nimbus-setup`). Claude correrá un grill corto — una pregunta a la vez — para personalizar NIMBUS a tu gusto y tu entorno (nombre, voz o texto, tus proyectos, idioma). Lo que respondas se guarda en tu capa **persona** (`~/.claude/persona/`), que es **tuya y privada**.

## Quitar

```bash
bash uninstall.sh
```

Pide escribir `DESINSTALAR`, hace backup, y deja tu capa persona intacta.

## Salud

```bash
bash nimbus-doctor.sh
```

Verifica que todo quedó bien instalado (flujo, escalones, hook, bloque del CLAUDE.md).

## Privacidad

Este repo es **genérico**: no contiene datos de nadie. Tu información (tus ideas, tus criterios, tus proyectos) vive solo en tu `~/.claude/persona/` local y **nunca** se sube a ningún lado por NIMBUS.
