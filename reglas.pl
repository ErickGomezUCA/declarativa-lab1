% Nombre y carnet: Erick Bladimir Gomez Hernandez - 00300723
:- consult('./hechos.pl').

% Reglas

% Regla 1. Un superviviente puede atacar a un enemigo si es superviviente de la isla, tiene un hacha en su inventario y el objetivo es un enemigo.
% Propósito: hay que reconocer cuáles de los sobrevivientes se pueden defender por sí mismos, y de quiénes se tiene que defender.
puede_atacar(Superviviente, Enemigo) :-
    superviviente(Superviviente),
    tiene_objeto(Superviviente, hacha),
    enemigo(Enemigo).

% Regla 2. Zona y momento viables para salir a construir una base, debe haber al menos un material disponible en esa zona, y el nivel de peligro en ese momento no debe ser alto.
% Propósito: hay conocer las zonas y los momentos que sean seguros para salir a recolectar recursos y construir una base para sobrevivir. 
% Por ejemplo, de día en la superficie es la única opción viable, porque la zona tiene materiales y su peligro no es alto. De noche el peligro es alto así que no es viable. Las cuevas siempre tienen peligro alto en todo momento. Y el búnker no tiene materiales, aunque no tenga enemigos.
viable_construir(Zona, Momento) :-
    material_aparece(_, Zona),
    nivel_peligro(Zona, Nivel, Momento),
    \==(Nivel, alto).

% Regla 3. Zonas y momentos donde Kelvin puede recoger troncos o construir una base, ya que la zona cuenta con los materiales necesarios y el peligro en ese momento no es alto.
% Propósito: es importante reconocer en qué zonas y momentos se puede llevar a Kelvin para ayudar a construir la base, en caso de que no sea viable, es mejor no exponerlo al peligro.
% Hay un OR entre cargar_tronco y construir, esto es porque Kelvin no puede hacer ambas acciones a la vez, y también puede ser asistido por Eric.
kelvin_puede_construir(Zona, Momento) :-
    ( puede(kelvin, cargar_tronco) ; puede(kelvin, construir) ),
    material_aparece(troncos, Zona),
    material_aparece(piedras, Zona),
    nivel_peligro(Zona, Nivel, Momento),
    \==(Nivel, alto).