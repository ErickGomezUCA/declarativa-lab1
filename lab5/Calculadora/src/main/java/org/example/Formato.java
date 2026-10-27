package org.example;

import alice.tuprolog.Number;
import alice.tuprolog.Struct;
import alice.tuprolog.Term;

import java.math.BigDecimal;
import java.math.RoundingMode;

/** Convierte un término de Prolog en texto legible: 3*x^2 + 1 en lugar de '+'('*'(3,'^'(x,2)),1). */
public final class Formato {

    private Formato() {
    }

    public static String texto(Term t) {
        return texto(t, 1200, false);
    }

    /**
     * @param max     precedencia máxima que acepta la posición sin paréntesis
     * @param derecha true si el término va a la derecha de un operador binario
     */
    private static String texto(Term t, int max, boolean derecha) {
        t = t.getTerm();

        if (t instanceof Number n) {
            String s = numero(n);
            return s.startsWith("-") && (derecha || max < 200) ? "(" + s + ")" : s;
        }
        if (!(t instanceof Struct st)) {
            return t.toString();
        }

        String nombre = st.getName();
        int prec = precedencia(st);

        // Signo negativo: -x, -2*x, -sin(x)/2 (en sumas y restas sí hacen falta paréntesis)
        if (prec == 200 && st.getArity() == 1) {
            String s = "-" + texto(st.getArg(0), 400, false);
            return prec > max || derecha ? "(" + s + ")" : s;
        }

        // Operadores binarios
        if (prec > 0) {
            // ^ asocia a la derecha (xfy), los demás a la izquierda (yfx)
            int maxIzq = nombre.equals("^") ? prec - 1 : prec;
            int maxDer = nombre.equals("^") ? prec : prec - 1;
            // a*(b*c) y a + (b + c) se pueden escribir sin paréntesis
            if ((nombre.equals("*") || nombre.equals("+")) && esOperador(st.getArg(1), nombre)) {
                maxDer = prec;
            }
            String sep = prec == 500 ? " " + nombre + " " : nombre;
            String s = texto(st.getArg(0), maxIzq, false) + sep + texto(st.getArg(1), maxDer, true);
            return prec > max ? "(" + s + ")" : s;
        }

        // Átomos y funciones: x, sin(x), log(abs(x))
        if (st.getArity() == 0) {
            return nombre;
        }
        StringBuilder sb = new StringBuilder(nombre).append('(');
        for (int i = 0; i < st.getArity(); i++) {
            if (i > 0) sb.append(", ");
            sb.append(texto(st.getArg(i), 999, false));
        }
        return sb.append(')').toString();
    }

    private static boolean esOperador(Term t, String nombre) {
        return t.getTerm() instanceof Struct st && st.getArity() == 2 && st.getName().equals(nombre);
    }

    private static int precedencia(Struct st) {
        String nombre = st.getName();
        if (st.getArity() == 1 && nombre.equals("-")) return 200;
        if (st.getArity() != 2) return 0;
        return switch (nombre) {
            case "+", "-" -> 500;
            case "*", "/" -> 400;
            case "^" -> 200;
            default -> 0;
        };
    }

    /** Enteros tal cual; decimales con hasta 6 cifras y sin ceros de más. */
    public static String numero(Number n) {
        if (n.isInteger()) {
            return Long.toString(n.longValue());
        }
        double v = n.doubleValue();
        if (Double.isNaN(v) || Double.isInfinite(v)) {
            return Double.toString(v);
        }
        BigDecimal bd = BigDecimal.valueOf(v).setScale(6, RoundingMode.HALF_UP).stripTrailingZeros();
        if (bd.signum() == 0) {
            return "0";
        }
        return bd.scale() < 0 ? bd.setScale(0).toPlainString() : bd.toPlainString();
    }
}
