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
DOMINIO="cristina.local"
SUFIJO_USUARIO="DAW"


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
done
done




