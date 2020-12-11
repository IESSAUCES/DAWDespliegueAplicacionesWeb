# Comprobamos que se ejecuta con permisos de root
user=$(whoami)
if [ "$user" != "root" ]; then
    echo "Necesitas tener permisos de root :("
    exit 1
fi


# Creamos las variables
# DIR_APACHE es el directorio donde estaran todos los home de los usuarios
# GRUPO_SFTP sera el grupo deberemos tener creado

DIR_APACHE="/var/www/"
GRUPO_SFTP="ftpusers"
DOMINIO="cristina.local"
SUFIJO_USUARIO="DAW"


# Comprobamos que el grupo de usuarios existe
# Con esta linea mostramos el fichero /etc/group si no muestra ninguna linea el codigo de error es 1
more /etc/group | grep "$GRUPO_SFTP" > /dev/null

if [ $? != 0 ]; then
    echo "Error!, el grupo $GRUPO_SFTP no existe"
    exit 0
fi 

#Comprobamos que el directorio de usuarios existe
if [ ! -d "$DIR_APACHE" ]; then
    echo "Error!, el directorio de usuarios no existe"
    exit 0
fi


#Pedimos el nombre de usuario hasta que se introduza un nombre
#while  [ "$USUARIO" == "" ]
#do
#	echo "Introduzca el nombre de usuario: "
#	read USUARIO
#done

CURSO=2
echo "CURSO $CURSO"
while [ $CURSO -lt 3 ]; do
	echo "CURSO: $CURSO "
	if [ $CURSO -eq 1 ]; then
	VALOR_INICIAL=101
	VALOR_FINAL=117
	else
	VALOR_INICIAL=201
	VALOR_FINAL=217
	fi
	let CURSO+=1
	echo "VALOR INICIAL $VALOR_INICIAL"
	for (( NUM=VALOR_INICIAL; NUM<=VALOR_FINAL; NUM++ ))
		do
		echo $NUM " "
		USUARIO=$SUFIJO_USUARIO$NUM;
		echo $USUARIO;
		PASSWORD="paso"
		#Creamos el usuario 
		useradd -G "$GRUPO_SFTP" -m -d  "$DIR_APACHE$USUARIO" -g www-data -p "paso" -s /bin/false "$USUARIO" 
		if [ $? -eq 0 ]
		then
			echo "Usuario creado correctamente $USUARIO"
		else
			echo "Error al crear el usuario $USUARIO"
			exit 1
		fi


# Le asignamos una contraseña
 	 echo $USUARIO:$PASSWORD |chpasswd

# Necesario para el chroot 
	chown root:root "$DIR_APACHE$USUARIO"

#Creamos el directorio de apache 
	mkdir "$DIR_APACHE$USUARIO/public_html"

#Asignamos permisos al directorio www
	chmod -c 2775 "$DIR_APACHE$USUARIO/public_html"
	chgrp "www-data" "$DIR_APACHE$USUARIO/public_html"
	chown "$USUARIO"  "$DIR_APACHE$USUARIO/public_html"

#  Crear el fichero index.html
	touch  "$DIR_APACHE$USUARIO/public_html"

	printf "%s\n"\
	"En construccion"   >>"/var/www/$USUARIO/public_html/index.html"


	chgrp  -R "www-data" "$DIR_APACHE$USUARIO/public_html"
	chown -R "$USUARIO"  "$DIR_APACHE$USUARIO/public_html/index.html"


#Vamos con apache
#Creamos el sitio 
 printf  "%s\n"\
        "<VirtualHost *:80>"\
        "       ServerName $USUARIO.$DOMINIO"\
        "       ServerAdmin webmaster@localhost"\
        "       DocumentRoot $DIR_APACHE$USUARIO/public_html/"\
	"	ServerAlias www.$USUARIO.$DOMINIO"\
        "       DirectoryIndex index.htm index.html index.php index.jsp"\
        "</VirtualHost>"\
 	>/etc/apache2/sites-available/"$USUARIO".conf

#Habilitamos el sitio
 a2ensite "$USUARIO.conf"
 echo "Sitio creado para el dominio http://$USUARIO.$DOMINIO"
	done
done
#Reiniciamos apache
 /etc/init.d/apache2 restart

#echo "Sitio creado para el dominio http://$USUARIO.$DOMINIO"
