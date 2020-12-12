# Comprobamos que se ejecuta con permisos de root
user=$(whoami)
if [ "$user" != "root" ]; then
    echo "Necesitas tener permisos de root :("
    exit 1
fi


# Creamos las variables
# DIR_APACHE es el directorio donde estaran todos los home de los usuarios
# GRUPO_SFTP sera el grupo deberemos tener creado
#DIR_DNS es el directorio donde se encuentra el archivo de configuracion de bind9

DIR_APACHE="/var/www/"
GRUPO_SFTP="ftpusers"
DOMINIO="luis.local"
SUFIJO_USUARIO="DAW"
DIR_DNS="/etc/bind/db.luis.local"
HOST="lpfused.${DOMINIO}."

#Comprueba si el fichero existe, en caso de no existir muestra un mensaje de error y sale con el codigo 1 
if [[ ! -f $DIR_DNS ]]; then
	echo -e "\e[31mEl fichero $DIR_DNS no existe, créalo antes de ejecutar el script\e[0m"
	exit 1
fi

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
	" 	ServerAlias www.$USUARIO.$DOMINIO"\
        "       DirectoryIndex index.htm index.html index.php index.jsp"\
        "</VirtualHost>"\
 	>/etc/apache2/sites-available/"$USUARIO".conf

#Habilitamos el sitio
	 a2ensite "$USUARIO.conf"

#Insertar en el DNS, no se comprueba que los registros esten insertados. Comprobar antes de ejecutar, puede crear duplicados en caso contrario
#Insertamos con sed los registros al final del archivo, se redirigen los mensajes a null
#En caso de error se redirige el stderr a stdout 
	sed -i "$ a $USUARIO IN CNAME $HOST" $DIR_DNS > /dev/null 2>&1
#En de que el ultimo comando se halla ejecutado correctamente se mostrara un mensaje indicandolo, en caso contrario se mostrará un mensaje de error
	if [[ $? -eq 0 ]]; then
	       echo -e "\e[34mEl registro $USUARIO se ha insertado correctamente\e[0m";
	else
	       echo -e "\e[32mError al insertar el registro DNS de $USUARIO\e[0m"
	fi
#Inserta el mismo registro de antes pero precedido de www
	sed -i "$ a www.$USUARIO IN CNAME $HOST \n" $DIR_DNS > /dev/null 2>&1
	if [[ $? -eq 0 ]]; then
	       echo -e "\e[34mEl registro www.${USUARIO} se ha insertado correctamente\e[0m";
	else
	       echo -e "\e[31mError al insertar el registro $DNS de www.${USUARIO}\e[0m"
	fi

	done

done

#Reiniciamos apache
/etc/init.d/apache2 restart

echo "Sitio creado para el dominio http://$USUARIO.$DOMINIO"
