package com.movierental.service;

import com.movierental.model.Review;
import com.movierental.util.FileHandler;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class ReviewService {

    private final String reviewFilePath;


    public ReviewService( String reviewFilePath ) {

        this.reviewFilePath =  reviewFilePath;

    }

    public void addReview(Review review)
            throws IOException {

        FileHandler.appendLine(reviewFilePath, convertReviewToLine(  review )
        );
    }


    public List<Review> getAllReviews()
            throws IOException {

        List<String> lines =FileHandler.readAllLines( reviewFilePath     );

        List<Review> reviews = new ArrayList<>();



        for (String line : lines) {

            if ( line == null ||line.trim().isEmpty() ) {

                continue;
            }


            Review review = convertLineToReview(line  );

            if (review != null) {

                reviews.add( review   );
            }
        }


        return reviews;
    }

    public List<Review> getReviewsByMovie(
            String movieId
    ) throws IOException {

        List<Review> result =new ArrayList<>();



        for (
                Review review :
                getAllReviews()
        ) {

            if (
                    review.getMovieId()
                            .equals(movieId)
            ) {

                result.add(
                        review
                );
            }
        }


        return result;
    }


    // =========================================================
    // FIND USER REVIEW
    // =========================================================

    public Review getUserReviewForMovie(
            String userId,
            String movieId
    ) throws IOException {

        for (
                Review review :
                getAllReviews()
        ) {

            if (
                    review.getUserId()
                            .equals(userId)
                            &&
                            review.getMovieId()
                                    .equals(movieId)
            ) {

                return review;
            }
        }


        return null;
    }


    // =========================================================
    // UPDATE REVIEW
    // =========================================================

    public boolean updateReview(
            Review updatedReview
    ) throws IOException {

        List<Review> reviews =
                getAllReviews();


        boolean found =
                false;


        for (
                int i = 0;
                i < reviews.size();
                i++
        ) {

            Review review =
                    reviews.get(i);


            if (
                    review.getReviewId()
                            .equals(
                                    updatedReview
                                            .getReviewId()
                            )
            ) {

                reviews.set(
                        i,
                        updatedReview
                );

                found = true;

                break;
            }
        }


        if (found) {

            saveAllReviews(
                    reviews
            );
        }


        return found;
    }


    // =========================================================
    // DELETE REVIEW
    // =========================================================

    public boolean deleteReview(
            String reviewId
    ) throws IOException {

        List<Review> reviews =
                getAllReviews();


        boolean removed =
                reviews.removeIf(
                        review ->
                                review.getReviewId()
                                        .equals(reviewId)
                );


        if (removed) {

            saveAllReviews(
                    reviews
            );
        }


        return removed;
    }


    // =========================================================
    // AVERAGE RATING
    // =========================================================

    public double calculateAverageRating(
            String movieId
    ) throws IOException {

        List<Review> reviews =
                getReviewsByMovie(
                        movieId
                );


        if (reviews.isEmpty()) {

            return 0.0;
        }


        int total =
                0;


        for (Review review : reviews) {

            total +=
                    review.getRating();
        }


        double average =
                (double) total
                        /
                        reviews.size();


        // Round to 1 decimal
        return Math.round(
                average * 10.0
        ) / 10.0;
    }


    // =========================================================
    // GENERATE REVIEW ID
    // =========================================================

    public String generateNextReviewId()
            throws IOException {

        int highest =
                0;


        for (
                Review review :
                getAllReviews()
        ) {

            String id =
                    review.getReviewId();


            if (
                    id != null
                            &&
                            id.startsWith("REV")
            ) {

                try {

                    int number =
                            Integer.parseInt(
                                    id.substring(3)
                            );


                    if (number > highest) {

                        highest =
                                number;
                    }

                } catch (
                        NumberFormatException ignored
                ) {
                }
            }
        }


        return String.format(
                "REV%03d",
                highest + 1
        );
    }


    // =========================================================
    // SAVE ALL REVIEWS
    // =========================================================

    private void saveAllReviews(
            List<Review> reviews
    ) throws IOException {

        List<String> lines =
                new ArrayList<>();


        for (Review review : reviews) {

            lines.add(
                    convertReviewToLine(
                            review
                    )
            );
        }


        FileHandler.writeAllLines(
                reviewFilePath,
                lines
        );
    }


    // =========================================================
    // REVIEW -> FILE
    // =========================================================

    private String convertReviewToLine(
            Review review
    ) {

        return clean(
                review.getReviewId()
        )
                + "|"
                + clean(
                review.getUserId()
        )
                + "|"
                + clean(
                review.getMovieId()
        )
                + "|"
                + review.getRating()
                + "|"
                + clean(
                review.getComment()
        )
                + "|"
                + clean(
                review.getReviewDate()
        );
    }


    // =========================================================
    // FILE -> REVIEW
    // =========================================================

    private Review convertLineToReview(
            String line
    ) {

        try {

            String[] data =
                    line.split(
                            "\\|",
                            -1
                    );


            if (data.length != 6) {

                return null;
            }


            return new Review(
                    data[0],
                    data[1],
                    data[2],
                    Integer.parseInt(
                            data[3]
                    ),
                    data[4],
                    data[5]
            );


        } catch (Exception e) {

            return null;
        }
    }


    private String clean(
            String value
    ) {

        if (value == null) {

            return "";
        }


        return value.replace(
                "|",
                " "
        );
    }
}