# Imagen de Docker - Esquite Framework v0.3  

## Inicio Rápido  

La versión 0.3 de `Esquite-docker` es más sencilla que la v0.2.  

En la v0.2, un script de control ofrecía múltiples opciones de configuración. Aunque útil, también era propenso a errores y algo complicado de usar.  

Esta nueva versión funciona exclusivamente con una configuración predefinida de Docker Compose, reduciendo la necesidad de configuración manual.  

Para más detalles, consulta el archivo `CHANGELOG`.  

---

### Uso de Docker Compose Directamente  

```sh
git clone https://github.com/ElotlMX/Esquite-docker.git
cd Esquite-docker
docker compose up
```

---

### Acceder a la Interfaz Web de Esquite  

Para acceder al frontend web, utiliza la dirección IP del contenedor.  

- Si ejecutas `docker compose` sin la opción `-d`, Esquite mostrará la dirección IP del contenedor después de cargar.  
- Si ejecutas `docker compose` con la opción `-d` y no configuraste una red personalizada en Docker, revisa los registros del contenedor para encontrar la dirección IP:  

```sh
docker logs NOMBRE_DEL_CONTENEDOR
```

**Ejemplo de salida:**  

```
esquite-1        | [2025-03-02 23:31:02] Esquite Web está disponible en
esquite-1        | [2025-03-02 23:31:02] - http://172.18.0.2       
```

También puedes obtener la dirección IP del contenedor con:  

```sh
docker inspect NOMBRE_DEL_CONTENEDOR | grep IPAddress
```

---

### Exposición de Puertos  

Para hacer que Esquite sea accesible en la red local o en Internet, agrega la configuración de puertos necesaria en el archivo `docker-compose.yaml`.  

**Ejemplo de configuración:**  

```yaml
...
    ports:
      - 80:80
...
```

---

### Acceder a la Sección de Administración de Corpus  

La sección de administración está disponible en:  

```
http://[IP-O-NOMBRE_DEL_HOST]/corpus-admin
```

**Credenciales predeterminadas:**  

- **Usuario:** `esquite`  
- **Contraseña:** `elotl`  

---

## Características de esta Configuración de Docker Compose  

### Directorio de Usuario: `esquite-user`  

El directorio `esquite-user` almacena todos los datos persistentes, garantizando que la configuración del usuario y los archivos cargados permanezcan intactos incluso cuando se crea un nuevo contenedor o se actualiza `Esquite-docker`.  

Contiene los siguientes elementos:  

- **`env.yaml`** — Archivo de configuración de Esquite  
- **`media/`** — Directorio para almacenar archivos subidos a través de `corpus-admin`  
- **`static-user/`** — Directorio para personalizar el frontend de Esquite  
- **`template-user/`** — Directorio para personalizar el contenido del frontend de Esquite  
- **`esquite-http-auth-users.pwd`** — Archivo de configuración de autenticación web para el acceso a `corpus-admin`  

Para más detalles, consulta la documentación de Esquite.  

---

### Proxy Inverso NGINX Integrado  

- NGINX está configurado como un proxy inverso para gestionar todo el tráfico HTTP hacia el backend de Django, facilitando la implementación.  
- La autenticación básica se gestiona mediante el archivo `esquite-user/esquite-http-auth-users.pwd`.  

---

### Configuración de Elasticsearch  

Si la opción `CFG_ESQUITE_ELASTICSEARCH` en `docker-compose.yaml` está configurada como `default-esquite` y la configuración del contenedor de Elasticsearch no está comentada (configuración predeterminada), `Esquite-docker` creará y configurará una instancia de Elasticsearch con un índice predeterminado.  

Esta opción está diseñada para un despliegue y pruebas rápidos.  

Si ya tienes una instancia de Elasticsearch, actualiza los campos `URL` e `Index` en `esquite-user/env.yaml` para especificar la instancia a la que Esquite debe conectarse.  

Si planeas utilizar este contenedor de Elasticsearch en un entorno de producción, asegúrate de ajustar sus parámetros según sea necesario (por ejemplo, nombre del índice, límites de memoria, permisos de la API, etc.).

