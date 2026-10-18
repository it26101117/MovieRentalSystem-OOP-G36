package com.movierental.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;


@WebServlet("/movie-image")
public class MovieImageServlet extends HttpServlet {


    private Path posterDirectory;


    @Override
    public void init() throws ServletException {


        posterDirectory =
                Paths.get(
                        System.getProperty(
                                "user.dir"
                        ),
                        "data",
                        "posters"
                );


        try {

            Files.createDirectories(
                    posterDirectory
            );

        } catch (IOException e) {

            throw new ServletException(
                    "Unable to create poster directory.",
                    e
            );
        }
    }


    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws IOException {


        String movieId =
                request.getParameter(
                        "id"
                );


        if (
                movieId == null
                        ||
                        !movieId.matches(
                                "[A-Za-z0-9_-]+"
                        )
        ) {

            sendDefaultImage(
                    request,
                    response
            );

            return;
        }


        String[] extensions = {
                ".jpg",
                ".jpeg",
                ".png",
                ".webp"
        };


        Path imagePath =
                null;


        for (
                String extension
                : extensions
        ) {


            Path candidate =
                    posterDirectory.resolve(
                            movieId
                                    + extension
                    );


            if (
                    Files.exists(
                            candidate
                    )
            ) {

                imagePath =
                        candidate;

                break;
            }
        }


        if (imagePath == null) {

            sendDefaultImage(
                    request,
                    response
            );

            return;
        }


        String contentType =
                Files.probeContentType(
                        imagePath
                );


        if (contentType == null) {

            contentType =
                    "application/octet-stream";
        }


        response.setContentType(
                contentType
        );


        response.setHeader(
                "Cache-Control",
                "no-cache"
        );


        response.setContentLengthLong(
                Files.size(
                        imagePath
                )
        );


        Files.copy(
                imagePath,
                response.getOutputStream()
        );
    }


    // =========================================================
    // DEFAULT IMAGE
    // =========================================================

    private void sendDefaultImage(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws IOException {


        response.sendRedirect(
                request.getContextPath()
                        + "/images/posters/default.svg"
        );
    }
}