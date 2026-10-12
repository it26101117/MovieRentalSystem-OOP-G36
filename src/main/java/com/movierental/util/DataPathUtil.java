package com.movierental.util;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

public final class DataPathUtil {

    private static final Path DATA_DIRECTORY =
            Paths.get(System.getProperty("user.dir"), "data");

    private DataPathUtil() {
    }

    public static String getFilePath(String fileName) {

        try {

            Files.createDirectories(DATA_DIRECTORY);

            Path filePath = DATA_DIRECTORY.resolve(fileName);

            if (Files.notExists(filePath)) {
                Files.createFile(filePath);
            }

            return filePath.toString();

        } catch (IOException e) {

            throw new IllegalStateException(
                    "Unable to create/access data file: " + fileName,
                    e
            );
        }
    }
}