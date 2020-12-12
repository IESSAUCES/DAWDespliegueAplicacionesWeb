user=$(whoami)
if [ "$user" != "root" ]; then
    echo "Necesitas tener permisos de root :("
    exit 1
fi

#Creamos las variables
    #DIR_APACHE es el directorio donde estaran todos los home de los usuarios
    #GRUPO_SFTP sera el grupo deberemos tener creado
DIR_APACHE="/var/www/"
GRUPO_SFTP="ftpusers"
DOMINIO="luis.local"
SUFIJO_USUARIO="DAW"
DIR_DNS="/etc/bind/db.luis.local"
HOST="lpfused.${DOMINIO}."

#Comprueba si el fichero existe, en caso de no existir muestra un mensaje de error y sale con el codigo 1
if [[ ! -f $DIR_DNS ]]; then
        echo -e "\e[31mEl fichero $DIR_DNS no existe\e[0m"
        exit 1
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
		USUARIO=$SUFIJO_USUARIO$NUM;
		echo $USUARIO;
		#Eliminamos el usuario
		userdel "$USUARIO"
		if [ $? -eq 0 ]
			then
				echo "Usuario eliminado correctamente"
			else
				echo "Error al eliminar el usuario"
			#	exit 1
		fi

		#Eliminamos el home
		sudo rm -R $DIR_APACHE$USUARIO
		if [ $? -eq 0 ]
			then
				echo "Home del usuario eliminado correctamente"
			else
				echo "Error al eliminar el directorio del usuario"
			#	exit 1
			fi

#Deshabilitamos el sitio en apache
	a2dissite "$USUARIO.conf"

#Eliminamos la configuracion del sitio 
	rm /etc/apache2/sites-available/"$USUARIO".conf


	echo "Usuario $USUARIO eliminado correctamente!"
#Eliminar registros del DNS
	sed -i -E "/^(www.)?$USUARIO/{n;d}" $DIR_DNS > /dev/null 2>&1
	sed -i -E "/^(www.)?$USUARIO/d" $DIR_DNS > /dev/null 2>&1

	if [[ $? -eq 0 ]]; then
	       echo -e "\e[34mEl registro del usuario $USUARIO se ha borrado del DNS\e[0m";
	else
	       echo -e "\e[31mError al borrar el registro DNS de ${USUARIO}\e[0m"
	fi
#Borra la ultima line en blanco
	 sed -i '${/^$/d}' $DIR_DNS > /dev/null 2>&1
done
done
/etc/init.d/apache2 restart


