# SERVERUS
*Guia de instalación paso a paso*
[Servidor SERVERUS](http://www.serverus.local "Servidor SERVERUS")
## 1. CONFIGURACIÓN DEL SERVIDOR
- [ ] Nombre del servidor
- [ ] Configuración de red
- [ ] Conectividad Internet

## 2. ACCESO REMOTO
- [ ] Instalación de SSH
- [ ] Cliente SSH

## 3. SERVIDOR WEB
- [ ] Instalación apache
- [ ] Comprobación de funcionamiento

## 4. SERVIDOR DNS
- [ ] Instalación bind9
- [ ] Configuración de la zona directa "xxxx.xxx"
- [ ] Configuración de la zona inversa 
- [ ] Reiniciar el servicio
- [ ] Cambiar la configuración de red (/etc/network/interfaces)
- [ ] Comprobar el funcionamiento.

## 5. SERVIDOR DE APLICACIONES PHP con MySQL

### MySQL

- [ ] Instalación de MySQL
- [ ] Testear funcionamiento de MySQL
    
### PHP 7.0
- [ ] Instalación de **PHP7.0**
- [ ] Testear funcionamiento de PHP
        
### MÓDULOS PHP7.0
```bash
sudo apt-get install nombredelmodulo
```
### Instalación de módulos
- [ ] libapache2-mod-php7.0 
- [ ] php7.0-mysql
- [ ] php7.0-intl
- [ ] php7.0-curl
- [ ] php7.0-soap

### Instalacion phpMyAdmin
- [ ] Instalación phpmyadmin
- [ ] Comprobación http://IP/phpmyadmin
  
  
## 6. DAR DE ALTA USUARIOS DEL SISTEMA

1. Crear grupo sftpusers
```bash
sudo  addgroup sftpusers
```
2. Ejecutar el script crear usuarios
```bash
sudo  ./crearUsuario.sh
```
3. SFTP: Enjaular o aislar usuarios

## 7. MYSQL: DAR DE ALTA USUARIOS



    

