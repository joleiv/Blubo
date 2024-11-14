#!/bin/bash

# Actualización de los repositorios
echo "Actualizando los repositorios..."
sudo apt-get update

# Actualización de paquetes
echo "Actualizando los paquetes..."
sudo apt-get upgrade -y

# Instalación de Git
echo "Instalando Git..."
sudo apt-get install git -y

# Instalación de paquetes de Python
echo "Instalando setuptools..."
sudo pip3 install --upgrade setuptools

echo "Instalando RPi.GPIO..."
sudo pip3 install RPi.GPIO

echo "Instalando Adafruit Blinka..."
sudo pip3 install adafruit-blinka

echo "Instalando Adafruit CircuitPython ADS1x15..."
sudo pip3 install adafruit-circuitpython-ads1x15

echo "Instalando Adafruit IO..."
sudo pip3 install adafruit-io

# Instalación de pigpio
echo "Instalando pigpio..."
sudo apt-get install pigpio python3-pigpio -y

echo "Instalando smbus2..."
sudo pip3 install smbus2

# Creación del servicio pigpiod
echo "Creando el servicio pigpiod en Systemd..."
sudo bash -c 'cat <<EOF > /etc/systemd/system/pigpiod.service
[Unit]
Description=Daemon de pigpio
After=network.target syslog.target

[Service]
ExecStart=/usr/bin/pigpiod
ExecStop=/bin/systemctl kill pigpiod
Type=forking

[Install]
WantedBy=multi-user.target
EOF'

# Recargar Systemd, habilitar e iniciar pigpiod
echo "Recargando Systemd..."
sudo systemctl daemon-reload

echo "Habilitando el servicio pigpiod..."
sudo systemctl enable pigpiod

echo "Iniciando el servicio pigpiod..."
sudo systemctl start pigpiod

# Clonar el repositorio para el Access Point
echo "Clonando el repositorio wifi-connect-headless-rpi..."
git clone https://github.com/drkmsmithjr/wifi-connect-headless-rpi.git

# Cambiar al directorio del script
echo "Accediendo al directorio del script..."
cd wifi-connect-headless-rpi/scripts

# Ejecutar el script de instalación del Access Point
echo "Instalando el Access Point..."
sudo ./rpi_headless_wifi_install.sh

# Regresar al directorio anterior
cd ~

# Activar SSH, I2C, SPI y VNC
echo "Activando SSH..."
sudo systemctl enable ssh
sudo systemctl start ssh

echo "Activando I2C..."
sudo raspi-config nonint do_i2c 0

echo "Activando SPI..."
sudo raspi-config nonint do_spi 0

echo "Activando VNC..."
sudo raspi-config nonint do_vnc 0

# Instalación de Tailscale
echo "Instalando Tailscale..."
sudo apt-get install apt-transport-https -y
curl -fsSL https://pkgs.tailscale.com/stable/raspbian/bullseye.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg > /dev/null
curl -fsSL https://pkgs.tailscale.com/stable/raspbian/bullseye.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
sudo apt-get update
sudo apt-get install tailscale -y

# Mensaje para completar el registro de Tailscale
read -p "Visita la URL proporcionada por Tailscale para registrar tu dispositivo y escribe 'Y' cuando estés listo: " ready
if [ "$ready" == "Y" ] || [ "$ready" == "y" ]; then
    sudo tailscale up --accept-dns=false
fi

# Sugerencia de solución para problema de DNS con Tailscale
echo "Para solucionar problemas de DNS con Tailscale, realiza los siguientes pasos:"
echo "1. Abre el archivo de configuración de DNS: sudo nano /etc/systemd/resolved.conf"
echo "2. Modifica la sección [Resolve] para incluir los siguientes servidores DNS:"
echo "   DNS=8.8.8.8 8.8.4.4"
echo "3. Guarda y cierra el archivo."
echo "4. Reinicia el servicio de resolución de DNS con: sudo systemctl restart systemd-resolved"

# Instalación de FTP Server
echo "Instalando servidor FTP (proftpd)..."
sudo apt install proftpd -y

# Configuración del archivo proftpd.conf
echo "Abriendo proftpd.conf para editar el nombre del servidor. Cambia la línea ServerName según tus preferencias y guarda el archivo."
sudo nano /etc/proftpd/proftpd.conf

# Recargar el servicio FTP
echo "Recargando el servicio FTP..."
sudo service proftpd reload

# Mensaje final
echo "####Reinicia la Raspberry####"