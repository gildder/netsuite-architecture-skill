# Índice de Documentación

Bienvenido a la documentación de **NetSuite Clean Architecture Skill**.

---

## 📚 Para Usuarios

### Primeros Pasos
| Documento | Descripción |
|-----------|-------------|
| **[GUIA-USUARIO.md](GUIA-USUARIO.md)** | Guía completa para usuarios que quieren crear proyectos |
| **[GUIA-ORKIDNS.md](GUIA-ORKIDNS.md)** | Guía del agente OrkidNS para validar y crear código |

### Referencia
| Documento | Descripción |
|-----------|-------------|
| **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** | Problemas comunes y soluciones |
| **[EXAMPLES.md](EXAMPLES.md)** | Ejemplos prácticos de uso |

---

## 🏗️ Para Desarrolladores

### Arquitectura
| Documento | Descripción |
|-----------|-------------|
| **[ARCHITECTURE.md](ARCHITECTURE.md)** | Explicación de Clean Architecture y Hexagonal Architecture |
| **[SKILL.md](SKILL.md)** | Instrucciones para AI assistants (técnico) |
| **[AGENT.md](AGENT.md)** | Definición del agente OrkidNS (técnico) |

---

## 📁 Estructura de Archivos

```
netsuite-architecture-skill/
├── GUIA-USUARIO.md          ← Punto de inicio para usuarios
├── GUIA-ORKIDNS.md           ← Guía del agente OrkidNS
├── INDICE.md                 ← Este archivo
├── ARCHITECTURE.md          ← Conceptos de arquitectura
├── TROUBLESHOOTING.md       ← Solución de problemas
├── EXAMPLES.md              ← Ejemplos de uso
├── SKILL.md                 ← Para AI assistants
├── AGENT.md                 ← Definición del agente
│
├── scripts/                 ← Scripts ejecutables
│   ├── create-project.ps1   ← Crear proyecto completo
│   ├── create-small.ps1     ← Proyecto pequeño
│   ├── create-medium.ps1    ← Proyecto mediano
│   ├── create-large.ps1     ← Proyecto grande
│   ├── normalize-ts.ps1     ← Normalizar TypeScript
│   ├── orkidns.ps1          ← CLI de OrkidNS
│   └── generate-sdf.ps1     ← Generar XMLs SDF
│
├── orkidns/                 ← Componentes de OrkidNS
│   ├── AGENT.md             ← Definición del agente
│   ├── orkidns.config.json  ← Configuración
│   ├── inference-rules.json ← Reglas de inferencia
│   └── templates/           ← Plantillas de código
│       ├── entity.template.ts
│       ├── service.template.ts
│       ├── repository.template.ts
│       ├── clientscript.template.ts
│       ├── userevent.template.ts
│       ├── mapreduce.template.ts
│       ├── scheduled.template.ts
│       └── portlet.template.ts
│
└── templates/               ← Configuración del proyecto
    ├── biome.json
    └── tsconfig.json
```

---

## 🚀 Inicio Rápido

### ¿Querés crear un proyecto nuevo?

1. Leer **[GUIA-USUARIO.md](GUIA-USUARIO.md)**
2. Ejecutar `scripts/create-project.ps1`

### ¿Querés validar tu código?

1. Leer **[GUIA-ORKIDNS.md](GUIA-ORKIDNS.md)**
2. Ejecutar `scripts/orkidns.ps1 check`

### ¿Tenés problemas?

1. Consultar **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)**

---

## 📋 Checklist de Uso

- [ ] Leer GUIA-USUARIO.md
- [ ] Ejecutar create-project.ps1
- [ ] Entender la estructura de carpetas
- [ ] Usar normalize-ts.ps1 para archivos nuevos
- [ ] Usar orkidns.ps1 para validar
- [ ] Consultar TROUBLESHOOTING.md si hay problemas

---

## 🔗 Enlaces Rápidos

- **Template NetSuite**: https://github.com/gildder/netsuite-ts-sdf-template
- **Clean Architecture**: https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html
- **NetSuite Help**: https://system.netsuite.com/app/help/helpcenter.nl

---

*Última actualización: Mayo 2026*