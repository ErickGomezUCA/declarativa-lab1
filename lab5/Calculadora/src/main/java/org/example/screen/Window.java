package org.example.screen;

import org.example.Connection;
import org.example.screen.components.Buttons;
import org.example.screen.components.PanelResult;
import org.example.screen.components.TextField;

import javax.swing.*;
import javax.swing.border.EmptyBorder;
import java.awt.*;
import java.awt.datatransfer.StringSelection;

/** Ventana principal: arma los componentes y conecta la interfaz con el motor Prolog. */
public class Window extends JFrame {

    private static final String[] EJEMPLOS = {
            "x", "log(x)", "3*x^2", "2^x", "sin(2*x)", "(2*x+1)^3", "x^3 - 2*x + 1"
    };

    private final TextField txtEntrada = new TextField("Ej: 5*x^2");
    private final TextField txtPunto = new TextField("x0", 5, 15);
    private final TextField txtLimiteA = new TextField("a", 5, 15);
    private final TextField txtLimiteB = new TextField("b", 5, 15);
    private final PanelResult panelResultado = new PanelResult();
    private final JLabel lblEstado = new JLabel(" ");

    public Window(Connection motor) {
        super("Cálculo simbólico en Prolog");

        // Enter en el campo = derivar
        txtEntrada.addActionListener(e -> ejecutar(motor, "derivada"));
        // Enter en el punto = evaluar, Enter en los límites = área
        txtPunto.addActionListener(e -> evaluarEnPunto(motor));
        txtLimiteA.addActionListener(e -> calcularArea(motor));
        txtLimiteB.addActionListener(e -> calcularArea(motor));

        JPanel contenido = new JPanel();
        contenido.setLayout(new BoxLayout(contenido, BoxLayout.Y_AXIS));
        contenido.setOpaque(false);
        agregar(contenido, etiqueta("Función f(x)"), 6);
        agregar(contenido, txtEntrada, 8);
        agregar(contenido, crearEjemplos(), 18);
        agregar(contenido, crearBotones(motor), 22);
        agregar(contenido, etiqueta("Evaluar"), 6);
        agregar(contenido, crearEvaluacion(motor), 22);
        agregar(contenido, panelResultado, 10);
        agregar(contenido, crearPie(), 0);

        JPanel raiz = new JPanel(new BorderLayout(0, 20));
        raiz.setBackground(Theme.BG);
        raiz.setBorder(new EmptyBorder(24, 28, 24, 28));
        raiz.add(crearEncabezado(), BorderLayout.NORTH);
        raiz.add(contenido, BorderLayout.CENTER);

        setContentPane(raiz);
        setMinimumSize(new Dimension(660, 520));
        pack();
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setLocationRelativeTo(null);
    }

    // ------------------------------------------------------------------
    //  Construcción de secciones
    // ------------------------------------------------------------------

    private JPanel crearEncabezado() {
        JLabel titulo = new JLabel("Cálculo simbólico");
        titulo.setFont(Theme.sans(Font.BOLD, 24));
        titulo.setForeground(Theme.TEXT);

        JLabel subtitulo = new JLabel("Derivadas e integrales resueltas con reglas en Prolog");
        subtitulo.setFont(Theme.sans(Font.PLAIN, 13));
        subtitulo.setForeground(Theme.MUTED);

        JPanel p = new JPanel();
        p.setLayout(new BoxLayout(p, BoxLayout.Y_AXIS));
        p.setOpaque(false);
        p.add(titulo);
        p.add(Box.createVerticalStrut(4));
        p.add(subtitulo);
        return p;
    }

    private JPanel crearEjemplos() {
        JPanel p = new JPanel(new FlowLayout(FlowLayout.LEFT, 6, 0));
        p.setOpaque(false);

        JLabel lbl = new JLabel("Ejemplos:");
        lbl.setForeground(Theme.MUTED);
        lbl.setFont(Theme.sans(Font.PLAIN, 12));
        p.add(lbl);

        for (String ej : EJEMPLOS) {
            Buttons chip = new Buttons(ej, Theme.CARD, Theme.TEXT, 12, 6, 11);
            chip.addActionListener(e -> {
                txtEntrada.setText(ej);
                txtEntrada.requestFocusInWindow();
            });
            p.add(chip);
        }
        return p;
    }

    private JPanel crearBotones(Connection motor) {
        Buttons btnDerivar = new Buttons("Derivar", Theme.BLUE, Theme.BG, 26, 11, 14);
        Buttons btnIntegrar = new Buttons("Integrar", Theme.GREEN, Theme.BG, 26, 11, 14);
        btnDerivar.addActionListener(e -> ejecutar(motor, "derivada"));
        btnIntegrar.addActionListener(e -> ejecutar(motor, "integral"));

        JPanel p = new JPanel(new FlowLayout(FlowLayout.LEFT, 10, 0));
        p.setOpaque(false);
        p.add(btnDerivar);
        p.add(btnIntegrar);
        return p;
    }

    private JPanel crearEvaluacion(Connection motor) {
        Buttons btnPunto = new Buttons("f'(x0)", Theme.BLUE, Theme.BG, 16, 9, 13);
        Buttons btnArea = new Buttons("Área", Theme.GREEN, Theme.BG, 16, 9, 13);
        btnPunto.addActionListener(e -> evaluarEnPunto(motor));
        btnArea.addActionListener(e -> calcularArea(motor));

        JPanel p = new JPanel(new FlowLayout(FlowLayout.LEFT, 8, 0));
        p.setOpaque(false);
        p.add(etiquetaCampo("x0 ="));
        p.add(txtPunto);
        p.add(btnPunto);
        p.add(Box.createHorizontalStrut(24));
        p.add(etiquetaCampo("de"));
        p.add(txtLimiteA);
        p.add(etiquetaCampo("a"));
        p.add(txtLimiteB);
        p.add(btnArea);
        return p;
    }

    private JPanel crearPie() {
        lblEstado.setFont(Theme.sans(Font.PLAIN, 12));
        lblEstado.setForeground(Theme.MUTED);

        Buttons btnCopiar = new Buttons("Copiar", Theme.CARD, Theme.TEXT, 16, 7, 12);
        btnCopiar.addActionListener(e -> copiarResultado());

        JPanel p = new JPanel(new BorderLayout());
        p.setOpaque(false);
        p.add(lblEstado, BorderLayout.WEST);
        p.add(btnCopiar, BorderLayout.EAST);
        return p;
    }

    // ------------------------------------------------------------------
    //  Lógica
    // ------------------------------------------------------------------

    private void ejecutar(Connection motor, String pred) {
        boolean derivar = pred.equals("derivada");
        panelResultado.setTitulo((derivar ? "Derivada" : "Integral") + " de f(x)");
        resolver(motor, pred, derivar ? "f'(x) = %s" : "∫ f(x) dx = %s + C");
    }

    private void evaluarEnPunto(Connection motor) {
        String x0 = txtPunto.getText().trim();
        panelResultado.setTitulo("Derivada en un punto");
        if (x0.isEmpty()) {
            mostrar("", "Escribí el punto x0.", Theme.AMBER);
            return;
        }
        resolver(motor, "derivada_en", "f'(" + x0 + ") = %s", x0);
    }

    private void calcularArea(Connection motor) {
        String a = txtLimiteA.getText().trim();
        String b = txtLimiteB.getText().trim();
        panelResultado.setTitulo("Área bajo la curva (integral definida)");
        if (a.isEmpty() || b.isEmpty()) {
            mostrar("", "Escribí los dos límites a y b.", Theme.AMBER);
            return;
        }
        resolver(motor, "area", "∫ de " + a + " a " + b + " f(x) dx = %s", a, b);
    }

    /** Consulta a Prolog y muestra el resultado con el formato indicado (%s = respuesta). */
    private void resolver(Connection motor, String pred, String formato, String... extras) {
        String entrada = txtEntrada.getText().trim();
        if (entrada.isEmpty()) {
            mostrar("", "Escribí una función primero.", Theme.AMBER);
            return;
        }
        try {
            String resultado = motor.consultar(pred, entrada, extras);
            if (resultado.startsWith("Sin solución")) {
                mostrar("", resultado, Theme.AMBER);
            } else {
                mostrar(String.format(formato, resultado), "Listo", Theme.GREEN);
            }
        } catch (Exception ex) {
            String detalle = ex.getMessage() != null ? ": " + ex.getMessage() : "";
            mostrar("", "Expresión inválida" + detalle, Theme.RED);
        }
    }

    private void mostrar(String resultado, String estado, Color colorEstado) {
        panelResultado.setTexto(resultado);
        lblEstado.setText(estado);
        lblEstado.setForeground(colorEstado);
    }

    private void copiarResultado() {
        String t = panelResultado.getTexto();
        if (t.isEmpty()) {
            return;
        }
        Toolkit.getDefaultToolkit().getSystemClipboard()
                .setContents(new StringSelection(t), null);
        lblEstado.setText("Copiado al portapapeles");
        lblEstado.setForeground(Theme.BLUE);
    }

    // ------------------------------------------------------------------
    //  Utilidades
    // ------------------------------------------------------------------

    private static void agregar(JPanel panel, JComponent c, int espacioDespues) {
        c.setAlignmentX(Component.LEFT_ALIGNMENT);
        panel.add(c);
        if (espacioDespues > 0) {
            panel.add(Box.createVerticalStrut(espacioDespues));
        }
    }

    private static JLabel etiqueta(String texto) {
        JLabel l = new JLabel(texto);
        l.setFont(Theme.sans(Font.BOLD, 12));
        l.setForeground(Theme.MUTED);
        return l;
    }

    private static JLabel etiquetaCampo(String texto) {
        JLabel l = new JLabel(texto);
        l.setFont(Theme.mono(Font.PLAIN, 14));
        l.setForeground(Theme.MUTED);
        return l;
    }
}