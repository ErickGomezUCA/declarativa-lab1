% =====================================================================
%  Calculadora de derivadas e integrales
%
%  Predicados que consulta Java:
%    derivada(X, F, R)            R = f'(x) simplificada
%    integral(X, F, R)            R = primitiva de f(x) simplificada
%    derivada_en(X, F, X0, R)     R = f'(x0)
%    area(X, F, A, B, R)          R = integral definida de f entre A y B
%
%  d/3 y s/3 contienen las reglas de derivacion e integracion. Cada
%  clausula termina su seleccion con un corte (!) para que, una vez
%  elegida una regla, Prolog no pruebe las siguientes y no devuelva
%  soluciones duplicadas o incorrectas al hacer backtracking.
% =====================================================================

% ---------------------------------------------------------------------
%  Predicados principales
% ---------------------------------------------------------------------

derivada(X, F, R) :-
    simplificar(F, F1),
    d(X, F1, D),
    simplificar(D, R).

integral(X, F, R) :-
    simplificar(F, F1),
    s(X, F1, I),
    simplificar(I, R).

% Derivada evaluada en un punto
derivada_en(X, F, X0, R) :-
    derivada(X, F, D),
    evaluar(X, D, X0, R).

% Area bajo la curva (integral definida) por el teorema fundamental:
% G(B) - G(A), con G primitiva de F
area(X, F, A, B, R) :-
    integral(X, F, G),
    evaluar(X, G, B, GB),
    evaluar(X, G, A, GA),
    R is GB - GA.

% ---------------------------------------------------------------------
%  Utilidades
% ---------------------------------------------------------------------

% contiene(X, E): la expresion E depende de la variable X
contiene(X, E) :- E == X, !.
contiene(X, E) :- compound(E), E =.. [_|Args], contiene_lista(X, Args).

contiene_lista(X, [A|_]) :- contiene(X, A), !.
contiene_lista(X, [_|As]) :- contiene_lista(X, As).

% constante(X, E): E no depende de X (numeros, otras letras, log(2), ...)
constante(X, E) :- \+ contiene(X, E).

% sustituir(X, V, E, R): R es E con cada aparicion de X cambiada por V
sustituir(X, V, E, V) :- E == X, !.
sustituir(_, _, E, E) :- atomic(E), !.
sustituir(X, V, E, R) :-
    E =.. [F|Args],
    sustituir_lista(X, V, Args, Args1),
    R =.. [F|Args1].

sustituir_lista(_, _, [], []).
sustituir_lista(X, V, [A|As], [B|Bs]) :-
    sustituir(X, V, A, B),
    sustituir_lista(X, V, As, Bs).

% lineal(X, U, A): U es de la forma A*x + B, con A numero distinto de 0
lineal(X, U, A) :-
    d(X, U, DU),
    simplificar(DU, A),
    number(A),
    A =\= 0.

% =====================================================================
%  DERIVADAS  d(Var, Funcion, Derivada)
% =====================================================================

% ---- Casos base ----

% Derivada de una constante
d(Var, Func, 0) :-
    atomic(Var), number(Func), !.

% Derivada de una variable con respecto a si misma
d(Var, Func, 1) :-
    Var == Func, !.

% Derivada de cualquier expresion que no dependa de la variable
d(Var, Func, 0) :-
    constante(Var, Func), !.

% Derivada de una variable por una constante
d(Var, N*Var, N) :-
    atomic(Var), number(N), !.

% Derivada de una variable elevada a la N
d(Var, Var^N, N*Var^Nm1) :-
    number(N), !, is(Nm1, N - 1).

% Derivada de una variable elevada a la N por una constante
d(Var, K*Var^N, C*Var^Nm1) :-
    atomic(Var), number(K), number(N), !, is(C, K*N), is(Nm1, N-1).

% Derivada de un logaritmo natural
d(Var, log(Var), 1/Var) :-
    atomic(Var), !.

% Derivada de la exponencial, seno y coseno
d(Var, exp(Var), exp(Var)) :- !.
d(Var, sin(Var), cos(Var)) :- !.
d(Var, cos(Var), -sin(Var)) :- !.

% ---- Casos recursivos ----

% Signo negativo: (-u)' = -u'
d(Var, -U, -DU) :- !,
    d(Var, U, DU).

% Suma: (u + v)' = u' + v'
d(Var, U+V, DU+DV) :- !,
    d(Var, U, DU), d(Var, V, DV).

% Resta: (u - v)' = u' - v'
d(Var, U-V, DU-DV) :- !,
    d(Var, U, DU), d(Var, V, DV).

% Constante por funcion: (k*u)' = k*u'
d(Var, K*U, K*DU) :-
    constante(Var, K), !, d(Var, U, DU).
d(Var, U*K, K*DU) :-
    constante(Var, K), !, d(Var, U, DU).

% Producto: (u*v)' = u'*v + u*v'
d(Var, U*V, DU*V + U*DV) :- !,
    d(Var, U, DU), d(Var, V, DV).

% Funcion entre constante: (u/k)' = u'/k
d(Var, U/K, DU/K) :-
    constante(Var, K), !, d(Var, U, DU).

% Constante entre funcion: (k/v)' = -k*v'/v^2
d(Var, K/V, -K*DV/V^2) :-
    constante(Var, K), !, d(Var, V, DV).

% Cociente: (u/v)' = (u'*v - u*v') / v^2
d(Var, U/V, (DU*V - U*DV)/V^2) :- !,
    d(Var, U, DU), d(Var, V, DV).

% Potencia con exponente constante (regla de la cadena):
% (u^n)' = n*u^(n-1)*u'
d(Var, U^N, N*U^(N-1)*DU) :-
    constante(Var, N), !, d(Var, U, DU).

% Exponencial de base e: (e^u)' = e^u*u'
d(Var, e^U, e^U*DU) :- !,
    d(Var, U, DU).

% Exponencial de base constante: (a^u)' = a^u*ln(a)*u'
d(Var, A^U, A^U*log(A)*DU) :-
    constante(Var, A), !, d(Var, U, DU).

% Potencia general: (u^v)' = u^v*(v'*ln(u) + v*u'/u)
d(Var, U^V, U^V*(DV*log(U) + V*DU/U)) :- !,
    d(Var, U, DU), d(Var, V, DV).

% Funciones compuestas (regla de la cadena)
d(Var, exp(U), exp(U)*DU) :- !, d(Var, U, DU).
d(Var, log(U), DU/U) :- !, d(Var, U, DU).
d(Var, sin(U), cos(U)*DU) :- !, d(Var, U, DU).
d(Var, cos(U), -sin(U)*DU) :- !, d(Var, U, DU).
d(Var, tan(U), DU/cos(U)^2) :- !, d(Var, U, DU).
d(Var, sqrt(U), DU/(2*sqrt(U))) :- !, d(Var, U, DU).

% =====================================================================
%  INTEGRALES  s(Var, Funcion, Primitiva)
% =====================================================================

% ---- Casos base ----

% Integral de una constante
s(Var, K, K*Var) :-
    number(K), atomic(Var), !.
s(Var, K, K*Var) :-
    constante(Var, K), !.

% Integral de una variable con respecto a si misma
s(Var, Var, 1/2*Var^2) :-
    atomic(Var), !.

% Integral de x^-1 = ln|x|
s(Var, Var^N, log(abs(Var))) :-
    N == -1, !.
s(Var, 1/Var, log(abs(Var))) :- !.

%% Integral de una constante por una variable elevada a la N
s(Var, K*Var^N, K/M*Var^M) :-
    atomic(Var), number(K), number(N), !, is(M, N+1).

% Integral de una variable elevada a la N
s(Var, Var^N, Var^(N+1)/(N+1)) :-
    constante(Var, N), !.

% 1/x^n = x^(-n)
s(Var, 1/Var^N, R) :-
    number(N), !, is(N1, -N), s(Var, Var^N1, R).

% Raiz cuadrada: sqrt(x) = x^(1/2)
s(Var, sqrt(Var), R) :- !,
    s(Var, Var^(1/2), R).

% Exponenciales
s(Var, exp(Var), exp(Var)) :- !.
s(Var, e^Var, e^Var) :- !.
s(Var, A^Var, A^Var/log(A)) :-
    constante(Var, A), !.

% Trigonometricas y logaritmo
s(Var, sin(Var), -cos(Var)) :- !.
s(Var, cos(Var), sin(Var)) :- !.
s(Var, tan(Var), -log(abs(cos(Var)))) :- !.
s(Var, log(Var), Var*log(Var) - Var) :- !.

% ---- Casos recursivos (linealidad) ----

% Signo negativo
s(Var, -U, -R) :- !,
    s(Var, U, R).

% Suma y resta: se integra termino por termino
s(Var, U+V, RU+RV) :- !,
    s(Var, U, RU), s(Var, V, RV).
s(Var, U-V, RU-RV) :- !,
    s(Var, U, RU), s(Var, V, RV).

% Constante por funcion: la constante sale de la integral
s(Var, K*U, K*R) :-
    constante(Var, K), !, s(Var, U, R).
s(Var, U*K, K*R) :-
    constante(Var, K), !, s(Var, U, R).
s(Var, U/K, R/K) :-
    constante(Var, K), !, s(Var, U, R).
s(Var, K/U, K*R) :-
    constante(Var, K), K \== 1, !, s(Var, 1/U, R).

% ---- Cambio de variable lineal: f(a*x + b) ----
% Si conocemos la primitiva G de f(x), la de f(a*x + b) es G(a*x + b)/a

% (U \== Var evita que la regla se llame a si misma para siempre, ej. tan(x))

s(Var, 1/U, log(abs(U))/A) :-
    U \== Var, lineal(Var, U, A), !.
s(Var, U^N, R) :-
    U \== Var, constante(Var, N), lineal(Var, U, A), !,
    s(Var, Var^N, G), sustituir(Var, U, G, GU), R = GU/A.
s(Var, e^U, e^U/A) :-
    U \== Var, lineal(Var, U, A), !.
s(Var, F, GU/A) :-
    F =.. [Nombre, U], U \== Var, lineal(Var, U, A), !,
    F1 =.. [Nombre, Var], s(Var, F1, G), sustituir(Var, U, G, GU).

% =====================================================================
%  SIMPLIFICACION
%  Se aplica simp/2 una y otra vez hasta que la expresion ya no cambia.
% =====================================================================

simplificar(E, R) :-
    simp(E, E1),
    ( E1 == E -> R = E ; simplificar(E1, R) ).

simp(E, E) :- atomic(E), !.
simp(-A, R) :- !,
    simp(A, A1), neg(A1, R).
simp(E, R) :-
    E =.. [Op, A, B], operador(Op), !,
    simp(A, A1), simp(B, B1), s_op(Op, A1, B1, R).
simp(E, R) :-
    E =.. [F, A], !,
    simp(A, A1), E1 =.. [F, A1], s_fun(E1, R).
simp(E, E).

operador('+').
operador('-').
operador('*').
operador('/').
operador('^').

% ---- Numeros: enteros, decimales y fracciones N/D ----

numerico(E) :- number(E), !.
numerico(N/D) :- integer(N), integer(D).

% vale(K, V): K es un numero igual a V (sirve tanto para 1 como para 1.0)
vale(K, V) :- number(K), K =:= V.

% Si ambos lados son numericos se calcula el resultado
s_op(Op, A, B, R) :-
    numerico(A), numerico(B), calcular(Op, A, B, R), !.

% ---- Suma ----
s_op('+', A, B, B) :- vale(A, 0), !.
s_op('+', A, B, A) :- vale(B, 0), !.
s_op('+', A, -B, A-B) :- !.
s_op('+', -A, B, B-A) :- !.
s_op('+', A, B, A-B1) :- negativo(B, B1), !.
s_op('+', A, B, (KA+KB)*T) :- semejantes(A, B, KA, KB, T), !.
s_op('+', K, B, B+K) :- numerico(K), !.
s_op('+', A+K1, K2, A+(K1+K2)) :- numerico(K1), numerico(K2), !.
s_op('+', A, B, A+B).

% ---- Resta ----
s_op('-', A, B, A) :- vale(B, 0), !.
s_op('-', A, B, -B) :- vale(A, 0), !.
s_op('-', A, B, 0) :- A == B, !.
s_op('-', A, -B, A+B) :- !.
s_op('-', A, B, A+B1) :- negativo(B, B1), !.
s_op('-', A, B, (KA-KB)*T) :- semejantes(A, B, KA, KB, T), !.
s_op('-', A+K1, K2, A+(K1-K2)) :- numerico(K1), numerico(K2), !.
s_op('-', A, B, A-B).

% ---- Multiplicacion ----
s_op('*', A, _, 0) :- vale(A, 0), !.
s_op('*', _, B, 0) :- vale(B, 0), !.
s_op('*', A, B, B) :- vale(A, 1), !.
s_op('*', A, B, A) :- vale(B, 1), !.
s_op('*', A, B, -B) :- vale(A, -1), !.
s_op('*', A, B, -A) :- vale(B, -1), !.
s_op('*', -A, B, -(A*B)) :- !.
s_op('*', A, -B, -(A*B)) :- !.
s_op('*', A, K, K*A) :- numerico(K), !.
s_op('*', N/D, B, (N*B)/D) :- integer(N), integer(D), !.
s_op('*', K1, K2*B, (K1*K2)*B) :- numerico(K1), numerico(K2), !.
s_op('*', A, K*B, K*(A*B)) :- numerico(K), !.
s_op('*', K*A, B, K*(A*B)) :- numerico(K), !.
s_op('*', A, B/C, (A*B)/C) :- !.
s_op('*', A/B, C, (A*C)/B) :- !.
s_op('*', A, B, A^2) :- A == B, !.
s_op('*', A^M, B, A^(M+1)) :- A == B, !.
s_op('*', A, B^N, B^(N+1)) :- A == B, !.
s_op('*', A^M, B^N, A^(M+N)) :- A == B, !.
s_op('*', A, B, A*B).

% ---- Division ----
s_op('/', A, _, 0) :- vale(A, 0), !.
s_op('/', A, B, A) :- vale(B, 1), !.
s_op('/', A, B, 1) :- A == B, !.
s_op('/', -A, B, -(A/B)) :- !.
s_op('/', A, -B, -(A/B)) :- !.
s_op('/', A, D, -(A/D1)) :- number(D), D < 0, !, D1 is -D.
s_op('/', K*A, D, (K1*A)/D1) :-
    integer(K), integer(D), mcd(K, D, G), G > 1, !,
    K1 is K // G, D1 is D // G.
s_op('/', A/B, C, A/(B*C)) :- !.
s_op('/', A, B/C, (A*C)/B) :- !.
s_op('/', A^M, B^N, A^(M-N)) :- A == B, !.
s_op('/', A^M, B, A^(M-1)) :- A == B, !.
s_op('/', A, B^N, 1/B^(N-1)) :- A == B, !.
s_op('/', K*A, B, K) :- A == B, !.
s_op('/', K*A, B^N, K/B^(N-1)) :- A == B, !.
s_op('/', A, B, A/B).

% ---- Potencia ----
s_op('^', _, B, 1) :- vale(B, 0), !.
s_op('^', A, B, A) :- vale(B, 1), !.
s_op('^', A, _, 1) :- vale(A, 1), !.
s_op('^', A^M, N, A^(M*N)) :- numerico(M), numerico(N), !.
s_op('^', A, N, 1/A^M) :- negativo(N, M), !.
s_op('^', A, B, A^B).

% ---- Signo negativo ----
neg(A, R) :- number(A), !, R is -A.
neg(N/D, M/D) :- integer(N), integer(D), !, M is -N.
neg(-A, A) :- !.
neg(K*A, K1*A) :- number(K), !, K1 is -K.
neg(K/A, K1/A) :- number(K), !, K1 is -K.
neg((K*A)/B, (K1*A)/B) :- number(K), !, K1 is -K.
neg(A-B, B-A) :- !.
neg(A, -A).

% negativo(E, P): E es un termino con coeficiente negativo y P es su opuesto
negativo(K, P) :- number(K), K < 0, !, P is -K.
negativo(N/D, P/D) :- integer(N), integer(D), N < 0, !, P is -N.
negativo(K*T, P*T) :- number(K), K < 0, !, P is -K.

% semejantes(A, B, KA, KB, T): A = KA*T y B = KB*T (terminos semejantes)
semejantes(A, B, KA, KB, T) :-
    coeficiente(A, KA, T), coeficiente(B, KB, TB),
    T == TB, \+ numerico(T).

coeficiente(K*T, K, T) :- numerico(K), !.
coeficiente(T, 1, T).

% ---- Funciones con valores conocidos ----
s_fun(ln(A), log(A)) :- !.
s_fun(log(1), 0) :- !.
s_fun(log(e), 1) :- !.
s_fun(exp(0), 1) :- !.
s_fun(sin(0), 0) :- !.
s_fun(cos(0), 1) :- !.
s_fun(E, E).

% ---------------------------------------------------------------------
%  Aritmetica exacta con fracciones
%  (en tuProlog 6/4 da 1 y ^ no se puede evaluar con is)
% ---------------------------------------------------------------------

calcular(Op, A, B, R) :-
    racional(A, N1, D1), racional(B, N2, D2), !,
    calcular_racional(Op, N1, D1, N2, D2, R).
calcular(Op, A, B, R) :-
    a_decimal(A, FA), a_decimal(B, FB),
    calcular_decimal(Op, FA, FB, R).

racional(E, E, 1) :- integer(E), !.
racional(N/D, N, D) :- integer(N), integer(D).

calcular_racional('+', N1, D1, N2, D2, R) :-
    N is N1*D2 + N2*D1, D is D1*D2, fraccion(N, D, R).
calcular_racional('-', N1, D1, N2, D2, R) :-
    N is N1*D2 - N2*D1, D is D1*D2, fraccion(N, D, R).
calcular_racional('*', N1, D1, N2, D2, R) :-
    N is N1*N2, D is D1*D2, fraccion(N, D, R).
calcular_racional('/', N1, D1, N2, D2, R) :-
    N2 =\= 0, N is N1*D2, D is D1*N2, fraccion(N, D, R).
calcular_racional('^', N1, D1, K, 1, R) :-
    K >= 0, !, potencia(N1, K, N), potencia(D1, K, D), fraccion(N, D, R).
calcular_racional('^', N1, D1, K, 1, R) :-
    N1 =\= 0, M is -K, potencia(N1, M, N), potencia(D1, M, D), fraccion(D, N, R).

% fraccion(N, D, R): R es N/D reducida (o un entero si D divide a N)
fraccion(N, D, R) :-
    D =\= 0, mcd(N, D, G),
    N1 is N // G, D1 is D // G,
    ( D1 < 0 -> N2 is -N1, D2 is -D1 ; N2 = N1, D2 = D1 ),
    ( D2 =:= 1 -> R = N2 ; R = N2/D2 ).

mcd(A, B, G) :-
    A1 is abs(A), B1 is abs(B), mcd_(A1, B1, G).
mcd_(A, 0, A) :- !.
mcd_(A, B, G) :- R is A mod B, mcd_(B, R, G).

potencia(_, 0, 1) :- !.
potencia(B, N, R) :- N1 is N - 1, potencia(B, N1, R1), R is B * R1.

a_decimal(E, F) :- number(E), !, F is E * 1.0.
a_decimal(N/D, F) :- F is N * 1.0 / D.

calcular_decimal('+', A, B, R) :- R is A + B.
calcular_decimal('-', A, B, R) :- R is A - B.
calcular_decimal('*', A, B, R) :- R is A * B.
calcular_decimal('/', A, B, R) :- B =\= 0, R is A / B.
calcular_decimal('^', A, B, R) :- R is A ** B.

% =====================================================================
%  EVALUACION NUMERICA
%  evaluar(X, E, V, R): R es el valor de E cuando X vale V
% =====================================================================

evaluar(X, E, V, R) :-
    eval(V, V1),
    sustituir(X, V1, E, E1),
    eval(E1, R).

eval(N, N) :- number(N), !.
eval(e, R) :- !, R is exp(1).
eval(pi, R) :- !, R is 4 * atan(1).
eval(-A, R) :- !, eval(A, VA), R is -VA.
eval(A+B, R) :- !, eval(A, VA), eval(B, VB), R is VA + VB.
eval(A-B, R) :- !, eval(A, VA), eval(B, VB), R is VA - VB.
eval(A*B, R) :- !, eval(A, VA), eval(B, VB), R is VA * VB.
eval(A/B, R) :- !, eval(A, VA), eval(B, VB), VB =\= 0, R is VA * 1.0 / VB.
eval(A^B, R) :- !, eval(A, VA), eval(B, VB), R is VA ** VB.
eval(sqrt(A), R) :- !, eval(A, VA), VA >= 0, R is sqrt(VA).
eval(log(A), R) :- !, eval(A, VA), VA > 0, R is log(VA).
eval(ln(A), R) :- !, eval(log(A), R).
eval(exp(A), R) :- !, eval(A, VA), R is exp(VA).
eval(sin(A), R) :- !, eval(A, VA), R is sin(VA).
eval(cos(A), R) :- !, eval(A, VA), R is cos(VA).
eval(tan(A), R) :- !, eval(A, VA), R is sin(VA) / cos(VA).
eval(abs(A), R) :- !, eval(A, VA), R is abs(VA).
