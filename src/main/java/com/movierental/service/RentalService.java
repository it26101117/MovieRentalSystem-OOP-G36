package com.movierental.service;

import com.movierental.model.Rental;
import com.movierental.util.FileHandler;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class RentalService {
    private final String rentalFilePath;
    public RentalService(String rentalFilePath) {
        this.rentalFilePath = rentalFilePath;
    }

    public void addRental(Rental rental) throws IOException {

        String line = convertRentalToLine(rental);
        FileHandler.appendLine(rentalFilePath, line);
    }

    public List<Rental> getAllRentals() throws IOException {

        List<String> lines = FileHandler.readAllLines(rentalFilePath);

        List<Rental> rentals = new ArrayList<>();


        for (String line : lines) {

            if (line == null || line.trim().isEmpty()) {
                continue;
            }
            Rental rental = convertLineToRental(line);
            if (rental != null) {
                rentals.add(rental);
            }
        }
        return rentals;
    }
    public List<Rental> getRentalsByUser(String userId) throws IOException {

        List<Rental> result = new ArrayList<>();
        List<Rental> rentals = getAllRentals();

        for (Rental rental : rentals) {

            if (rental.getUserId() != null && rental.getUserId().equals(userId)) {

                result.add(rental);
            }
        }
        return result;
    }
    public Rental getRentalById(String rentalId) throws IOException {
        List<Rental> rentals = getAllRentals();

        for (Rental rental : rentals) {

            if (rental.getRentalId() != null && rental.getRentalId().equals(rentalId)) {
                return rental;
            }
        }
        return null;
    }
    public boolean updateRental(Rental updatedRental) throws IOException {
        List<Rental> rentals = getAllRentals();
        boolean found = false;

        for (int i = 0; i < rentals.size(); i++) {
            Rental rental = rentals.get(i);

            if (rental.getRentalId() != null && rental.getRentalId().equals(updatedRental.getRentalId())) {
                rentals.set(i, updatedRental);
                found = true;
                break;
            }
        }
        if (found) {saveAllRentals(rentals);
        }
        return found;
    }

    public boolean hasActiveRental(String userId, String movieId) throws IOException {
        List<Rental> rentals =
                getAllRentals();

        for (Rental rental : rentals) {
            boolean sameUser = rental.getUserId() != null && rental.getUserId().equals(userId);

            boolean sameMovie = rental.getMovieId() != null && rental.getMovieId().equals(movieId);

            boolean currentlyRented = rental.getStatus() != null && "RENTED".equalsIgnoreCase(rental.getStatus());

            if (sameUser && sameMovie && currentlyRented) {
                return true;
            }
        }
        return false;
    }

    public boolean hasReturnedRental(
            String userId,
            String movieId
    ) throws IOException {

        List<Rental> rentals = getAllRentals();

        for (Rental rental : rentals) {

            boolean sameUser = rental.getUserId() != null && rental.getUserId().equals(userId);

            boolean sameMovie = rental.getMovieId() != null && rental.getMovieId().equals(movieId);

            boolean returned = rental.getStatus() != null && "RETURNED".equalsIgnoreCase(rental.getStatus());


            if (sameUser && sameMovie && returned) {
                return true;
            }
        }
        return false;
    }

    public List<Rental> getActiveRentals()
            throws IOException {

        List<Rental> result =
                new ArrayList<>();


        for (
                Rental rental :
                getAllRentals()
        ) {

            if (
                    rental.getStatus() != null && "RENTED".equalsIgnoreCase(rental.getStatus())) {

                result.add(rental);
            }
        }
        return result;
    }

    // GET RETURNED RENTALS

    public List<Rental> getReturnedRentals()
            throws IOException {

        List<Rental> result = new ArrayList<>();

        for (Rental rental : getAllRentals()) {

            if (rental.getStatus() != null && "RETURNED".equalsIgnoreCase(rental.getStatus())) {

                result.add(rental);
            }
        }
        return result;
    }

    // GET RENTALS BY MOVIE

    public List<Rental> getRentalsByMovie(String movieId) throws IOException {

        List<Rental> result = new ArrayList<>();

        for (Rental rental : getAllRentals()) {

            if (rental.getMovieId() != null && rental.getMovieId().equals(movieId)) {

                result.add(rental);
            }
        }
        return result;
    }

    // GENERATE NEXT RENTAL ID

    public String generateNextRentalId()
            throws IOException {

        List<Rental> rentals = getAllRentals();

        int highestNumber = 0;

        for (Rental rental : rentals) {

            String rentalId = rental.getRentalId();


            if (rentalId != null && rentalId.startsWith("R")) {

                try {

                    int number = Integer.parseInt(rentalId.substring(1));

                    if (number > highestNumber) {
                        highestNumber = number;
                    }

                } catch (NumberFormatException ignored) {

                    // Ignore invalid rental IDs
                }
            }
        }
        return String.format("R%03d", highestNumber + 1);
    }

    // SAVE ALL RENTALS

    private void saveAllRentals(List<Rental> rentals) throws IOException {

        List<String> lines = new ArrayList<>();

        for (Rental rental : rentals) {

            lines.add(convertRentalToLine(rental));
        }
        FileHandler.writeAllLines(rentalFilePath, lines);
    }

    // RENTAL OBJECT -> FILE LINE

    private String convertRentalToLine(Rental rental) {

        return clean(rental.getRentalId())
                + "|"
                + clean(
                rental.getUserId()
        )
                + "|"
                + clean(
                rental.getMovieId()
        )
                + "|"
                + clean(
                rental.getRentalDate()
        )
                + "|"
                + clean(
                rental.getReturnDate()
        )
                + "|"
                + clean(
                rental.getStatus()
        );
    }

    // FILE LINE -> RENTAL OBJECT

    private Rental convertLineToRental(String line) {
        try {
            String[] data = line.split("\\|", -1);


            /*
             * Expected format:
             * R001|U001|M001|2026-10-08||RENTED
             * OR
             * R001|U001|M001|2026-10-08|2026-10-09|RETURNED
             */

            if (data.length != 6) {
                return null;
            }


            return new Rental(data[0], data[1], data[2], data[3], data[4], data[5]);

        }
        catch (Exception e) {

            System.out.println("Error reading rental line: " + line);
            return null;
        }
    }

    private String clean(String value) {
        if (value == null) {
            return "";
        }
        /*
         * "|" is used as the text file separator,
         * so remove any "|" characters from stored values.
         */

        return value.replace("|", " ");
    }
}