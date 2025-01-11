import java.sql.*;

public class Main {

    public static class DBConnectionDetails {
        private String url = "jdbc:postgresql://ep-young-wave-61044232.us-east-2.aws.neon.tech:5432/neondb";
        private String user = "db_user";
        private String password = "db_pass";

        private DBConnectionDetails(){
        }

        public static DBConnectionDetails getInstance(){
            return new DBConnectionDetails();
        }

        public String getUrl(){
            return url;
        }

        public String getUser(){
            return user;
        }

        public String getPassword(){
            return password;
        }

        public Connection getConnection() throws SQLException {
            return DriverManager.getConnection(url, user, password);
        }
    }

    public record Lecturer(
            int id,
            String nazwisko,
            Integer manager_id,
            int rok_zatrudnienia,
            int wynagrodzenie,
            int instytut_id
    ) {
        public static Lecturer createLecturer(int id, String surname, Integer managerId, int hireYear, int salary, int instituteId) {

            String query = """
                    INSERT INTO lab11.wykladowca (wykladowca_id, nazwisko, manager_id, rok_zatrudnienia, wynagrodzenie, instytut_id)
                    VALUES (?, ?, ?, ?, ?, ?) 
                    ON CONFLICT (wykladowca_id) DO NOTHING
            """;

            try (Connection conn = DBConnectionDetails.getInstance().getConnection();
                 PreparedStatement pstmt = conn.prepareStatement(query)) {

                pstmt.setInt(1, id);
                pstmt.setString(2, surname);
                if (managerId != null) {
                    pstmt.setInt(3, managerId);
                } else {
                    pstmt.setNull(3, java.sql.Types.INTEGER);
                }
                pstmt.setInt(4, hireYear);
                pstmt.setInt(5, salary);
                pstmt.setInt(6, instituteId);

                pstmt.executeUpdate();
                System.out.println("Lecturer created successfully: ID = " + id);
                return new Lecturer(id, surname, managerId, hireYear, salary, instituteId);

            } catch (SQLException e) {
                System.err.println("Error while creating lecturer: " + e.getMessage());
            }
            return null;
        }
    }

    public static void main(String[] args) {
        try {
            assignLecturerToCourse(99, 100);
            assignLecturerToCourse(1, 4);
            assignLecturerToCourse(1, 99);
            fetchCoursesBySurname("Nowak");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void assignLecturerToCourse(int lecturerId, int courseId) {

        try (Connection conn = DBConnectionDetails.getInstance().getConnection()) {

            // Check if lecturer exists
            if (!entityExists(conn, "lab11.wykladowca", "wykladowca_id", lecturerId)) {
                System.out.println("Lecturer not found. Creating a new one.");
                Lecturer.createLecturer(lecturerId, "Default Surname", null, 2023, 3000, 1);
            }

            // Check if course exists
            if (!entityExists(conn, "lab11.kurs", "kurs_id", courseId)) {
                System.out.println("Course not found. Creating a new one.");
                createCourse(courseId, "Default Course", Date.valueOf("2023-01-01"), null);
            }

            // Assign lecturer to course
            String query = """
                INSERT INTO lab11.wykladowca_kurs(wykladowca_id, kurs_id)
                VALUES (?, ?) 
                ON CONFLICT DO NOTHING
            """;
            try (PreparedStatement pstmt = conn.prepareStatement(query)) {
                pstmt.setInt(1, lecturerId);
                pstmt.setInt(2, courseId);
                pstmt.executeUpdate();
                System.out.println("Lecturer assigned to course successfully.");
            }

        } catch (SQLException e) {
            System.err.println("Error while assigning lecturer to course: " + e.getMessage());
        }
    }

    public static void createCourse(int courseId, String courseName, Date startDate, Date endDate) {

        String query = "INSERT INTO lab11.kurs (kurs_id, nazwa, start, koniec) VALUES (?, ?, ?, ?) ON CONFLICT DO NOTHING";

        try (Connection conn = DBConnectionDetails.getInstance().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {

            pstmt.setInt(1, courseId);
            pstmt.setString(2, courseName);
            pstmt.setDate(3, startDate);
            if (endDate != null) {
                pstmt.setDate(4, endDate);
            } else {
                pstmt.setNull(4, java.sql.Types.DATE);
            }

            pstmt.executeUpdate();
            System.out.println("Course created successfully: " + courseName);

        } catch (SQLException e) {
            System.err.println("Error while creating course: " + e.getMessage());
        }
    }

    public static boolean entityExists(Connection conn, String tableName, String columnName, int id) throws SQLException {
        String query = "SELECT COUNT(*) FROM " + tableName + " WHERE " + columnName + " = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(query)) {
            pstmt.setInt(1, id);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        }
        return false;
    }

    public static void fetchCoursesBySurname(String surname) {

        String queryLecturers = "SELECT wykladowca_id FROM lab11.wykladowca WHERE nazwisko = ?";
        String callFunction = "SELECT * FROM lab11.get_courses_for_lecturer(?)";

        try (Connection conn = DBConnectionDetails.getInstance().getConnection();
             PreparedStatement pstmtLecturers = conn.prepareStatement(queryLecturers)) {

            pstmtLecturers.setString(1, surname);
            ResultSet rsLecturers = pstmtLecturers.executeQuery();

            while (rsLecturers.next()) {
                int lecturerId = rsLecturers.getInt("wykladowca_id");

                try (CallableStatement cstmt = conn.prepareCall(callFunction)) {
                    cstmt.setInt(1, lecturerId);
                    ResultSet rsCourses = cstmt.executeQuery();

                    System.out.println("Courses for Lecturer ID " + lecturerId + ":");
                    while (rsCourses.next()) {
                        String courseName = rsCourses.getString("course_name");
                        Date startDate = rsCourses.getDate("start_date");
                        boolean isCompleted = rsCourses.getBoolean("is_completed");

                        System.out.printf("- %s (Start: %s, Completed: %b)%n", courseName, startDate, isCompleted);
                    }
                }
            }

        } catch (SQLException e) {
            System.err.println("Error fetching courses by surname: " + e.getMessage());
        }
    }
}
