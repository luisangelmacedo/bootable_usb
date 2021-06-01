#!/bin/bash
# leemos las variables de entrada
opcion=$1
rutaISO=$2
rutaUSB=$3
extISO=$(echo $rutaISO | awk -F . '{print $NF}')
# definimos las funciones
textoAyuda() {
	echo "Esta es la version 1.0 de este programa. La lista de comandos se detalla a continuacion:"
	echo "  --disk  Muestra los discos existentes en el sistema"
	echo "  --boot  Genera el USB booteable, y recibe los parametros"
	echo "          siguientes [-boot rutaArchivoISO rutaDispositivoUSB]"
	echo "          i.e. -boot /home/usr/archivo.iso /dev/sdb1"
	echo "  --help  Muestra este menu informativo desplegado"
}
# comenzamos la logica segun opciones
if [[ -z $opcion ]]; then
	textoAyuda
elif [[ $opcion = "--disk" ]]; then
	echo "Estos son los discos encontrados en el sistema de ficheros:"
	echo ""
	lsblk | awk '{print $1 "\t" $4 "\t" $6 "\t" $7}'
	echo ""
	echo "Considere la primera seccion (sda/sdb/etc) para el parametro rutaDispositivoUSB del comando [--boot]. Guiese por el tamaño, la etiqueta y ruta del dispositivo que quiera usar para hacer la conversion."
elif [[ $opcion = "--boot" ]]; then
	if [[ -z $rutaISO || -z $rutaUSB ]]; then
		echo "Para el comando -boot se requieren los parametros"
		echo "siguientes [-boot rutaArchivoISO rutaDispositivoUSB]"
		echo "i.e. -boot /home/usr/archivo.iso /dev/sdb1"
	else
		if [[ $extISO = "iso" ]]; then
			echo "Esta operacion hará perder todos los datos que están almacenados en el dispositivo."
			echo "Confirme la operacion escribiendo -> (yes/no) y luego presionando ENTER (<RETURN>)."
			read confirmaBoot
			if [[ $confirmaBoot = "yes" ]]; then
				echo "Desmontando dispositivo.."
				sudo umount -q $rutaUSB 2>/dev/null
				echo "Formateando dispositivo.."
				sudo mkfs.vfat -F 32 -n DATADRIVE $rutaUSB 2>/dev/null
				echo "Comenzando operacion boot.."
				sudo dd if=$rutaISO of=$rutaUSB bs=4M status=progress oflag=sync
				echo "Remontando dispositivo.."
				sudo umount -q $rutaUSB 2>/dev/null
				sudo mount -rw $rutaUSB /media/luisangelmacedo 2>/dev/null
				echo "Operacion terminada!"
			else
				echo "Operacion cancelada. Saliendo del programa"
				exit
			fi
		else
			echo "El archivo input indicado no tiene la extensión correcta."
			echo "Solo se admiten archivos de extensión *.iso para las conversiones."
		fi
	fi
elif [[ $opcion = "--help" ]]; then
	textoAyuda
else
	echo "El parametro que ha ingreso no existe para el programa. Ejecute el parametro --help para mas información."
fi