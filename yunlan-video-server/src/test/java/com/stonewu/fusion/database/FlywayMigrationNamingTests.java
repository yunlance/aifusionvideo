package com.stonewu.fusion.database;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Stream;
import org.junit.jupiter.api.Test;

class FlywayMigrationNamingTests {

    private static final Pattern VERSIONED_NAME = Pattern.compile(
            "^V(\\d+)\\.(\\d+)\\.(\\d+)\\.(\\d+)__[a-z0-9]+(?:_[a-z0-9]+)*\\.sql$");

    private static final Pattern BASELINE_NAME = Pattern.compile(
            "^B(\\d+)\\.(\\d+)\\.(\\d+)__baseline_(\\d+)\\.(\\d+)\\.(\\d+)\\.sql$");

    @Test
    void migrationsUseProductVersionAndContinuousSequence() throws Exception {
        URL migrationResource = getClass().getClassLoader().getResource("db/migration");
        assertNotNull(migrationResource, "db/migration resource must exist");

        List<String> migrationFiles;
        try (Stream<Path> paths = Files.list(Path.of(migrationResource.toURI()))) {
            migrationFiles = paths
                    .map(path -> path.getFileName().toString())
                    .filter(name -> name.endsWith(".sql"))
                    .sorted()
                    .toList();
        }

        Map<String, List<Integer>> sequencesByProductVersion = new HashMap<>();
        Set<String> versionedFlywayVersions = new HashSet<>();
        List<String> baselineFiles = new ArrayList<>();
        for (String migrationFile : migrationFiles) {
            if (migrationFile.startsWith("B")) {
                baselineFiles.add(migrationFile);
                continue;
            }

            Matcher matcher = VERSIONED_NAME.matcher(migrationFile);
            assertTrue(matcher.matches(), () -> "invalid Flyway migration name: " + migrationFile);

            int major = Integer.parseInt(matcher.group(1));
            int minor = Integer.parseInt(matcher.group(2));
            int patch = Integer.parseInt(matcher.group(3));
            int sequence = Integer.parseInt(matcher.group(4));
            assertTrue(major >= 1, () -> "new migrations must target product version 1.0.0 or later: "
                    + migrationFile);

            String productVersion = major + "." + minor + "." + patch;
            versionedFlywayVersions.add(productVersion + "." + sequence);
            sequencesByProductVersion
                    .computeIfAbsent(productVersion, ignored -> new ArrayList<>())
                    .add(sequence);
        }

        List<int[]> baselineVersions = new ArrayList<>();
        for (String baselineFile : baselineFiles) {
            Matcher matcher = BASELINE_NAME.matcher(baselineFile);
            assertTrue(matcher.matches(), () -> "invalid Flyway baseline name: " + baselineFile);

            int major = Integer.parseInt(matcher.group(1));
            assertTrue(major >= 1, () -> "new baselines must target product version 1.0.0 or later: "
                    + baselineFile);

            int[] fileVersion = {
                    major,
                    Integer.parseInt(matcher.group(2)),
                    Integer.parseInt(matcher.group(3))
            };
            int[] descriptionVersion = {
                    Integer.parseInt(matcher.group(4)),
                    Integer.parseInt(matcher.group(5)),
                    Integer.parseInt(matcher.group(6))
            };
            assertTrue(Arrays.equals(fileVersion, descriptionVersion),
                    () -> "baseline description version must match its product version: " + baselineFile);

            baselineVersions.add(fileVersion);
        }

        for (int[] baselineVersion : baselineVersions) {
            for (String flywayVersion : versionedFlywayVersions) {
                assertTrue(compareVersion(parseVersion(flywayVersion), baselineVersion) > 0,
                        () -> "V migrations must be newer than baseline "
                                + Arrays.toString(baselineVersion) + ": " + flywayVersion);
            }
        }

        for (Map.Entry<String, List<Integer>> entry : sequencesByProductVersion.entrySet()) {
            List<Integer> actual = entry.getValue().stream().sorted().toList();
            assertEquals(actual.size(), new HashSet<>(actual).size(),
                    () -> "duplicate migration sequence for product version " + entry.getKey());

            List<Integer> expected = new ArrayList<>();
            for (int sequence = 0; sequence < actual.size(); sequence++) {
                expected.add(sequence);
            }
            assertEquals(expected, actual,
                    () -> "migration sequence must start at 0 and remain continuous for product version "
                            + entry.getKey());
        }
    }

    private static int[] parseVersion(String version) {
        String[] parts = version.split("\\.");
        int[] parsed = new int[parts.length];
        for (int index = 0; index < parts.length; index++) {
            parsed[index] = Integer.parseInt(parts[index]);
        }
        return parsed;
    }

    private static int compareVersion(int[] left, int[] right) {
        int length = Math.max(left.length, right.length);
        for (int index = 0; index < length; index++) {
            int leftPart = index < left.length ? left[index] : 0;
            int rightPart = index < right.length ? right[index] : 0;
            if (leftPart != rightPart) {
                return Integer.compare(leftPart, rightPart);
            }
        }
        return 0;
    }
}
