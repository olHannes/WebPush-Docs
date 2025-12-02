# SmartDataLyser
## GeoResource
### Distance [Modified]
```java
@GET
@Path("distance")
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
@SmartUserAuth
@Operation(summary = "Distance",
        description = "Calculates the distance between all the datasets that are delivered")
@APIResponse(
        responseCode = "200",
        description = "Distance from first to last point")
@APIResponse(
        responseCode = "404",
        description = "Collection could not be found")
@APIResponse(
        responseCode = "500",
        description = "Internal error")
public Response distance(
        @Parameter(description = "SmartData URL", required = true, example = "/SmartData") @QueryParam("smartdataurl") String smartdataurl,
        @Parameter(description = "Collections name", example = "col1") @QueryParam("collection") String collection,
        @Parameter(description = "Storage name", schema = @Schema(type = STRING, defaultValue = "public")) @QueryParam("storage") String storage,
        @Parameter(description = "Any filter statement accepted by SmartData") @QueryParam("filter") List<String> filters,
        @Parameter(description = "Date attribute (default: ts)", example = "ts") @QueryParam("dateattribute") String dateattr,
        @Parameter(description = "Start date (default: now - 30 days)", example = "2020-12-24T18:00") @QueryParam("start") String start,
        @Parameter(description = "End date (default: now)", example = "2020-12-24T19:00") @QueryParam("end") String end,
        @Parameter(description = "Geo attribute (default: pos)", example = "point") @QueryParam("geoattr") String geoattr) {

    return getDistance(smartdataurl, collection, storage, filters, dateattr, start, end, geoattr);
}

private Response getDistance(String smartdataurl, String collection, String storage, List<String> filters, String dateattr, String start, String end, String geoattr) {
    ResponseObjectBuilder rob = new ResponseObjectBuilder();

    SmartDataAccessor acc = new SmartDataAccessor();

    if (smartdataurl == null) {
        rob.setStatus(Response.Status.BAD_REQUEST);
        rob.addErrorMessage("Parameter >smartdataurl< is missing.");
        return rob.toResponse();
    }

    if (smartdataurl.startsWith("/")) {
        smartdataurl = "http://localhost:8080" + smartdataurl;
    }

    if (collection == null) {
        rob.setStatus(Response.Status.BAD_REQUEST);
        rob.addErrorMessage("Parameter >collection< is missing.");
        return rob.toResponse();
    }

    if (dateattr == null) {
        dateattr = "ts";
    }

    if (geoattr == null) {
        geoattr = "pos";
    }

    LocalDateTime endDT;
    if (end != null) {
        endDT = LocalDateTime.parse(end);
    } else {
        endDT = LocalDateTime.now();
    }

    LocalDateTime startDT;
    if (start != null) {
        startDT = LocalDateTime.parse(start);
    } else {
        startDT = LocalDateTime.now().minusDays(30);
    }

    JsonArray data;

    try {
        data = acc.fetchData(smartdataurl, collection, storage, geoattr, filters, dateattr, startDT, endDT, dateattr, null);
    } catch (SmartDataAccessorException ex) {
        rob.setStatus(Response.Status.INTERNAL_SERVER_ERROR);
        rob.addErrorMessage("Could not calculate distance because of error: " + ex.getLocalizedMessage());
        return rob.toResponse();
    }

    double totalDistance = 0;
    Double prevLat = null;
    Double prevLng = null;

    // Walk trough sets
    for (JsonValue curObj : data) {
        JsonObject dateobj = curObj.asJsonObject();

        JsonObject geoobj = dateobj.getJsonObject(geoattr);
        if (geoobj == null) {
            continue;
        }

        JsonArray geoarr = geoobj.getJsonArray("coordinates");
        if (geoarr == null) {
            continue;
        }

        double lat = geoarr.getJsonNumber(0).doubleValue();
        double lng = geoarr.getJsonNumber(1).doubleValue();

        if (prevLat != null && prevLng != null) {
            totalDistance += Distance.calc(lat, lng, prevLat, prevLng);
        }
        prevLat = lat;
        prevLng = lng;
    }

    rob.add("totalKM", totalDistance);
    rob.setStatus(Response.Status.OK);
    return rob.toResponse();
}
```

### Duration
```java
@GET
@Path("duration")
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
@SmartUserAuth
@Operation(summary = "Duration",
        description = "Calculates the duration between all the datasets that are delivered")
@APIResponse(
        responseCode = "200",
        description = "Duration from first to last point")
@APIResponse(
        responseCode = "404",
        description = "Collection could not be found")
@APIResponse(
        responseCode = "500",
        description = "Internal error")
public Response duration(
        @Parameter(description = "SmartData URL", required = true, example = "/SmartData") @QueryParam("smartdataurl") String smartdataurl,
        @Parameter(description = "Collections name", example = "col1") @QueryParam("collection") String collection,
        @Parameter(description = "Storage name", schema = @Schema(type = STRING, defaultValue = "public")) @QueryParam("storage") String storage,
        @Parameter(description = "Any filter statement accepted by SmartData") @QueryParam("filter") List<String> filters,
        @Parameter(description = "Date attribute (default: ts)", example = "ts") @QueryParam("dateattribute") String dateattr,
        @Parameter(description = "Start date (default: now - 30 days)", example = "2020-12-24T18:00") @QueryParam("start") String start,
        @Parameter(description = "End date (default: now)", example = "2020-12-24T19:00") @QueryParam("end") String end,
        @Parameter(description = "Geo attribute (default: pos)", example = "point") @QueryParam("geoattr") String geoattr) {

    return getDuration(smartdataurl, collection, storage, filters, dateattr, start, end, geoattr);
}

private Response getDuration(String smartdataurl, String collection, String storage, List<String> filters, String dateattr, String start, String end, String geoattr) {
    ResponseObjectBuilder rob = new ResponseObjectBuilder();

    SmartDataAccessor acc = new SmartDataAccessor();

    if (smartdataurl == null) {
        rob.setStatus(Response.Status.BAD_REQUEST);
        rob.addErrorMessage("Parameter >smartdataurl< is missing.");
        return rob.toResponse();
    }

    if (smartdataurl.startsWith("/")) {
        smartdataurl = "http://localhost:8080" + smartdataurl;
    }

    if (collection == null) {
        rob.setStatus(Response.Status.BAD_REQUEST);
        rob.addErrorMessage("Parameter >collection< is missing.");
        return rob.toResponse();
    }

    if (dateattr == null) {
        dateattr = "ts";
    }

    if (geoattr == null) {
        geoattr = "pos";
    }

    LocalDateTime endDT;
    if (end != null) {
        endDT = LocalDateTime.parse(end);
    } else {
        endDT = LocalDateTime.now();
    }

    LocalDateTime startDT;
    if (start != null) {
        startDT = LocalDateTime.parse(start);
    } else {
        startDT = LocalDateTime.now().minusDays(30);
    }

    JsonArray data;

    try {
        data = acc.fetchData(smartdataurl, collection, storage, geoattr, filters, dateattr, startDT, endDT, dateattr + ",ASC", null);
    } catch (SmartDataAccessorException ex) {
        rob.setStatus(Response.Status.INTERNAL_SERVER_ERROR);
        rob.addErrorMessage("Could not calculate duration because of error: " + ex.getLocalizedMessage());
        return rob.toResponse();
    }

    if (data == null || data.isEmpty()) {
        rob.add("durationH", 0);
        rob.setStatus(Response.Status.OK);
        return rob.toResponse();
    }

    String firstTS = data.get(0).asJsonObject().getString("ts");
    String lastTS = data.get(data.size() - 1).asJsonObject().getString("ts");
    LocalDateTime first = LocalDateTime.parse(firstTS);
    LocalDateTime last = LocalDateTime.parse(lastTS);

    double duration = Duration.between(first, last).toSeconds() / 3600.0;

    rob.add("durationH", duration);
    rob.setStatus(Response.Status.OK);
    return rob.toResponse();
}
```

### Speed
```java
@GET
@Path("speed")
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
@SmartUserAuth
@Operation(summary = "Speed",
        description = "Calculates the average speed between all the datasets that are delivered")
@APIResponse(
        responseCode = "200",
        description = "Average speed from first to last point")
@APIResponse(
        responseCode = "404",
        description = "Collection could not be found")
@APIResponse(
        responseCode = "500",
        description = "Internal error")
public Response speed(
        @Parameter(description = "SmartData URL", required = true, example = "/SmartData") @QueryParam("smartdataurl") String smartdataurl,
        @Parameter(description = "Collections name", example = "col1") @QueryParam("collection") String collection,
        @Parameter(description = "Storage name", schema = @Schema(type = STRING, defaultValue = "public")) @QueryParam("storage") String storage,
        @Parameter(description = "Any filter statement accepted by SmartData") @QueryParam("filter") List<String> filters,
        @Parameter(description = "Date attribute (default: ts)", example = "ts") @QueryParam("dateattribute") String dateattr,
        @Parameter(description = "Start date (default: now - 30 days)", example = "2020-12-24T18:00") @QueryParam("start") String start,
        @Parameter(description = "End date (default: now)", example = "2020-12-24T19:00") @QueryParam("end") String end,
        @Parameter(description = "Geo attribute (default: pos)", example = "point") @QueryParam("geoattr") String geoattr) {

    ResponseObjectBuilder rob = new ResponseObjectBuilder();

    Response respDist = getDistance(smartdataurl, collection, storage, filters, dateattr, start, end, geoattr);

    if (respDist.getStatus() != 200) {
        return respDist;
    }

    String jsonDist = (String) respDist.getEntity();
    double totalDistance = Json
            .createReader(new StringReader(jsonDist))
            .readObject()
            .getJsonNumber("totalKM")
            .doubleValue();

    Response respDur = getDuration(smartdataurl, collection, storage, filters, dateattr, start, end, geoattr);

    if (respDur.getStatus() != 200) {
        return respDur;
    }

    String jsonDur = (String) respDur.getEntity();
    double totalDuration = Json
            .createReader(new StringReader(jsonDur))
            .readObject()
            .getJsonNumber("durationH")
            .doubleValue();

    rob.add("avgSpeedKMH", (totalDistance / totalDuration));
    rob.setStatus(Response.Status.OK);
    return rob.toResponse();
}
```