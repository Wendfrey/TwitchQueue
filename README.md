# TwitchQueue
Bot para Twitch.tv para hacer una cola de usuarios

## Funciones
- Total control de la cola
- Permite vetar a jugadores
- Personalizar comandos (añadir alias, añadir o quitar permisos)

## Iniciar sesión
Primero deberás iniciar sesión, para ello sigue los siguientes pasos:

1. Pulsa el boton Iniciar
2. Pon usuario, token y canal (para obtener el token de usuario consulta https://twitchapps.com/tmi/)
3. Listo!

## Comandos
### !queue_clear
  Elimina a todos los jugadores de la cola

###!queue_join
  Únete a la cola!

### !queue_exit
  Salte de la cola

### !queue_top10
  Muestra al jugador actual y a los 10 primeros de la cola
  
### !queue_commands
  Muestra los comandos disponibles en el chat

### !queue_next
  Avanza la lista y actualiza al jugador actual

### !queue_position
  Muestra al espectador en que posición de la cola está

### !queue_rmp <espectador>
  Elimina al espectador de la cola

### !queue_ban <espectador>
  Veta al espectador de la cola
  
### !queue_unban <espectador>
  Desveta al jugador de la cola
  
## Funciones extra del cliente

### Controles intuitivos
  Pulsa a un espectador en cola o vetado para abrir un menu desplegable!
  
### Personalizar comandos
Para personalizar comandos en la barra superior pulsa el boton 'opciones' y dentro del listado 'Cambiar Comandos'.

*La pantalla te permite limitar el permiso minimo que necesita un espectador para poder ejecutar los comandos de chat y añadir alias (separado por comas)*

## Creditos
[Gift](https://github.com/MennoMax/gift) creado por MennoMax
Software creado mediante [Godot Engine](https://godotengine.org/)
