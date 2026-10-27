package org.example;

import alice.tuprolog.MalformedGoalException;
import alice.tuprolog.Prolog;
import alice.tuprolog.SolveInfo;
import alice.tuprolog.Theory;

import java.io.InputStream;

public class Connection {
    private final Prolog engine = new Prolog();

    public Connection() throws Exception {
        try (InputStream in = getClass().getResourceAsStream("/calculo.pl")) {
            if (in == null) throw new IllegalStateException("No se encontró calculo.pl");
            engine.setTheory(new Theory(in));
        }
    }

    /**
     * Arma la consulta predicado(x, expresion, extras..., R) y devuelve R como texto.
     * Los extras son el punto donde evaluar o los límites de integración.
     */
    public String consultar(String predicado, String expresion, String... extras) throws Exception {
        StringBuilder consulta = new StringBuilder(predicado)
                .append("(x, ").append(normalizar(expresion));
        for (String extra : extras) {
            consulta.append(", ").append(normalizar(extra));
        }
        consulta.append(", R).");

        SolveInfo info;
        try {
            info = engine.solve(consulta.toString());
        } catch (MalformedGoalException e) {
            throw new IllegalArgumentException("revisá la sintaxis");
        }
        return info.isSuccess() ? Formato.texto(info.getTerm("R"))
                : "Sin solución para esa expresión";
    }

    /**
     * En Prolog las mayúsculas son variables, así que todo se pasa a minúsculas.
     * Además x^-1 no es válido en Prolog, se reescribe como x^(-1).
     */
    private static String normalizar(String texto) {
        return texto.trim()
                .toLowerCase()
                .replaceAll("\\^\\s*-\\s*([0-9.]+)", "^(-$1)");
    }
}
