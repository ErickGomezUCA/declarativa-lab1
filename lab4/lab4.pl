% Hecho por: Erick Bladimir Gomez Hernandez - 00300723

% Caso base: No hay mas digitos por guardar, ya que es el unico presente (por eso N < 10, ya que no se puede hacer modulo).
almacenar(N, [N]) :- N < 10, !.

% Recursion: Asigamos el primer digito del numero como parte del head (H) y el resto de los digitos se van a recursion con el resto de la lista (T).
almacenar(N, [H|T]) :-
  H is N mod 10,
  N1 is N // 10,
  almacenar(N1, T).
