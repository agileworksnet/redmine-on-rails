# Redmine-on-Rails

![Redmine](https://img.shields.io/badge/Redmine-5.0+-b52024?style=for-the-badge&logo=redmine&logoColor=white)
![Rails](https://img.shields.io/badge/Rails-7.0+-CC0000?style=for-the-badge&logo=rubyonrails&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-20.10+-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Ruby](https://img.shields.io/badge/Ruby-3.0+-CC342D?style=for-the-badge&logo=ruby&logoColor=white)
![License](https://img.shields.io/badge/Licencia-MIT-green?style=for-the-badge)

Redmine-on-Rails es una solución containerizada diseñada para simplificar la gestión de Redmine mediante un enfoque de "Aprovisionamiento como Código". Utilizando los inicializadores estándar de Ruby on Rails, el sistema configura automáticamente tu instancia cada vez que inicia. Esto asegura que tu entorno sea siempre consistente y te ahorra el tiempo de realizar configuraciones manuales repetitivas.

## Características Principales

*   **Aprovisionamiento como Código**: Gestiona Roles, Tipos de Petición, Estados, Grupos, Usuarios, Proyectos, Flujos de trabajo y Configuración general usando archivos YAML fáciles de leer.
*   **Arranque Directo**: Levanta una instancia de Redmine completamente operativa con un solo comando.
*   **Ejecución Inteligente**: Los scripts de configuración se ejecutan en cada arranque, pero son lo suficientemente listos para aplicar cambios solo cuando es necesario, evitando duplicados.
*   **Inicio Seguro**: El sistema espera automáticamente a que terminen las migraciones de base de datos antes de configurar nada, garantizando un arranque limpio y sin errores.
*   **Dockerizado**: Todo corre en un entorno aislado y reproducible utilizando Docker y Docker Compose.

## Guía de Inicio

1.  **Clonar el repositorio**:

```bash
git clone https://github.com/tuusuario/redmine-on-rails.git
cd redmine-on-rails
```

2.  **Iniciar la aplicación**:

```bash
docker compose up -d --build
```

3.  **Acceder a Redmine**:

Abra su navegador y navegue a `http://localhost:8080`.

*   **Usuario**: `admin` / `admin` (por defecto)
*   **Usuario Aprovisionado**: `manager` / `password123` (por defecto 12345678 si está configurado)

## Configuración

El sistema de aprovisionamiento vigila el directorio `provision/`. Modifique estos archivos YAML para personalizar su instalación:

* `provision/settings/email.yml`: Configuración de servidor y correo.
* `provision/roles.yml`: Definir roles de usuario.
* `provision/trackers.yml`: Definir tipos de petición (trackers).
* `provision/issue_statuses.yml`: Definir estados de petición.
* `provision/workflows.yml`: Definir transiciones de flujo de trabajo.
* `provision/groups.yml`: Crear grupos de usuarios.
* `provision/users.yml`: Crear usuarios y asignar grupos.
* `provision/projects.yml`: Crear proyectos y asignar miembros.

## Licencia

Este proyecto es de código abierto y está disponible bajo la [Licencia MIT](LICENSE).
