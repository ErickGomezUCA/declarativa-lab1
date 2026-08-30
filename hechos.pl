% Nombre y carnet: Erick Bladimir Gomez Hernandez - 00300723

% Hechos

% 1. Personajes
superviviente(eric).
superviviente(timmy).
superviviente(kelvin).
superviviente(virginia).

protagonista(eric).
edad(eric, 30).

aliado(kelvin).
no_habla(kelvin).

mutante_aliada(virginia).

% 2. Objetos y acciones
tiene_objeto(eric, hacha).
tiene_objeto(eric, encendedor).
puede(kelvin, cargar_tronco).
puede(kelvin, construir).

% 3. Zonas
zona(superficie).
zona(cuevas).
zona(bunkeres).

% 4. Enemigos y apariciones
enemigo(canibales).
enemigo(mutantes).

aparece(canibales, superficie).
aparece(mutantes, superficie).
aparece(mutantes, cuevas).

requiere(bunkeres, llave).

% 5. Nivel de peligro
nivel_peligro(cuevas, alto).
nivel_peligro(superficie, medio, dia).
nivel_peligro(superficie, alto, noche).

% 6. Necesidades del jugador para sobrevivir
necesita(eric, refugio).
necesita(eric, comida).
necesita(eric, agua).

% 7. Materiales y donde encontrarlos
material(troncos).
material(piedras).
material_aparece(troncos, superficie).
material_aparece(piedras, superficie).
