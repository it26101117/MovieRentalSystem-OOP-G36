package com.movierental.util;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.List;
public final class FileHandler {
    private FileHandler() {
        // Prevent creating FileHandler objects
    }
    private static Path prepareFile(String filePath) throws IOException {
        Path path = Paths.get(filePath);
        if (path.getParent() != null) {
            Files.createDirectories(path.getParent());
        }
        if (!Files.exists(path)) {
            Files.createFile(path);
        }
        return path;
    }

    public static List<String> readAllLines(String filePath)
            throws IOException {
        Path path = prepareFile(filePath);
        return Files.readAllLines(path, StandardCharsets.UTF_8);
    }

    public static void appendLine(String filePath, String line)
            throws IOException {
        Path path = prepareFile(filePath);
        Files.write(path, List.of(line), StandardCharsets.UTF_8, StandardOpenOption.APPEND);
    }
    public static void writeAllLines(String filePath, List<String> lines)
            throws IOException {
        Path path = prepareFile(filePath);
        Files.write(path, lines, StandardCharsets.UTF_8, StandardOpenOption.TRUNCATE_EXISTING);
    }
}