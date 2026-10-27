package org.example;

import org.example.screen.Window;

import javax.swing.*;

//TIP To <b>Run</b> code, press <shortcut actionId="Run"/> or
// click the <icon src="AllIcons.Actions.Execute"/> icon in the gutter.
public class Main {
    public static void main(String[] args) throws Exception {
        Connection motor = new Connection();
        SwingUtilities.invokeLater(() -> new
                Window(motor).setVisible(true));
    }
}