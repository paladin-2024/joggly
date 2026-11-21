package com.joggly.backend.common;

public final class GeoUtils {

    private static final double EARTH_RADIUS_KM = 6371.0;

    /** Caps how wide a "nearby" search can go, since the bounding-box queries have no index
     *  past this and an unbounded radius is an easy way to force a near-full-table scan. */
    public static final double MAX_SEARCH_RADIUS_KM = 50.0;

    private GeoUtils() {
    }

    public static double clampRadiusKm(double radiusKm) {
        return Math.clamp(radiusKm, 0.1, MAX_SEARCH_RADIUS_KM);
    }

    public static double distanceKm(double lat1, double lng1, double lat2, double lng2) {
        double dLat = Math.toRadians(lat2 - lat1);
        double dLng = Math.toRadians(lng2 - lng1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLng / 2) * Math.sin(dLng / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return EARTH_RADIUS_KM * c;
    }

    /** Degrees of latitude spanned by a given radius, for a cheap bounding-box pre-filter. */
    public static double latDegreesForRadius(double radiusKm) {
        return radiusKm / 111.0;
    }

    /** Degrees of longitude spanned by a given radius at the given latitude. */
    public static double lngDegreesForRadius(double radiusKm, double atLat) {
        double cos = Math.max(Math.cos(Math.toRadians(atLat)), 0.01);
        return radiusKm / (111.0 * cos);
    }

    /**
     * Snaps a coordinate onto a coarse grid (default ~300m cells), so another user's
     * marker can be shown on a map without exposing their exact GPS fix.
     */
    public static double snapToPrivacyGrid(double value) {
        double gridDegrees = 0.003;
        return Math.floor(value / gridDegrees) * gridDegrees + gridDegrees / 2;
    }
}
