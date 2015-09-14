$(document).ready(function() {
    $.ajax({
        dataType: "json",
        url: "images/index.json",
        success: function(fileListing) {
            fileListing.sort();
            fileListing.reverse();
            $.each(fileListing, function addImage(idx, imageInformation){
                var image = $("<img />"),
                    link = $("<a />"),
                    imageLocation = "images/" + imageInformation[1];
                image.attr("src", "template.jpg");
                image.attr("data-src", imageLocation);
                link.attr("href", imageLocation);
                link.append(image)
                $("body").append(link);

            });
            $("img").unveil();
        },
        error: function failedToLoadIndex() {
            $("body").text("FAILED");
        }
    });
});